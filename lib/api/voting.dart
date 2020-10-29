import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:dvote/net/gateway-web3.dart';
import 'package:dvote/util/json-content.dart';
import 'package:dvote/util/random.dart';
import 'package:dvote/util/waiters.dart';
import 'package:dvote/wrappers/process-results.dart';
import 'package:web3dart/crypto.dart';
import 'dart:typed_data';
import 'package:dvote/api/file.dart';
import 'package:dvote/util/asyncify.dart';
import 'package:dvote/util/parsers.dart';
import 'package:dvote/wrappers/content-uri.dart';
import 'package:dvote/wrappers/process-keys.dart';
import 'package:dvote_crypto/dvote_crypto.dart';

import '../net/gateway-pool.dart';
import '../util/random.dart';
import "./entity.dart";
import '../models/build/dart/metadata/entity.pb.dart';
import '../models/build/dart/metadata/process.pb.dart';
import '../util/json-signature.dart';
import '../constants.dart';

// ENUMS AND WRAPPERS

class ProcessEnvelopeType {
  final int type;
  ProcessEnvelopeType(this.type) {
    final allFlags = ProcessEnvelopeType.SERIAL |
        ProcessEnvelopeType.ANONYMOUS |
        ProcessEnvelopeType.ENCRYPTED;
    if (this.type > allFlags || this.type < 0) {
      throw Exception("ProcessEnvelopeType ${this.type} is invalid");
    }
  }

  ProcessEnvelopeType.make(
      {bool serial = false, anonymous = false, encrypted = false})
      : type = 0 |
            (serial ? ProcessEnvelopeType.SERIAL : 0) |
            (anonymous ? ProcessEnvelopeType.ANONYMOUS : 0) |
            (encrypted ? ProcessEnvelopeType.ENCRYPTED : 0);

  //  By default, all votes are sent within a single envelope. When set, the process questions are voted one by one (enables `questionIndex`).
  static const SERIAL = 1 << 0;
  //  By default, the franchise proof relies on an ECDSA signature (this could reveal the voter's identity). When set, the franchise proof will use ZK-Snarks.
  static const ANONYMOUS = 1 << 1;
  //  By default, votes are sent unencrypted. When the flag is set, votes are sent encrypted and become public when the process ends.
  static const ENCRYPTED = 1 << 2;

  int get value => this.type;

  // Returns true if the process expects one envelope to be sent for each question.
  bool get hasSerialVoting => type & ProcessEnvelopeType.SERIAL != 0;
  //  Returns true if franchise proofs use ZK-Snarks.
  bool get hasAnonymousVoters => type & ProcessEnvelopeType.ANONYMOUS != 0;
  //  Returns true if envelopes are to be sent encrypted.
  bool get hasEncryptedVotes => type & ProcessEnvelopeType.ENCRYPTED != 0;
}

class ProcessMode {
  final int mode;
  ProcessMode(this.mode) {
    final allFlags = ProcessMode.AUTO_START |
        ProcessMode.INTERRUPTIBLE |
        ProcessMode.DYNAMIC_CENSUS |
        ProcessMode.ALLOW_VOTE_OVERWRITE |
        ProcessMode.ENCRYPTED_METADATA;
    if (this.mode > allFlags || this.mode < 0) {
      throw Exception("ProcessMode ${this.mode} is invalid");
    }
  }

  ProcessMode.make(
      {bool autoStart = false,
      interruptible = false,
      dynamicCensus = false,
      allowVoteOverwrite = false,
      encryptedMetadata = false})
      : mode = 0 |
            (autoStart ? ProcessMode.AUTO_START : 0) |
            (interruptible ? ProcessMode.INTERRUPTIBLE : 0) |
            (dynamicCensus ? ProcessMode.DYNAMIC_CENSUS : 0) |
            (allowVoteOverwrite ? ProcessMode.ALLOW_VOTE_OVERWRITE : 0) |
            (encryptedMetadata ? ProcessMode.ENCRYPTED_METADATA : 0);

  //  By default, the process is started on demand (PAUSED). If set, the process will sIf set, the process will work like `status=PAUSED` before `startBlock` and like `status=ENDED` after `startBlock + blockCount`. The process works on demand, by default.tart as READY and the Vochain will allow incoming votes after `startBlock`
  static const AUTO_START = 1 << 0;
  //  By default, the process can't be paused, ended or canceled. If set, the process can be paused, ended or canceled by the creator.
  static const INTERRUPTIBLE = 1 << 1;
  //  By default, the census is immutable. When set, the creator can update the census while the process remains `READY` or `PAUSED`.
  static const DYNAMIC_CENSUS = 1 << 2;
  // By default, the first valid vote is final. If set, users will be allowed to vote up to `maxVoteOverwrites` times and the last valid vote will be counted.
  static const ALLOW_VOTE_OVERWRITE = 1 << 3;
  //  By default, the metadata is not encrypted. If set, clients should fetch the decryption key before trying to display the metadata.
  static const ENCRYPTED_METADATA = 1 << 4;

  int get value => this.mode;

  //  Returns true if the Vochain will not allow votes until `startBlock`.
  bool get isAutoStart => mode & ProcessMode.AUTO_START != 0;
  //  Returns true if the process can be paused, ended and canceled by the creator.
  bool get isInterruptible => mode & ProcessMode.INTERRUPTIBLE != 0;
  //  Returns true if the census can be updated by the creator.
  bool get hasDynamicCensus => mode & ProcessMode.DYNAMIC_CENSUS != 0;
  //  Returns true if voters can overwrite their last vote.
  bool get allowsVoteOverwrite => mode & ProcessMode.ALLOW_VOTE_OVERWRITE != 0;
  //  Returns true if the process metadata is expected to be encrypted.
  bool get hasEncryptedMetadata => mode & ProcessMode.ENCRYPTED_METADATA != 0;
}

class ProcessStatus {
  final int status;
  ProcessStatus(this.status) {
    if (!processStatusValues.contains(this.status)) {
      throw Exception("ProcessStatus ${this.status} is invalid");
    }
  }

  // The process is ready to accept votes, according to `AUTO_START`, `startBlock` and `blockCount`.
  static const READY = 0;
  // The creator has ended the process and the results will be available soon.
  static const ENDED = 1;
  // The process has been canceled. Results will not be available anytime.
  static const CANCELED = 2;
  // The process is temporarily paused and votes are not accepted at the time. It might be resumed in the future.
  static const PAUSED = 3;
  // The process is ended and its results are available.
  static const RESULTS = 4;

  static const processStatusValues = [
    ProcessStatus.READY,
    ProcessStatus.ENDED,
    ProcessStatus.CANCELED,
    ProcessStatus.PAUSED,
    ProcessStatus.RESULTS,
  ];

  int get value => this.status;

  bool get isReady => status == ProcessStatus.READY;
  bool get isEnded => status == ProcessStatus.ENDED;
  bool get isCanceled => status == ProcessStatus.CANCELED;
  bool get isPaused => status == ProcessStatus.PAUSED;
  bool get hasResults => status == ProcessStatus.RESULTS;
}

class ProcessContractGetIdx {
  // First-level array indexes
  // MODE, ENVELOPE_TYPE [2]uint8
  static const MODE_ENVELOPE_TYPE = 0;
  // ENTITY_ADDRESS address
  static const ENTITY_ADDRESS = 1;
  //METADATA, CENSUS_MERKLE_ROOT, CENSUS_MERKLE_TREE [3]string
  static const METADATA_CENSUS_MERKLE_ROOT_CENSUS_MERKLE_TREE = 2;
  // START_BLOCK uint64
  static const START_BLOCK = 3;
  // BLOCK_COUNT uint32
  static const BLOCK_COUNT = 4;
  // STATUS ProcessStatus
  static const STATUS = 5;
  // QUESTION_INDEX, QUESTION_COUNT, MAX_COUNT, MAX_VALUE, MAX_VOTE_OVERWRITES [5]uint8
  static const QUESTION_INDEX_QUESTION_COUNT_MAX_COUNT_MAX_VALUE_MAX_VOTE_OVERWRITES =
      6;
  // UNIQUE_VALUES: bool
  static const UNIQUE_VALUES = 7;
  // MAX_TOTAL_COST, COST_EXPONENT, NAMESPACE [3]uint16
  static const MAX_TOTAL_COST_COST_EXPONENT_NAMESPACE = 8;

  // the length of the process contract list
  static const PROCESS_CONTRACT_LENGTH = 9;

  // Second-level array indexes

  // MODE, ENVELOPE_TYPE [2]uint8
  static const SUB_INDEX_MODE = 0;
  static const SUB_INDEX_ENVELOPE_TYPE = 1;

  //METADATA, CENSUS_MERKLE_ROOT, CENSUS_MERKLE_TREE [3]string
  static const SUB_INDEX_METADATA = 0;
  static const SUB_INDEX_CENSUS_MERKLE_ROOT = 1;
  static const SUB_INDEX_CENSUS_MERKLE_TREE = 2;

  // QUESTION_INDEX, QUESTION_COUNT, MAX_COUNT, MAX_VALUE, MAX_VOTE_OVERWRITES [5]uint8
  static const SUB_INDEX_QUESTION_INDEX = 0;
  static const SUB_INDEX_QUESTION_COUNT = 1;
  static const SUB_INDEX_MAX_COUNT = 2;
  static const SUB_INDEX_MAX_VALUE = 3;
  static const SUB_INDEX_MAX_VOTE_OVERWRITES = 4;

  // MAX_TOTAL_COST, COST_EXPONENT, NAMESPACE [3]uint16
  static const SUB_INDEX_MAX_TOTAL_COST = 0;
  static const SUB_INDEX_COST_EXPONENT = 1;
  static const SUB_INDEX_NAMESPACE = 2;
}

/// Wraps the Process contract response and provides getters to the response's fields
class ProcessData {
  List<dynamic> data;

  ProcessData(this.data) {
    if (this.data is! List ||
        this.data.length != ProcessContractGetIdx.PROCESS_CONTRACT_LENGTH ||
        this.data[ProcessContractGetIdx.MODE_ENVELOPE_TYPE] is! List ||
        this.data[ProcessContractGetIdx.ENTITY_ADDRESS] is! String ||
        this.data[ProcessContractGetIdx
            .METADATA_CENSUS_MERKLE_ROOT_CENSUS_MERKLE_TREE] is! List ||
        this.data[ProcessContractGetIdx.START_BLOCK] is! int ||
        this.data[ProcessContractGetIdx.BLOCK_COUNT] is! int ||
        this.data[ProcessContractGetIdx.STATUS] is! int ||
        this.data[ProcessContractGetIdx
                .QUESTION_INDEX_QUESTION_COUNT_MAX_COUNT_MAX_VALUE_MAX_VOTE_OVERWRITES]
            is! List ||
        this.data[ProcessContractGetIdx.UNIQUE_VALUES] is! bool ||
        this.data[ProcessContractGetIdx.MAX_TOTAL_COST_COST_EXPONENT_NAMESPACE]
            is! List) {
      throw Exception("Process data is invalid");
    }
  }

  // First-level array indexes:
  List get _getModeEnvelopeType {
    if (data[ProcessContractGetIdx.MODE_ENVELOPE_TYPE] is! List) return null;
    return data[ProcessContractGetIdx.MODE_ENVELOPE_TYPE];
  }

  String get getEntityAddress {
    if (data[ProcessContractGetIdx.ENTITY_ADDRESS] is! String) return null;
    return data[ProcessContractGetIdx.ENTITY_ADDRESS];
  }

  List get _getMetadataCensusMerkleRootCensusMerkleTree {
    if (data[ProcessContractGetIdx
        .METADATA_CENSUS_MERKLE_ROOT_CENSUS_MERKLE_TREE] is! List) return null;
    return data[
        ProcessContractGetIdx.METADATA_CENSUS_MERKLE_ROOT_CENSUS_MERKLE_TREE];
  }

  int get getStartBlock {
    if (data[ProcessContractGetIdx.START_BLOCK] is! int) return null;
    return data[ProcessContractGetIdx.START_BLOCK];
  }

  int get getBlockCount {
    if (data[ProcessContractGetIdx.BLOCK_COUNT] is! int) return null;
    return data[ProcessContractGetIdx.BLOCK_COUNT];
  }

  ProcessStatus get getStatus {
    if (data[ProcessContractGetIdx.STATUS] is! int) return null;
    return ProcessStatus(data[ProcessContractGetIdx.STATUS]);
  }

  List get _getQuestionIndexQuestionCountMaxCountMaxValueMaxVoteOverwrites {
    if (data[ProcessContractGetIdx
            .QUESTION_INDEX_QUESTION_COUNT_MAX_COUNT_MAX_VALUE_MAX_VOTE_OVERWRITES]
        is! List) return null;
    return data[ProcessContractGetIdx
        .QUESTION_INDEX_QUESTION_COUNT_MAX_COUNT_MAX_VALUE_MAX_VOTE_OVERWRITES];
  }

  bool get getUniqueValues {
    if (data[ProcessContractGetIdx.UNIQUE_VALUES] is! bool) return null;
    return data[ProcessContractGetIdx.UNIQUE_VALUES];
  }

  List get _getMaxTotalCostCostExponentNamespace {
    if (data[ProcessContractGetIdx.MAX_TOTAL_COST_COST_EXPONENT_NAMESPACE]
        is! List) return null;
    return data[ProcessContractGetIdx.MAX_TOTAL_COST_COST_EXPONENT_NAMESPACE];
  }

  // Second-level array indexes
  ProcessMode get getMode {
    final list = _getModeEnvelopeType;
    if (list == null || list[ProcessContractGetIdx.SUB_INDEX_MODE] is! int)
      return null;
    return ProcessMode(list[ProcessContractGetIdx.SUB_INDEX_MODE]);
  }

  ProcessEnvelopeType get getEnvelopeType {
    final list = _getModeEnvelopeType;
    if (list == null ||
        list[ProcessContractGetIdx.SUB_INDEX_ENVELOPE_TYPE] is! int)
      return null;
    return ProcessEnvelopeType(
        list[ProcessContractGetIdx.SUB_INDEX_ENVELOPE_TYPE]);
  }

  String get getMetadata {
    final list = _getMetadataCensusMerkleRootCensusMerkleTree;
    if (list == null ||
        list[ProcessContractGetIdx.SUB_INDEX_METADATA] is! String) return null;
    return list[ProcessContractGetIdx.SUB_INDEX_METADATA];
  }

  String get getCensusMerkleRoot {
    final list = _getMetadataCensusMerkleRootCensusMerkleTree;
    if (list == null ||
        list[ProcessContractGetIdx.SUB_INDEX_CENSUS_MERKLE_ROOT] is! String)
      return null;
    return list[ProcessContractGetIdx.SUB_INDEX_CENSUS_MERKLE_ROOT];
  }

  String get getCensusMerkleTree {
    final list = _getMetadataCensusMerkleRootCensusMerkleTree;
    if (list == null ||
        list[ProcessContractGetIdx.SUB_INDEX_CENSUS_MERKLE_TREE] is! String)
      return null;
    return list[ProcessContractGetIdx.SUB_INDEX_CENSUS_MERKLE_TREE];
  }

  int get getQuestionIndex {
    final list =
        _getQuestionIndexQuestionCountMaxCountMaxValueMaxVoteOverwrites;
    if (list == null ||
        list[ProcessContractGetIdx.SUB_INDEX_QUESTION_INDEX] is! int)
      return null;
    return list[ProcessContractGetIdx.SUB_INDEX_QUESTION_INDEX];
  }

  int get getQuestionCount {
    final list =
        _getQuestionIndexQuestionCountMaxCountMaxValueMaxVoteOverwrites;
    if (list == null ||
        list[ProcessContractGetIdx.SUB_INDEX_QUESTION_COUNT] is! int)
      return null;
    return list[ProcessContractGetIdx.SUB_INDEX_QUESTION_COUNT];
  }

  int get getMaxCount {
    final list =
        _getQuestionIndexQuestionCountMaxCountMaxValueMaxVoteOverwrites;
    if (list == null || list[ProcessContractGetIdx.SUB_INDEX_MAX_COUNT] is! int)
      return null;
    return list[ProcessContractGetIdx.SUB_INDEX_MAX_COUNT];
  }

  int get getMaxValue {
    final list =
        _getQuestionIndexQuestionCountMaxCountMaxValueMaxVoteOverwrites;
    if (list == null || list[ProcessContractGetIdx.SUB_INDEX_MAX_VALUE] is! int)
      return null;
    return list[ProcessContractGetIdx.SUB_INDEX_MAX_VALUE];
  }

  int get getMaxVoteOverwrites {
    final list =
        _getQuestionIndexQuestionCountMaxCountMaxValueMaxVoteOverwrites;
    if (list == null ||
        list[ProcessContractGetIdx.SUB_INDEX_MAX_VOTE_OVERWRITES] is! int)
      return null;
    return list[ProcessContractGetIdx.SUB_INDEX_MAX_VOTE_OVERWRITES];
  }

  int get getMaxTotalCost {
    final list = _getMaxTotalCostCostExponentNamespace;
    if (list == null ||
        list[ProcessContractGetIdx.SUB_INDEX_MAX_TOTAL_COST] is! int)
      return null;
    return list[ProcessContractGetIdx.SUB_INDEX_MAX_TOTAL_COST];
  }

  int get getCostExponent {
    final list = _getMaxTotalCostCostExponentNamespace;
    if (list == null ||
        list[ProcessContractGetIdx.SUB_INDEX_COST_EXPONENT] is! int)
      return null;
    return list[ProcessContractGetIdx.SUB_INDEX_COST_EXPONENT];
  }

  int get getNamespace {
    final list = _getMaxTotalCostCostExponentNamespace;
    if (list == null || list[ProcessContractGetIdx.SUB_INDEX_NAMESPACE] is! int)
      return null;
    return list[ProcessContractGetIdx.SUB_INDEX_NAMESPACE];
  }
}

class BlockStatus {
  int blockNumber;
  int blockTimestamp;
  List<int> averageBlockTimes;
  BlockStatus(this.blockNumber, this.blockTimestamp, this.averageBlockTimes);
}

// HANDLERS

/// Fetch the metadata for the given Process ID
Future<ProcessMetadata> getProcessMetadata(String processId, GatewayPool gw) {
  return getProcess(processId, gw).then((processData) {
    if (processData.getMetadata is! String) return null;
    final metadataUri = ContentURI(processData.getMetadata);
    return fetchFileString(metadataUri, gw);
  }, onError: (err) {
    print("ERROR Fetching Process metadata: $err");
    return null;
  }).then((strMetadata) {
    return parseProcessMetadata(strMetadata);
  }, onError: (err) {
    print("ERROR Parsing Process metadata: $err");
    return null;
  });
}

/// Fetch the Process from the contract
Future<ProcessData> getProcess(String processId, GatewayPool gw) {
  List<int> pid;
  try {
    pid = hex.decode(processId.substring(2));
  } catch (err) {
    print("ERROR Decoding process id: $err");
    return null;
  }
  return gw.callMethod("get", [pid], ContractEnum.Process).then((data) {
    return ProcessData(data);
  }, onError: (err) {
    print("ERROR Fetching Process data: $err");
    return null;
  });
}

/// Returns number of existing blocks in the blockchain
Future<ProcessResults> getRawResults(String processId, GatewayPool gw) async {
  if (gw == null || processId == "") throw Exception("Invalid parameters");
  processId = processId.startsWith("0x") ? processId : "0x" + processId;
  try {
    Map<String, dynamic> reqParams = {
      "method": "getResults",
      "processId": processId
    };
    Map<String, dynamic> response = await gw.sendRequest(reqParams, timeout: 7);
    if (response is! Map) {
      throw Exception("Invalid response received from the gateway");
    }
    return parseProcessResults(response);
  } catch (err) {
    throw Exception("Unable to get process results: $err");
  }
}

Future<ProcessResultsDigested> getResultsDigest(
    String processId, GatewayPool gw,
    {ProcessMetadata meta}) async {
  if (gw == null || processId == "") throw Exception("Invalid parameters");
  final pid = processId.startsWith("0x") ? processId : "0x" + processId;
  try {
    // Enable option to pass-in metadata, otherwise call metadata api
    if (meta == null) {
      meta = await getProcessMetadata(pid, gw);
    }
    final processMetadata = meta;
    final currentBlock = await getBlockHeight(gw);

    // If process hasn't started yet, throw exception
    if (currentBlock < processMetadata.startBlock) {
      return null; // No results yet
    }
    final rawResults = await getRawResults(pid, gw);
    if (processMetadata.details.questions?.isEmpty ?? true) {
      return ProcessResultsDigested(rawResults.state, rawResults.type);
    }
    if (processMetadata == null) {
      throw Exception("Process Metadata is empty");
    }

    if (processMetadata.type == "encrypted-poll") {
      final endBlock = processMetadata.startBlock + processMetadata.blockCount;
      if ((currentBlock < endBlock) && rawResults.state != "canceled") {
        return null; // No results
      }

      // Wait until decryption keys are available
      int retries = 3;
      ProcessKeys procKeys;
      do {
        procKeys = await getProcessKeys(pid, gw);
        if (procKeys?.encryptionPrivKeys?.isNotEmpty ?? false) break;
        await waitVochainBlocks(2, gw);
        retries--;
      } while (retries >= 0);

      if (procKeys?.encryptionPrivKeys?.isEmpty ?? true) {
        return null; // No results
      }
    }

    return parseProcessResultsDigested(rawResults, processMetadata);
  } catch (err) {
    throw Exception("The results could not be digested: $err");
  }
}

/// Returns number of existing blocks in the blockchain
Future<ProcessKeys> getProcessKeys(String processId, GatewayPool gw) async {
  if (gw == null) throw Exception("Invalid parameters");
  try {
    Map<String, dynamic> reqParams = {
      "method": "getProcessKeys",
      "processId": processId
    };
    Map<String, dynamic> response = await gw.sendRequest(reqParams, timeout: 7);
    if (response is! Map) {
      throw Exception("Invalid response received from the gateway");
    }

    ProcessKeys keys = ProcessKeys();
    if (response["encryptionPubKeys"] is List &&
        response["encryptionPubKeys"].length > 0)
      keys.encryptionPubKeys =
          _parseProcessKeyList(response["encryptionPubKeys"]);
    if (response["encryptionPrivKeys"] is List &&
        response["encryptionPrivKeys"].length > 0)
      keys.encryptionPrivKeys =
          _parseProcessKeyList(response["encryptionPrivKeys"]);
    if (response["commitmentKeys"] is List &&
        response["commitmentKeys"].length > 0)
      keys.commitmentKeys = _parseProcessKeyList(response["commitmentKeys"]);
    if (response["revealKeys"] is List && response["revealKeys"].length > 0)
      keys.revealKeys = _parseProcessKeyList(response["revealKeys"]);
    return keys;
  } catch (err) {
    throw Exception("The process encryption keys could not be retrieved");
  }
}

/// Returns number of existing blocks in the blockchain
Future<int> getBlockHeight(GatewayPool gw) async {
  if (gw == null) throw Exception("Invalid parameters");
  try {
    Map<String, dynamic> reqParams = {"method": "getBlockHeight"};
    Map<String, dynamic> response = await gw.sendRequest(reqParams, timeout: 7);
    if (!(response is Map) || !(response["height"] is int)) {
      throw Exception("Invalid response received from the gateway");
    }
    return response["height"];
  } catch (err) {
    throw Exception("The block height could not be retrieved");
  }
}

/// Returns number of existing envelopes in the process
Future<int> getEnvelopeHeight(String processId, GatewayPool gw) async {
  if (processId == null || gw == null) throw Exception("Invalid parameters");
  try {
    Map<String, dynamic> reqParams = {
      "method": "getEnvelopeHeight",
      "processId": processId,
    };
    Map<String, dynamic> response = await gw.sendRequest(reqParams, timeout: 9);
    if (!(response is Map) || !(response["height"] is int)) {
      throw Exception("Invalid response received from the gateway");
    }
    return response["height"];
  } catch (err) {
    throw Exception("The envelope height could not be retrieved");
  }
}

/// Returns the status of an already submited vote envelope
Future<bool> getEnvelopeStatus(
    String processId, String nullifier, GatewayPool gw) async {
  if (processId == null || nullifier == null || gw == null)
    throw Exception("Invalid parameters");
  try {
    Map<String, dynamic> reqParams = {
      "method": "getEnvelopeStatus",
      "nullifier": nullifier,
      "processId": processId,
    };
    Map<String, dynamic> response =
        await gw.sendRequest(reqParams, timeout: 20);
    if (!(response is Map) || !(response["registered"] is bool)) {
      throw Exception("Invalid response received from the gateway");
    }
    return response["registered"];
  } catch (err) {
    throw err ?? "The envelope status could not be retrieved";
  }
}

/// Computes the nullifier of the user's vote within a voting process.
/// Returns a hex string with kecak256(bytes(address) + bytes(processId))
Future<String> getSignedVoteNullifier(String address, String processId) {
  address = address.replaceFirst(new RegExp(r'^0x'), '');
  processId = processId.replaceFirst(new RegExp(r'^0x'), '');

  if (address.length != 40) return Future.value(null);
  if (processId.length != 64) return Future.value(null);

  return runAsync<String, String Function(String, String)>(
      _getSignedVoteNullifier, [address, processId]);
}

// internal wrapped function to run the hash computation out of the UI thread
String _getSignedVoteNullifier(String address, String processId) {
  final addressBytes = hex.decode(address);
  final processIdBytes = hex.decode(processId);

  final hashBytes =
      keccak256(Uint8List.fromList(addressBytes + processIdBytes));

  return "0x" + hex.encode(hashBytes);
}

/// Retrieves the current block number, the timestamp at which the block was mined and the average block time in miliseconds for 1m, 10m, 1h, 6h and 24h.
/// @see estimateBlockAtDateTime (date, gateway)
/// @see estimateDateAtBlock (blockNumber, gateway)
Future<BlockStatus> getBlockStatus(GatewayPool gw) {
  if (gw is! GatewayPool)
    return Future.error(Exception("Invalid Gateway object"));

  final body = {"method": "getBlockStatus"};
  return gw.sendRequest(body, timeout: 5).then((response) {
    if (!(response is Map))
      throw Exception("Invalid response received from the gateway");

    if (!(response["height"] is int) || response["height"] < 0)
      throw Exception("The block height is not valid");
    else if (!(response["blockTimestamp"] is int) ||
        response["blockTimestamp"] < 0)
      throw Exception("The block timestamp is not valid");
    else if (response["blockTime"] is! List)
      throw Exception("The block times are not valid");

    final blockTimes = response["blockTime"].cast<int>().toList();
    if (blockTimes.length < 5 ||
        blockTimes.any((item) => !(item is int) || item < 0))
      throw Exception("The block times are not valid");

    return BlockStatus(
        response["height"], response["blockTimestamp"] * 1000, blockTimes);
  }).catchError((error) {
    final message = error != null
        ? "Could not retrieve the block status: " + error.toString()
        : "Could not retrieve the block status";
    throw Exception(message);
  });
}

/// Returns the block number that is expected to be current at the given date and time
/// @param dateTime
/// @param gateway
Future<int> estimateBlockAtDateTime(DateTime targetDate, GatewayPool gw) async {
  if (!(targetDate is DateTime)) return null;
  final targetTimestamp = targetDate.millisecondsSinceEpoch;

  return getBlockStatus(gw).then((status) {
    final blockTimestamp = status.blockTimestamp;
    final blockTimes = status.averageBlockTimes;
    double averageBlockTime = VOCHAIN_BLOCK_TIME * 1000.0;
    double weightA, weightB;

    // Diff between the last mined block and the given date
    final dateDiff = (targetTimestamp - blockTimestamp).abs();

    // status.blockTime => [1m, 10m, 1h, 6h, 24h]

    if (dateDiff >= 1000 * 60 * 60 * 24) {
      if (blockTimes[4] > 0)
        averageBlockTime = blockTimes[4].toDouble();
      else if (blockTimes[3] > 0)
        averageBlockTime = blockTimes[3].toDouble();
      else if (blockTimes[2] > 0)
        averageBlockTime = blockTimes[2].toDouble();
      else if (blockTimes[1] > 0)
        averageBlockTime = blockTimes[1].toDouble();
      else if (blockTimes[0] > 0) averageBlockTime = blockTimes[0].toDouble();
    } else if (dateDiff >= 1000 * 60 * 60 * 6) {
      // 1000 * 60 * 60 * 6 <= dateDiff < 1000 * 60 * 60 * 24
      final pivot = (dateDiff - 1000 * 60 * 60 * 6) / (1000 * 60 * 60);
      weightB = pivot / (24 - 6); // 0..1
      weightA = 1 - weightB;

      if (blockTimes[4] > 0 && blockTimes[3] > 0) {
        averageBlockTime = weightA * blockTimes[3] + weightB * blockTimes[4];
      } else if (blockTimes[3] > 0)
        averageBlockTime = blockTimes[3].toDouble();
      else if (blockTimes[2] > 0)
        averageBlockTime = blockTimes[2].toDouble();
      else if (blockTimes[1] > 0)
        averageBlockTime = blockTimes[1].toDouble();
      else if (blockTimes[0] > 0) averageBlockTime = blockTimes[0].toDouble();
    } else if (dateDiff >= 1000 * 60 * 60) {
      // 1000 * 60 * 60 <= dateDiff < 1000 * 60 * 60 * 6
      final pivot = (dateDiff - 1000 * 60 * 60) / (1000 * 60 * 60);
      weightB = pivot / (6 - 1); // 0..1
      weightA = 1 - weightB;

      if (blockTimes[3] > 0 && blockTimes[2] > 0) {
        averageBlockTime = weightA * blockTimes[2] + weightB * blockTimes[3];
      } else if (blockTimes[2] > 0)
        averageBlockTime = blockTimes[2].toDouble();
      else if (blockTimes[1] > 0)
        averageBlockTime = blockTimes[1].toDouble();
      else if (blockTimes[0] > 0) averageBlockTime = blockTimes[0].toDouble();
    } else if (dateDiff >= 1000 * 60 * 10) {
      // 1000 * 60 * 10 <= dateDiff < 1000 * 60 * 60
      final pivot = (dateDiff - 1000 * 60 * 10) / (1000 * 60);
      weightB = pivot / (60 - 10); // 0..1
      weightA = 1 - weightB;

      if (blockTimes[2] > 0 && blockTimes[1] > 0) {
        averageBlockTime = weightA * blockTimes[1] + weightB * blockTimes[2];
      } else if (blockTimes[1] > 0)
        averageBlockTime = blockTimes[1].toDouble();
      else if (blockTimes[0] > 0) averageBlockTime = blockTimes[0].toDouble();
    } else if (dateDiff >= 1000 * 60) {
      // 1000 * 60 <= dateDiff < 1000 * 60 * 6
      final pivot = (dateDiff - 1000 * 60) / (1000 * 60);
      weightB = pivot / (10 - 1); // 0..1
      weightA = 1 - weightB;

      if (blockTimes[1] > 0 && blockTimes[0] > 0) {
        averageBlockTime = weightA * blockTimes[0] + weightB * blockTimes[1];
      } else if (blockTimes[0] > 0) averageBlockTime = blockTimes[0].toDouble();
    } else {
      if (blockTimes[0] > 0) averageBlockTime = blockTimes[0].toDouble();
    }

    final estimatedBlockDiff = dateDiff / averageBlockTime;
    final estimatedBlock = targetTimestamp < blockTimestamp
        ? status.blockNumber - estimatedBlockDiff.ceil()
        : status.blockNumber + estimatedBlockDiff.floor();

    if (estimatedBlock < 0) return 0;
    return estimatedBlock;
  });
}

const blocksPerM = 60.0 / VOCHAIN_BLOCK_TIME;
const blocksPer10m = 10 * blocksPerM;
const blocksPerH = blocksPerM * 60;
const blocksPer6h = 6 * blocksPerH;
const blocksPerDay = 24 * blocksPerH;

/// Returns the DateTime at which the given block number is expected to be mined
/// @param blockNumber
/// @param gateway
/// @param status
Future<DateTime> estimateDateAtBlock(int blockNumber, GatewayPool gw,
    {BlockStatus status}) async {
  if (!(blockNumber is int)) return null;

  if (status == null) {
    status = await getBlockStatus(gw);
  }

  return estimateDateAtBlockSync(blockNumber, status);
}

/// Returns the DateTime at which the given block number is expected to be mined, given a BlockStatus.
/// @param blockNumber
/// @param status
DateTime estimateDateAtBlockSync(int blockNumber, BlockStatus status) {
  if (!(blockNumber is int)) return null;

  // Diff between the last mined block and the given one
  final blockDiff = (blockNumber - status.blockNumber).abs();
  double averageBlockTime = VOCHAIN_BLOCK_TIME * 1000.0;
  double weightA, weightB;

  // status.blockTime => [1m, 10m, 1h, 6h, 24h]
  if (blockDiff > blocksPerDay) {
    if (status.averageBlockTimes[4] > 0)
      averageBlockTime = status.averageBlockTimes[4].toDouble();
    // Falbacks
    else if (status.averageBlockTimes[3] > 0)
      averageBlockTime = status.averageBlockTimes[3].toDouble();
    else if (status.averageBlockTimes[2] > 0)
      averageBlockTime = status.averageBlockTimes[2].toDouble();
    else if (status.averageBlockTimes[1] > 0)
      averageBlockTime = status.averageBlockTimes[1].toDouble();
    else if (status.averageBlockTimes[0] > 0)
      averageBlockTime = status.averageBlockTimes[0].toDouble();
  } else if (blockDiff > blocksPer6h) {
    // blocksPer6h <= blockDiff < blocksPerDay
    if (status.averageBlockTimes[4] > 0 && status.averageBlockTimes[3] > 0) {
      final pivot = (blockDiff - blocksPer6h) / (blocksPerH);
      weightB = pivot / (24 - 6); // 0..1
      weightA = 1 - weightB;

      averageBlockTime = weightA * status.averageBlockTimes[3] +
          weightB * status.averageBlockTimes[4];
    }
    // Falbacks
    else if (status.averageBlockTimes[3] > 0)
      averageBlockTime = status.averageBlockTimes[3].toDouble();
    else if (status.averageBlockTimes[2] > 0)
      averageBlockTime = status.averageBlockTimes[2].toDouble();
    else if (status.averageBlockTimes[1] > 0)
      averageBlockTime = status.averageBlockTimes[1].toDouble();
    else if (status.averageBlockTimes[0] > 0)
      averageBlockTime = status.averageBlockTimes[0].toDouble();
  } else if (blockDiff > blocksPerH) {
    // blocksPerH <= blockDiff < blocksPer6h
    if (status.averageBlockTimes[3] > 0 && status.averageBlockTimes[2] > 0) {
      final pivot = (blockDiff - blocksPerH) / (blocksPerH);
      weightB = pivot / (6 - 1); // 0..1
      weightA = 1 - weightB;

      averageBlockTime = weightA * status.averageBlockTimes[2] +
          weightB * status.averageBlockTimes[3];
    }
    // Falbacks
    else if (status.averageBlockTimes[2] > 0)
      averageBlockTime = status.averageBlockTimes[2].toDouble();
    else if (status.averageBlockTimes[1] > 0)
      averageBlockTime = status.averageBlockTimes[1].toDouble();
    else if (status.averageBlockTimes[0] > 0)
      averageBlockTime = status.averageBlockTimes[0].toDouble();
  } else if (blockDiff > blocksPer10m) {
    // blocksPer10m <= blockDiff < blocksPerH
    if (status.averageBlockTimes[2] > 0 && status.averageBlockTimes[1] > 0) {
      final pivot = (blockDiff - blocksPer10m) / (blocksPerM);
      weightB = pivot / (60 - 10); // 0..1
      weightA = 1 - weightB;

      averageBlockTime = weightA * status.averageBlockTimes[1] +
          weightB * status.averageBlockTimes[2];
    }
    // Falbacks
    else if (status.averageBlockTimes[1] > 0)
      averageBlockTime = status.averageBlockTimes[1].toDouble();
    else if (status.averageBlockTimes[0] > 0)
      averageBlockTime = status.averageBlockTimes[0].toDouble();
  } else if (blockDiff > blocksPerM) {
    // blocksPerM <= blockDiff < blocksPer10m
    if (status.averageBlockTimes[1] > 0 && status.averageBlockTimes[0] > 0) {
      final pivot = (blockDiff - blocksPerM) / (blocksPerM);
      weightB = pivot / (10 - 1); // 0..1
      weightA = 1 - weightB;

      averageBlockTime = weightA * status.averageBlockTimes[0] +
          weightB * status.averageBlockTimes[1];
    }
    // Falbacks
    else if (status.averageBlockTimes[0] > 0)
      averageBlockTime = status.averageBlockTimes[0].toDouble();
  } else {
    if (status.averageBlockTimes[0] > 0)
      averageBlockTime = status.averageBlockTimes[0].toDouble();
  }

  final targetTimestamp = 1000 *
      (status.blockTimestamp +
          (blockNumber - status.blockNumber) * averageBlockTime);
  return DateTime.fromMicrosecondsSinceEpoch(targetTimestamp.floor());
}

/// Submit vote Envelope to the gateway
Future<void> submitEnvelope(
    Map<String, dynamic> voteEnvelope, GatewayPool gw) async {
  if (!(voteEnvelope is Map) || gw is! GatewayPool) {
    throw Exception("Invalid parameters");
  } else if (!(voteEnvelope["processId"] is String) ||
      !(voteEnvelope["proof"] is String) ||
      !(voteEnvelope["nonce"] is String) ||
      !(voteEnvelope["votePackage"] is String) ||
      !(voteEnvelope["signature"] is String)) {
    throw Exception("Invalid parameters");
  }

  try {
    Map<String, dynamic> reqParams = {
      "method": "submitEnvelope",
      "payload": voteEnvelope
    };
    Map<String, dynamic> response = await gw.sendRequest(reqParams);
    if (!(response is Map)) {
      throw Exception("Invalid response received from the gateway");
    }
  } catch (err) {
    throw err;
  }
}

Future<String> packageAnonymousEnvelope(
    List<int> votes, String proof, String privateKey) async {
  throw Exception("unimplemented");
  // TODO: Generate hash of private key for nullifier as in Snarks
  /*
  String votePackage = packageVoteContent(votes);
  Map<String, String>  package = {
    "processId": processId,
    "proof": proof, // ZK Proof
    "nonce": nonce, // Unique number per vote attempt, so that replay attacks can't reuse this payload
    "nullifier": "0x1234...", // Hash of the private key
    "votePackage": votePackage, // base64(jsonString) is encrypted
  };
  return jsonEncode(package);
  */
}

Future<Map<String, dynamic>> packageSignedEnvelope(List<int> votes,
    String merkleProof, String processId, String signingPrivateKey,
    {ProcessKeys processKeys}) async {
  if (!(votes is List) ||
      !(processId is String) ||
      !(merkleProof is String) ||
      !(signingPrivateKey is String))
    throw Exception("Invalid parameters");
  else if (processKeys is ProcessKeys) {
    if (!(processKeys.encryptionPubKeys is List) ||
        !processKeys.encryptionPubKeys.every((item) =>
            item is ProcessKey &&
            item.idx is int &&
            item.key is String &&
            RegExp(r"^(0x)?[0-9a-zA-Z]+$").hasMatch(item.key))) {
      throw Exception("Some encryption public keys are not valid");
    }
  }
  try {
    final nonce = makeRandomNonce(32);

    final packageValues =
        await packageVoteContent(votes, processKeys: processKeys);

    Map<String, dynamic> package = {
      "processId": processId,
      "proof": merkleProof,
      "nonce":
          nonce, // Unique number per vote attempt, so that replay attacks can't reuse this payload
      "votePackage": packageValues["votePackage"]
      //singature:  Must be unset because the body must be singed without the  signature
    };
    if (packageValues["keyIndexes"] is List &&
        packageValues["keyIndexes"].length > 0) {
      package["encryptionKeyIndexes"] = packageValues["keyIndexes"];
    }

    // Important: Sorting the JSON data itself, the same way that it will be signed later on
    package = sortJsonFields(package);

    // Sign the vote package
    final signature =
        await JSONSignature.signJsonPayloadAsync(package, signingPrivateKey);
    package["signature"] = signature;

    return package;
  } catch (error) {
    throw Exception("Poll vote Envelope could not be generated");
  }
}

// ////////////////////////////////////////////////////////////////////////////
// / Internal helpers
// ////////////////////////////////////////////////////////////////////////////

/// Packages the vote and returns `{ votePackage: "..." }` on non-encrypted polls and
/// `{ votePackage: "...", keyIndexes: [0, 1, 2, 3, 4] }` on encrypted polls
Future<Map<String, dynamic>> packageVoteContent(List<int> votes,
    {ProcessKeys processKeys}) async {
  if (!(votes is List))
    throw Exception("Invalid parameters");
  else if (processKeys is ProcessKeys) {
    if (!(processKeys.encryptionPubKeys is List) ||
        !processKeys.encryptionPubKeys.every((item) =>
            item is ProcessKey &&
            item.idx is int &&
            item.key is String &&
            RegExp(r"^(0x)?[0-9a-zA-Z]+$").hasMatch(item.key))) {
      throw Exception("Some encryption public keys are not valid");
    }
  }

  final nonce = makeRandomNonce(16);

  Map<String, dynamic> package = {
    "type": "poll-vote",
    "nonce":
        nonce, // (encrypted payload only) random number to prevent guessing the encrypted payload before the key is revealed
    "votes": votes // Directly mapped to the `questions` field of the metadata
  };
  final strPayload = jsonEncode(package);

  if (processKeys is ProcessKeys &&
      processKeys.encryptionPubKeys is List &&
      processKeys.encryptionPubKeys.length > 0) {
    // Sort key indexes
    processKeys.encryptionPubKeys.sort((a, b) => a.idx - b.idx);

    final List<String> publicKeys = [];
    final List<int> publicKeysIdx = [];

    // NOTE: Using all keys by now
    processKeys.encryptionPubKeys.forEach((entry) {
      publicKeys.add(entry.key.replaceFirst("0x", ""));
      publicKeysIdx.add(entry.idx);
    });

    Uint8List result;
    for (int i = 0; i < publicKeys.length; i++) {
      if (i > 0)
        result = await Asymmetric.encryptRawAsync(
            result, publicKeys[i]); // reencrypt the previous result
      else
        result = await Asymmetric.encryptRawAsync(
            utf8.encode(strPayload), publicKeys[i]); // encrypt the first round
    }
    return {"votePackage": base64.encode(result), "keyIndexes": publicKeysIdx};
  } else {
    return {"votePackage": base64.encode(utf8.encode(strPayload))};
  }
}

// HELPERS

/// Turns [{idx:1, key: "1234"}, ...] into [ProcessKey(...), ...]
List<ProcessKey> _parseProcessKeyList(List<dynamic> items) {
  if (!(items is List)) return <ProcessKey>[];
  return items
      .map((item) {
        if (!(item is Map) || !(item["idx"] is int) || !(item["key"] is String))
          return null;
        final k = ProcessKey();
        k.idx = item["idx"];
        k.key = item["key"];
        return k;
      })
      .whereType<ProcessKey>()
      .cast<ProcessKey>()
      .toList();
}

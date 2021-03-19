import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:dvote/dvote.dart';
import 'package:dvote/models/build/dart/common/vote.pb.dart';
import 'package:dvote/models/build/dart/vochain/vochain.pbserver.dart';
import 'package:dvote/net/gateway-web3.dart';
import 'package:dvote/util/bytes-signature.dart';
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
import 'package:web3dart/web3dart.dart';

import '../net/gateway-pool.dart';
import '../util/random.dart';
import '../models/build/dart/metadata/process.pb.dart';
import '../constants.dart';

// ENUMS AND WRAPPERS

/// A wrapper for the block time and status of a blockchain state.
class BlockStatus {
  int blockNumber;
  int blockTimestamp;
  List<int> averageBlockTimes;
  BlockStatus(this.blockNumber, this.blockTimestamp, this.averageBlockTimes);
}

/// A single vote package containing [votes] and a [nonce].
class VotePackage {
  String nonce;
  List<int> votes;

  Map<String, dynamic> toJSON() {
    return {"nonce": nonce, "votes": votes};
  }
}

/// A wrapper providing meaningful interaction with the `mode` process flag.
class ProcessMode {
  final int mode;
  ProcessMode(this.mode) {
    final allFlags = ProcessMode.AUTO_START |
        ProcessMode.INTERRUPTIBLE |
        ProcessMode.DYNAMIC_CENSUS |
        ProcessMode.ENCRYPTED_METADATA;
    if (this.mode > allFlags || this.mode < 0) {
      throw Exception("ProcessMode ${this.mode} is invalid");
    }
  }

  ProcessMode.make(
      {bool autoStart = false,
      interruptible = false,
      dynamicCensus = false,
      encryptedMetadata = false})
      : mode = 0 |
            (autoStart ? ProcessMode.AUTO_START : 0) |
            (interruptible ? ProcessMode.INTERRUPTIBLE : 0) |
            (dynamicCensus ? ProcessMode.DYNAMIC_CENSUS : 0) |
            (encryptedMetadata ? ProcessMode.ENCRYPTED_METADATA : 0);

  String toString() {
    return "Auto start: $isAutoStart, Interruptible: $isInterruptible, Dynamic census: $hasDynamicCensus, Encrypted metadata: $hasEncryptedMetadata";
  }

  //  By default, the process is started on demand (PAUSED). If set, the process will sIf set, the process will work like `status=PAUSED` before `startBlock` and like `status=ENDED` after `startBlock + blockCount`. The process works on demand, by default.tart as READY and the Vochain will allow incoming votes after `startBlock`
  /// Constant representing the auto start binary flag.
  static const AUTO_START = 1 << 0;
  //  By default, the process can't be paused, ended or canceled. If set, the process can be paused, ended or canceled by the creator.
  /// Constant representing the interruptible binary fla.
  static const INTERRUPTIBLE = 1 << 1;
  //  By default, the census is immutable. When set, the creator can update the census while the process remains `READY` or `PAUSED`.
  /// Constant representing the dynamic census binary flag.
  static const DYNAMIC_CENSUS = 1 << 2;
  //  By default, the metadata is not encrypted. If set, clients should fetch the decryption key before trying to display the metadata.
  /// Constant representing the encrypted metadata binary flag.
  static const ENCRYPTED_METADATA = 1 << 3;

  /// The integer value of the mode.
  int get value => this.mode;

  ///  Flag signifying whether the Vochain will not allow votes until `startBlock`.
  bool get isAutoStart => mode & ProcessMode.AUTO_START != 0;

  ///  Flag signifying whether the process can be paused, ended and canceled by the creator.
  bool get isInterruptible => mode & ProcessMode.INTERRUPTIBLE != 0;

  ///  Flag signifying whether the census can be updated by the creator.
  bool get hasDynamicCensus => mode & ProcessMode.DYNAMIC_CENSUS != 0;

  ///  Flag signifying whether the process metadata is expected to be encrypted.
  bool get hasEncryptedMetadata => mode & ProcessMode.ENCRYPTED_METADATA != 0;
}

/// A wrapper for the envelopeType process flag.
class ProcessEnvelopeType {
  final int type;
  ProcessEnvelopeType(this.type) {
    final allFlags = ProcessEnvelopeType.SERIAL |
        ProcessEnvelopeType.ANONYMOUS |
        ProcessEnvelopeType.ENCRYPTED |
        ProcessEnvelopeType.UNIQUE_VALUES;
    if (this.type > allFlags || this.type < 0) {
      throw Exception("ProcessEnvelopeType ${this.type} is invalid");
    }
  }

  ProcessEnvelopeType.make(
      {bool serial = false,
      anonymous = false,
      encrypted = false,
      uniqueValues = false})
      : type = 0 |
            (serial ? ProcessEnvelopeType.SERIAL : 0) |
            (anonymous ? ProcessEnvelopeType.ANONYMOUS : 0) |
            (encrypted ? ProcessEnvelopeType.ENCRYPTED : 0) |
            (uniqueValues ? ProcessEnvelopeType.UNIQUE_VALUES : 0);

  String toString() {
    return "Serial: ${this.hasSerialVoting}, Anonymous: ${this.hasAnonymousVoters}, Encrypted: ${this.hasEncryptedVotes}, Unique: ${this.hasUniqueValues}";
  }

  //  By default, all votes are sent within a single envelope. When set, the process questions are voted one by one (enables `questionIndex`).
  /// Constant representing the serial binary flag.
  static const SERIAL = 1 << 0;
  //  By default, the franchise proof relies on an ECDSA signature (this could reveal the voter's identity). When set, the franchise proof will use ZK-Snarks.
  /// Constant representing the anonymous binary flag.
  static const ANONYMOUS = 1 << 1;
  //  By default, votes are sent unencrypted. When the flag is set, votes are sent encrypted and become public when the process ends.
  /// Constant representing the encrypted binary flag.
  static const ENCRYPTED = 1 << 2;
  // Whether choices for a question can only appear once or not.
  /// Constant representing the unique values binary flag.
  static const UNIQUE_VALUES = 1 << 3;

  /// The integer value of [type].
  int get value => this.type;

  /// Flag signifying whether the process expects one envelope to be sent for each question.
  bool get hasSerialVoting => type & ProcessEnvelopeType.SERIAL != 0;

  /// Flag signifying whether franchise proofs use ZK-Snarks.
  bool get hasAnonymousVoters => type & ProcessEnvelopeType.ANONYMOUS != 0;

  /// Flag signifying whether envelopes are to be sent encrypted.
  bool get hasEncryptedVotes => type & ProcessEnvelopeType.ENCRYPTED != 0;

  /// Flag signifying whether envelopes must contain unique values.
  bool get hasUniqueValues => type & ProcessEnvelopeType.UNIQUE_VALUES != 0;
}

/// A wrapper for the census origin process flag.
class ProcessCensusOrigin {
  final int origin;
  ProcessCensusOrigin(this.origin) {
    if (!processCensusOriginValues.contains(this.origin)) {
      throw Exception("Process census origin ${this.origin} is invalid");
    }
  }

  String toString() {
    if (this.isOffChain) return "Off chain";
    if (this.isOffChainWeighted) return "Off chain weighted";
    if (this.isOffChainCA) return "Off chain CA";
    if (this.isERC20) return "ERC 20";
    if (this.isERC721) return "ERC 721";
    if (this.isERC1155) return "ERC 1155";
    if (this.isERC777) return "ERC 777";
    if (this.isMiniMe) return "MiniMe";
    return "Unknown";
  }

  /// Flag value of off-chain tree.
  static const OFF_CHAIN_TREE = 1;

  /// Flag value of off-chain weighted tree.
  static const OFF_CHAIN_TREE_WEIGHTED = 2;

  /// Flag value of off-chain CA.
  static const OFF_CHAIN_CA = 3;

  /// Flag value of ERC20.
  static const ERC20 = 11;

  /// Flag value of ERC721.
  static const ERC721 = 12;

  /// Flag value of ERC1155.
  static const ERC1155 = 13;

  /// Flag value of ERC777.
  static const ERC777 = 14;

  /// Flag value of MINI ME.
  static const MINI_ME = 15;

  /// All valid flag values.
  static const processCensusOriginValues = [
    ProcessCensusOrigin.OFF_CHAIN_TREE,
    ProcessCensusOrigin.OFF_CHAIN_TREE_WEIGHTED,
    ProcessCensusOrigin.OFF_CHAIN_CA,
    ProcessCensusOrigin.ERC20,
    ProcessCensusOrigin.ERC721,
    ProcessCensusOrigin.ERC1155,
    ProcessCensusOrigin.ERC777,
    ProcessCensusOrigin.MINI_ME,
  ];

  /// Integer value of origin flag.
  int get value => this.origin;

  /// Census origin is off-chain.
  bool get isOffChain => origin == ProcessCensusOrigin.OFF_CHAIN_TREE;

  /// Census origin is off-chain weighted.
  bool get isOffChainWeighted =>
      origin == ProcessCensusOrigin.OFF_CHAIN_TREE_WEIGHTED;

  /// Census origin is off-chain CA.
  bool get isOffChainCA => origin == ProcessCensusOrigin.OFF_CHAIN_CA;

  /// Census origin is ERC20.
  bool get isERC20 => origin == ProcessCensusOrigin.ERC20;

  /// Census origin is ERC721.
  bool get isERC721 => origin == ProcessCensusOrigin.ERC721;

  /// Census origin is ERC1155.
  bool get isERC1155 => origin == ProcessCensusOrigin.ERC1155;

  /// Census origin is ERC777.
  bool get isERC777 => origin == ProcessCensusOrigin.ERC777;

  /// Census origin is MINI ME.
  bool get isMiniMe => origin == ProcessCensusOrigin.MINI_ME;
}

/// A wrapper for the process status flag.
class ProcessStatus {
  final int status;
  ProcessStatus(this.status) {
    if (!processStatusValues.contains(this.status)) {
      throw Exception("ProcessStatus ${this.status} is invalid");
    }
  }

  String toString() {
    if (this.isReady) return "Ready";
    if (this.isEnded) return "Ended";
    if (this.isCanceled) return "Canceled";
    if (this.isPaused) return "Paused";
    if (this.hasResults) return "Results";
    return "Unknown";
  }

  /// The process is ready to accept votes, according to `AUTO_START`, `startBlock` and `blockCount`.
  static const READY = 0;

  /// The creator has ended the process and the results will be available soon.
  static const ENDED = 1;

  /// The process has been canceled. Results will not be available anytime.
  static const CANCELED = 2;

  /// The process is temporarily paused and votes are not accepted at the time. It might be resumed in the future.
  static const PAUSED = 3;

  /// The process is ended and its results are available.
  static const RESULTS = 4;

  /// All valid flag values.
  static const processStatusValues = [
    ProcessStatus.READY,
    ProcessStatus.ENDED,
    ProcessStatus.CANCELED,
    ProcessStatus.PAUSED,
    ProcessStatus.RESULTS,
  ];

  /// The numeric value of the status flag.
  int get value => this.status;

  /// The process status is `ready`.
  bool get isReady => status == ProcessStatus.READY;

  /// The process status is `ended`.
  bool get isEnded => status == ProcessStatus.ENDED;

  /// The process status is `canceled`.
  bool get isCanceled => status == ProcessStatus.CANCELED;

  /// The process status is `paused`.
  bool get isPaused => status == ProcessStatus.PAUSED;

  /// The process status is `ready`.
  bool get hasResults => status == ProcessStatus.RESULTS;
}

/// A record of expected index values for each process data flag.
class ProcessContractGetIdx {
  // First-level array indexes
  /// Index of MODE, ENVELOPE_TYPE, CENSUS_ORIGIN [3]uint8.
  static const MODE_ENVELOPE_TYPE_CENSUS_ORIGIN = 0;

  /// Index of ENTITY_ADDRESS address.
  static const ENTITY_ADDRESS = 1;

  /// Index of METADATA, CENSUS_ROOT, CENSUS_URI [3]string.
  static const METADATA_CENSUS_ROOT_CENSUS_URI = 2;

  /// Index of START_BLOCK, BLOCK_COUNT [2]uint32.
  static const START_BLOCK_BLOCK_COUNT = 3;

  /// Index of STATUS ProcessStatus.
  static const STATUS = 4;

  /// Index of QUESTION_INDEX, QUESTION_COUNT, MAX_COUNT, MAX_VALUE, MAX_VOTE_OVERWRITES [5]uint8.
  static const QUESTION_INDEX_QUESTION_COUNT_MAX_COUNT_MAX_VALUE_MAX_VOTE_OVERWRITES =
      5;

  /// Index of MAX_TOTAL_COST, COST_EXPONENT [2]uint16.
  static const MAX_TOTAL_COST_COST_EXPONENT = 6;

  /// Index of EVM_BLOCK_HEIGHT BigInt.
  static const EVM_BLOCK_HEIGHT = 7;

  /// Index of the length of the process contract list.
  static const PROCESS_CONTRACT_LENGTH = 8;

  // Second-level array indexes

  /// Index of MODE, ENVELOPE_TYPE, CENSUS_ORIGIN [3]uint8.
  static const SUB_INDEX_MODE = 0;
  static const SUB_INDEX_ENVELOPE_TYPE = 1;
  static const SUB_INDEX_CENSUS_ORIGIN = 2;

  /// Index of METADATA, CENSUS_ROOT, CENSUS_URI [3]string.
  static const SUB_INDEX_METADATA = 0;
  static const SUB_INDEX_CENSUS_ROOT = 1;
  static const SUB_INDEX_CENSUS_URI = 2;

  /// Index of START_BLOCK, BLOCK_COUNT [2]uint32.
  static const SUB_INDEX_START_BLOCK = 0;
  static const SUB_INDEX_BLOCK_COUNT = 1;

  /// Index of QUESTION_INDEX, QUESTION_COUNT, MAX_COUNT, MAX_VALUE, MAX_VOTE_OVERWRITES [5]uint8.
  static const SUB_INDEX_QUESTION_INDEX = 0;
  static const SUB_INDEX_QUESTION_COUNT = 1;
  static const SUB_INDEX_MAX_COUNT = 2;
  static const SUB_INDEX_MAX_VALUE = 3;
  static const SUB_INDEX_MAX_VOTE_OVERWRITES = 4;

  /// Index of MAX_TOTAL_COST, COST_EXPONENT [2]uint16.
  static const SUB_INDEX_MAX_TOTAL_COST = 0;
  static const SUB_INDEX_COST_EXPONENT = 1;
}

/// A wrapper for the Process contract response, provides getters to the response's fields.
class ProcessData {
  final List<dynamic> data;

  ProcessData(this.data) {
    if (this.data is! List)
      throw Exception("Process data is invalid: data should be a list");
    if (this.data.length != ProcessContractGetIdx.PROCESS_CONTRACT_LENGTH)
      throw Exception(
          "Process data is invalid: data should contain ${ProcessContractGetIdx.PROCESS_CONTRACT_LENGTH} elements");
    try {
      // Use all getters to ensure data is parsed correctly
      this.mode;
      this.envelopeType;
      this.censusOrigin;
      this.entityAddress;
      this.metadata;
      this.censusRoot;
      this.censusUri;
      this.startBlock;
      this.blockCount;
      this.status;
      this.questionIndex;
      this.questionCount;
      this.maxCount;
      this.maxValue;
      this.maxVoteOverwrites;
      this.maxTotalCost;
      this.costExponent;
      this.evmBlockHeight;
    } catch (err) {
      throw Exception("ProcessData could not be initialized: $err");
    }
  }

  ProcessData.fromJsonString(String jsonString)
      : this(parseJsonFields(jsonString));

  String toJsonString() {
    try {
      return json.encode(data, toEncodable: (object) {
        try {
          return object.toJson();
        } catch (_) {
          // EthereumAddress or BigInt
          return object.toString();
        }
      });
    } catch (err) {
      throw Exception("Could not encode ProcessData to json: $err");
    }
  }

  String toString() {
    return """
    Mode: ${this.mode.toString()}  
    Envelope type: ${this.envelopeType.toString()}
    Census origin: ${this.censusOrigin.toString()}
    Entity address: ${this.entityAddress}
    Metadata: ${this.metadata}
    Census root: ${this.censusRoot}
    Census uri: ${this.censusUri}
    Start block: ${this.startBlock}
    Block count: ${this.blockCount}
    Status: ${this.status.toString()}
    Question index: ${this.questionIndex}
    Question count: ${this.questionCount}
    Max count: ${this.maxCount}
    Max Value: ${this.maxValue}
    Max vote overwrites: ${this.maxVoteOverwrites}
    Max total cost: ${this.maxTotalCost}
    Cost exponent: ${this.costExponent}
    Evm block height: ${this.evmBlockHeight}""";
  }

  // First-level array indexes:
  List get _getModeEnvelopeTypeCensusOrigin {
    if (data[ProcessContractGetIdx.MODE_ENVELOPE_TYPE_CENSUS_ORIGIN] is! List)
      throw Exception(
          "ProcessData MODE_ENVELOPE_TYPE_CENSUS_ORIGIN expected to be a list, instead is a ${data[ProcessContractGetIdx.MODE_ENVELOPE_TYPE_CENSUS_ORIGIN].runtimeType}");
    return data[ProcessContractGetIdx.MODE_ENVELOPE_TYPE_CENSUS_ORIGIN];
  }

  /// The entity address.
  EthereumAddress get entityAddress {
    if (data[ProcessContractGetIdx.ENTITY_ADDRESS] is! EthereumAddress)
      throw Exception(
          "ProcessData ENTITY_ADDRESS expected to be an EthereumAddress, instead is a ${[
        ProcessContractGetIdx.ENTITY_ADDRESS
      ].runtimeType}");
    return data[ProcessContractGetIdx.ENTITY_ADDRESS];
  }

  List get _getMetadataCensusRootCensusUri {
    if (data[ProcessContractGetIdx.METADATA_CENSUS_ROOT_CENSUS_URI] is! List)
      throw Exception(
          "ProcessData METADATA_CENSUS_ROOT_CENSUS_URI expected to be a List, instead is a ${data[ProcessContractGetIdx.METADATA_CENSUS_ROOT_CENSUS_URI].runtimeType}");
    return data[ProcessContractGetIdx.METADATA_CENSUS_ROOT_CENSUS_URI];
  }

  List get _getStartBlockBlockCount {
    if (data[ProcessContractGetIdx.START_BLOCK_BLOCK_COUNT] is! List)
      throw Exception(
          "ProcessData START_BLOCK_BLOCK_COUNT expected to be a List, instead is a ${data[ProcessContractGetIdx.START_BLOCK_BLOCK_COUNT].runtimeType}");
    return data[ProcessContractGetIdx.START_BLOCK_BLOCK_COUNT];
  }

  /// The process status.
  ProcessStatus get status {
    if (data[ProcessContractGetIdx.STATUS] is! BigInt)
      throw Exception(
          "ProcessData STATUS expected to be a BigInt, instead is a ${data[ProcessContractGetIdx.STATUS].runtimeType}");
    return ProcessStatus(data[ProcessContractGetIdx.STATUS].toInt());
  }

  List get _getQuestionIndexQuestionCountMaxCountMaxValueMaxVoteOverwrites {
    if (data[ProcessContractGetIdx
            .QUESTION_INDEX_QUESTION_COUNT_MAX_COUNT_MAX_VALUE_MAX_VOTE_OVERWRITES]
        is! List)
      throw Exception(
          "ProcessData QUESTION_INDEX_QUESTION_COUNT_MAX_COUNT_MAX_VALUE_MAX_VOTE_OVERWRITES expected to be a List, instead is a ${data[ProcessContractGetIdx.QUESTION_INDEX_QUESTION_COUNT_MAX_COUNT_MAX_VALUE_MAX_VOTE_OVERWRITES].runtimeType}");
    return data[ProcessContractGetIdx
        .QUESTION_INDEX_QUESTION_COUNT_MAX_COUNT_MAX_VALUE_MAX_VOTE_OVERWRITES];
  }

  List get _getMaxTotalCostCostExponent {
    if (data[ProcessContractGetIdx.MAX_TOTAL_COST_COST_EXPONENT] is! List)
      throw Exception(
          "ProcessData MAX_TOTAL_COST_COST_EXPONENT expected to be a List, instead is a ${data[ProcessContractGetIdx.MAX_TOTAL_COST_COST_EXPONENT].runtimeType}");
    return data[ProcessContractGetIdx.MAX_TOTAL_COST_COST_EXPONENT];
  }

  /// The evm block height.
  BigInt get evmBlockHeight {
    if (data[ProcessContractGetIdx.EVM_BLOCK_HEIGHT] is! BigInt)
      throw Exception(
          "ProcessData EVM_BLOCK_HEIGHT expected to be a BigInt, instead is a ${data[ProcessContractGetIdx.EVM_BLOCK_HEIGHT].runtimeType}");
    return data[ProcessContractGetIdx.EVM_BLOCK_HEIGHT];
  }

  // Second-level array indexes
  /// The process mode.
  ProcessMode get mode {
    final list = _getModeEnvelopeTypeCensusOrigin;
    if (list == null) throw Exception("ModeEnvelopeTypeCensusOrigin is null");
    if (list[ProcessContractGetIdx.SUB_INDEX_MODE] is! BigInt)
      throw Exception(
          "ProcessData SUB_INDEX_MODE expected to be a BigInt, instead is a ${list[ProcessContractGetIdx.SUB_INDEX_MODE].runtimeType}");
    return ProcessMode(list[ProcessContractGetIdx.SUB_INDEX_MODE].toInt());
  }

  /// The envelope type.
  ProcessEnvelopeType get envelopeType {
    final list = _getModeEnvelopeTypeCensusOrigin;
    if (list == null) throw Exception("LISTTYPE is null");

    if (list[ProcessContractGetIdx.SUB_INDEX_ENVELOPE_TYPE] is! BigInt)
      throw Exception(
          "ProcessData ENVELOPE_TYPE expected to be a BigInt, instead is a ${list[ProcessContractGetIdx.SUB_INDEX_ENVELOPE_TYPE].runtimeType}");
    return ProcessEnvelopeType(
        list[ProcessContractGetIdx.SUB_INDEX_ENVELOPE_TYPE].toInt());
  }

  /// The census origin.
  ProcessCensusOrigin get censusOrigin {
    final list = _getModeEnvelopeTypeCensusOrigin;
    if (list == null) throw Exception("ModeEnvelopeTypeCensusOrigin is null");

    if (list[ProcessContractGetIdx.SUB_INDEX_CENSUS_ORIGIN] is! BigInt)
      throw Exception(
          "ProcessData CENSUS_ORIGIN expected to be a BigInt, instead is a ${list[ProcessContractGetIdx.SUB_INDEX_CENSUS_ORIGIN].runtimeType}");
    return ProcessCensusOrigin(
        list[ProcessContractGetIdx.SUB_INDEX_CENSUS_ORIGIN].toInt());
  }

  /// The Metadata uri.
  String get metadata {
    final list = _getMetadataCensusRootCensusUri;
    if (list == null) throw Exception("ModeEnvelopeTypeCensusOrigin is null");

    if (list[ProcessContractGetIdx.SUB_INDEX_METADATA] is! String)
      throw Exception(
          "ProcessData METADATA expected to be a String, instead is a ${list[ProcessContractGetIdx.SUB_INDEX_METADATA].runtimeType}");
    return list[ProcessContractGetIdx.SUB_INDEX_METADATA];
  }

  /// The census root.
  String get censusRoot {
    final list = _getMetadataCensusRootCensusUri;
    if (list == null) throw Exception("ModeEnvelopeTypeCensusOrigin is null");

    if (list[ProcessContractGetIdx.SUB_INDEX_CENSUS_ROOT] is! String)
      throw Exception(
          "ProcessData CENSUS_ROOT expected to be a String, instead is a ${list[ProcessContractGetIdx.SUB_INDEX_CENSUS_ROOT].runtimeType}");
    return list[ProcessContractGetIdx.SUB_INDEX_CENSUS_ROOT];
  }

  /// The census uri.
  String get censusUri {
    final list = _getMetadataCensusRootCensusUri;
    if (list == null) throw Exception("ModeEnvelopeTypeCensusOrigin is null");

    if (list[ProcessContractGetIdx.SUB_INDEX_CENSUS_URI] is! String)
      throw Exception(
          "ProcessData CENSUS_URI expected to be a String, instead is a ${list[ProcessContractGetIdx.SUB_INDEX_CENSUS_URI].runtimeType}");
    return list[ProcessContractGetIdx.SUB_INDEX_CENSUS_URI];
  }

  /// The start block.
  int get startBlock {
    final list = _getStartBlockBlockCount;
    if (list == null) throw Exception("ModeEnvelopeTypeCensusOrigin is null");
    if (list[ProcessContractGetIdx.SUB_INDEX_START_BLOCK] is! BigInt)
      throw Exception(
          "ProcessData START_BLOCK expected to be a BigInt, instead is a ${list[ProcessContractGetIdx.SUB_INDEX_START_BLOCK].runtimeType}");
    return list[ProcessContractGetIdx.SUB_INDEX_START_BLOCK].toInt();
  }

  /// The block count.\.
  int get blockCount {
    final list = _getStartBlockBlockCount;
    if (list == null) throw Exception("ModeEnvelopeTypeCensusOrigin is null");
    if (list[ProcessContractGetIdx.SUB_INDEX_BLOCK_COUNT] is! BigInt)
      throw Exception(
          "ProcessData BLOCK_COUNT expected to be a BigInt, instead is a ${list[ProcessContractGetIdx.SUB_INDEX_BLOCK_COUNT].runtimeType}");
    return list[ProcessContractGetIdx.SUB_INDEX_BLOCK_COUNT].toInt();
  }

  /// The question index.
  int get questionIndex {
    final list =
        _getQuestionIndexQuestionCountMaxCountMaxValueMaxVoteOverwrites;
    if (list == null) throw Exception("ModeEnvelopeTypeCensusOrigin is null");

    if (list[ProcessContractGetIdx.SUB_INDEX_QUESTION_INDEX] is! BigInt)
      throw Exception(
          "ProcessData QUESTION_INDEX expected to be a BigInt, instead is a ${list[ProcessContractGetIdx.SUB_INDEX_QUESTION_INDEX].runtimeType}");
    return list[ProcessContractGetIdx.SUB_INDEX_QUESTION_INDEX].toInt();
  }

  /// The question count.
  int get questionCount {
    final list =
        _getQuestionIndexQuestionCountMaxCountMaxValueMaxVoteOverwrites;
    if (list == null) throw Exception("ModeEnvelopeTypeCensusOrigin is null");

    if (list[ProcessContractGetIdx.SUB_INDEX_QUESTION_COUNT] is! BigInt)
      throw Exception(
          "ProcessData QUESTION_COUNT expected to be a BigInt, instead is a ${list[ProcessContractGetIdx.SUB_INDEX_QUESTION_COUNT].runtimeType}");
    return list[ProcessContractGetIdx.SUB_INDEX_QUESTION_COUNT].toInt();
  }

  /// The max count for vote values.
  int get maxCount {
    final list =
        _getQuestionIndexQuestionCountMaxCountMaxValueMaxVoteOverwrites;
    if (list == null) throw Exception("ModeEnvelopeTypeCensusOrigin is null");

    if (list[ProcessContractGetIdx.SUB_INDEX_MAX_COUNT] is! BigInt)
      throw Exception(
          "ProcessData MAX_COUNT expected to be a BigInt, instead is a ${list[ProcessContractGetIdx.SUB_INDEX_MAX_COUNT].runtimeType}");
    return list[ProcessContractGetIdx.SUB_INDEX_MAX_COUNT].toInt();
  }

  /// The max value of a vote.
  int get maxValue {
    final list =
        _getQuestionIndexQuestionCountMaxCountMaxValueMaxVoteOverwrites;
    if (list == null) throw Exception("ModeEnvelopeTypeCensusOrigin is null");

    if (list[ProcessContractGetIdx.SUB_INDEX_MAX_VALUE] is! BigInt)
      throw Exception(
          "ProcessData MAX_VALUE expected to be a BigInt, instead is a ${list[ProcessContractGetIdx.SUB_INDEX_MAX_VALUE].runtimeType}");
    return list[ProcessContractGetIdx.SUB_INDEX_MAX_VALUE].toInt();
  }

  /// The max number of vote overwrites.
  int get maxVoteOverwrites {
    final list =
        _getQuestionIndexQuestionCountMaxCountMaxValueMaxVoteOverwrites;
    if (list == null) throw Exception("ModeEnvelopeTypeCensusOrigin is null");

    if (list[ProcessContractGetIdx.SUB_INDEX_MAX_VOTE_OVERWRITES] is! BigInt)
      throw Exception(
          "ProcessData MAX_VOTE_OVERWRITES expected to be a BigInt, instead is a ${list[ProcessContractGetIdx.SUB_INDEX_MAX_VOTE_OVERWRITES].runtimeType}");
    return list[ProcessContractGetIdx.SUB_INDEX_MAX_VOTE_OVERWRITES].toInt();
  }

  /// The max total cost for a vote.
  int get maxTotalCost {
    final list = _getMaxTotalCostCostExponent;
    if (list == null) throw Exception("ModeEnvelopeTypeCensusOrigin is null");

    if (list[ProcessContractGetIdx.SUB_INDEX_MAX_TOTAL_COST] is! BigInt)
      throw Exception(
          "ProcessData MAX_TOTAL_COST expected to be a BigInt, instead is a ${list[ProcessContractGetIdx.SUB_INDEX_MAX_TOTAL_COST].runtimeType}");
    return list[ProcessContractGetIdx.SUB_INDEX_MAX_TOTAL_COST].toInt();
  }

  /// The cost exponent for a vote.
  int get costExponent {
    final list = _getMaxTotalCostCostExponent;
    if (list == null) throw Exception("ModeEnvelopeTypeCensusOrigin is null");

    if (list[ProcessContractGetIdx.SUB_INDEX_COST_EXPONENT] is! BigInt)
      throw Exception(
          "ProcessData COST_EXPONENT expected to be a BigInt, instead is a ${list[ProcessContractGetIdx.SUB_INDEX_COST_EXPONENT].runtimeType}");
    return list[ProcessContractGetIdx.SUB_INDEX_COST_EXPONENT].toInt();
  }
}

/// Converts [ProcessData] to a serializable json string.
parseJsonFields(String jsonString) {
  final jsonData = json.decode(jsonString);
  if (jsonData[ProcessContractGetIdx.ENTITY_ADDRESS] is String) {
    jsonData[ProcessContractGetIdx.ENTITY_ADDRESS] =
        EthereumAddress.fromHex(jsonData[ProcessContractGetIdx.ENTITY_ADDRESS]);
  }
  decodeBigInt(jsonData, ProcessContractGetIdx.STATUS);
  decodeBigInt(jsonData, ProcessContractGetIdx.EVM_BLOCK_HEIGHT);
  decodeBigInt(jsonData, ProcessContractGetIdx.MODE_ENVELOPE_TYPE_CENSUS_ORIGIN,
      idx2: ProcessContractGetIdx.SUB_INDEX_MODE);
  decodeBigInt(jsonData, ProcessContractGetIdx.MODE_ENVELOPE_TYPE_CENSUS_ORIGIN,
      idx2: ProcessContractGetIdx.SUB_INDEX_ENVELOPE_TYPE);
  decodeBigInt(jsonData, ProcessContractGetIdx.MODE_ENVELOPE_TYPE_CENSUS_ORIGIN,
      idx2: ProcessContractGetIdx.SUB_INDEX_CENSUS_ORIGIN);
  decodeBigInt(jsonData, ProcessContractGetIdx.START_BLOCK_BLOCK_COUNT,
      idx2: ProcessContractGetIdx.SUB_INDEX_START_BLOCK);
  decodeBigInt(jsonData, ProcessContractGetIdx.START_BLOCK_BLOCK_COUNT,
      idx2: ProcessContractGetIdx.SUB_INDEX_BLOCK_COUNT);
  decodeBigInt(
      jsonData,
      ProcessContractGetIdx
          .QUESTION_INDEX_QUESTION_COUNT_MAX_COUNT_MAX_VALUE_MAX_VOTE_OVERWRITES,
      idx2: ProcessContractGetIdx.SUB_INDEX_QUESTION_INDEX);
  decodeBigInt(
      jsonData,
      ProcessContractGetIdx
          .QUESTION_INDEX_QUESTION_COUNT_MAX_COUNT_MAX_VALUE_MAX_VOTE_OVERWRITES,
      idx2: ProcessContractGetIdx.SUB_INDEX_QUESTION_COUNT);
  decodeBigInt(
      jsonData,
      ProcessContractGetIdx
          .QUESTION_INDEX_QUESTION_COUNT_MAX_COUNT_MAX_VALUE_MAX_VOTE_OVERWRITES,
      idx2: ProcessContractGetIdx.SUB_INDEX_MAX_COUNT);
  decodeBigInt(
      jsonData,
      ProcessContractGetIdx
          .QUESTION_INDEX_QUESTION_COUNT_MAX_COUNT_MAX_VALUE_MAX_VOTE_OVERWRITES,
      idx2: ProcessContractGetIdx.SUB_INDEX_MAX_VALUE);
  decodeBigInt(
      jsonData,
      ProcessContractGetIdx
          .QUESTION_INDEX_QUESTION_COUNT_MAX_COUNT_MAX_VALUE_MAX_VOTE_OVERWRITES,
      idx2: ProcessContractGetIdx.SUB_INDEX_MAX_VOTE_OVERWRITES);
  decodeBigInt(jsonData, ProcessContractGetIdx.MAX_TOTAL_COST_COST_EXPONENT,
      idx2: ProcessContractGetIdx.SUB_INDEX_MAX_TOTAL_COST);
  decodeBigInt(jsonData, ProcessContractGetIdx.MAX_TOTAL_COST_COST_EXPONENT,
      idx2: ProcessContractGetIdx.SUB_INDEX_COST_EXPONENT);
  return jsonData;
}

/// Decodes a [BigInt] from a [string] at [idx1] and [idx2] of [jsonData].
void decodeBigInt(dynamic jsonData, int idx1, {int idx2}) {
  if (idx2 == null) {
    jsonData[idx1] = BigInt.tryParse(jsonData[idx1]);
    return;
  }
  jsonData[idx1][idx2] = BigInt.tryParse(jsonData[idx1][idx2]);
}

// HANDLERS

/// Fetch the metadata for the given Process ID.
Future<ProcessMetadata> getProcessMetadata(String processId, GatewayPool gw,
    {ProcessData data}) async {
  try {
    // If data param exists, start with future of this value. Otherwise get ProcessData
    if (data == null) data = await getProcess(processId, gw);
    if (data.metadata is! String) return null;
    final ipfsUri = ContentURI(data.metadata);
    final strMetadata = await fetchFileString(ipfsUri, gw);
    return parseProcessMetadata(strMetadata);
  } catch (err) {
    print("ERROR Parsing Process metadata: $err");
    return null;
  }
}

/// Fetch the Process from the contract.
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

/// Returns number of existing blocks in the blockchain.
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

/// Fetches the digested results of a process, using [meta] and [processData] if provided.
Future<ProcessResultsDigested> getResultsDigest(
    String processId, GatewayPool gw,
    {ProcessMetadata meta, ProcessData processData}) async {
  if (gw == null || processId == "") throw Exception("Invalid parameters");
  final pid = processId.startsWith("0x") ? processId : "0x" + processId;
  try {
    if (processData == null) {
      processData = await getProcess(processId, gw);
    }
    // Enable option to pass-in metadata, otherwise call metadata api
    if (meta == null) {
      meta = await getProcessMetadata(pid, gw, data: processData);
    }
    final processMetadata = meta;
    final currentBlock = await getBlockHeight(gw);

    // If process hasn't started yet, throw exception
    if (currentBlock < processData.startBlock) {
      return null; // No results yet
    }
    final rawResults = await getRawResults(pid, gw);
    if (processMetadata.questions?.isEmpty ?? true) {
      return ProcessResultsDigested(rawResults.state, rawResults.type);
    }
    if (processMetadata == null) {
      throw Exception("Process Metadata is empty");
    }

    if (processData.envelopeType.hasEncryptedVotes) {
      final endBlock = processData.startBlock + processData.blockCount;
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

    if (processMetadata.results.aggregation == "index-weighted")
      return parseProcessResultsDigestedSingleQuestion(
          rawResults, processMetadata, processData);
    // default to multi question
    else
      return parseProcessResultsDigestedMultiQuestion(
          rawResults, processMetadata, processData);
  } catch (err) {
    throw Exception("The results could not be digested: $err");
  }
}

/// Returns number of existing blocks in the blockchain.
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

/// Returns number of existing blocks in the blockchain.
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

/// Returns number of existing envelopes in the process.
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

/// Returns the status of an already submited vote envelope.
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

/// Computes the user ethereum address from their pubkey for some specific entity.
String getUserAddressFromPubKey(String pubKey) {
  final hexPubKey = hex.decode(pubKey.replaceAll("0x", ""));
  Uint8List publicKeyBytes = decompressPublicKey(hexPubKey);

  // If decompress appends 04, remove this byte
  if (publicKeyBytes.length > 64 && publicKeyBytes.first == 4)
    publicKeyBytes = publicKeyBytes.sublist(1);

  final addrBytes = publicKeyToAddress(publicKeyBytes);
  return EthereumAddress(addrBytes).hexEip55;
}

/// Checks if two pubkeys are equal, normalizing for compression & prefixes.
bool pubKeysAreEqual(String key1, String key2) {
  // Ensure both pubkeys are compressed
  if (key1.startsWith("0x04"))
    key1 =
        hex.encode(compressPublicKey(hex.decode(key1.replaceFirst("0x", ""))));
  if (key2.startsWith("0x04"))
    key2 =
        hex.encode(compressPublicKey(hex.decode(key2.replaceFirst("0x", ""))));
  key1 = key1.replaceAll("0x", "");
  key2 = key2.replaceAll("0x", "");
  return key1 == key2;
}

/// Computes the nullifier of the user's vote within a voting process.
/// Returns a hex string with kecak256(bytes(address) + bytes(processId)).
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
/// @see estimateBlockAtDateTime (date, gateway).
/// @see estimateDateAtBlock (blockNumber, gateway).
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

/// Returns the block number that is expected to be current at the given [targetDate].
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

/// Returns the DateTime at which the given block number is expected to be mined.
/// @param blockNumber.
/// @param gateway.
/// @param status.
Future<DateTime> estimateDateAtBlock(int blockNumber, GatewayPool gw,
    {BlockStatus status}) async {
  if (!(blockNumber is int)) return null;

  if (status == null) {
    status = await getBlockStatus(gw);
  }

  return estimateDateAtBlockSync(blockNumber, status);
}

/// Returns the DateTime at which the given block number is expected to be mined, given a BlockStatus.
/// @param blockNumber.
/// @param status.
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

/// Submit a raw transaction (SignedTx) to the gateway.
Future<void> submitRawTx(List<int> package, GatewayPool gw) async {
  if (gw is! GatewayPool) throw Exception("Invalid parameters");
  if ((package.length ?? 0) == 0) throw Exception("Invalid parameters");

  try {
    Map<String, dynamic> reqParams = {
      "method": "submitRawTx",
      "payload": base64.encode(package),
    };
    Map<String, dynamic> response = await gw.sendRequest(reqParams);
    if (!(response is Map)) {
      throw Exception("Invalid response received from the gateway");
    }
  } catch (err) {
    throw err;
  }
}

/// (Not implemented) Packages an anonymous vote envelope.
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

/// Packages and signes a vote transaction.
Future<SignedTx> packageVoteTx(
    VoteEnvelope voteEnvelope, String signingPrivateKey) async {
  if (signingPrivateKey is! String) throw Exception("Invalid parameters");
  final transaction = Tx(vote: voteEnvelope);
  final txBytes = transaction.writeToBuffer();
  final signature = await BytesSignature.signBytesPayloadAsync(
      txBytes, signingPrivateKey.replaceAll("0x", ""));
  return SignedTx(
      tx: txBytes, signature: hex.decode(signature.replaceAll("0x", "")));
}

/// packages a vote envelope.
Future<VoteEnvelope> packageEnvelope(List<int> votes, String merkleProof,
    String processId, ProcessCensusOrigin censusOrigin,
    {ProcessKeys processKeys}) async {
  if (!(votes is List) || !(processId is String) || !(merkleProof is String))
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
    final envelope = VoteEnvelope.create();
    final proof = Proof();
    if (!(censusOrigin.isOffChain || censusOrigin.isOffChainWeighted)) {
      throw UnimplementedError(
          "On-chain and CA voting not supported yet in-app");
    } else {
      // Off-chain census origin:
      final gravitron = ProofGraviton();
      // set proof
      gravitron.siblings = hex.decode(merkleProof.replaceFirst("0x", ""));
      proof.graviton = gravitron;
    }

    // All census origins
    final nonce = makeRandomNonce(32);
    envelope.proof = proof;
    envelope.processId =
        Uint8List.fromList(hex.decode(processId.replaceAll("0x", "")));
    envelope.nonce = hex.decode(nonce);

    final packageValues =
        await packageVoteContent(votes, processKeys: processKeys);

    envelope.votePackage = packageValues["votePackage"];

    if (packageValues["keyIndexes"] is List &&
        packageValues["keyIndexes"].length > 0) {
      envelope.encryptionKeyIndexes.insertAll(0, packageValues["keyIndexes"]);
    }

    return envelope;
  } catch (error) {
    throw Exception("Poll vote Envelope could not be generated: $error");
  }
}

// ////////////////////////////////////////////////////////////////////////////
// / Internal helpers
// ////////////////////////////////////////////////////////////////////////////

/// Packages the vote and returns `{ votePackage: "..." }` on non-encrypted polls and.
/// `{ votePackage: "...", keyIndexes: [0, 1, 2, 3, 4] }` on encrypted polls.
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

  VotePackage package = VotePackage();
  package.nonce = nonce;
  package.votes = votes;

  final strPayload = jsonEncode(package.toJSON());

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
    return {"votePackage": result, "keyIndexes": publicKeysIdx};
  } else {
    return {"votePackage": utf8.encode(strPayload)};
  }
}

// HELPERS

/// Turns [{idx:1, key: "1234"}, ...] into [ProcessKey(...), .].
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

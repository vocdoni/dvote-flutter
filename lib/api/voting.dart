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
import "./entity.dart";
import '../models/build/dart/metadata/entity.pb.dart';
import '../models/build/dart/metadata/process.pb.dart';
import '../util/json-signature.dart';
import '../constants.dart';

// ENUMS AND WRAPPERS

// class ProcessEnvelopeType {
//   final int type;
//   ProcessEnvelopeType(this.type);

//   static const REALTIME_POLL = 0;
//   static const PETITION_SIGNING = 1;
//   static const ENCRYPTED_POLL = 4;
//   static const ENCRYPTED_PRIVATE_POLL = 6;
//   static const REALTIME_ELECTION = 8;
//   static const PRIVATE_ELECTION = 10;
//   static const ELECTION = 12;
//   static const REALTIME_PRIVATE_ELECTION = 14;

//   bool isRealtimePoll() => type == ProcessEnvelopeType.REALTIME_POLL;
//   bool isPetitionSigning() => type == ProcessEnvelopeType.PETITION_SIGNING;
//   bool isEncryptedPoll() => type == ProcessEnvelopeType.ENCRYPTED_POLL;
//   bool isEncryptedPrivatePoll() =>
//       type == ProcessEnvelopeType.ENCRYPTED_PRIVATE_POLL;
//   bool isRealtimeElection() => type == ProcessEnvelopeType.REALTIME_ELECTION;
//   bool isPrivateElection() => type == ProcessEnvelopeType.PRIVATE_ELECTION;
//   bool isElection() => type == ProcessEnvelopeType.ELECTION;
//   bool isRealtimePrivateElection() =>
//       type == ProcessEnvelopeType.REALTIME_PRIVATE_ELECTION;

//   bool isRealtime() =>
//       type == ProcessEnvelopeType.REALTIME_POLL ||
//       type == ProcessEnvelopeType.REALTIME_ELECTION ||
//       type == ProcessEnvelopeType.REALTIME_PRIVATE_ELECTION;
// }

// class ProcessMode {
//   final int mode;
//   ProcessMode(this.mode);

//   static const SCHEDULED_SINGLE_ENVELOPE = 0;
//   static const ON_DEMAND_SINGLE_ENVELOPE = 1;

//   bool isScheduled() => mode == ProcessMode.SCHEDULED_SINGLE_ENVELOPE;
//   bool isOnDemand() => mode == ProcessMode.ON_DEMAND_SINGLE_ENVELOPE;
//   bool isSingleEnvelope() =>
//       mode == ProcessMode.SCHEDULED_SINGLE_ENVELOPE ||
//       mode == ProcessMode.ON_DEMAND_SINGLE_ENVELOPE;
// }

// class ProcessStatus {
//   final int status;
//   ProcessStatus(this.status);

//   static const OPEN = 0;
//   static const ENDED = 1;
//   static const CANCELED = 2;
//   static const PAUSED = 3;

//   bool isOpen() => status == ProcessStatus.OPEN;
//   bool isEnded() => status == ProcessStatus.ENDED;
//   bool isCanceled() => status == ProcessStatus.CANCELED;
//   bool isPaused() => status == ProcessStatus.PAUSED;
// }

class ProcessContractGetResultIdx {
  // static const ENVELOPE_TYPE = 0; // See EnvelopeTypes above
  // static const PROCESS_MODE = 1; // See ProcessModes above
  // static const ENTITY_ADDRESS = 2;
  // static const START_BLOCK = 3;
  // static const NUMBER_OF_BLOCKS = 4;
  // static const METADATA_CONTENT_URI = 5;
  // static const MERKLE_ROOT = 6;
  // static const MERKLE_TREE_CONTENT_URI = 7;
  // static const PROCESS_STATUS = 8; // See ProcessStatus above

  // TODO: Use the fields above
  static const PROCESS_TYPE = 0;
  static const ENTITY_ADDRESS = 1;
  static const START_BLOCK = 2;
  static const NUMBER_OF_BLOCKS = 3;
  static const METADATA_CONTENT_URI = 4;
  static const MERKLE_ROOT = 5;
  static const MERKLE_TREE_CONTENT_URI = 6;
  static const ENCRYPTION_PRIVATE_KEY = 7;
  static const CANCELED = 8;
}

class BlockStatus {
  int blockNumber;
  int blockTimestamp;
  List<int> averageBlockTimes;
  BlockStatus(this.blockNumber, this.blockTimestamp, this.averageBlockTimes);
}

// HANDLERS

/// Fetch both the active and ended voting processes of an Entity
Future<List<ProcessMetadata>> fetchAllProcesses(
    EntityReference entityRef, GatewayPool gw) async {
  try {
    final entity = await fetchEntity(entityRef, gw);

    final List<String> processes = entity.votingProcesses?.active ?? [];
    processes.addAll(entity.votingProcesses?.ended ?? []);

    return getProcessesMetadata(processes, gw);
  } catch (err) {
    throw Exception("The voting processes can't be retrieved");
  }
}

/// Fetch the active voting processes of an Entity
Future<List<ProcessMetadata>> fetchActiveProcesses(
    EntityReference entityRef, GatewayPool gw) async {
  try {
    final entity = await fetchEntity(entityRef, gw);

    final List<String> processes = entity.votingProcesses?.active ?? [];

    return getProcessesMetadata(processes, gw);
  } catch (err) {
    throw Exception("The active voting processes can't be retrieved");
  }
}

/// Fetch the ended voting processes of an Entity
Future<List<ProcessMetadata>> fetchEndedProcesses(
    EntityReference entityRef, GatewayPool gw) async {
  try {
    final entity = await fetchEntity(entityRef, gw);

    final List<String> processes = entity.votingProcesses?.ended ?? [];

    return getProcessesMetadata(processes, gw);
  } catch (err) {
    throw Exception("The active voting processes can't be retrieved");
  }
}

/// Fetch the metadata for the given Process ID
Future<ProcessMetadata> getProcessMetadata(String processId, GatewayPool gw) {
  return getProcessesMetadata([processId], gw).then((result) {
    if (result is List && result.length > 0)
      return result[0];
    else
      return null;
  });
}

/// Fetch the metadata for the given Process ID's
Future<List<ProcessMetadata>> getProcessesMetadata(
    List<String> processIds, GatewayPool gw) {
  return Future.wait(processIds.map((strProcessId) async {
    try {
      final processId = hex.decode(strProcessId.substring(2));
      final processData =
          await gw.callMethod("get", [processId], ContractEnum.Process);

      if (!(processData is List) ||
          !(processData[ProcessContractGetResultIdx.METADATA_CONTENT_URI]
              is String)) return null;
      // // TODO: USE PROCESS_STATUS INSTEAD OF CANCELED
      // else if (processData[ProcessContractGetResultIdx.CANCELED] is bool &&
      //     processData[ProcessContractGetResultIdx.CANCELED] == true)
      //   return null;
      // else if (processData[ProcessContractGetResultIdx.PROCESS_STATUS] is int &&
      //     processData[ProcessContractGetResultIdx.PROCESS_STATUS] ==
      //         ProcessStatus.CANCELED) return null;

      final metadataUri = ContentURI(
          processData[ProcessContractGetResultIdx.METADATA_CONTENT_URI]);
      final String strMetadata = await fetchFileString(metadataUri, gw);

      return parseProcessMetadata(strMetadata);
    } catch (err) {
      print("ERROR Fetching Process metadata: $err");
      return null;
    }
  })).then((result) => result.whereType<ProcessMetadata>().toList());
}

// TODO: UNCOMMENT
// /// Fetch the envelope type defined for the given Process ID
// Future<ProcessEnvelopeType> getProcessEnvelopeType(
//     String processId, GatewayPool gw) async {
//   try {
//     final pid = hex.decode(processId.substring(2));
//     final processData =
//         await callVotingProcessMethod(web3Gw.rpcUri, "get", [pid]);

//     if (processData[ProcessContractGetResultIdx.ENVELOPE_TYPE] is int)
//       return ProcessEnvelopeType(
//           processData[ProcessContractGetResultIdx.ENVELOPE_TYPE]);
//     return null;
//   } catch (err) {
//     if (kReleaseMode) print("ERROR Fetching Process metadata: $err");
//     return null;
//   }
// }

// TODO: UNCOMMENT
// /// Fetch the mode defined for the given Process ID
// Future<ProcessMode> getProcessMode(String processId, GatewayPool gw) async {
//   try {
//     final pid = hex.decode(processId.substring(2));
//     final processData =
//         await callVotingProcessMethod(web3Gw.rpcUri, "get", [pid]);

//     if (processData[ProcessContractGetResultIdx.PROCESS_MODE] is int)
//       return ProcessMode(processData[ProcessContractGetResultIdx.PROCESS_MODE]);
//     return null;
//   } catch (err) {
//     if (kReleaseMode) print("ERROR Fetching Process metadata: $err");
//     return null;
//   }
// }

// TODO: UNCOMMENT
// /// Fetch the status for the given Process ID
// Future<ProcessStatus> getProcessStatus(
//     String processId, GatewayPool gw) async {
//   try {
//     final pid = hex.decode(processId.substring(2));
//     final processData =
//         await callVotingProcessMethod(web3Gw.rpcUri, "get", [pid]);

//     if (processData[ProcessContractGetResultIdx.PROCESS_STATUS] is int)
//       return ProcessStatus(
//           processData[ProcessContractGetResultIdx.PROCESS_STATUS]);
//     return null;
//   } catch (err) {
//     if (kReleaseMode) print("ERROR Fetching Process metadata: $err");
//     return null;
//   }
// }

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
Future<DateTime> estimateDateAtBlock(int blockNumber, GatewayPool gw,
    {BlockStatus status}) async {
  if (!(blockNumber is int)) return null;

  if (status == null) {
    status = await getBlockStatus(gw);
  }

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

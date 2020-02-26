import 'dart:convert';
import 'dart:math';
import 'package:convert/convert.dart';
import 'package:dvote/dvote.dart';
import 'package:dvote/util/parsers.dart';
import 'package:flutter/foundation.dart';
import 'package:web3dart/crypto.dart';
import 'dart:typed_data';

import '../net/gateway.dart';
import "./entity.dart";
import "../blockchain/index.dart";
import '../models/dart/entity.pb.dart';
import '../models/dart/process.pb.dart';
import '../util/json-signature.dart';
import '../constants.dart';

enum ProcessContractGetResultIdx {
  PROCESS_TYPE,
  ENTITY_ADDRESS,
  START_BLOCK,
  NUMBER_OF_BLOCKS,
  METADATA_CONTENT_URI,
  MERKLE_ROOT,
  MERKLE_TREE_CONTENT_URI,
  ENCRYPTION_PRIVATE_KEY,
  CANCELED
}

var _random = Random.secure();

/// Fetch both the active and ended voting processes of an Entity
Future<List<ProcessMetadata>> fetchAllProcesses(
    EntityReference entityRef, DVoteGateway dvoteGw, Web3Gateway web3Gw) async {
  try {
    final entity = await fetchEntity(entityRef, dvoteGw, web3Gw);

    final List<String> processes = entity.votingProcesses?.active ?? [];
    processes.addAll(entity.votingProcesses?.ended ?? []);

    return getProcessesMetadata(processes, dvoteGw, web3Gw);
  } catch (err) {
    throw Exception("The voting processes can't be retrieved");
  }
}

/// Fetch the active voting processes of an Entity
Future<List<ProcessMetadata>> fetchActiveProcesses(
    EntityReference entityRef, DVoteGateway dvoteGw, Web3Gateway web3Gw) async {
  try {
    final entity = await fetchEntity(entityRef, dvoteGw, web3Gw);

    final List<String> processes = entity.votingProcesses?.active ?? [];

    return getProcessesMetadata(processes, dvoteGw, web3Gw);
  } catch (err) {
    throw Exception("The active voting processes can't be retrieved");
  }
}

/// Fetch the ended voting processes of an Entity
Future<List<ProcessMetadata>> fetchEndedProcesses(
    EntityReference entityRef, DVoteGateway dvoteGw, Web3Gateway web3Gw) async {
  try {
    final entity = await fetchEntity(entityRef, dvoteGw, web3Gw);

    final List<String> processes = entity.votingProcesses?.ended ?? [];

    return getProcessesMetadata(processes, dvoteGw, web3Gw);
  } catch (err) {
    throw Exception("The active voting processes can't be retrieved");
  }
}

/// Fetch the metadata for the given Process ID
Future<ProcessMetadata> getProcessMetadata(
    String processId, DVoteGateway dvoteGw, Web3Gateway web3Gw) {
  return getProcessesMetadata([processId], dvoteGw, web3Gw).then((result) {
    if (result is List && result.length > 0)
      return result[0];
    else
      throw Exception("The process metadata could not be fetched");
  });
}

/// Fetch the metadata for the given Process ID's
Future<List<ProcessMetadata>> getProcessesMetadata(
    List<String> processIds, DVoteGateway dvoteGw, Web3Gateway web3Gw) {
  return Future.wait(processIds.map((processId) async {
    try {
      final pid = hex.decode(processId.substring(2));
      final processData =
          await callVotingProcessMethod(web3Gw.rpcUri, "get", [pid]);

      if (!(processData is List) ||
          !(processData[ProcessContractGetResultIdx.METADATA_CONTENT_URI.index]
              is String))
        return null;
      else if (processData[ProcessContractGetResultIdx.CANCELED.index]
              is bool &&
          processData[ProcessContractGetResultIdx.CANCELED.index] == true)
        return null;

      final String strMetadata = await fetchFileString(
          ContentURI(processData[
              ProcessContractGetResultIdx.METADATA_CONTENT_URI.index]),
          dvoteGw);
      return parseProcessMetadata(strMetadata);
    } catch (err) {
      if (kReleaseMode) print("ERROR Fetching Process metadata: $err");
      return null;
    }
  })).then((result) => result.whereType<ProcessMetadata>().toList());
}

/// Returns number of existing blocks in the process
Future<int> getBlockHeight(DVoteGateway dvoteGw) async {
  if (dvoteGw == null) throw Exception("Invalid parameters");
  try {
    Map<String, dynamic> reqParams = {"method": "getBlockHeight"};
    Map<String, dynamic> response =
        await dvoteGw.sendRequest(reqParams, timeout: 7);
    if (!(response is Map) || !(response["height"] is int)) {
      throw Exception("Invalid response received from the gateway");
    }
    return response["height"];
  } catch (err) {
    throw Exception("The block height could not be retrieved");
  }
}

/// Returns number of existing envelopes in the process
Future<int> getEnvelopeHeight(String processId, DVoteGateway dvoteGw) async {
  if (processId == null || dvoteGw == null)
    throw Exception("Invalid parameters");
  try {
    Map<String, dynamic> reqParams = {
      "method": "getEnvelopeHeight",
      "processId": processId,
    };
    Map<String, dynamic> response =
        await dvoteGw.sendRequest(reqParams, timeout: 9);
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
    String processId, String nullifier, DVoteGateway dvoteGw) async {
  if (processId == null || nullifier == null || dvoteGw == null)
    throw Exception("Invalid parameters");
  try {
    Map<String, dynamic> reqParams = {
      "method": "getEnvelopeStatus",
      "nullifier": nullifier,
      "processId": processId,
    };
    Map<String, dynamic> response =
        await dvoteGw.sendRequest(reqParams, timeout: 20);
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
String getPollNullifier(String address, String processId) {
  address = address.replaceFirst(new RegExp(r'^0x'), '');
  processId = processId.replaceFirst(new RegExp(r'^0x'), '');

  if (address.length != 40) return null;
  if (processId.length != 64) return null;

  final addressBytes = hex.decode(address);
  final processIdBytes = hex.decode(processId);

  final hashBytes =
      keccak256(Uint8List.fromList(addressBytes + processIdBytes));

  return "0x" + hex.encode(hashBytes);
}

/// Returns estimated process remaining time in seconds
Future<int> getTimeUntilEnd(String processId, int startBlock,
    int numberOfBlocks, DVoteGateway dvoteGw) async {
  if (!(processId is String) ||
      !(startBlock is int) ||
      !(numberOfBlocks is int) ||
      !(dvoteGw is DVoteGateway)) throw Exception("Invalid parameters");
  try {
    int currentHeight = await getBlockHeight(dvoteGw);
    int remainingBlocks = (startBlock + numberOfBlocks) - currentHeight;
    if (remainingBlocks <= 0)
      return 0;
    else
      return remainingBlocks * VOCHAIN_BLOCK_TIME;
  } catch (err) {
    throw Exception("The process deadline could not be determined");
  }
}

/// Returns estimated remaining time for the process start in seconds
Future<int> getTimeUntilStart(
    String processId, int startBlock, DVoteGateway dvoteGw) async {
  if (!(processId is String) ||
      !(startBlock is int) ||
      !(dvoteGw is DVoteGateway)) throw Exception("Invalid parameters");
  try {
    int currentHeight = await getBlockHeight(dvoteGw);
    int remainingBlocks = startBlock - currentHeight;
    if (remainingBlocks <= 0)
      return 0;
    else
      return remainingBlocks * VOCHAIN_BLOCK_TIME;
  } catch (err) {
    throw Exception("The process starting time could not be determined");
  }
}

/// Submit vote Envelope to the gateway
Future<void> submitEnvelope(
    Map<String, dynamic> voteEnvelope, DVoteGateway dvoteGw) async {
  if (!(voteEnvelope is Map) || !(dvoteGw is DVoteGateway)) {
    throw Exception("Invalid parameters");
  } else if (!(voteEnvelope["processId"] is String) ||
      !(voteEnvelope["proof"] is String) ||
      !(voteEnvelope["nonce"] is String) ||
      !(voteEnvelope["vote-package"] is String) ||
      !(voteEnvelope["signature"] is String)) {
    throw Exception("Invalid parameters");
  }

  try {
    Map<String, dynamic> reqParams = {
      "method": "submitEnvelope",
      "payload": voteEnvelope
    };
    Map<String, dynamic> response = await dvoteGw.sendRequest(reqParams);
    if (!(response is Map)) {
      throw Exception("Invalid response received from the gateway");
    } else if (response["ok"] != true) {
      throw Exception("The vote envelope could not be submitted");
    }
  } catch (err) {
    throw err;
  }
}

Future<String> packageSnarkEnvelope(
    List<int> votes, String proof, String privateKey) async {
  throw Exception("unimplemented");
  // TODO: Generate hash of private key for nullifier as in Snarks
  /*
  String votePackage = packageSnarkVote(votes);
  Map<String, String>  package = {
    "processId": processId,
    "proof": proof, // ZK Proof
    "nonce": nonce, // Unique number per vote attempt, so that replay attacks can't reuse this payload
    "nullifier": "0x1234...", // Hash of the private key
    "vote-package": votePackage, // base64(jsonString) is encrypted
  };
  return jsonEncode(package);
  */
}

Future<Map<String, String>> packagePollEnvelope(List<int> votes,
    String merkleProof, String processId, String signingPrivateKey) async {
  if (!(votes is List) ||
      !(processId is String) ||
      !(merkleProof is String) ||
      !(signingPrivateKey is String)) throw Exception("Invalid parameters");

  try {
    final nonce = _generateRandomNumber(32);

    String votePackage = packagePollVote(votes);

    Map<String, String> package = {
      "processId": processId,
      "proof": merkleProof,
      "nonce":
          nonce, // Unique number per vote attempt, so that replay attacks can't reuse this payload
      "vote-package": votePackage
      //singature:  Must be unset because the body must be singed without the  signature
    };

    final signature = await signJsonPayload(package, signingPrivateKey);
    package["signature"] = signature;

    return package;
  } catch (error) {
    throw Exception("Poll vote Envelope could not be generated");
  }
}

// ////////////////////////////////////////////////////////////////////////////
// / Internal helpers
// ////////////////////////////////////////////////////////////////////////////

String packageSnarkVote(List<int> votes, String publicKey) {
  final nonce = _generateRandomNumber(32);

  // TODO: ENCRYPT IT WITH publicKey

  Map<String, dynamic> package = {
    "type": "snark-vote",
    "nonce":
        nonce, // random number to prevent guessing the encrypted payload before the key is revealed
    "votes": votes // Directly mapped to the `questions` field of the metadata
  };
  return base64.encode(utf8.encode(jsonEncode(package)));
}

String packagePollVote(List<int> votes) {
  final nonce = _generateRandomNumber(32);
  Map<String, dynamic> package = {
    "type": "poll-vote",
    "nonce":
        nonce, // (optional) random number to prevent guessing the encrypted payload before the key is revealed
    "votes": votes // Directly mapped to the `questions` field of the metadata
  };
  return base64.encode(utf8.encode(jsonEncode(package)));
}

String _generateRandomNumber(int digits) {
  var result = "";
  for (var i = 0; i < 6; i++) {
    result = result + _random.nextInt(9).toString();
  }
  return result;
}

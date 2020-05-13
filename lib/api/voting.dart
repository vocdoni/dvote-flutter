import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:convert/convert.dart';
import 'package:dvote/crypto/asyncify.dart';
import 'package:dvote/dvote.dart';
import 'package:dvote/util/parsers.dart';
import 'package:dvote/wrappers/process-keys.dart';
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
import 'package:dvote_native/dvote_native.dart' as dvoteNative;

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

/// Returns number of existing blocks in the blockchain
Future<ProcessKeys> getProcessKeys(
    String processId, DVoteGateway dvoteGw) async {
  if (dvoteGw == null) throw Exception("Invalid parameters");
  try {
    Map<String, dynamic> reqParams = {
      "method": "getProcessKeys",
      "processId": processId
    };
    Map<String, dynamic> response =
        await dvoteGw.sendRequest(reqParams, timeout: 7);
    if (!(response is Map)) {
      throw Exception("Invalid response received from the gateway");
    }

    ProcessKeys keys = ProcessKeys();
    if (response["encryptionPubKeys"] is List &&
        response["encryptionPubKeys"].length > 0)
      keys.encryptionPubKeys = response["encryptionPubKeys"];
    if (response["encryptionPrivKeys"] is List &&
        response["encryptionPrivKeys"].length > 0)
      keys.encryptionPrivKeys = response["encryptionPrivKeys"];
    if (response["commitmentKeys"] is List &&
        response["commitmentKeys"].length > 0)
      keys.commitmentKeys = response["commitmentKeys"];
    if (response["revealKeys"] is List && response["revealKeys"].length > 0)
      keys.revealKeys = response["revealKeys"];
    return keys;
  } catch (err) {
    throw Exception("The process encryption keys could not be retrieved");
  }
}

/// Returns number of existing blocks in the blockchain
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
Future<String> getPollNullifier(String address, String processId) {
  address = address.replaceFirst(new RegExp(r'^0x'), '');
  processId = processId.replaceFirst(new RegExp(r'^0x'), '');

  if (address.length != 40) return Future.value(null);
  if (processId.length != 64) return Future.value(null);

  return wrap2ParamFunc<String, String, String>(
      _getPollNullifier, address, processId);
}

// internal wrapped function to run the hash computation out of the UI thread
String _getPollNullifier(List<dynamic> args) {
  assert(args.length == 2);
  final address = args[0];
  assert(address is String);
  final processId = args[1];
  assert(processId is String);

  final addressBytes = hex.decode(address);
  final processIdBytes = hex.decode(processId);

  final hashBytes =
      keccak256(Uint8List.fromList(addressBytes + processIdBytes));

  return "0x" + hex.encode(hashBytes);
}

/// Returns estimated process remaining time in seconds
Future<int> getTimeUntilEnd(
    int startBlock, int numberOfBlocks, DVoteGateway dvoteGw) async {
  if (!(startBlock is int) ||
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
Future<int> getTimeUntilStart(int startBlock, DVoteGateway dvoteGw) async {
  if (!(startBlock is int) || !(dvoteGw is DVoteGateway))
    throw Exception("Invalid parameters");
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
      !(voteEnvelope["votePackage"] is String) ||
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
    "votePackage": votePackage, // base64(jsonString) is encrypted
  };
  return jsonEncode(package);
  */
}

Future<Map<String, dynamic>> packagePollEnvelope(List<int> votes,
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
    final nonce = _generateRandomNonce(32);

    final packageValues = packagePollVote(votes, processKeys: processKeys);

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

    final signature = await signJsonPayloadAsync(package, signingPrivateKey);
    package["signature"] = signature;

    return package;
  } catch (error) {
    throw Exception("Poll vote Envelope could not be generated");
  }
}

/// Returns a zero-knowledge proof computed on the given circuit inputs
/// using the given proving key path. The proving key file needs to be accessible
/// on the filesystem.
Future<String> generateZkProof(
    Map<String, dynamic> circuitInputs, String provingKeyPath) async {
  final fd = File(provingKeyPath);
  if (!(await fd.exists())) {
    throw Exception("The proving key does not exist");
  }

  return wrap2ParamFunc<String, Map<String, dynamic>, String>(
      _generateZkProof, circuitInputs, provingKeyPath);
}

String _generateZkProof(List<dynamic> args) {
  if (!(args is List) || args.length != 2)
    throw Exception("The function expects a list of two arguments");
  else if (!(args[0] is Map))
    throw Exception(
        "The first argument has to be a Map with the circuit inputs");
  else if (!(args[1] is String))
    throw Exception("The second argument has to be a String with a path");

  final Map<String, dynamic> circuitInputs = args[0];
  final String provingKeyPath = args[1];
  return dvoteNative.generateZkProof(circuitInputs, provingKeyPath);
}

// ////////////////////////////////////////////////////////////////////////////
// / Internal helpers
// ////////////////////////////////////////////////////////////////////////////

String packageSnarkVote(List<int> votes, String publicKey) {
  final nonce = _generateRandomNonce(16);

  // TODO: ENCRYPT IT WITH publicKey

  Map<String, dynamic> package = {
    "type": "snark-vote",
    "nonce":
        nonce, // random number to prevent guessing the encrypted payload before the key is revealed
    "votes": votes // Directly mapped to the `questions` field of the metadata
  };
  return base64.encode(utf8.encode(jsonEncode(package)));
}

/// Packages the vote and returns `{ votePackage: "..." }` on non-encrypted polls and
/// `{ votePackage: "...", keyIndexes: [0, 1, 2, 3, 4] }` on encrypted polls
Map<String, dynamic> packagePollVote(List<int> votes,
    {ProcessKeys processKeys}) {
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

  final nonce = _generateRandomNonce(16);

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

    String result;
    for (int i = 0; i < publicKeys.length; i++) {
      if (i > 0)
        result =
            Asymmetric.encryptString(result, publicKeys[i]); // reencrypt result
      else
        result = Asymmetric.encryptString(
            strPayload, publicKeys[i]); // encrypt the first round
    }
    return {"votePackage": result, "keyIndexes": publicKeysIdx};
  } else {
    return {"votePackage": base64.encode(utf8.encode(strPayload))};
  }
}

// HELPERS

String _generateRandomNonce(int length) {
  final digits = [
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    'a',
    'b',
    'c',
    'd',
    'e',
    'f'
  ];
  var result = "";
  for (var i = 0; i < length; i++) {
    result = result + digits[_random.nextInt(digits.length)];
  }
  return result;
}

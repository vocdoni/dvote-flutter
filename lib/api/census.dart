import 'dart:developer';

import 'package:dvote/net/gateway-pool.dart';

/// Fetch the Proof that proves that the given claim is part
/// of the Census Tree with the given Root Hash.
Future<String> generateProof(
    String censusRoot, String censusKey, bool isDigested, GatewayPool gw,
    {BigInt censusValue}) async {
  if (!(censusRoot is String) || !(censusKey is String))
    throw Exception('Invalid parameters');
  if (censusValue == null) censusValue = BigInt.zero;
  try {
    Map<String, dynamic> reqParams = {
      "method": "genProof",
      "censusId": censusRoot,
      "digested": isDigested,
      "censuskey": censusKey,
      "censusValue": censusValue.toRadixString(8).padLeft(2, "0"),
    };
    final response = await gw.sendRequest(reqParams, timeout: 20);
    if (!(response is Map)) {
      throw Exception("Invalid response received from the gateway");
    }
    return (response["siblings"] is String) ? response["siblings"] : null;
  } on Exception catch (err) {
    log(err.toString());
    if (err.toString() == "Exception: censusId not valid or not found")
      throw err;
    throw Exception("The claim proof could not be obtained");
  }
}

/// Determine whether the Merkle Proof is valid for the given claim.
Future<bool> checkProof(String censusMerkleRootHash, String base64Claim,
    bool isDigested, String proofData, GatewayPool gw,
    {BigInt censusValue}) async {
  if (!(censusMerkleRootHash is String) || !(base64Claim is String))
    throw Exception('Invalid parameters');
  if (censusValue == null) censusValue = BigInt.zero;
  try {
    Map<String, dynamic> reqParams = {
      "method": "checkProof",
      "censusId": censusMerkleRootHash,
      "censusKey": base64Claim,
      "censusValue": censusValue.toRadixString(8).padLeft(2, "0"),
      "proofData": proofData,
      "digested": isDigested,
    };
    final response = await gw.sendRequest(reqParams, timeout: 12);
    if (!(response is Map) || !(response["validProof"] is bool)) {
      throw Exception("Invalid response received from the gateway");
    }
    return response["validProof"] == true;
  } on Exception catch (err) {
    log(err.toString());
    if (err.toString() == "Exception: censusId not valid or not found")
      throw err;
    throw Exception("The claim proof could not be checked");
  }
}

/// Get the number of people in the census with the given Merkle Root Hash.
Future<int> getCensusSize(String censusMerkleRootHash, GatewayPool gw) async {
  if (!(censusMerkleRootHash is String) || !(gw is GatewayPool))
    throw Exception('Invalid parameters');
  try {
    Map<String, dynamic> reqParams = {
      "method": "getSize",
      "censusId": censusMerkleRootHash
    };
    Map<String, dynamic> response =
        await gw.sendRequest(reqParams, timeout: 12);
    if (!(response is Map) || !(response["size"] is int)) {
      throw Exception("Invalid response received from the gateway");
    }
    return response["size"];
  } catch (err) {
    throw Exception("The census size could not be retrieved");
  }
}

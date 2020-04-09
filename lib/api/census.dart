import 'package:dvote/crypto/asyncify.dart';
import 'package:dvote/dvote.dart';
import 'package:dvote/util/dev.dart';
import '../net/gateway.dart';
import 'package:dvote_native/dvote_native.dart' as dvoteNative;

/// Returns the Poseidon hash of the given hex ECDSA public key.
/// The result is provided in base64
Future<String> digestHexClaim(String hexPublicKey) {
  if (!(hexPublicKey is String) || hexPublicKey.length == 0)
    throw Exception("The payload is empty");

  return wrap1ParamFunc<String, String>(
      dvoteNative.digestHexClaim, hexPublicKey);
}

/// Fetch the Merkle Proof that proves that the given claim is part
/// of the Census Merkle Tree with the given Root Hash
Future<String> generateProof(String censusMerkleRootHash, String base64Claim,
    bool isDigested, DVoteGateway dvoteGw) async {
  if (!(censusMerkleRootHash is String) || !(base64Claim is String))
    throw Exception('Invalid parameters');
  try {
    Map<String, dynamic> reqParams = {
      "method": "genProof",
      "censusId": censusMerkleRootHash,
      "digested": isDigested,
      "claimData": base64Claim,
    };
    final response = await dvoteGw.sendRequest(reqParams, timeout: 20);
    if (!(response is Map) || response["ok"] != true) {
      throw Exception("Invalid response received from the gateway");
    }
    return (response["siblings"] is String) ? response["siblings"] : null;
  } on Exception catch (err) {
    devPrint(err);
    if (err.toString() == "Exception: censusId not valid or not found")
      throw err;
    throw Exception("The claim proof could not be obtained");
  }
}

/// Determine whether the Merkle Proof is valid for the given claim
Future<bool> checkProof(String censusMerkleRootHash, String base64Claim,
    bool isDigested, String proofData, DVoteGateway dvoteGw) async {
  if (!(censusMerkleRootHash is String) || !(base64Claim is String))
    throw Exception('Invalid parameters');
  try {
    Map<String, dynamic> reqParams = {
      "method": "checkProof",
      "censusId": censusMerkleRootHash,
      "digested": isDigested,
      "claimData": base64Claim,
      "proofData": proofData
    };
    final response = await dvoteGw.sendRequest(reqParams, timeout: 12);
    if (!(response is Map) ||
        response["ok"] != true ||
        !(response["validProof"] is bool)) {
      throw Exception("Invalid response received from the gateway");
    }
    return response["validProof"] == true;
  } on Exception catch (err) {
    devPrint(err);
    if (err.toString() == "Exception: censusId not valid or not found")
      throw err;
    throw Exception("The claim proof could not be checked");
  }
}

/// Get the number of people in the census with the given Merkle Root Hash
Future<int> getCensusSize(
    String censusMerkleRootHash, DVoteGateway dvoteGw) async {
  if (!(censusMerkleRootHash is String) || !(dvoteGw is DVoteGateway))
    throw Exception('Invalid parameters');
  try {
    Map<String, dynamic> reqParams = {
      "method": "getSize",
      "censusId": censusMerkleRootHash
    };
    Map<String, dynamic> response =
        await dvoteGw.sendRequest(reqParams, timeout: 12);
    if (!(response is Map) || !(response["size"] is int)) {
      throw Exception("Invalid response received from the gateway");
    }
    return response["size"];
  } catch (err) {
    throw Exception("The census size could not be retrieved");
  }
}

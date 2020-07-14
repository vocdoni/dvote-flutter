import 'dart:convert';
import '../crypto/signature.dart';

/// Sign the given body using privateKey. Returns an hex-encoded string with the signature.
String signJsonPayload(Map<String, dynamic> body, String privateKey,
    {int chainId}) {
  final strBody = serializeJsonBody(body);

  return signString(strBody, privateKey, chainId: chainId);
}

/// Sign the given body using privateKey. Returns an hex-encoded string with the signature.
Future<String> signJsonPayloadAsync(
    Map<String, dynamic> body, String privateKey,
    {int chainId}) {
  final strBody = serializeJsonBody(body);
  return signStringAsync(strBody, privateKey, chainId: chainId);
}

/// Recover the public key that signed the given JSON payload into the given signature
String recoverJsonSignerPubKey(String signature, Map<String, dynamic> body,
    {int chainId}) {
  if (signature == null || body == null) throw Exception("Invalid parameters");

  final strBody = serializeJsonBody(body);
  return recoverSignerPubKey(signature, strBody, chainId: chainId);
}

/// Recover the public key that signed the given JSON payload into the given signature
Future<String> recoverJsonSignerPubKeyAsync(
    String signature, Map<String, dynamic> body,
    {int chainId}) {
  if (signature == null || body == null) throw Exception("Invalid parameters");

  final strBody = serializeJsonBody(body);
  return recoverSignerPubKeyAsync(signature, strBody, chainId: chainId);
}

/// Check whether the given signature matches the given body and publicKey.
/// Returns true if no publicKey is given
bool isValidJsonSignature(
    String signature, Map<String, dynamic> body, String publicKey,
    {int chainId}) {
  if (signature == null || body == null)
    throw Exception("Invalid parameters");
  else if (publicKey == null || publicKey == "") return true;

  final strBody = serializeJsonBody(body);
  return isValidSignature(signature, strBody, publicKey, chainId: chainId);
}

/// Check whether the given signature matches the given body and publicKey.
/// Returns true if no publicKey is given
Future<bool> isValidJsonSignatureAsync(
    String signature, Map<String, dynamic> body, String publicKey,
    {int chainId}) {
  if (signature == null || body == null)
    throw Exception("Invalid parameters");
  else if (publicKey == null || publicKey == "") return Future.value(true);

  final strBody = serializeJsonBody(body);
  return isValidSignatureAsync(signature, strBody, publicKey, chainId: chainId);
}

////////////////////////////////////////////////////////////////////////////////
// HELPERS
////////////////////////////////////////////////////////////////////////////////

/// Returns a serialized, reproduceable string from the JSON body, used to compute signatures
String serializeJsonBody(dynamic body) {
  // Ensure alphabetically ordered key names
  final sortedData = sortJsonFields(body);
  return jsonEncode(sortedData);
}

/// Signatures need to be computed over objects that can be 100% reproduceable.
/// Since the ordering is not guaranteed, this function returns a recursively
/// ordered map
dynamic sortJsonFields(dynamic data) {
  if (!(data is Map) && !(data is List))
    return data;
  else if (data is List) {
    return data.map((item) => sortJsonFields(item)).cast().toList();
  }

  final keys = <String>[];
  final result = Map<String, dynamic>();

  data.forEach((k, v) {
    keys.add(k);
  });
  keys.sort((String a, String b) => a.compareTo(b));
  keys.forEach((k) {
    result[k] = sortJsonFields(data[k]);
  });
  return result;
}

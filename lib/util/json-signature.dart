import 'dart:convert';
import '../crypto/signature.dart';

////////////////////////////////////////////////////////////////////////////////
// SYNC VERSION
////////////////////////////////////////////////////////////////////////////////

/// Sign the given body using privateKey. Returns an hex-encoded string with the signature.
String signJsonPayload(Map<String, dynamic> body, String privateKey,
    {int chainId}) {
  // Ensure alphabetically ordered key names
  final sortedBody = sortJsonFields(body);
  final strBody = jsonEncode(sortedBody);

  return signString(strBody, privateKey, chainId: chainId);
}

/// Recover the public key that signed the given JSON payload into the given signature
String recoverJsonSignerPubKey(String signature, Map<String, dynamic> body,
    {int chainId}) {
  if (signature == null || body == null) throw Exception("Invalid parameters");

  // Ensure alphabetically ordered key names
  final sortedBody = sortJsonFields(body);
  final strBody = jsonEncode(sortedBody);

  return recoverSignerPubKey(signature, strBody, chainId: chainId);
}

/// Check whether the given signature matches the given body and publicKey.
/// Returns true if no publicKey is given
bool isValidJsonSignature(
    String signature, Map<String, dynamic> body, String publicKey,
    {int chainId}) {
  if (signature == null || body == null)
    throw Exception("Invalid parameters");
  else if (publicKey == null || publicKey == "") return true;

  // Ensure alphabetically ordered key names
  final sortedBody = sortJsonFields(body);
  final strBody = jsonEncode(sortedBody);

  return isValidSignature(signature, strBody, publicKey, chainId: chainId);
}

////////////////////////////////////////////////////////////////////////////////
// ASYNC VERSION
////////////////////////////////////////////////////////////////////////////////

/// Sign the given body using privateKey. Returns an hex-encoded string with the signature.
Future<String> signJsonPayloadAsync(
    Map<String, dynamic> body, String privateKey,
    {int chainId}) {
  // Ensure alphabetically ordered key names
  final sortedBody = sortJsonFields(body);
  final strBody = jsonEncode(sortedBody);

  return signStringAsync(strBody, privateKey, chainId: chainId);
}

/// Recover the public key that signed the given JSON payload into the given signature
Future<String> recoverJsonSignerPubKeyAsync(
    String signature, Map<String, dynamic> body,
    {int chainId}) {
  if (signature == null || body == null) throw Exception("Invalid parameters");

  // Ensure alphabetically ordered key names
  final sortedBody = sortJsonFields(body);
  final strBody = jsonEncode(sortedBody);

  return recoverSignerPubKeyAsync(signature, strBody, chainId: chainId);
}

/// Check whether the given signature matches the given body and publicKey.
/// Returns true if no publicKey is given
Future<bool> isValidJsonSignatureAsync(
    String signature, Map<String, dynamic> body, String publicKey,
    {int chainId}) {
  if (signature == null || body == null)
    throw Exception("Invalid parameters");
  else if (publicKey == null || publicKey == "") return Future.value(true);

  // Ensure alphabetically ordered key names
  final sortedBody = sortJsonFields(body);
  final strBody = jsonEncode(sortedBody);

  return isValidSignatureAsync(signature, strBody, publicKey, chainId: chainId);
}

////////////////////////////////////////////////////////////////////////////////
// HELPERS
////////////////////////////////////////////////////////////////////////////////

/// Signatures need to be computed over objects that can be 100% reproduceable.
/// Since the ordering is not guaranteed, this function returns a recursively
/// ordered map
dynamic sortJsonFields(dynamic data) {
  if (!(data is Map)) return data;

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

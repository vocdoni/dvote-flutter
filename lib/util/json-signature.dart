import './json-content.dart';
import '../crypto/signature.dart';

class JSONSignature {
  /// Sign the given body using privateKey. Returns an hex-encoded string with the signature.
  static String signJsonPayload(Map<String, dynamic> body, String privateKey,
      {int chainId}) {
    final strBody = serializeJsonBody(body);

    return Signature.signString(strBody, privateKey, chainId: chainId);
  }

  /// Sign the given body using privateKey. Returns an hex-encoded string with the signature.
  static Future<String> signJsonPayloadAsync(
      Map<String, dynamic> body, String privateKey,
      {int chainId}) {
    final strBody = serializeJsonBody(body);
    return Signature.signStringAsync(strBody, privateKey, chainId: chainId);
  }

  /// Recover the public key that signed the given JSON payload into the given signature
  static String recoverJsonSignerPubKey(
      String signature, Map<String, dynamic> body,
      {int chainId}) {
    if (signature == null || body == null)
      throw Exception("Invalid parameters");

    final strBody = serializeJsonBody(body);
    return Signature.recoverSignerPubKey(signature, strBody, chainId: chainId);
  }

  /// Recover the public key that signed the given JSON payload into the given signature
  static Future<String> recoverJsonSignerPubKeyAsync(
      String signature, Map<String, dynamic> body,
      {int chainId}) {
    if (signature == null || body == null)
      throw Exception("Invalid parameters");

    final strBody = serializeJsonBody(body);
    return Signature.recoverSignerPubKeyAsync(signature, strBody,
        chainId: chainId);
  }

  /// Check whether the given signature matches the given body and publicKey.
  /// Returns true if no publicKey is given
  static bool isValidJsonSignature(
      String signature, Map<String, dynamic> body, String publicKey,
      {int chainId}) {
    if (signature == null || body == null)
      throw Exception("Invalid parameters");
    else if (publicKey == null || publicKey == "") return true;

    final strBody = serializeJsonBody(body);
    return Signature.isValidSignature(signature, strBody, publicKey,
        chainId: chainId);
  }

  /// Check whether the given signature matches the given body and publicKey.
  /// Returns true if no publicKey is given
  static Future<bool> isValidJsonSignatureAsync(
      String signature, Map<String, dynamic> body, String publicKey,
      {int chainId}) {
    if (signature == null || body == null)
      throw Exception("Invalid parameters");
    else if (publicKey == null || publicKey == "") return Future.value(true);

    final strBody = serializeJsonBody(body);
    return Signature.isValidSignatureAsync(signature, strBody, publicKey,
        chainId: chainId);
  }
}

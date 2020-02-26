import 'package:hex/hex.dart';
import 'package:web3dart/crypto.dart';

/// Sign the given payload using the private key and return a hex signature
String signString(String payload, String privateKey) {
  if (payload == null)
    throw Exception("The payload is empty");
  else if (privateKey == null) throw Exception("The privateKey is empty");

  try {
    final privKeyBytes = HEX.decode(privateKey);
    final messageHashBytes = keccakUtf8(payload);
    final signature = sign(messageHashBytes, privKeyBytes);

    return "0x" +
        signature.r.toRadixString(16) +
        signature.s.toRadixString(16) +
        signature.v.toRadixString(16);
  } catch (err) {
    throw Exception("The signature could not be verified");
  }
}

/// Check whether the given signature is valid and belongs to the given message and
/// public key
bool verifySignature(
    String hexSignature, String strPayload, String hexPublicKey) {
  if (hexSignature == null)
    throw Exception("The hexSignature is empty");
  else if (strPayload == null)
    throw Exception("The payload is empty");
  else if (hexPublicKey == null) throw Exception("The hexPublicKey is empty");

  try {
    // TODO: UNAVAILABLE ON WEB3DART
    throw Exception("UNIMPLEMENTED");
  } catch (err) {
    throw Exception("The signature could not be verified");
  }
}

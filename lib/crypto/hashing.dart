import 'package:dvote/crypto/asyncify.dart';
import 'package:dvote_native/dvote_native.dart' as dvoteNative;

/// Returns the Poseidon hash of the given hex string.
/// The result is provided in base64
Future<String> digestHexClaim(String hexPublicKey) {
  if (!(hexPublicKey is String) || hexPublicKey.length == 0)
    throw Exception("The payload is empty");

  return wrap1ParamFunc<String, String>(
      dvoteNative.Hashing.digestHexClaim, hexPublicKey);
}

/// Returns the Poseidon hash of the given UTF8 string.
/// The result is provided in base64
Future<String> digestStringClaim(String strClaim) {
  if (strClaim is! String) throw Exception("The payload is invalid");

  return wrap1ParamFunc<String, String>(
      dvoteNative.Hashing.digestStringClaim, strClaim);
}

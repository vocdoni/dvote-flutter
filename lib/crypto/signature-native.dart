import 'package:dvote/crypto/asyncify.dart';
import 'package:dvote_native/dvote_native.dart' as dvoteNative;

class SignatureNative {
  /// Sign the given payload using the private key and return a hex signature
  static String signString(String payload, String hexPrivateKey,
      {int chainId}) {
    return _signString([payload, hexPrivateKey, chainId]);
  }

  /// Sign the given payload using the private key and return a hex signature
  static Future<String> signStringAsync(String payload, String hexPrivateKey,
      {int chainId}) {
    return wrap3ParamFunc<String, String, String, int>(
        _signString, payload, hexPrivateKey, chainId);
  }

  /// Recover the public key that signed the given message into the given signature
  static String recoverSignerPubKey(String hexSignature, String strPayload,
      {int chainId}) {
    return _recoverSignerPubKey([hexSignature, strPayload, chainId]);
  }

  /// Recover the public key that signed the given message into the given signature
  static Future<String> recoverSignerPubKeyAsync(
      String hexSignature, String strPayload,
      {int chainId}) {
    return wrap3ParamFunc<String, String, String, int>(
        _recoverSignerPubKey, hexSignature, strPayload, chainId);
  }

  /// Check whether the given signature is valid and belongs to the given message and
  /// public key
  static bool isValidSignature(
      String hexSignature, String strPayload, String hexPublicKey,
      {int chainId}) {
    return _isValidSignature([hexSignature, strPayload, hexPublicKey, chainId]);
  }

  /// Check whether the given signature is valid and belongs to the given message and
  /// public key
  static Future<bool> isValidSignatureAsync(
      String hexSignature, String strPayload, String hexPublicKey,
      {int chainId}) {
    return wrap4ParamFunc<bool, String, String, String, int>(
        _isValidSignature, hexSignature, strPayload, hexPublicKey, chainId);
  }

  // ////////////////////////////////////////////////////////////////////////////
  // / IMPLEMENTATION
  // ////////////////////////////////////////////////////////////////////////////

  /// Sign the given payload using the private key and return a hex signature
  static String _signString(List<dynamic> args) {
    assert(args.length == 2 || args.length == 3);
    final payload = args[0];
    assert(payload is String);
    final hexPrivateKey = args[1];
    assert(hexPrivateKey is String);
    // final chainId = args[2];
    // assert(chainId is int || chainId == null);

    // TODO: CHAIN ID IS NOT USED

    if (payload == null)
      throw Exception("The payload is empty");
    else if (hexPrivateKey == null) throw Exception("The privateKey is empty");

    try {
      return dvoteNative.Wallet.sign(payload, hexPrivateKey);
    } catch (err) {
      throw Exception("The signature could not be computed");
    }
  }

  /// Recover the public key that signed the given message into the given signature
  static String _recoverSignerPubKey(List<dynamic> args) {
    assert(args.length == 2 || args.length == 3);
    final hexSignature = args[0];
    assert(hexSignature is String);
    final strPayload = args[1];
    assert(strPayload is String);
    // final chainId = args[2];
    // assert(chainId is int || chainId == null);

    // TODO: CHAIN ID IS NOT USED

    if (hexSignature == null ||
        hexSignature.length < 130 ||
        hexSignature.length > 132)
      throw Exception("The hexSignature is invalid");
    else if (strPayload == null) throw Exception("The payload is empty");

    try {
      return "0x04" +
          dvoteNative.Wallet.recoverSigner(hexSignature, strPayload);
    } catch (err) {
      throw Exception("The signature could not be verified");
    }
  }

  /// Check whether the given signature is valid and belongs to the given message and
  /// public key
  static bool _isValidSignature(List<dynamic> args) {
    assert(args.length == 3 || args.length == 4);
    var hexSignature = args[0];
    assert(hexSignature is String);
    final strPayload = args[1];
    assert(strPayload is String);
    var hexPublicKey = args[2];
    assert(hexPublicKey is String);
    // final chainId = args[3];
    // assert(chainId is int || chainId == null);

    // TODO: CHAIN ID IS NOT USED

    try {
      return dvoteNative.Wallet.isValid(hexSignature, strPayload, hexPublicKey);
    } catch (err) {
      throw Exception("The signature could not be verified");
    }
  }
}

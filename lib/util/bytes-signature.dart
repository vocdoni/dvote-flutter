import 'package:dvote_crypto/dvote_crypto.dart';

/// A wrapper for bytes signing methods
class BytesSignature {
  /// Signs a [List<int>] payload.
  static String sign(List<int> body, String privateKey, {int chainId}) {
    return Signature.signBytes(body, privateKey, chainId: chainId);
  }

  /// Signs a [List<int>] payload asynchronously.
  static Future<String> signAsync(List<int> body, String privateKey,
      {int chainId}) {
    return Signature.signBytesAsync(body, privateKey, chainId: chainId);
  }
}

import 'package:dvote_crypto/dvote_crypto.dart';

class BytesSignature {
  static String signBytesPayload(List<int> body, String privateKey,
      {int chainId}) {
    return Signature.signBytes(body, privateKey, chainId: chainId);
  }

  static Future<String> signBytesPayloadAsync(List<int> body, String privateKey,
      {int chainId}) {
    return Signature.signBytesAsync(body, privateKey, chainId: chainId);
  }
}

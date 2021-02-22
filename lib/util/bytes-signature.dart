import 'package:convert/convert.dart';
import 'package:dvote_crypto/dvote_crypto.dart';

class BytesSignature {
  static String signBytesPayload(List<int> body, String privateKey,
      {int chainId}) {
    final strBody = hex.encode(body);

    return Signature.signString(strBody, privateKey, chainId: chainId);
  }

  static Future<String> signBytesPayloadAsync(List<int> body, String privateKey,
      {int chainId}) {
    final strBody = hex.encode(body);

    return Signature.signStringAsync(strBody, privateKey, chainId: chainId);
  }
  // static String signBytesPayload(List<int> body, String privateKey,
  //     {int chainId}) {
  //   return Signature.signBytes(body, privateKey, chainId: chainId);
  // }

  // static Future<String> signBytesPayloadAsync(List<int> body, String privateKey,
  //     {int chainId}) {
  //   return Signature.signBytesAsync(body, privateKey, chainId: chainId);
  // }
}

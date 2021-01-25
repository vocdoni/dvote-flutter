import 'dart:convert';

import 'package:dvote_crypto/dvote_crypto.dart';

class BytesSignature {
  static String signBytesPayload(List<int> body, String privateKey,
      {int chainId}) {
    final strBody = utf8.decode(body);

    return Signature.signString(strBody, privateKey, chainId: chainId);
  }

  static Future<String> signBytesPayloadAsync(List<int> body, String privateKey,
      {int chainId}) {
    final strBody = utf8.decode(body, allowMalformed: true);

    return Signature.signStringAsync(strBody, privateKey, chainId: chainId);
  }
}

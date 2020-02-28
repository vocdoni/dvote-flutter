import 'package:flutter_test/flutter_test.dart';
import 'package:dvote/dvote.dart';

import '../../lib/util/json-signature.dart';

void signature() {
  test("Sign a JSON body", () async {
    EthereumWallet wallet = EthereumWallet.fromMnemonic(
        'poverty castle step need baby chair measure leader dress print cruise baby avoid fee sock shoulder rate opinion');

    Map<String, dynamic> body = {
      "actionKey": "register",
      "dateOfBirth": "1975-01-25T12:00:00.000Z",
      "email": "john@me.com",
      "entityId":
          "0xf6515536038e12212adc96395021ad1f1f089a239f0ba4c139d364ededd00c54",
      "firstName": "John",
      "lastName": "Mayer",
      "method": "register",
      "phone": "5555555",
      "timestamp": 1582821257721
    };
    String signature = await signJsonPayload(body, wallet.privateKey);
    expect(signature,
        "0x3086bf3de0d22d2d51f274d4618ea963b60b1e590f5ef0b1a2df17447746d4503f595e87330fb9cc9387c321acc9e476baedfd0681d864f68f4f1bc84548725c1b");

    body = {
      "actionKey": "register",
      "dateOfBirth": "1975-01-23T12:00:00.000Z",
      "email": "ferran@me.com",
      "entityId":
          "0xf6515536038e12212adc96395021ad1f1f089a239f0ba4c139d364ededd00c54",
      "firstName": "Ferran",
      "lastName": "Adrià",
      "method": "register",
      "phone": "5555555555",
      "timestamp": 1582820811597
    };
    signature = await signJsonPayload(body, wallet.privateKey);
    expect(signature,
        "0x12d77e67c734022f7ab66231377621b75b454d724303bb158019549cf9f02d384d9af1d33266ca017248d8914b111cbb68b7cc9f045e95ccbde5ce389254450f1b");
  });
}

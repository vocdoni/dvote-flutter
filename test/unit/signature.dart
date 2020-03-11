import 'package:flutter_test/flutter_test.dart';
import 'package:dvote/dvote.dart';

import '../../lib/util/json-signature.dart';

void signature() {
  // String

  test("Sign a plain string", () {
    EthereumWallet wallet = EthereumWallet.fromMnemonic(
        'poverty castle step need baby chair measure leader dress print cruise baby avoid fee sock shoulder rate opinion');

    String message = "hello";
    String signature = signString(message, wallet.privateKey);
    expect(signature,
        "0x9d06b4f31641aba791bb79dfb211c1141c4b3e346f230c05256c657c5c10916229a8f4cee40bfdbe0d90061d60e712ec5ec0c59cb90321814848ec2f6f7763181b");

    message = "àèìòù";
    signature = signString(message, wallet.privateKey);
    expect(signature,
        "0x2cbf9ae0de3df7e975b68b4cf67e14a0b49a1f8ed5d54c6c13d2ff936585036232fb53846fd49331bf8832fcd7e4517c3f07c951b95d5e0e102e572bbbadda811c");
  });

  // Received

  test("Recover the public key of signatures received externally", () {
    final originalPublicKey =
        "0x04d811f8ade566618a667715c637a7f3019f46ae0ffc8b2ec3b16b1f72999e2e2f9e9b50c78ca34175d78942de88798cce5d53569f96579a95ec9bab17c0131d4f";

    String message = "hello";
    String signature =
        "0x9d06b4f31641aba791bb79dfb211c1141c4b3e346f230c05256c657c5c10916229a8f4cee40bfdbe0d90061d60e712ec5ec0c59cb90321814848ec2f6f7763181b";
    String recoveredPubKey = recoverSignerPubKey(signature, message);
    expect(recoveredPubKey, originalPublicKey,
        reason: "The public key should match");

    message = "àèìòù";
    signature =
        "0x2cbf9ae0de3df7e975b68b4cf67e14a0b49a1f8ed5d54c6c13d2ff936585036232fb53846fd49331bf8832fcd7e4517c3f07c951b95d5e0e102e572bbbadda811c";
    recoveredPubKey = recoverSignerPubKey(signature, message);
    expect(recoveredPubKey, originalPublicKey,
        reason: "The public key should match");
  });

  test("Verify a signature received externally", () {
    final publicKey =
        "0x04d811f8ade566618a667715c637a7f3019f46ae0ffc8b2ec3b16b1f72999e2e2f9e9b50c78ca34175d78942de88798cce5d53569f96579a95ec9bab17c0131d4f";

    String message = "hello";
    String signature =
        "0x9d06b4f31641aba791bb79dfb211c1141c4b3e346f230c05256c657c5c10916229a8f4cee40bfdbe0d90061d60e712ec5ec0c59cb90321814848ec2f6f7763181b";
    bool valid = isValidSignature(signature, message, publicKey);
    expect(valid, true, reason: "The signature should be valid");

    message = "àèìòù";
    signature =
        "0x2cbf9ae0de3df7e975b68b4cf67e14a0b49a1f8ed5d54c6c13d2ff936585036232fb53846fd49331bf8832fcd7e4517c3f07c951b95d5e0e102e572bbbadda811c";
    valid = isValidSignature(signature, message, publicKey);
    expect(valid, true, reason: "The signature should be valid");
  });

  // Signed here

  test("Recover the public key of signatures generated locally", () {
    EthereumWallet wallet = EthereumWallet.fromMnemonic(
        'poverty castle step need baby chair measure leader dress print cruise baby avoid fee sock shoulder rate opinion');

    final originalPublicKey = wallet.publicKey;

    String message = "hello";
    String signature = signString(message, wallet.privateKey);
    String recoveredPubKey = recoverSignerPubKey(signature, message);
    expect(recoveredPubKey, originalPublicKey,
        reason: "The public key should match");

    message = "àèìòù";
    signature = signString(message, wallet.privateKey);
    recoveredPubKey = recoverSignerPubKey(signature, message);
    expect(recoveredPubKey, originalPublicKey,
        reason: "The public key should match");
  });

  test("Verify a signature generated locally", () {
    EthereumWallet wallet = EthereumWallet.fromMnemonic(
        'poverty castle step need baby chair measure leader dress print cruise baby avoid fee sock shoulder rate opinion');

    final expectedPublicKey = wallet.publicKey;

    String message = "hello";
    String signature = signString(message, wallet.privateKey);
    bool valid = isValidSignature(signature, message, expectedPublicKey);
    expect(valid, true, reason: "The signature should be valid");

    message = "àèìòù";
    signature = signString(message, wallet.privateKey);
    valid = isValidSignature(signature, message, expectedPublicKey);
    expect(valid, true, reason: "The signature should be valid");
  });

  // The same with JSON payloads

  test("Sign a JSON body", () {
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
    String signature = signJsonPayload(body, wallet.privateKey);
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
    signature = signJsonPayload(body, wallet.privateKey);
    expect(signature,
        "0x12d77e67c734022f7ab66231377621b75b454d724303bb158019549cf9f02d384d9af1d33266ca017248d8914b111cbb68b7cc9f045e95ccbde5ce389254450f1b");
  });

  // Externally signed JSON's

  test("Sign a JSON body", () {
    final expectedPublicKey =
        "0x04d811f8ade566618a667715c637a7f3019f46ae0ffc8b2ec3b16b1f72999e2e2f9e9b50c78ca34175d78942de88798cce5d53569f96579a95ec9bab17c0131d4f";

    // Plain ascii
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
    String signature =
        "0x3086bf3de0d22d2d51f274d4618ea963b60b1e590f5ef0b1a2df17447746d4503f595e87330fb9cc9387c321acc9e476baedfd0681d864f68f4f1bc84548725c1b";
    expect(isValidJsonSignature(signature, body, expectedPublicKey), true,
        reason: "The signature should be valid");

    // With UTF8 characters
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

    signature =
        "0x12d77e67c734022f7ab66231377621b75b454d724303bb158019549cf9f02d384d9af1d33266ca017248d8914b111cbb68b7cc9f045e95ccbde5ce389254450f1b";
    expect(isValidJsonSignature(signature, body, expectedPublicKey), true,
        reason: "The signature should be valid");
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:dvote/dvote.dart';

// import '../../lib/util/json-signature-native.dart';
import '../../lib/util/json-signature.dart';
import '../../lib/util/json-content.dart';

void signature() {
  _syncSignature();
  _asyncSignature();
  _signingMatch();
  _reproduceableSignatures();
}

void _syncSignature() {
  // String

  test("Sign a plain string", () {
    EthereumDartWallet wallet = EthereumDartWallet.fromMnemonic(
        'poverty castle step need baby chair measure leader dress print cruise baby avoid fee sock shoulder rate opinion');

    String message = "hello";
    String signature = SignatureDart.signString(message, wallet.privateKey);
    expect(signature,
        "0x9d06b4f31641aba791bb79dfb211c1141c4b3e346f230c05256c657c5c10916229a8f4cee40bfdbe0d90061d60e712ec5ec0c59cb90321814848ec2f6f7763181b");

    message = "àèìòù";
    signature = SignatureDart.signString(message, wallet.privateKey);
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
    String recoveredPubKey =
        SignatureDart.recoverSignerPubKey(signature, message);
    expect(recoveredPubKey, originalPublicKey,
        reason: "The public key should match");

    message = "àèìòù";
    signature =
        "0x2cbf9ae0de3df7e975b68b4cf67e14a0b49a1f8ed5d54c6c13d2ff936585036232fb53846fd49331bf8832fcd7e4517c3f07c951b95d5e0e102e572bbbadda811c";
    recoveredPubKey = SignatureDart.recoverSignerPubKey(signature, message);
    expect(recoveredPubKey, originalPublicKey,
        reason: "The public key should match");
  });

  test("Verify a signature received externally", () {
    final publicKey =
        "0x04d811f8ade566618a667715c637a7f3019f46ae0ffc8b2ec3b16b1f72999e2e2f9e9b50c78ca34175d78942de88798cce5d53569f96579a95ec9bab17c0131d4f";

    String message = "hello";
    String signature =
        "0x9d06b4f31641aba791bb79dfb211c1141c4b3e346f230c05256c657c5c10916229a8f4cee40bfdbe0d90061d60e712ec5ec0c59cb90321814848ec2f6f7763181b";
    bool valid = SignatureDart.isValidSignature(signature, message, publicKey);
    expect(valid, true, reason: "The signature should be valid");

    message = "àèìòù";
    signature =
        "0x2cbf9ae0de3df7e975b68b4cf67e14a0b49a1f8ed5d54c6c13d2ff936585036232fb53846fd49331bf8832fcd7e4517c3f07c951b95d5e0e102e572bbbadda811c";
    valid = SignatureDart.isValidSignature(signature, message, publicKey);
    expect(valid, true, reason: "The signature should be valid");
  });

  test("Verify a signature received externally with 'v' below 72", () {
    final publicKey =
        "0x04d811f8ade566618a667715c637a7f3019f46ae0ffc8b2ec3b16b1f72999e2e2f9e9b50c78ca34175d78942de88798cce5d53569f96579a95ec9bab17c0131d4f";

    String message = "hello";
    String signature =
        "0x9d06b4f31641aba791bb79dfb211c1141c4b3e346f230c05256c657c5c10916229a8f4cee40bfdbe0d90061d60e712ec5ec0c59cb90321814848ec2f6f77631800";
    bool valid = SignatureDart.isValidSignature(signature, message, publicKey);
    expect(valid, true, reason: "The signature should be valid");

    message = "àèìòù";
    signature =
        "0x2cbf9ae0de3df7e975b68b4cf67e14a0b49a1f8ed5d54c6c13d2ff936585036232fb53846fd49331bf8832fcd7e4517c3f07c951b95d5e0e102e572bbbadda8101";
    valid = SignatureDart.isValidSignature(signature, message, publicKey);
    expect(valid, true, reason: "The signature should be valid");
  });

  // Signed here

  test("Recover the public key of signatures generated locally", () {
    EthereumDartWallet wallet = EthereumDartWallet.fromMnemonic(
        'poverty castle step need baby chair measure leader dress print cruise baby avoid fee sock shoulder rate opinion');

    final originalPublicKey = wallet.publicKey;

    String message = "hello";
    String signature = SignatureDart.signString(message, wallet.privateKey);
    String recoveredPubKey =
        SignatureDart.recoverSignerPubKey(signature, message);
    expect(recoveredPubKey, originalPublicKey,
        reason: "The public key should match");

    message = "àèìòù";
    signature = SignatureDart.signString(message, wallet.privateKey);
    recoveredPubKey = SignatureDart.recoverSignerPubKey(signature, message);
    expect(recoveredPubKey, originalPublicKey,
        reason: "The public key should match");
  });

  test("Verify a signature generated locally", () {
    EthereumDartWallet wallet = EthereumDartWallet.fromMnemonic(
        'poverty castle step need baby chair measure leader dress print cruise baby avoid fee sock shoulder rate opinion');

    final expectedPublicKey = wallet.publicKey;

    String message = "hello";
    String signature = SignatureDart.signString(message, wallet.privateKey);
    bool valid =
        SignatureDart.isValidSignature(signature, message, expectedPublicKey);
    expect(valid, true, reason: "The signature should be valid");

    message = "àèìòù";
    signature = SignatureDart.signString(message, wallet.privateKey);
    valid =
        SignatureDart.isValidSignature(signature, message, expectedPublicKey);
    expect(valid, true, reason: "The signature should be valid");
  });

  // The same with JSON payloads

  test("Sign a JSON body", () {
    EthereumDartWallet wallet = EthereumDartWallet.fromMnemonic(
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
    String signature =
        JSONSignatureDart.signJsonPayload(body, wallet.privateKey);
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
    signature = JSONSignatureDart.signJsonPayload(body, wallet.privateKey);
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
    expect(
        JSONSignatureDart.isValidJsonSignature(
            signature, body, expectedPublicKey),
        true,
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
    expect(
        JSONSignatureDart.isValidJsonSignature(
            signature, body, expectedPublicKey),
        true,
        reason: "The signature should be valid");
  });
}

void _asyncSignature() {
  // String

  test("Sign a plain string [async]", () async {
    EthereumDartWallet wallet = EthereumDartWallet.fromMnemonic(
        'poverty castle step need baby chair measure leader dress print cruise baby avoid fee sock shoulder rate opinion');

    String message = "hello";
    String signature =
        await SignatureDart.signStringAsync(message, wallet.privateKey);
    expect(signature,
        "0x9d06b4f31641aba791bb79dfb211c1141c4b3e346f230c05256c657c5c10916229a8f4cee40bfdbe0d90061d60e712ec5ec0c59cb90321814848ec2f6f7763181b");

    message = "àèìòù";
    signature = await SignatureDart.signStringAsync(message, wallet.privateKey);
    expect(signature,
        "0x2cbf9ae0de3df7e975b68b4cf67e14a0b49a1f8ed5d54c6c13d2ff936585036232fb53846fd49331bf8832fcd7e4517c3f07c951b95d5e0e102e572bbbadda811c");
  });

  // Received

  test("Recover the public key of signatures received externally [async]",
      () async {
    final originalPublicKey =
        "0x04d811f8ade566618a667715c637a7f3019f46ae0ffc8b2ec3b16b1f72999e2e2f9e9b50c78ca34175d78942de88798cce5d53569f96579a95ec9bab17c0131d4f";

    String message = "hello";
    String signature =
        "0x9d06b4f31641aba791bb79dfb211c1141c4b3e346f230c05256c657c5c10916229a8f4cee40bfdbe0d90061d60e712ec5ec0c59cb90321814848ec2f6f7763181b";
    String recoveredPubKey =
        await SignatureDart.recoverSignerPubKeyAsync(signature, message);
    expect(recoveredPubKey, originalPublicKey,
        reason: "The public key should match");

    message = "àèìòù";
    signature =
        "0x2cbf9ae0de3df7e975b68b4cf67e14a0b49a1f8ed5d54c6c13d2ff936585036232fb53846fd49331bf8832fcd7e4517c3f07c951b95d5e0e102e572bbbadda811c";
    recoveredPubKey =
        await SignatureDart.recoverSignerPubKeyAsync(signature, message);
    expect(recoveredPubKey, originalPublicKey,
        reason: "The public key should match");
  });

  test("Verify a signature received externally [async]", () async {
    final publicKey =
        "0x04d811f8ade566618a667715c637a7f3019f46ae0ffc8b2ec3b16b1f72999e2e2f9e9b50c78ca34175d78942de88798cce5d53569f96579a95ec9bab17c0131d4f";

    String message = "hello";
    String signature =
        "0x9d06b4f31641aba791bb79dfb211c1141c4b3e346f230c05256c657c5c10916229a8f4cee40bfdbe0d90061d60e712ec5ec0c59cb90321814848ec2f6f7763181b";
    bool valid = await SignatureDart.isValidSignatureAsync(
        signature, message, publicKey);
    expect(valid, true, reason: "The signature should be valid");

    message = "àèìòù";
    signature =
        "0x2cbf9ae0de3df7e975b68b4cf67e14a0b49a1f8ed5d54c6c13d2ff936585036232fb53846fd49331bf8832fcd7e4517c3f07c951b95d5e0e102e572bbbadda811c";
    valid = await SignatureDart.isValidSignatureAsync(
        signature, message, publicKey);
    expect(valid, true, reason: "The signature should be valid");
  });

  test("Verify a signature received externally with 'v' below 72 [async]",
      () async {
    final publicKey =
        "0x04d811f8ade566618a667715c637a7f3019f46ae0ffc8b2ec3b16b1f72999e2e2f9e9b50c78ca34175d78942de88798cce5d53569f96579a95ec9bab17c0131d4f";

    String message = "hello";
    String signature =
        "0x9d06b4f31641aba791bb79dfb211c1141c4b3e346f230c05256c657c5c10916229a8f4cee40bfdbe0d90061d60e712ec5ec0c59cb90321814848ec2f6f77631800";
    bool valid = await SignatureDart.isValidSignatureAsync(
        signature, message, publicKey);
    expect(valid, true, reason: "The signature should be valid");

    message = "àèìòù";
    signature =
        "0x2cbf9ae0de3df7e975b68b4cf67e14a0b49a1f8ed5d54c6c13d2ff936585036232fb53846fd49331bf8832fcd7e4517c3f07c951b95d5e0e102e572bbbadda8101";
    valid = await SignatureDart.isValidSignatureAsync(
        signature, message, publicKey);
    expect(valid, true, reason: "The signature should be valid");
  });

  // Signed here

  test("Recover the public key of signatures generated locally [async]",
      () async {
    EthereumDartWallet wallet = EthereumDartWallet.fromMnemonic(
        'poverty castle step need baby chair measure leader dress print cruise baby avoid fee sock shoulder rate opinion');

    final originalPublicKey = wallet.publicKey;

    String message = "hello";
    String signature =
        await SignatureDart.signStringAsync(message, wallet.privateKey);
    String recoveredPubKey =
        await SignatureDart.recoverSignerPubKeyAsync(signature, message);
    expect(recoveredPubKey, originalPublicKey,
        reason: "The public key should match");

    message = "àèìòù";
    signature = await SignatureDart.signStringAsync(message, wallet.privateKey);
    recoveredPubKey =
        await SignatureDart.recoverSignerPubKeyAsync(signature, message);
    expect(recoveredPubKey, originalPublicKey,
        reason: "The public key should match");
  });

  test("Verify a signature generated locally [async]", () async {
    EthereumDartWallet wallet = EthereumDartWallet.fromMnemonic(
        'poverty castle step need baby chair measure leader dress print cruise baby avoid fee sock shoulder rate opinion');

    final expectedPublicKey = wallet.publicKey;

    String message = "hello";
    String signature =
        await SignatureDart.signStringAsync(message, wallet.privateKey);
    bool valid = await SignatureDart.isValidSignatureAsync(
        signature, message, expectedPublicKey);
    expect(valid, true, reason: "The signature should be valid");

    message = "àèìòù";
    signature = await SignatureDart.signStringAsync(message, wallet.privateKey);
    valid = await SignatureDart.isValidSignatureAsync(
        signature, message, expectedPublicKey);
    expect(valid, true, reason: "The signature should be valid");
  });

  // The same with JSON payloads

  test("Sign a JSON body [async]", () async {
    EthereumDartWallet wallet = EthereumDartWallet.fromMnemonic(
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
    String signature =
        await JSONSignatureDart.signJsonPayloadAsync(body, wallet.privateKey);
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
    signature =
        await JSONSignatureDart.signJsonPayloadAsync(body, wallet.privateKey);
    expect(signature,
        "0x12d77e67c734022f7ab66231377621b75b454d724303bb158019549cf9f02d384d9af1d33266ca017248d8914b111cbb68b7cc9f045e95ccbde5ce389254450f1b");
  });

  // Externally signed JSON's

  test("Sign a JSON body [async]", () async {
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
    expect(
        await JSONSignatureDart.isValidJsonSignatureAsync(
            signature, body, expectedPublicKey),
        true,
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
    expect(
        await JSONSignatureDart.isValidJsonSignatureAsync(
            signature, body, expectedPublicKey),
        true,
        reason: "The signature should be valid");
  });
}

void _signingMatch() {
  test("Sync and async should match", () async {
    EthereumDartWallet wallet = EthereumDartWallet.fromMnemonic(
        'poverty castle step need baby chair measure leader dress print cruise baby avoid fee sock shoulder rate opinion');

    // Plain
    String message = "hello";
    String signature1 = SignatureDart.signString(message, wallet.privateKey);
    String signature2 =
        await SignatureDart.signStringAsync(message, wallet.privateKey);
    expect(signature1, signature2);

    String recoveredPubKey1 =
        SignatureDart.recoverSignerPubKey(signature1, message);
    String recoveredPubKey2 =
        await SignatureDart.recoverSignerPubKeyAsync(signature2, message);
    expect(recoveredPubKey1, recoveredPubKey2);

    bool isValid1 =
        SignatureDart.isValidSignature(signature1, message, wallet.publicKey);
    bool isValid2 = await SignatureDart.isValidSignatureAsync(
        signature2, message, wallet.publicKey);
    expect(isValid1, isValid2);

    // UTF-8
    message = "àèìòù";
    signature1 = SignatureDart.signString(message, wallet.privateKey);
    signature2 =
        await SignatureDart.signStringAsync(message, wallet.privateKey);
    expect(signature1, signature2);

    recoveredPubKey1 = SignatureDart.recoverSignerPubKey(signature1, message);
    recoveredPubKey2 =
        await SignatureDart.recoverSignerPubKeyAsync(signature2, message);
    expect(recoveredPubKey1, recoveredPubKey2);

    isValid1 =
        SignatureDart.isValidSignature(signature1, message, wallet.publicKey);
    isValid2 = await SignatureDart.isValidSignatureAsync(
        signature2, message, wallet.publicKey);
    expect(isValid1, isValid2);
  });

  test("Sync and async should match with JSON", () async {
    EthereumDartWallet wallet = EthereumDartWallet.fromMnemonic(
        'poverty castle step need baby chair measure leader dress print cruise baby avoid fee sock shoulder rate opinion');

    // Plain json
    Map<String, dynamic> payload = {"hello": 1234, "abcde": 2345};
    String signature1 =
        JSONSignatureDart.signJsonPayload(payload, wallet.privateKey);
    String signature2 = await JSONSignatureDart.signJsonPayloadAsync(
        payload, wallet.privateKey);
    expect(signature1, signature2);

    String recoveredPubKey1 =
        JSONSignatureDart.recoverJsonSignerPubKey(signature1, payload);
    String recoveredPubKey2 =
        await JSONSignatureDart.recoverJsonSignerPubKeyAsync(
            signature2, payload);
    expect(recoveredPubKey1, recoveredPubKey2);

    bool isValid1 = JSONSignatureDart.isValidJsonSignature(
        signature1, payload, wallet.publicKey);
    bool isValid2 = await JSONSignatureDart.isValidJsonSignatureAsync(
        signature2, payload, wallet.publicKey);
    expect(isValid1, isValid2);

    // UTF-8 json
    payload = {"Z": 1234, "àèìòù": 2345};
    signature1 = JSONSignatureDart.signJsonPayload(payload, wallet.privateKey);
    signature2 = await JSONSignatureDart.signJsonPayloadAsync(
        payload, wallet.privateKey);
    expect(signature1, signature2);

    recoveredPubKey1 =
        JSONSignatureDart.recoverJsonSignerPubKey(signature1, payload);
    recoveredPubKey2 = await JSONSignatureDart.recoverJsonSignerPubKeyAsync(
        signature2, payload);
    expect(recoveredPubKey1, recoveredPubKey2);

    isValid1 = JSONSignatureDart.isValidJsonSignature(
        signature1, payload, wallet.publicKey);
    isValid2 = await JSONSignatureDart.isValidJsonSignatureAsync(
        signature2, payload, wallet.publicKey);
    expect(isValid1, isValid2);
  });
}

void _reproduceableSignatures() {
  test("JSON payloads should be signed in alphabetic order", () async {
    final wallet = EthereumDartWallet.random();

    // Simple types
    String payload1 = serializeJsonBody("Hello");
    String signature1 = SignatureDart.signString(payload1, wallet.privateKey);
    String payload2 = serializeJsonBody("Hello");
    String signature2 = SignatureDart.signString(payload2, wallet.privateKey);
    expect(payload1, payload2);
    expect(signature1, signature2);

    bool isValid =
        SignatureDart.isValidSignature(signature1, payload1, wallet.publicKey);
    expect(isValid, true);

    //
    payload1 = serializeJsonBody(1234);
    signature1 = SignatureDart.signString(payload1, wallet.privateKey);
    payload2 = serializeJsonBody(1234);
    signature2 = SignatureDart.signString(payload2, wallet.privateKey);
    expect(payload1, payload2);
    expect(signature1, signature2);

    isValid =
        SignatureDart.isValidSignature(signature1, payload1, wallet.publicKey);
    expect(isValid, true);

    // Maps
    payload1 = serializeJsonBody({"a": 1234, "z": 2345});
    signature1 = SignatureDart.signString(payload1, wallet.privateKey);
    payload2 = serializeJsonBody({"z": 2345, "a": 1234});
    signature2 = SignatureDart.signString(payload2, wallet.privateKey);
    expect(payload1, payload2);
    expect(signature1, signature2);

    isValid =
        SignatureDart.isValidSignature(signature1, payload1, wallet.publicKey);
    expect(isValid, true);

    // Recursive maps
    payload1 = serializeJsonBody({
      "a": 1,
      "b": {"c": 3, "d": 4}
    });
    signature1 = SignatureDart.signString(payload1, wallet.privateKey);
    payload2 = serializeJsonBody({
      "b": {"d": 4, "c": 3},
      "a": 1
    });
    signature2 = SignatureDart.signString(payload2, wallet.privateKey);
    expect(payload1, payload2);
    expect(signature1, signature2);

    isValid =
        SignatureDart.isValidSignature(signature1, payload1, wallet.publicKey);
    expect(isValid, true);

    // Lists
    payload1 = serializeJsonBody([
      {"a": 10, "m": 10, "z": 10},
      {"b": 11, "n": 11, "y": 11},
      4,
      5
    ]);
    signature1 = SignatureDart.signString(payload1, wallet.privateKey);
    payload2 = serializeJsonBody([
      {"z": 10, "m": 10, "a": 10},
      {"y": 11, "n": 11, "b": 11},
      4,
      5
    ]);
    signature2 = SignatureDart.signString(payload2, wallet.privateKey);
    expect(payload1, payload2);
    expect(signature1, signature2);

    isValid =
        SignatureDart.isValidSignature(signature1, payload1, wallet.publicKey);
    expect(isValid, true);

    // Recursive maps and lists
    payload1 = serializeJsonBody({
      "a": 1,
      "b": [
        {"a": 10, "m": 10, "z": 10},
        {"b": 11, "n": 11, "y": 11},
        4,
        5
      ]
    });
    signature1 = SignatureDart.signString(payload1, wallet.privateKey);
    payload2 = serializeJsonBody({
      "b": [
        {"z": 10, "m": 10, "a": 10},
        {"y": 11, "n": 11, "b": 11},
        4,
        5
      ],
      "a": 1
    });
    signature2 = SignatureDart.signString(payload2, wallet.privateKey);
    expect(payload1, payload2);
    expect(signature1, signature2);

    isValid =
        SignatureDart.isValidSignature(signature1, payload1, wallet.publicKey);
    expect(isValid, true);
  });
}

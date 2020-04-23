import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
// import 'package:convert/convert.dart';
import 'dart:typed_data';
import 'package:dvote/crypto/encryption.dart';
// import 'package:pinenacl/secret.dart'
//     show SecretBox, SealedBox, PrivateKey, PublicKey, EncryptedMessage;

void encryption() {
  testSymmetricEncryptionWrapper();
  testSymmetricEncryptionAsyncWrapper();

  testAsymmetricEncriptionWrapper();
  testAsymmetricEncriptionAsyncWrapper();
}

// SYMMETRIC ENCRYPTION

testSymmetricEncryptionWrapper() {
  final msg1 =
      "Change is a tricky thing, it threatens what we find familiar with...";
  final msg2 =
      "Changes are a hacky thing that threaten what we are familiar with...";

  final passphrase1 = "Top secret";
  final passphrase2 = "Ultra top secret";

  test('Encryption wrapper: String encryption should match', () {
    final encrypted1 = Symmetric.encryptString(msg1, passphrase1);
    final decrypted1 = Symmetric.decryptString(encrypted1, passphrase1);
    expect(decrypted1, msg1, reason: "Decrypted string does not match");

    final encrypted2 = Symmetric.encryptString(msg2, passphrase1);
    final decrypted2 = Symmetric.decryptString(encrypted2, passphrase1);
    expect(decrypted2, msg2, reason: "Decrypted string does not match");

    final encrypted3 = Symmetric.encryptString(msg1, passphrase2);
    final decrypted3 = Symmetric.decryptString(encrypted3, passphrase2);
    expect(decrypted3, msg1, reason: "Decrypted string does not match");

    final encrypted4 = Symmetric.encryptString(msg2, passphrase2);
    final decrypted4 = Symmetric.decryptString(encrypted4, passphrase2);
    expect(decrypted4, msg2, reason: "Decrypted string does not match");
  });

  test('Encryption wrapper: Byte array encryption should match', () {
    final msg1Buffer = Uint8List.fromList([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
    final msg2Buffer =
        Uint8List.fromList([100, 101, 102, 103, 104, 105, 106, 107, 108, 109]);

    final encrypted1 = Symmetric.encryptBytes(msg1Buffer, passphrase1);
    final decrypted1 = Symmetric.decryptBytes(encrypted1, passphrase1);
    expect(decrypted1.join(","), msg1Buffer.join(","),
        reason: "Decrypted string does not match");

    final encrypted2 = Symmetric.encryptBytes(msg2Buffer, passphrase1);
    final decrypted2 = Symmetric.decryptBytes(encrypted2, passphrase1);
    expect(decrypted2.join(","), msg2Buffer.join(","),
        reason: "Decrypted string does not match");

    final encrypted3 = Symmetric.encryptBytes(msg1Buffer, passphrase2);
    final decrypted3 = Symmetric.decryptBytes(encrypted3, passphrase2);
    expect(decrypted3.join(","), msg1Buffer.join(","),
        reason: "Decrypted string does not match");

    final encrypted4 = Symmetric.encryptBytes(msg2Buffer, passphrase2);
    final decrypted4 = Symmetric.decryptBytes(encrypted4, passphrase2);
    expect(decrypted4.join(","), msg2Buffer.join(","),
        reason: "Decrypted string does not match");
  });

  test('Encryption wrapper: Bytes should match', () {
    final msg1Buffer = Uint8List.fromList([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
    final msg2Buffer =
        Uint8List.fromList([100, 101, 102, 103, 104, 105, 106, 107, 108, 109]);

    final encrypted1 = Symmetric.encryptRaw(msg1Buffer, passphrase1);
    final decrypted1 = Symmetric.decryptRaw(encrypted1, passphrase1);
    expect(decrypted1.join(","), msg1Buffer.join(","),
        reason: "Decrypted string does not match");

    final encrypted2 = Symmetric.encryptRaw(msg2Buffer, passphrase1);
    final decrypted2 = Symmetric.decryptRaw(encrypted2, passphrase1);
    expect(decrypted2.join(","), msg2Buffer.join(","),
        reason: "Decrypted string does not match");

    final encrypted3 = Symmetric.encryptRaw(msg1Buffer, passphrase2);
    final decrypted3 = Symmetric.decryptRaw(encrypted3, passphrase2);
    expect(decrypted3.join(","), msg1Buffer.join(","),
        reason: "Decrypted string does not match");

    final encrypted4 = Symmetric.encryptRaw(msg2Buffer, passphrase2);
    final decrypted4 = Symmetric.decryptRaw(encrypted4, passphrase2);
    expect(decrypted4.join(","), msg2Buffer.join(","),
        reason: "Decrypted string does not match");
  });

  test('Encryption wrapper: Invalid passphrases should fail', () {
    final expectedErrorString =
        "The message is forged or malformed or the shared secret is invalid";
    final unexpectedErrorString = """Expected: <1>
  Actual: <0>
Decrypting should have failed but didn't
""";

    try {
      final encrypted1 = Symmetric.encryptString(msg1, passphrase1);
      Symmetric.decryptString(
          encrypted1, passphrase1 + "INVALID_PASSPHRASE_THAT_DOES_NOT_MATCH");
      expect(0, 1, reason: "Decrypting should have failed but didn't");
    } on TestFailure catch (err) {
      if (err.message == unexpectedErrorString) throw err.message;
    } catch (err) {
      if (err != expectedErrorString) throw err;
    }

    try {
      final encrypted2 = Symmetric.encryptString(msg2, passphrase1);
      Symmetric.decryptString(
          encrypted2, passphrase1 + "INVALID_PASSPHRASE_THAT_DOES_NOT_MATCH");
      expect(0, 1, reason: "Decrypting should have failed but didn't");
    } on TestFailure catch (err) {
      if (err.message == unexpectedErrorString) throw err.message;
    } catch (err) {
      if (err != expectedErrorString) throw err;
    }

    try {
      final encrypted3 = Symmetric.encryptString(msg1, passphrase2);
      Symmetric.decryptString(
          encrypted3, passphrase2 + "1234 RANDOM PASSPHRASE");
      expect(0, 1, reason: "Decrypting should have failed but didn't");
    } on TestFailure catch (err) {
      if (err.message == unexpectedErrorString) throw err.message;
    } catch (err) {
      if (err != expectedErrorString) throw err;
    }

    try {
      final encrypted4 = Symmetric.encryptString(msg2, passphrase2);
      Symmetric.decryptString(
          encrypted4, passphrase2 + "1234 RANDOM PASSPHRASE");
      expect(0, 1, reason: "Decrypting should have failed but didn't");
    } on TestFailure catch (err) {
      if (err.message == unexpectedErrorString) throw err.message;
    } catch (err) {
      if (err != expectedErrorString) throw err;
    }
  });
}

testSymmetricEncryptionAsyncWrapper() {
  final msg1 =
      "Change is a tricky thing, it threatens what we find familiar with...";
  final msg2 =
      "Changes are a hacky thing that threaten what we are familiar with...";

  final passphrase1 = "Top secret";
  final passphrase2 = "Ultra top secret";

  test('Encryption wrapper: Sync and async should match', () async {
    final encrypted1 = Symmetric.encryptString(msg1, passphrase1);
    final encrypted2 = await Symmetric.encryptStringAsync(msg1, passphrase1);

    final decrypted1 = Symmetric.decryptString(encrypted1, passphrase1);
    final decrypted2 =
        await Symmetric.decryptStringAsync(encrypted2, passphrase1);
    expect(decrypted1, decrypted2,
        reason: "Sync and async decrypted should match");
  });

  test('Encryption wrapper: String encryption should match [async]', () async {
    final encrypted1 = await Symmetric.encryptStringAsync(msg1, passphrase1);
    final decrypted1 =
        await Symmetric.decryptStringAsync(encrypted1, passphrase1);
    expect(decrypted1, msg1, reason: "Decrypted string does not match");

    final encrypted2 = await Symmetric.encryptStringAsync(msg2, passphrase1);
    final decrypted2 =
        await Symmetric.decryptStringAsync(encrypted2, passphrase1);
    expect(decrypted2, msg2, reason: "Decrypted string does not match");

    final encrypted3 = await Symmetric.encryptStringAsync(msg1, passphrase2);
    final decrypted3 =
        await Symmetric.decryptStringAsync(encrypted3, passphrase2);
    expect(decrypted3, msg1, reason: "Decrypted string does not match");

    final encrypted4 = await Symmetric.encryptStringAsync(msg2, passphrase2);
    final decrypted4 =
        await Symmetric.decryptStringAsync(encrypted4, passphrase2);
    expect(decrypted4, msg2, reason: "Decrypted string does not match");
  });

  test('Encryption wrapper: Byte array encryption should match [async]',
      () async {
    final msg1Buffer = Uint8List.fromList([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
    final msg2Buffer =
        Uint8List.fromList([100, 101, 102, 103, 104, 105, 106, 107, 108, 109]);

    final encrypted1 =
        await Symmetric.encryptBytesAsync(msg1Buffer, passphrase1);
    final decrypted1 =
        await Symmetric.decryptBytesAsync(encrypted1, passphrase1);
    expect(decrypted1.join(","), msg1Buffer.join(","),
        reason: "Decrypted string does not match");

    final encrypted2 =
        await Symmetric.encryptBytesAsync(msg2Buffer, passphrase1);
    final decrypted2 =
        await Symmetric.decryptBytesAsync(encrypted2, passphrase1);
    expect(decrypted2.join(","), msg2Buffer.join(","),
        reason: "Decrypted string does not match");

    final encrypted3 =
        await Symmetric.encryptBytesAsync(msg1Buffer, passphrase2);
    final decrypted3 =
        await Symmetric.decryptBytesAsync(encrypted3, passphrase2);
    expect(decrypted3.join(","), msg1Buffer.join(","),
        reason: "Decrypted string does not match");

    final encrypted4 =
        await Symmetric.encryptBytesAsync(msg2Buffer, passphrase2);
    final decrypted4 =
        await Symmetric.decryptBytesAsync(encrypted4, passphrase2);
    expect(decrypted4.join(","), msg2Buffer.join(","),
        reason: "Decrypted string does not match");
  });

  test('Encryption wrapper: Bytes should match [async]', () async {
    final msg1Buffer = Uint8List.fromList([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
    final msg2Buffer =
        Uint8List.fromList([100, 101, 102, 103, 104, 105, 106, 107, 108, 109]);

    final encrypted1 = await Symmetric.encryptRawAsync(msg1Buffer, passphrase1);
    final decrypted1 = await Symmetric.decryptRawAsync(encrypted1, passphrase1);
    expect(decrypted1.join(","), msg1Buffer.join(","),
        reason: "Decrypted string does not match");

    final encrypted2 = await Symmetric.encryptRawAsync(msg2Buffer, passphrase1);
    final decrypted2 = await Symmetric.decryptRawAsync(encrypted2, passphrase1);
    expect(decrypted2.join(","), msg2Buffer.join(","),
        reason: "Decrypted string does not match");

    final encrypted3 = await Symmetric.encryptRawAsync(msg1Buffer, passphrase2);
    final decrypted3 = await Symmetric.decryptRawAsync(encrypted3, passphrase2);
    expect(decrypted3.join(","), msg1Buffer.join(","),
        reason: "Decrypted string does not match");

    final encrypted4 = await Symmetric.encryptRawAsync(msg2Buffer, passphrase2);
    final decrypted4 = await Symmetric.decryptRawAsync(encrypted4, passphrase2);
    expect(decrypted4.join(","), msg2Buffer.join(","),
        reason: "Decrypted string does not match");
  });

  test('Encryption wrapper: Invalid passphrases should fail [async]', () async {
    final expectedErrorString =
        "The message is forged or malformed or the shared secret is invalid";
    final unexpectedErrorString = """Expected: <1>
  Actual: <0>
Decrypting should have failed but didn't
""";

    try {
      final encrypted1 = await Symmetric.encryptStringAsync(msg1, passphrase1);
      await Symmetric.decryptStringAsync(
          encrypted1, passphrase1 + "INVALID_PASSPHRASE_THAT_DOES_NOT_MATCH");
      expect(0, 1, reason: "Decrypting should have failed but didn't");
    } on TestFailure catch (err) {
      if (err.message == unexpectedErrorString) throw err.message;
    } catch (err) {
      if (err.message != expectedErrorString) throw err;
    }

    try {
      final encrypted2 = await Symmetric.encryptStringAsync(msg2, passphrase1);
      await Symmetric.decryptStringAsync(
          encrypted2, passphrase1 + "INVALID_PASSPHRASE_THAT_DOES_NOT_MATCH");
      expect(0, 1, reason: "Decrypting should have failed but didn't");
    } on TestFailure catch (err) {
      if (err.message == unexpectedErrorString) throw err.message;
    } catch (err) {
      if (err.message != expectedErrorString) throw err;
    }

    try {
      final encrypted3 = await Symmetric.encryptStringAsync(msg1, passphrase2);
      await Symmetric.decryptStringAsync(
          encrypted3, passphrase2 + "1234 RANDOM PASSPHRASE");
      expect(0, 1, reason: "Decrypting should have failed but didn't");
    } on TestFailure catch (err) {
      if (err.message == unexpectedErrorString) throw err.message;
    } catch (err) {
      if (err.message != expectedErrorString) throw err;
    }

    try {
      final encrypted4 = await Symmetric.encryptStringAsync(msg2, passphrase2);
      await Symmetric.decryptStringAsync(
          encrypted4, passphrase2 + "1234 RANDOM PASSPHRASE");
      expect(0, 1, reason: "Decrypting should have failed but didn't");
    } on TestFailure catch (err) {
      if (err.message == unexpectedErrorString) throw err.message;
    } catch (err) {
      if (err.message != expectedErrorString) throw err;
    }
  });
}

// ASYMMETRIC ENCRYPTION

testAsymmetricEncriptionWrapper() {
  final messages = [
    "",
    "hello",
    "!·\$%&/)1234567890",
    "UTF-8-charsàèìòù",
    "😃🌟🌹⚖️🚀",
    "Longer message here and there, one two, three. Longer message here and there, one two, three. Longer message here and there, one two, three. Longer message here and there, one two, three. Longer message here and there, one two, three. Longer message here and there, one two, three. Longer message here and there, one two, three. Longer message here and there, one two, three. "
  ];
  final List<Uint8List> msgBuffers = [
    Uint8List.fromList([]),
    Uint8List.fromList([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]),
    Uint8List.fromList([100, 101, 102, 103, 104, 105, 106, 107, 108, 109]),
    Uint8List.fromList([
      0,
      30,
      60,
      90,
      120,
      150,
      180,
      210,
      240,
      255,
      0,
      30,
      60,
      90,
      120,
      150,
      180,
      210,
      240,
      255,
      0,
      30,
      60,
      90,
      120,
      150,
      180,
      210,
      240,
      255,
      0,
      30,
      60,
      90,
      120,
      150,
      180,
      210,
      240,
      255,
      0,
      30,
      60,
      90,
      120,
      150,
      180,
      210,
      240,
      255
    ]),
  ];

  final privKey =
      "91f86dd7a9ac258c4908ca8fbdd3157f84d1f74ffffcb9fa428fba14a1d40150";
  final pubKey =
      "6876524df21d6983724a2b032e41471cc9f1772a9418c4d701fcebb6c306af50";

  test("Encryption wrapper: Should seal a message using a public key", () {
    String encrypted, decrypted;

    for (String msg in messages) {
      encrypted = Asymmetric.encryptString(msg, pubKey);
      base64.decode(encrypted); // should not fail
      decrypted = Asymmetric.decryptString(encrypted, privKey);
      expect(decrypted, msg,
          reason: "The decrypted message should match the original one");
    }
  });

  test('Encryption wrapper: Byte array encryption should match', () {
    String encrypted;
    Uint8List decrypted;

    for (Uint8List msg in msgBuffers) {
      encrypted = Asymmetric.encryptBytes(msg, pubKey);
      decrypted = Asymmetric.decryptBytes(encrypted, privKey);
      expect(decrypted.join(","), msg.join(","),
          reason: "Decrypted string does not match");
    }
  });

  test('Encryption wrapper: Bytes should match', () {
    Uint8List encrypted, decrypted;

    for (Uint8List msg in msgBuffers) {
      encrypted = Asymmetric.encryptRaw(msg, pubKey);
      decrypted = Asymmetric.decryptRaw(encrypted, privKey);
      expect(decrypted.join(","), msg.join(","),
          reason: "Decrypted string does not match");
    }
  });
}

testAsymmetricEncriptionAsyncWrapper() {
  final messages = [
    "",
    "hello",
    "!·\$%&/)1234567890",
    "UTF-8-charsàèìòù",
    "😃🌟🌹⚖️🚀",
    "Longer message here and there, one two, three. Longer message here and there, one two, three. Longer message here and there, one two, three. Longer message here and there, one two, three. Longer message here and there, one two, three. Longer message here and there, one two, three. Longer message here and there, one two, three. Longer message here and there, one two, three. "
  ];

  final List<Uint8List> msgBuffers = [
    Uint8List.fromList([]),
    Uint8List.fromList([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]),
    Uint8List.fromList([100, 101, 102, 103, 104, 105, 106, 107, 108, 109]),
    Uint8List.fromList([
      0,
      30,
      60,
      90,
      120,
      150,
      180,
      210,
      240,
      255,
      0,
      30,
      60,
      90,
      120,
      150,
      180,
      210,
      240,
      255,
      0,
      30,
      60,
      90,
      120,
      150,
      180,
      210,
      240,
      255,
      0,
      30,
      60,
      90,
      120,
      150,
      180,
      210,
      240,
      255,
      0,
      30,
      60,
      90,
      120,
      150,
      180,
      210,
      240,
      255
    ]),
  ];

  final privKey =
      "91f86dd7a9ac258c4908ca8fbdd3157f84d1f74ffffcb9fa428fba14a1d40150";
  final pubKey =
      "6876524df21d6983724a2b032e41471cc9f1772a9418c4d701fcebb6c306af50";

  test("Encryption wrapper: Should seal a message using a public key",
      () async {
    String encrypted, decrypted;

    for (String msg in messages) {
      encrypted = await Asymmetric.encryptStringAsync(msg, pubKey);
      base64.decode(encrypted); // should not fail
      decrypted = await Asymmetric.decryptStringAsync(encrypted, privKey);
      expect(decrypted, msg,
          reason: "The decrypted message should match the original one");
    }
  });

  test('Encryption wrapper: Byte array encryption should match', () async {
    String encrypted;
    Uint8List decrypted;

    for (Uint8List msg in msgBuffers) {
      encrypted = await Asymmetric.encryptBytesAsync(msg, pubKey);
      decrypted = await Asymmetric.decryptBytesAsync(encrypted, privKey);
      expect(decrypted.join(","), msg.join(","),
          reason: "Decrypted string does not match");
    }
  });

  test('Encryption wrapper: Bytes should match', () async {
    Uint8List encrypted, decrypted;

    for (Uint8List msg in msgBuffers) {
      encrypted = await Asymmetric.encryptRawAsync(msg, pubKey);
      decrypted = await Asymmetric.decryptRawAsync(encrypted, privKey);
      expect(decrypted.join(","), msg.join(","),
          reason: "Decrypted string does not match");
    }
  });

  test("The sealed message should match the sync/async version", () async {
    String sEncrypted, sDecrypted, aEncrypted, aDecrypted;

    for (String msg in messages) {
      sEncrypted = Asymmetric.encryptString(msg, pubKey);
      sDecrypted = Asymmetric.decryptString(sEncrypted, privKey);
      aEncrypted = await Asymmetric.encryptStringAsync(msg, pubKey);
      aDecrypted = await Asymmetric.decryptStringAsync(aEncrypted, privKey);
      expect(sDecrypted, aDecrypted,
          reason: "The decrypted messages should match");
      expect(sDecrypted, msg,
          reason: "The decrypted message should match the original one");
    }
  });
}

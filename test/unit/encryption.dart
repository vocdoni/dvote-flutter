import 'package:test/test.dart';
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

final privKey =
    "91f86dd7a9ac258c4908ca8fbdd3157f84d1f74ffffcb9fa428fba14a1d40150";
final pubKey =
    "6876524df21d6983724a2b032e41471cc9f1772a9418c4d701fcebb6c306af50";

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

final encryptedMsgsFromJs = [
  [
    "exact move glare echo legal evoke hungry extend lucky bright dilemma goat",
    "oz8Il/o2VVExtZqeuiG8I/ah2aXg0Sd0uyI6RXqbHSvMA9LYW8CRL4sIOfku82ck+DSHBA86dZJzDwdIxiDyMwyU9I4LXDNhMRg2F4RWi/WKxUoBXjmrZjc4secxCI4PZiAvgmuGdf2d4rpFxeHHIATaTlSOVtqUqQ=="
  ],
  [
    "gold hockey hair critic curve cactus dice embark drama cloud riot panther",
    "ENUbrbTLAPdpPHFeUMysriq1zl5ZT0nA9ioJhAhRCSEqByPmffc5G77PmH4CWuSMx/MhtpaMwalKbNX+Kg4sgJrCXLkrCQrDgAESeq856gpQjxj04CuwK8BSsBEnYuwYLxpOuJNkfuIxsY0u36Na6f3W4ekTfoHp8w=="
  ],
  [
    "stage issue wrong infant swallow order bless series style dirt success program",
    "a7kJtmW0Meq+iJxeYgrkpdsMCQsdlkNq1XFxIKVL816H+PeNBtrJjmEnb91O4L0Cc6x1neiXiB7Z/1YiHyedGZ6xevBibpnXkqCwj1kz0EVhaKCJ9bWE0YbkvHCP3GYvhw/kUAM4jq5f4FpsxOfOC12V1CNurQqhFDIxWuy1"
  ],
  [
    "void carbon south picnic clarify wrist wage indoor tree october stereo skill",
    "kdFGTnQOZV7bjHdrCPXRZLQbomp4tMNZ+RVKa6sZT1k2L7USf3sg6wu0mJvpRyu0KxNb9ynHEq1FYp7AefJtt8Y7+fx3gU+iXW2YnS5F4R3oZIRyI9OTHCqLKG56HSx3XzpZzF3qsIRZJ9ZFoqX0w6khKFGaEDmpSUcRkQ=="
  ],
  [
    "blood increase target correct sad cloud depend nut case aware chair shiver",
    "HVvWIRw2j5NFI57W0xPG/Ef+6SUnC9CvjccYoF1bGlgTU9kkzK+0jPmgXwIqR4/WHE9tTK7FCJ3v9YApRpjgMafoiLp9icva5LnUZzs2dLh9LdCOCiI3+3aOSAFPvt/NEseW9ui9gA6kSv5tdpEPEaDPZkOoAdkCzlw="
  ],
  [
    "black sell obtain consider dwarf virtual tomato relax borrow pottery october risk",
    "OiugLdNGseR5DqBHNy81Ty52iiLi/lrFJibtVEjJkzq7IG6AZGQ6/Ies+Edx4wiFswxGitr5l8oUiB9lRyAkp3XqTnxxrw7glo7cBU9K1BDF3MERxf1W2xw/yi/n885L+9Uphh2rdEjrRS0+mITNgsoTtmOAcET4HusmIlSDntQv"
  ],
  [
    "right dash emerge like mountain claim hollow wine gentle very call grace",
    "LODQ0BbM2baUUNwfoHjQhPcIoDfShBN/1cmJ2Q1jWjnYmb1SLJF3wpAgvQxfRcYv/MDHZXzWcAjFu7jj3Eb1tqBlDw0SH6e8I00ed4BMCwQNU4j2xVuO1y57L22wOwfmrGsQx9iY9UaLdq81oFUmU6R9eTzwNGxS"
  ],
  [
    "spare oven blue girl snow plate actor shy object young juice tag",
    "A5DKcFA5I6GsyEAzUobd5/pX4TVChThmX7wsLZCpcSB/d3Nyk1o5obN8MZstiiJ/C06SyQ3yw6gaojLq6zmzR6E9jx+QEzwpH0AahIdwjTLE7Te+wzvxDdjs+r5TDkHi3GQg+Zxb2bIl0nW0gjOI7Q=="
  ],
  [
    "merge eager order silver wheat maid tobacco parent athlete crash purpose train",
    "Xx+e6RJ5J7TRFCRoTj7Faj1QICK2Vx7uBcn42IAsWW2Uvt04z3RPjnbNu3SZh30JrT69w9lXHKt2FtbC1yO3DxXwPaIGej3RF8jSqwK0CZGCzmn+W3JB4oor55bCoyJuV6qimD7DZUI4qfjQbxq8Cmm2Dy3n4fuz46ViMfiW"
  ],
  [
    "arch door romance curtain retire habit squirrel again treat dwarf toddler fitness",
    "UYC73qKgaWRXIY79oebuwgVW8YdzDWwMjgTc+p53zX/RH53h3XZBRqfqQJp7EVLo5wSHzcQde53ma8qNCJ87abbiYx9xBmvNNEx0E+ZMa3iBGT4QLckp3ewujIbjlDaB/CkvQjuZW20xxgyw665CRc8JJU8AsDJs+c1lCeoZIsNn"
  ],
  [
    "liberty disorder clerk punch subject museum ugly news pill victory school any",
    "FNmtmLuY0SxrenjbqYil6bOkTffAfpNuAIyYSPfxsWFC4S47Llf13Wh9sokk9hn2CzCzR7DcNK2t7/w7WDefDJUMRptNBE5wcrfT19e8DL4bTtBWDLwyV/GgDH67GnNS/Y06iVK4464tcfR/RDtZbVdN+pXN1HlGFsKEpew="
  ],
  [
    "health olive bid tortoise orchard like answer curious rabbit seed notable decade",
    "9ReHzKCDVRajIDODCXiemHAyJypf7/FZXSCizYomqwmsDeu/LZtIqO03Dq+7ol5hmbZOUaQ8ppEYdPoH14s/IufBQ/gEOBVVegdImsToA2KnbgFT9nd0yIOzSHSuy7xNIFsxYLFeH9B0t4AoZOY9h7awmEerzaR92uLxeSNOnxA="
  ],
  [
    "poet scrap soda because stumble foster depth snap range box cruise monster",
    "mssXLCEQJvBBTrVqFy9Aek0i31yAQ0dZaX0x3OZiqCjcQoUYgclU7V4vLdq7b2RjNiZ35h6qpioMEm5405d39bBc51ZlgUxLXFiGBbVCBMDyU/xWmXQRSYBplmn5ELEsiSG+m4OcY2AqNHSROIqCVnAP7fa4h19qdPg="
  ],
  [
    "bus sand above ocean damage marine rice morning huge where outer there",
    "+pTOi6XTXfoYX5OmIfz4fujKFy6aVKOqRkkBeK4b5XsD1aNKNjCS3RayxOXN/iMrsmrrW1RIQgJn5kfBYayHh+Hk1CN2DD7NiWWvl8gO3qZ40zqMfL6eRZ8/L0hCbNhvWgptzW/ZFNByhvscVzHu5V48PA1NHA=="
  ],
  [
    "rabbit ten orphan climb divorce mother laugh fox hammer inspire theme glide",
    "NQJQfIxDKOovuVL9m703Y0MR/T/g1341OXb5hO9ONX8Z+axVHWVNRrREHDy9duCLY4fWCm8vdAWT2fs47eyd+JbTEpYUdwGx4nQJIw9iwhehUB/p6GGjtvjpCn4JI2rumCn2LGR//Ax14WJFuOMKPPSPjzKAJwptZOxR"
  ],
  [
    "weird hammer skill intact right canvas spoil way artist mail light cute",
    "39rk7aymqdBSaD1kY6e9eI1ws2mdz0BVqj2R0eHnP2cJWMqSgRgrqRf87eZy1hgbZ9LtafFKU7FvB/b1Bwq9m+oia6w7uilJJ8u8pxKN6kRlnOGVMGGIPaTRjzoQyh4ZS7Y5GJYGAXc9PQDCpTFPcqTtTxuJU34="
  ],
  [
    "layer razor cement puppy tag echo access huge tattoo search donor base",
    "pLuazTgjhinWelNemiaLMV/yKjnVEVICnwWOhuIzczAJ5xsR6EOEzTt+Q5IPZ1d57df8sJG7PK3vJymFBeZ4Om/0erDR0h9c4e5WwOBYJYGEZBqEJldAQcBHLZ2AHOM+zDHOdXeovnE9vI8jlWVlCvnLJk5rNw=="
  ],
  [
    "embrace crisp legend purchase describe iron tornado dignity borrow require strong obvious",
    "9YBz3d8OQshokoGw2nBwPUifxxDRlzXfP0jQZ3/yOQ5XfXlTr7F50O34+3Yj+E3C/1Lw9Mx8dd/df2THmsX6+tp0WkwdcdamcDe8Kz6pKk/GzeX/U4J8CyXMBg6VqK7OSua1AMcEuN7eoyRTf4c3aXXOHjyE/UF22Q2i4NqQVigj1YBP11v6WU0="
  ],
  [
    "tide marriage fence special student mesh marine wasp fashion put soon wise",
    "o5RWOeo1uwsoAErFNy3aecOkYrXAiITaVsXb1yQRY2+8lQGMPwUWShDnBEhw6VbBmnGb3bb2mh5bYT7urAXv6Nr6v2w1EsXARggtffe4iDAkd1iiHOERtIboks/AwPP1v4LiimHBPsu938/YaKHbgf/ROvARkdb++9E="
  ],
  [
    "owner sadness clerk thunder ordinary injury dignity system happy zero account alone",
    "RMRYOcvOk5Y1fOB+n39z22T6iXBXiqJJKGoKG224sylAlyJAf+r+9cC2S9Tn+qzSuwFT/Xdvp+IOVuhMOhJxXLDzOeE4tm3+mnT9FADeEV4p8EjLr/J8Q/tCXKt/O7fQaVNnkKwUwk3MSfx1y9cLadDyLoEFRjxzI+h03Ok6DZv92yY="
  ],
  [
    "deal oyster snow focus throw simple fee diet weapon combine worry badge",
    "1RcMJhNe3R7VXN22/jOfP2PaCMMKiHMJ93lF+kC0zzwqxGoeRgQ9x9W+Ak2Ks9aNu8Y3pScakYlwdCz29S4D/73IxutBYIVNu19g9SSxecF7GLnIpDh0Ow3+Une/7sUWTyUzQnNTqyACZ102eSmbzj7t7CgmO1U="
  ],
  [
    "work bench brief rug peace renew mansion assist improve universe uphold basic",
    "xvzto5LbTsCh/E7S4+QlIx2rP8GiVqtbZ9DYIak4dRl9Gd+2So4j4vzElcpJLO+NIVXfYCJcQbYm4ieaEXixOOswELBoUbCWZYnHyfBEWjiHWtxYVvgFk/mypK3pqmXTt18PPCgXnCctmW+QyZMR+7T0rUlpITsafBiU9i8="
  ],
  [
    "forum hold enrich caught cloud way chest resemble peasant scene token ostrich",
    "qUnFw82bG0PYhC7KVZ8RCDWMq681XddBBeCZocA3JC5ZPCUTDiDHbzxjKhgxKcDRKGiHz7oGA/v1Iulr57Tz4cBNBt5oPahDbAFzdkFA0eP+s58+aDfS83vw7YVToRc3JPRPtuFgzR50Uk6M5UmNXahbMwntvb9jaKBJX44="
  ],
  [
    "never amount pitch mass smile caution interest liquid cupboard sketch gossip dizzy",
    "DGv9drPL8cRVjmkE09OC0cJubzPhBXIUFs+hXDSMpCz5NxgfzuoDdrBgW7sl2Zjkwbpn6JbO7tSpTgDD+9Y7W3klIkaLrAy9sxUZQI+gTIlQqxe9le62olcsnHqjOZ78VeDwQzrJ8/bs74KTDCndBOKQtCbIzuta03SdjS0BWhOqAw=="
  ],
  [
    "puzzle choose lunar runway another trade stable dawn viable combine remove ivory",
    "fHjL6i9793jOanVENeV1CSTbad0bolf8hmMS8MuoFWkMNGPHeDH4FHqR+GMUEsz4XoU3esq72Gva1gawrL7a82HZMoAMgrGJVPjNia5IFR/1LaBWnQDozrpzGViaD34eu3uMcaZhSOExi9ZzlCcUZkPGQhqN0O368yTpwYLqufk="
  ],
  [
    "barrel nice ceiling wild fox blur buffalo daughter load long wish cool",
    "EFwd62Hf+sB+SfJHDJXdy//LMg7cU1pykxuE3oYlgEplO50g99qOGJsUpnYxOmtHgzz3TPUX94hx/hMu2CT90CCDdzvIdJJ8j4Ep2AFdjFRohIOHn6uMQen8jNTP3cRQJQOA85IH+6WuRNCWK+HJWUd5NMNB+Q=="
  ],
  [
    "ozone hold cotton guess smart travel march open marriage sock crew abandon",
    "4F6hOfT6cDKnkGA5XrXdVWUWNCxBM9wYQ1HNrwmwUAXF3R4uQTntnt/cMnsYg1ZaicLiM3oLZYDhprrUdCy4cr37xUTeQjZt77WZYSgqFejhyb8khGrxy+NbvAXBIbPFWzULdFg6qu5mpOdTWGeEWd+cTy5BOSbnDOo="
  ],
  [
    "ceiling throw tool front vacuum border grape solar organ absent frozen decade",
    "EvRaTr5w3xx+zVXZxW2rJrv6ZmmFwnY9KkDj/OpHSH5/9IkRTBAsfKvEfpffCpIXIzOXN1N107WeVZfS4pe/d73NhS1RTH+JHJv0RQajtCoahe1li9HjC3HHW1o8fFeAakMquCyHpxgCyftougT8qeVKRURoFb7s4B4txqQ="
  ],
  [
    "fire scorpion pattern claw original dwarf relief horn stem silly inherit animal",
    "9tZde12QUZI0Mvy61u68ZGUXlZ3RBlDpxCPkvxFWUwzl/sE/uZAj8Zzyi5N8f1kx7zSvxyHcgFG/uivrFlIJOJSQ/HV0bW7nF1eIjt0ru7qbOjsOSqLkaWO+noGVoKuhvinJP0J6LooNUWrXRX/THdTouipWCzVbhWBAL8sEFg=="
  ],
  [
    "stereo main birth memory focus liquid index crowd donate guess regret report",
    "zQtkiBjSuGlxo9cnB16QTCf2Wo73XNQ0Xkux++AFgm6CHw+D5umR2sSQsTeH4+S1+R7L5ncH6pEEXgEQTr+rvnBUwIqvKyNE5bzw0GZNJY+2hwcEttLQAgPDAfd4A8Dlna6emWfnFs04mtQqgmcUD1IjubCR0ROzNiDpLQ=="
  ],
  [
    "broccoli ecology physical situate kidney fruit cradle flight egg strike client trophy",
    "fyoRi6SXZPrAmTS7XEPwKjHP6ZxvqqktEPtyk6v7mx7C76tKXMuxJiqBaGwcFbBIcKxDVGLiPsN00aRINsCnhm0F4MHTWYNzZzVEyOgeJ06JdZToYgZeNE34wgk6hBZrQD3DGb/h0QG810tS3znWgzIQubeX8T0aCjNjoTcuubbqO068Zg=="
  ],
  [
    "ketchup hotel arctic ride prize lawsuit joke crucial success ozone orange custom",
    "se6RDtRkalflvmeM3IGn+6fZGJDjuboZGzAneVHkVUiCpYHXHZP5xGzxIg6u2/Tx1NffowCGisw6Y01GWaBL0F85XjFOkb7GyLlGmsZLYyviXgWq+1d7ztUFy4l0erPmHWgSBL8dSQxgmDnE5+yFIT/BGXEyjxSsK2nz0POpKGM="
  ],
  [
    "jaguar tiger increase legal sentence mammal planet very shield blind field puzzle",
    "Pe+cnmyrM0KKs8s2Vr2FojbKydH2z2QEMNJCX7fGC2PL6/rsnd4PveD6qcn/pexYluBTlxd1Jftg0xi3jiF3cMRDUE6PAz+2DQ4ZpjLO02YB6Sfv8j1khlI10zKC5oCIKN49GfCpEhTeNmZibET0n4wQCyCg8kV2OqW0X1iuKR2W"
  ],
  [
    "green spike please scout shoe measure force remain dragon victory coral stool",
    "yaPJJcFvsNY8cALMAgN8JrTYyvMEUKFNrpJmaBZ64kkBka0AchQOOQn73Erj2Q6DNn0KgijLzXRlDl62cY7ZEG5X9EFnkcZ8vv98JipZHqjeTnTzl0hFbos4saRiktebPwxdIikDEtiSVeR2N10mrx74XNCM2AcxwtvhEIw="
  ],
  [
    "hospital blame journey squirrel gadget fix winner arch umbrella sing you truly",
    "JsZvWdX2WK4+zsjmVPwLMNRqqSrDSl80jnqkBeYujlvFvOfWOWc1RVGuU79HoMjoD55IEve4OvkQjgeGQHb83ct+VnNRCcoReu0/R38f5bKWZL5iJyye5aYStyfwGkHx6C6usWYtJRoanIURi7B9VdPvyJ8Skwpwyd5oQ8Au"
  ],
  [
    "creek panic skate knee melt refuse draft scrap trap phrase differ hollow",
    "sOWApk5ihFdOgrd2iL1k+FqO2Ias1EAhWMIvPtkHiCpNNyVoD6u5hEQwu6wqPjE8MEB2n/HXeyodPzU3xPqBDW5hrCd13JyOr1ZWlUo4NXZrM2kzC1LxvSSt5a7pR2KhogPvene9S6uMRPch8Izm+lr8TgmYFjbC"
  ],
  [
    "pact clay evil model dilemma resemble luggage patch little aspect network extra",
    "oUObVYX91Ke+yDpv9VWf5CJHZWbY0Yrn56vOsqAv6T7bvO2/bC5RKF7UVrAa37LwmOfpn4nm36X3WXeFHN/NBULhcnz7K1CxZAFURxvCnmmFtwIK8E+3RKoo4E7bOr10rvHehrYeNZ4ErbuMCNDlC9CcPPy/FLYXdlcYAPFRGg=="
  ],
  [
    "broken state design gold banner tribe tongue system replace enact oil crazy",
    "LajpYbvtz9OsoGtcsSKGLHlsxv/8D2hmIrZYWuePOGgoDj4NvozrW55IoGzK8geL6S8mmPHGZENGFc6J/fBgCjJaAxKLsGEAESmqclxShqIUV23tEqhQ/RUmcOZ4G3U+Frc7ueQqFF5LdevdfAUtjKcglF3I5rSeZ6G7"
  ],
  [
    "beyond wait flower inch cradle main surround inner travel produce monitor crack",
    "hWqWWZAWyuB/KnmLuuvrhD9nZt5JLfrNQ76x0iHW1XpOiD4KVE9us5faxb7dBUoEGRW5NcGhXDnuTmchC73ZWw5OblPi5jCmRUAKgPGOTaVgBhGhffPwuaJuxpSP/4SfqYSnRBqoOgY4tjHX9DMUfFgDkFHuLhohsa+7lvnjrg=="
  ],
  [
    "smoke blossom control grape file valve hope antique rain arrest arena finish",
    "rBz6wQTDp/2Uw3Fbm2nbfGEkIgVgcJnRiMEaJm4i23+0FBaDeXsNbt9KnBQ7EaSq32j96UZbhds7utRKLoXOgHiagoItMKXLJmojvLWYAIm6wIAZ6J3Vd86vm7Zl5vrnpm8FkrfM3yvmDawyCnIkHnn5DtB1ngIgvrX+4w=="
  ],
  [
    "awesome fan doll boil cruel hedgehog sudden expect vault polar merit vault",
    "h0cdU9+6A/PFsgx3XN7DjnMmqeus+ICqlLyqtFe0OmSkibvg03bYKOEHiy6Yt2aN7E66WvE+DMPtDnQcOj2K7+z8swUZopsViLg8wVp82uDhZnOssQ6DVpiF/bnSkKiJtMimseNKdb2WCNlfPjL/+7u7URIlS9bBN+4="
  ],
  [
    "genuine vocal delay enroll tomorrow tiger lyrics luggage make undo pulp guard",
    "toF4nz6Re1S/AESXlyLpuQK1J/PW4lGeDUcxhl6EsT9ba67BnUSPkbrfvgF855s8TAP11fLI7J7BbBFHJge0c9D+UlL7SDidWam9QU02SdMDJkiP1zoTD1Ht0ewIKfoWnWp/9C0HRKWHuH/HOtWl7D3rMInPS61dzHi1j+I="
  ],
  [
    "below hungry lazy mutual place slush basket cupboard become endless coast puzzle",
    "Sm1PJ6k1REbl18f5xPjZ8JIcbsPq47f6/6K950/T/XHsFkllf/zBd+Y+WgiLgsRxsVka3CHcYeEPkUzB8Zpgyq/0O7p+JT2RgPWhzmQh/VAv3gjLI7e09RtOzG9BN8sOGWm8MwfdMTi3wN3PyPo3LSGkDWmsL3+HJabKP+NnB7k="
  ],
  [
    "cherry van critic option deer smart track spin ticket upset crystal list",
    "RY2vuhO5aiY3E5Vi/Xnjr7Y0fW51001G2DhQm5hS9giFUlMuUOUOVD6TpFACFjO+0XqoJFC2dyYg3rBqGbU9uyVQs/RrwHWey4EC8Q3Z210QYYgNA7GttI+FXtK7a8ZsAX01wn31Z16ZgwXfkixZ2L/+hgOS76X2"
  ],
  [
    "limb salad nose index member exit tomorrow bus plastic twist top twist",
    "kG+FEKrojEjm9dd0ZaBIzbB4hes2Bsy6o51Nuf36ERlYC1EUQEMYybkrEX4LdkGxmL2yk1j0ndq7SZrgg9Kysi2zeoHzO5USymWoidhaCkcrEtxc3lanKzz3BP5rbRYmtsL1Tpv0Gf0Mbo8d+tb3rqWMpnza0g=="
  ],
  [
    "recipe crazy pass bench off round section spirit oak grape cover camp",
    "sd5iq3LzaTnoRR15qnoQm97LYF+Jxe+DEc3rvrIHri7eVFT8HB9vltfT0P4suEKk4n1AmReZ2B1ZmGqoz8Ou2GZk60WYuyV2wPJkURDgFyRWGdx1b68DxEfSIu8JEUTBcr73hPZryfvsBMQQBmk2WypeMLoY"
  ],
  [
    "void cannon fresh wrap movie payment sudden replace toy twin start ability",
    "4wg9SFmkRDNRahtQ95ygSkPdTnPFUdQGS0xpGUyA8wi4M7LQjYMD9GiT7XLSajN/rDs8WZ58uECW8DNMYvTHwHE59DK7HjSJ+e0b+PErWNlXOtPeoFL6URm3phpo1oTd8xb48AIg28XlSsV15j/MNiANTfh7EoDhpH8="
  ],
  [
    "frequent radar culture pottery swim confirm bulb alone version orient amateur enemy",
    "i50K1rmOa6IyTI99t8aMdWiX4EwB593AhkCuPX+f0TMYqTUqjFtsxILzwI6BBqZA8kGtBoMM3LT59FD4qhjUvZr38PGKsWHC4ku8RbHSOHDP20c6S9TGzkbYsXNAW9g0R4fnNXhBdYAILeHexC9t5K1JOlsOGgQ8hePLnDv6UemCzlg="
  ],
  [
    "gossip cruel alarm sport boat velvet isolate pig zebra extend inquiry mushroom",
    "kCpZqKgZUBEVHf0di/ZdxgwPiVEc+7lXY/9rT97oLkAB/l3Vdhq/99RVjAiuGlIxiRBdm2N79w92n7/F8rWws1PqIIW8Y01k6Uv2Tm//fTeqoqO9P7XrSE7llBUIhj3vYna3e+mCs11o3sqy1F7yflImuhBeQmBhDKAoR0yH"
  ],
  [
    "among cherry melt tail lucky whisper area subway gate hill fiction excess",
    "wR79JZFeYHGcQJ1bD9yaQZ4F4/Zw+b2WFI/qmlzHgRMFQsbQCER3aLZureyhEhztXgsZm0y0oUtjYsleu/rSMu/1Kaklz6n/DWkyOFM3zzBzwmZEBUSJKAmYH9VAagWTCvBu96Zs+gmuKgTuxXkUkvy5S1OBw/8TYA=="
  ],
];

testAsymmetricEncriptionWrapper() {
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

  test(
      "Encryption wrapper: Should decrypt messages encrypted from TweetNaCl (JS)",
      () {
    String decrypted;

    for (var item in encryptedMsgsFromJs) {
      decrypted = Asymmetric.decryptString(item[1], privKey);
      expect(decrypted, item[0],
          reason: "The decrypted message should match the JS original one");
    }
  });
}

testAsymmetricEncriptionAsyncWrapper() {
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

import 'dart:convert';
import 'package:convert/convert.dart';
import 'dart:typed_data';
import 'package:crypto/crypto.dart'; // To hash the passphrase to a fixed length
import 'package:dvote/crypto/asyncify.dart';
import 'package:pinenacl/secret.dart'
    show SecretBox, SealedBox, PrivateKey, PublicKey, EncryptedMessage;

// All of the methods below provide two versions, a sync and an async one.
// Async versions allow to detach heavy computations from the UI thread.
// Both versions invoke the same helper functions at the bottom.

class Symmetric {
  /// Encrypts the given data using NaCl SecretBox and returns a Uint8List containing `nonce[24] + cipherText[]`.
  /// The 24 first bytes represent the nonce, and the rest of the buffer contains the cipher text.
  static Uint8List encryptRaw(Uint8List buffer, String passphrase) {
    return _encryptSymmetricRaw([buffer, passphrase]);
  }

  /// Encrypts the given data using NaCl SecretBox and returns a Uint8List Future containing `nonce[24] + cipherText[]`.
  /// The 24 first bytes represent the nonce, and the rest of the buffer contains the cipher text.
  static Future<Uint8List> encryptRawAsync(
      Uint8List buffer, String passphrase) {
    return wrap2ParamFunc<Uint8List, Uint8List, String>(
        _encryptSymmetricRaw, buffer, passphrase);
  }

  /// Encrypts the given data using NaCl SecretBox and returns a Base64 string containing `nonce[24] + cipherText[]`.
  /// The 24 first bytes represent the nonce, and the rest of the buffer contains the cipher text.
  static String encryptBytes(Uint8List buffer, String passphrase) {
    return _encryptSymmetricBytes([buffer, passphrase]);
  }

  /// Encrypts the given data using NaCl SecretBox and returns a Base64 string Future containing `nonce[24] + cipherText[]`.
  /// The 24 first bytes represent the nonce, and the rest of the buffer contains the cipher text.
  static Future<String> encryptBytesAsync(Uint8List buffer, String passphrase) {
    return wrap2ParamFunc<String, Uint8List, String>(
        _encryptSymmetricBytes, buffer, passphrase);
  }

  /// Encrypts the given string using NaCl SecretBox and returns a Base64 string containing `nonce[24] + cipherText[]`.
  /// The 24 first bytes must contain the nonce, and the rest of the buffer needs to contain the cipher text.
  static String encryptString(String message, String passphrase) {
    return _encryptSymmetricString([message, passphrase]);
  }

  /// Encrypts the given string using NaCl SecretBox and returns a Base64 string Future containing `nonce[24] + cipherText[]`.
  /// The 24 first bytes must contain the nonce, and the rest of the buffer needs to contain the cipher text.
  static Future<String> encryptStringAsync(String message, String passphrase) {
    return wrap2ParamFunc<String, String, String>(
        _encryptSymmetricString, message, passphrase);
  }

  /// Decrypts a byte array containing `nonce[24] + cipherText[]` using NaCl SecretBox:
  /// https://github.com/ilap/pinenacl-dart#a-secret-key-encryption-example
  static Uint8List decryptRaw(Uint8List encryptedBuffer, String passphrase) {
    return _decryptSymmetricRaw([encryptedBuffer, passphrase]);
  }

  /// Decrypts a byte array containing `nonce[24] + cipherText[]` using NaCl SecretBox:
  /// https://github.com/ilap/pinenacl-dart#a-secret-key-encryption-example
  static Future<Uint8List> decryptRawAsync(
      Uint8List encryptedBuffer, String passphrase) {
    return wrap2ParamFunc<Uint8List, Uint8List, String>(
        _decryptSymmetricRaw, encryptedBuffer, passphrase);
  }

  /// Decrypts a byte array containing `nonce[24] + cipherText[]` using NaCl SecretBox:
  /// https://github.com/ilap/pinenacl-dart#a-secret-key-encryption-example
  static Uint8List decryptBytes(String encryptedBase64, String passphrase) {
    return _decryptSymmetricBytes([encryptedBase64, passphrase]);
  }

  /// Decrypts a byte array containing `nonce[24] + cipherText[]` using NaCl SecretBox:
  /// https://github.com/ilap/pinenacl-dart#a-secret-key-encryption-example
  static Future<Uint8List> decryptBytesAsync(
      String encryptedBase64, String passphrase) {
    return wrap2ParamFunc<Uint8List, String, String>(
        _decryptSymmetricBytes, encryptedBase64, passphrase);
  }

  /// Decrypts a byte array containing `nonce[24] + cipherText[]` into a String using NaCl SecretBox:
  /// https://github.com/ilap/pinenacl-dart#a-secret-key-encryption-example
  static String decryptString(String encryptedBase64, String passphrase) {
    return _decryptSymmetricString([encryptedBase64, passphrase]);
  }

  /// Decrypts a byte array containing `nonce[24] + cipherText[]` into a String Future using NaCl SecretBox:
  /// https://github.com/ilap/pinenacl-dart#a-secret-key-encryption-example
  static Future<String> decryptStringAsync(
      String encryptedBase64, String passphrase) {
    return wrap2ParamFunc<String, String, String>(
        _decryptSymmetricString, encryptedBase64, passphrase);
  }
}

class Asymmetric {
  /// Encrypts the given buffer using hexPublicKey and returns the resulting buffer
  static Uint8List encryptRaw(Uint8List payload, String hexPublicKey) {
    return _encryptAsymmetricRaw([payload, hexPublicKey]);
  }

  /// Encrypts the given buffer using hexPublicKey and returns the resulting buffer
  static Future<Uint8List> encryptRawAsync(
      Uint8List payload, String hexPublicKey) {
    return wrap2ParamFunc<Uint8List, Uint8List, String>(
        _encryptAsymmetricRaw, payload, hexPublicKey);
  }

  /// Encrypts the given buffer using hexPublicKey and returns a base64 string with the result
  static String encryptBytes(Uint8List payload, String hexPublicKey) {
    return _encryptAsymmetricBytes([payload, hexPublicKey]);
  }

  /// Encrypts the given buffer using hexPublicKey and returns a base64 string with the result
  static Future<String> encryptBytesAsync(
      Uint8List payload, String hexPublicKey) {
    return wrap2ParamFunc<String, Uint8List, String>(
        _encryptAsymmetricBytes, payload, hexPublicKey);
  }

  /// Encrypts the given string using hexPublicKey and returns a base64 string with the result
  static String encryptString(String message, String hexPublicKey) {
    return _encryptAsymmetricString([message, hexPublicKey]);
  }

  /// Encrypts the given string using hexPublicKey and returns a base64 string with the result
  static Future<String> encryptStringAsync(
      String message, String hexPublicKey) {
    return wrap2ParamFunc<String, String, String>(
        _encryptAsymmetricString, message, hexPublicKey);
  }

  /// Decrypts the given buffer using hexPublicKey and returns the resulting buffer
  static Uint8List decryptRaw(Uint8List encryptedBuffer, String hexPrivateKey) {
    return _decryptAsymmetricRaw([encryptedBuffer, hexPrivateKey]);
  }

  /// Decrypts the given buffer using hexPublicKey and returns the resulting buffer
  static Future<Uint8List> decryptRawAsync(
      Uint8List encryptedBuffer, String hexPrivateKey) {
    return wrap2ParamFunc<Uint8List, Uint8List, String>(
        _decryptAsymmetricRaw, encryptedBuffer, hexPrivateKey);
  }

  /// Decrypts the given base64 string using hexPublicKey and returns the original buffer
  static Uint8List decryptBytes(String encryptedBase64, String hexPrivateKey) {
    return _decryptAsymmetricBytes([encryptedBase64, hexPrivateKey]);
  }

  /// Decrypts the given base64 string using hexPublicKey and returns the original buffer
  static Future<Uint8List> decryptBytesAsync(
      String encryptedBase64, String hexPrivateKey) {
    return wrap2ParamFunc<Uint8List, String, String>(
        _decryptAsymmetricBytes, encryptedBase64, hexPrivateKey);
  }

  /// Decrypts the given base64 string using hexPublicKey and returns the original string
  static String decryptString(String encryptedBase64, String hexPrivateKey) {
    return _decryptAsymmetricString([encryptedBase64, hexPrivateKey]);
  }

  /// Decrypts the given base64 string using hexPublicKey and returns the original string
  static Future<String> decryptStringAsync(
      String encryptedBase64, String hexPrivateKey) {
    return wrap2ParamFunc<String, String, String>(
        _decryptAsymmetricString, encryptedBase64, hexPrivateKey);
  }
}

// ////////////////////////////////////////////////////////////////////////////
// / IMPLEMENTATION
// ////////////////////////////////////////////////////////////////////////////

// The helpers below will be called within compute<T, R>(...) and only accept one parameter

/// Encrypts the given data using NaCl SecretBox and returns a Uint8List containing `nonce[24] + cipherText[]`.
/// The 24 first bytes represent the nonce, and the rest of the buffer contains the cipher text.
Uint8List _encryptSymmetricRaw(List<dynamic> args) {
  assert(args.length == 2);
  final buffer = args[0];
  assert(buffer is Uint8List);
  final passphrase = args[1];
  assert(passphrase is String);

  final key = utf8.encode(passphrase);
  final keyDigest =
      sha256.convert(key); // Hash the passphrase to get a 32 byte key
  final box = SecretBox(keyDigest.bytes);
  final encrypted = box.encrypt(buffer);

  return Uint8List.fromList(encrypted.toList());
}

/// Encrypts the given data using NaCl SecretBox and returns a Base64 string containing `nonce[24] + cipherText[]`.
/// The 24 first bytes represent the nonce, and the rest of the buffer contains the cipher text.
String _encryptSymmetricBytes(List<dynamic> args) {
  assert(args.length == 2);
  final buffer = args[0];
  assert(buffer is Uint8List);
  final passphrase = args[1];
  assert(passphrase is String);

  final encryptedBuffer = _encryptSymmetricRaw([buffer, passphrase]);
  return base64.encode(encryptedBuffer);
}

/// Encrypts the given string using NaCl SecretBox and returns a Base64 string containing `nonce[24] + cipherText[]`.
/// The 24 first bytes must contain the nonce, and the rest of the buffer needs to contain the cipher text.
String _encryptSymmetricString(List<dynamic> args) {
  assert(args.length == 2);
  final message = args[0];
  assert(message is String);
  final passphrase = args[1];
  assert(passphrase is String);

  final messageBytes = Uint8List.fromList(utf8.encode(message));
  final encryptedBuffer = _encryptSymmetricRaw([messageBytes, passphrase]);

  return base64.encode(encryptedBuffer);
}

/// Decrypts a byte array containing `nonce[24] + cipherText[]` using NaCl SecretBox:
/// https://github.com/ilap/pinenacl-dart#a-secret-key-encryption-example
Uint8List _decryptSymmetricRaw(List<dynamic> args) {
  assert(args.length == 2);
  final encryptedBuffer = args[0];
  assert(encryptedBuffer is Uint8List);
  final passphrase = args[1];
  assert(passphrase is String);

  final key = utf8.encode(passphrase);
  final keyDigest =
      sha256.convert(key); // Hash the passphrase to get a 32 byte key
  final box = SecretBox(keyDigest.bytes);

  final encrypted = EncryptedMessage(
      cipherText: encryptedBuffer.sublist(24),
      nonce: encryptedBuffer.sublist(0, 24));
  return box.decrypt(encrypted);
}

/// Decrypts a byte array containing `nonce[24] + cipherText[]` using NaCl SecretBox:
/// https://github.com/ilap/pinenacl-dart#a-secret-key-encryption-example
Uint8List _decryptSymmetricBytes(List<dynamic> args) {
  assert(args.length == 2);
  final encryptedBase64 = args[0];
  assert(encryptedBase64 is String);
  final passphrase = args[1];
  assert(passphrase is String);

  final encryptedBuffer = base64.decode(encryptedBase64);
  return _decryptSymmetricRaw([encryptedBuffer, passphrase]);
}

/// Decrypts a byte array containing `nonce[24] + cipherText[]` into a String using NaCl SecretBox:
/// https://github.com/ilap/pinenacl-dart#a-secret-key-encryption-example
String _decryptSymmetricString(List<dynamic> args) {
  assert(args.length == 2);
  final encryptedBase64 = args[0];
  assert(encryptedBase64 is String);
  final passphrase = args[1];
  assert(passphrase is String);

  final encryptedBuffer = base64.decode(encryptedBase64);
  final strBytes = _decryptSymmetricRaw([encryptedBuffer, passphrase]);

  return utf8.decode(strBytes);
}

// Asymmetric

Uint8List _encryptAsymmetricRaw(List<dynamic> args) {
  assert(args.length == 2);
  final Uint8List bytesPayload = args[0];
  assert(bytesPayload is Uint8List);
  final hexPublicKey = args[1];
  assert(hexPublicKey is String);

  final pubKey = PublicKey(hex.decode(hexPublicKey));
  final sealedBox = SealedBox(pubKey);

  return sealedBox.encrypt(bytesPayload);
}

String _encryptAsymmetricBytes(List<dynamic> args) {
  assert(args.length == 2);
  final Uint8List bytesPayload = args[0];
  assert(bytesPayload is Uint8List);
  final hexPublicKey = args[1];
  assert(hexPublicKey is String);

  final pubKey = PublicKey(hex.decode(hexPublicKey));
  final sealedBox = SealedBox(pubKey);

  final encrypted = sealedBox.encrypt(bytesPayload);
  return base64.encode(encrypted);
}

String _encryptAsymmetricString(List<dynamic> args) {
  assert(args.length == 2);
  final strPayload = args[0];
  assert(strPayload is String);
  final hexPublicKey = args[1];
  assert(hexPublicKey is String);

  final pubKey = PublicKey(hex.decode(hexPublicKey));
  final sealedBox = SealedBox(pubKey);

  final encrypted = sealedBox.encrypt(utf8.encode(strPayload));
  return base64.encode(encrypted);
}

Uint8List _decryptAsymmetricRaw(List<dynamic> args) {
  assert(args.length == 2);
  final encryptedBytes = args[0];
  assert(encryptedBytes is Uint8List);
  final hexPrivateKey = args[1];
  assert(hexPrivateKey is String);

  final privKeyBytes = hex.decode(hexPrivateKey);
  final privKey = PrivateKey(privKeyBytes);

  final unsealedBox = SealedBox(privKey);
  return unsealedBox.decrypt(encryptedBytes);
}

Uint8List _decryptAsymmetricBytes(List<dynamic> args) {
  assert(args.length == 2);
  final encryptedBase64 = args[0];
  assert(encryptedBase64 is String);
  final hexPrivateKey = args[1];
  assert(hexPrivateKey is String);

  final encryptedBytes = base64.decode(encryptedBase64);

  final privKeyBytes = hex.decode(hexPrivateKey);
  final privKey = PrivateKey(privKeyBytes);

  final unsealedBox = SealedBox(privKey);
  return unsealedBox.decrypt(encryptedBytes);
}

String _decryptAsymmetricString(List<dynamic> args) {
  assert(args.length == 2);
  final encryptedBase64 = args[0];
  assert(encryptedBase64 is String);
  final hexPrivateKey = args[1];
  assert(hexPrivateKey is String);

  final encryptedBytes = base64.decode(encryptedBase64);

  final privKeyBytes = hex.decode(hexPrivateKey);
  final privKey = PrivateKey(privKeyBytes);

  final unsealedBox = SealedBox(privKey);

  final decrypted = unsealedBox.decrypt(encryptedBytes);
  return utf8.decode(decrypted);
}

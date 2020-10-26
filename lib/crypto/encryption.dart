import 'dart:convert';
import 'package:convert/convert.dart';
import 'dart:typed_data';
import 'package:crypto/crypto.dart'; // To hash the passphrase to a fixed length
import 'package:dvote/util/asyncify.dart';
import 'package:pinenacl/secret.dart'
    show SecretBox, SealedBox, PrivateKey, PublicKey, EncryptedMessage;

// All of the methods below provide two versions, a sync and an async one.
// Async versions allow to detach heavy computations from the UI thread.
// Both versions invoke the same helper functions at the bottom.

class Symmetric {
  /// Encrypts the given data using NaCl SecretBox and returns a Uint8List containing `nonce[24] + cipherText[]`.
  /// The 24 first bytes represent the nonce, and the rest of the buffer contains the cipher text.
  static Uint8List encryptRaw(Uint8List buffer, String passphrase) {
    return _encryptSymmetricRaw(buffer, passphrase);
  }

  /// Encrypts the given data using NaCl SecretBox and returns a Uint8List Future containing `nonce[24] + cipherText[]`.
  /// The 24 first bytes represent the nonce, and the rest of the buffer contains the cipher text.
  static Future<Uint8List> encryptRawAsync(
      Uint8List buffer, String passphrase) {
    return runAsync<Uint8List, Uint8List Function(Uint8List, String)>(
        _encryptSymmetricRaw, [buffer, passphrase]);
  }

  /// Encrypts the given data using NaCl SecretBox and returns a Base64 string containing `nonce[24] + cipherText[]`.
  /// The 24 first bytes represent the nonce, and the rest of the buffer contains the cipher text.
  static String encryptBytes(Uint8List buffer, String passphrase) {
    return _encryptSymmetricBytes(buffer, passphrase);
  }

  /// Encrypts the given data using NaCl SecretBox and returns a Base64 string Future containing `nonce[24] + cipherText[]`.
  /// The 24 first bytes represent the nonce, and the rest of the buffer contains the cipher text.
  static Future<String> encryptBytesAsync(Uint8List buffer, String passphrase) {
    return runAsync<String, String Function(Uint8List, String)>(
        _encryptSymmetricBytes, [buffer, passphrase]);
  }

  /// Encrypts the given string using NaCl SecretBox and returns a Base64 string containing `nonce[24] + cipherText[]`.
  /// The 24 first bytes must contain the nonce, and the rest of the buffer needs to contain the cipher text.
  static String encryptString(String message, String passphrase) {
    return _encryptSymmetricString(message, passphrase);
  }

  /// Encrypts the given string using NaCl SecretBox and returns a Base64 string Future containing `nonce[24] + cipherText[]`.
  /// The 24 first bytes must contain the nonce, and the rest of the buffer needs to contain the cipher text.
  static Future<String> encryptStringAsync(String message, String passphrase) {
    return runAsync<String, String Function(String, String)>(
        _encryptSymmetricString, [message, passphrase]);
  }

  /// Decrypts a byte array containing `nonce[24] + cipherText[]` using NaCl SecretBox:
  /// https://github.com/ilap/pinenacl-dart#a-secret-key-encryption-example
  static Uint8List decryptRaw(Uint8List encryptedBuffer, String passphrase) {
    return _decryptSymmetricRaw(encryptedBuffer, passphrase);
  }

  /// Decrypts a byte array containing `nonce[24] + cipherText[]` using NaCl SecretBox:
  /// https://github.com/ilap/pinenacl-dart#a-secret-key-encryption-example
  static Future<Uint8List> decryptRawAsync(
      Uint8List encryptedBuffer, String passphrase) {
    return runAsync<Uint8List, Uint8List Function(Uint8List, String)>(
        _decryptSymmetricRaw, [encryptedBuffer, passphrase]);
  }

  /// Decrypts a byte array containing `nonce[24] + cipherText[]` using NaCl SecretBox:
  /// https://github.com/ilap/pinenacl-dart#a-secret-key-encryption-example
  static Uint8List decryptBytes(String encryptedBase64, String passphrase) {
    return _decryptSymmetricBytes(encryptedBase64, passphrase);
  }

  /// Decrypts a byte array containing `nonce[24] + cipherText[]` using NaCl SecretBox:
  /// https://github.com/ilap/pinenacl-dart#a-secret-key-encryption-example
  static Future<Uint8List> decryptBytesAsync(
      String encryptedBase64, String passphrase) {
    return runAsync<Uint8List, Uint8List Function(String, String)>(
        _decryptSymmetricBytes, [encryptedBase64, passphrase]);
  }

  /// Decrypts a byte array containing `nonce[24] + cipherText[]` into a String using NaCl SecretBox:
  /// https://github.com/ilap/pinenacl-dart#a-secret-key-encryption-example
  static String decryptString(String encryptedBase64, String passphrase) {
    return _decryptSymmetricString(encryptedBase64, passphrase);
  }

  /// Decrypts a byte array containing `nonce[24] + cipherText[]` into a String Future using NaCl SecretBox:
  /// https://github.com/ilap/pinenacl-dart#a-secret-key-encryption-example
  static Future<String> decryptStringAsync(
      String encryptedBase64, String passphrase) {
    return runAsync<String, String Function(String, String)>(
        _decryptSymmetricString, [encryptedBase64, passphrase]);
  }
}

class Asymmetric {
  /// Encrypts the given buffer using hexPublicKey and returns the resulting buffer
  static Uint8List encryptRaw(Uint8List payload, String hexPublicKey) {
    return _encryptAsymmetricRaw(payload, hexPublicKey);
  }

  /// Encrypts the given buffer using hexPublicKey and returns the resulting buffer
  static Future<Uint8List> encryptRawAsync(
      Uint8List payload, String hexPublicKey) {
    return runAsync<Uint8List, Uint8List Function(Uint8List, String)>(
        _encryptAsymmetricRaw, [payload, hexPublicKey]);
  }

  /// Encrypts the given buffer using hexPublicKey and returns a base64 string with the result
  static String encryptBytes(Uint8List payload, String hexPublicKey) {
    return _encryptAsymmetricBytes(payload, hexPublicKey);
  }

  /// Encrypts the given buffer using hexPublicKey and returns a base64 string with the result
  static Future<String> encryptBytesAsync(
      Uint8List payload, String hexPublicKey) {
    return runAsync<String, String Function(Uint8List, String)>(
        _encryptAsymmetricBytes, [payload, hexPublicKey]);
  }

  /// Encrypts the given string using hexPublicKey and returns a base64 string with the result
  static String encryptString(String message, String hexPublicKey) {
    return _encryptAsymmetricString(message, hexPublicKey);
  }

  /// Encrypts the given string using hexPublicKey and returns a base64 string with the result
  static Future<String> encryptStringAsync(
      String message, String hexPublicKey) {
    return runAsync<String, String Function(String, String)>(
        _encryptAsymmetricString, [message, hexPublicKey]);
  }

  /// Decrypts the given buffer using hexPublicKey and returns the resulting buffer
  static Uint8List decryptRaw(Uint8List encryptedBuffer, String hexPrivateKey) {
    return _decryptAsymmetricRaw(encryptedBuffer, hexPrivateKey);
  }

  /// Decrypts the given buffer using hexPublicKey and returns the resulting buffer
  static Future<Uint8List> decryptRawAsync(
      Uint8List encryptedBuffer, String hexPrivateKey) {
    return runAsync<Uint8List, Uint8List Function(Uint8List, String)>(
        _decryptAsymmetricRaw, [encryptedBuffer, hexPrivateKey]);
  }

  /// Decrypts the given base64 string using hexPublicKey and returns the original buffer
  static Uint8List decryptBytes(String encryptedBase64, String hexPrivateKey) {
    return _decryptAsymmetricBytes(encryptedBase64, hexPrivateKey);
  }

  /// Decrypts the given base64 string using hexPublicKey and returns the original buffer
  static Future<Uint8List> decryptBytesAsync(
      String encryptedBase64, String hexPrivateKey) {
    return runAsync<Uint8List, Uint8List Function(String, String)>(
        _decryptAsymmetricBytes, [encryptedBase64, hexPrivateKey]);
  }

  /// Decrypts the given base64 string using hexPublicKey and returns the original string
  static String decryptString(String encryptedBase64, String hexPrivateKey) {
    return _decryptAsymmetricString(encryptedBase64, hexPrivateKey);
  }

  /// Decrypts the given base64 string using hexPublicKey and returns the original string
  static Future<String> decryptStringAsync(
      String encryptedBase64, String hexPrivateKey) {
    return runAsync<String, String Function(String, String)>(
        _decryptAsymmetricString, [encryptedBase64, hexPrivateKey]);
  }
}

// ////////////////////////////////////////////////////////////////////////////
// / IMPLEMENTATION
// ////////////////////////////////////////////////////////////////////////////

// The helpers below will be called within compute<T, R>(...) and only accept one parameter

/// Encrypts the given data using NaCl SecretBox and returns a Uint8List containing `nonce[24] + cipherText[]`.
/// The 24 first bytes represent the nonce, and the rest of the buffer contains the cipher text.
Uint8List _encryptSymmetricRaw(Uint8List buffer, String passphrase) {
  final key = utf8.encode(passphrase);
  final keyDigest =
      sha256.convert(key); // Hash the passphrase to get a 32 byte key
  final box = SecretBox(keyDigest.bytes);
  final encrypted = box.encrypt(buffer);

  return Uint8List.fromList(encrypted.toList());
}

/// Encrypts the given data using NaCl SecretBox and returns a Base64 string containing `nonce[24] + cipherText[]`.
/// The 24 first bytes represent the nonce, and the rest of the buffer contains the cipher text.
String _encryptSymmetricBytes(Uint8List buffer, String passphrase) {
  final encryptedBuffer = _encryptSymmetricRaw(buffer, passphrase);
  return base64.encode(encryptedBuffer);
}

/// Encrypts the given string using NaCl SecretBox and returns a Base64 string containing `nonce[24] + cipherText[]`.
/// The 24 first bytes must contain the nonce, and the rest of the buffer needs to contain the cipher text.
String _encryptSymmetricString(String message, String passphrase) {
  final messageBytes = Uint8List.fromList(utf8.encode(message));
  final encryptedBuffer = _encryptSymmetricRaw(messageBytes, passphrase);

  return base64.encode(encryptedBuffer);
}

/// Decrypts a byte array containing `nonce[24] + cipherText[]` using NaCl SecretBox:
/// https://github.com/ilap/pinenacl-dart#a-secret-key-encryption-example
Uint8List _decryptSymmetricRaw(Uint8List encryptedBuffer, String passphrase) {
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
Uint8List _decryptSymmetricBytes(String encryptedBase64, String passphrase) {
  final encryptedBuffer = base64.decode(encryptedBase64);
  return _decryptSymmetricRaw(encryptedBuffer, passphrase);
}

/// Decrypts a byte array containing `nonce[24] + cipherText[]` into a String using NaCl SecretBox:
/// https://github.com/ilap/pinenacl-dart#a-secret-key-encryption-example
String _decryptSymmetricString(String encryptedBase64, String passphrase) {
  final encryptedBuffer = base64.decode(encryptedBase64);
  final strBytes = _decryptSymmetricRaw(encryptedBuffer, passphrase);

  return utf8.decode(strBytes);
}

// Asymmetric

Uint8List _encryptAsymmetricRaw(Uint8List bytesPayload, String hexPublicKey) {
  final pubKey = PublicKey(hex.decode(hexPublicKey));
  final sealedBox = SealedBox(pubKey);

  return sealedBox.encrypt(bytesPayload);
}

String _encryptAsymmetricBytes(Uint8List bytesPayload, String hexPublicKey) {
  final pubKey = PublicKey(hex.decode(hexPublicKey));
  final sealedBox = SealedBox(pubKey);

  final encrypted = sealedBox.encrypt(bytesPayload);
  return base64.encode(encrypted);
}

String _encryptAsymmetricString(String strPayload, String hexPublicKey) {
  final pubKey = PublicKey(hex.decode(hexPublicKey));
  final sealedBox = SealedBox(pubKey);

  final encrypted = sealedBox.encrypt(utf8.encode(strPayload));
  return base64.encode(encrypted);
}

Uint8List _decryptAsymmetricRaw(
    Uint8List encryptedBytes, String hexPrivateKey) {
  final privKeyBytes = hex.decode(hexPrivateKey);
  final privKey = PrivateKey(privKeyBytes);

  final unsealedBox = SealedBox(privKey);
  return unsealedBox.decrypt(encryptedBytes);
}

Uint8List _decryptAsymmetricBytes(
    String encryptedBase64, String hexPrivateKey) {
  final encryptedBytes = base64.decode(encryptedBase64);

  final privKeyBytes = hex.decode(hexPrivateKey);
  final privKey = PrivateKey(privKeyBytes);

  final unsealedBox = SealedBox(privKey);
  return unsealedBox.decrypt(encryptedBytes);
}

String _decryptAsymmetricString(String encryptedBase64, String hexPrivateKey) {
  final encryptedBytes = base64.decode(encryptedBase64);

  final privKeyBytes = hex.decode(hexPrivateKey);
  final privKey = PrivateKey(privKeyBytes);

  final unsealedBox = SealedBox(privKey);

  final decrypted = unsealedBox.decrypt(encryptedBytes);
  return utf8.decode(decrypted);
}

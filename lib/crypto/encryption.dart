import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart'; // To hash the passphrase to a fixed length
import 'package:dvote/crypto/asyncify.dart';
import 'package:pinenacl/public.dart';
import 'package:pinenacl/secret.dart' show SecretBox;

// All of the methods below provide two versions, a sync and an async one.
// Async versions allow to detach heavy computations from the UI thread.
// Both versions invoke the same helper functions at the bottom.

class Symmetric {
  /// Encrypts the given data using NaCl SecretBox and returns a Uint8List containing `nonce[24] + cipherText[]`.
  /// The 24 first bytes represent the nonce, and the rest of the buffer contains the cipher text.
  static Uint8List encryptRaw(Uint8List buffer, String passphrase) {
    return _encryptRaw([buffer, passphrase]);
  }

  /// Encrypts the given data using NaCl SecretBox and returns a Uint8List Future containing `nonce[24] + cipherText[]`.
  /// The 24 first bytes represent the nonce, and the rest of the buffer contains the cipher text.
  static Future<Uint8List> encryptRawAsync(
      Uint8List buffer, String passphrase) {
    return wrap2ParamFunc<Uint8List, Uint8List, String>(
        _encryptRaw, buffer, passphrase);
  }

  /// Encrypts the given data using NaCl SecretBox and returns a Base64 string containing `nonce[24] + cipherText[]`.
  /// The 24 first bytes represent the nonce, and the rest of the buffer contains the cipher text.
  static String encryptBytes(Uint8List buffer, String passphrase) {
    return _encryptBytes([buffer, passphrase]);
  }

  /// Encrypts the given data using NaCl SecretBox and returns a Base64 string Future containing `nonce[24] + cipherText[]`.
  /// The 24 first bytes represent the nonce, and the rest of the buffer contains the cipher text.
  static Future<String> encryptBytesAsync(Uint8List buffer, String passphrase) {
    return wrap2ParamFunc<String, Uint8List, String>(
        _encryptBytes, buffer, passphrase);
  }

  /// Encrypts the given string using NaCl SecretBox and returns a Base64 string containing `nonce[24] + cipherText[]`.
  /// The 24 first bytes must contain the nonce, and the rest of the buffer needs to contain the cipher text.
  static String encryptString(String message, String passphrase) {
    return _encryptString([message, passphrase]);
  }

  /// Encrypts the given string using NaCl SecretBox and returns a Base64 string Future containing `nonce[24] + cipherText[]`.
  /// The 24 first bytes must contain the nonce, and the rest of the buffer needs to contain the cipher text.
  static Future<String> encryptStringAsync(String message, String passphrase) {
    return wrap2ParamFunc<String, String, String>(
        _encryptString, message, passphrase);
  }

  /// Decrypts a byte array containing `nonce[24] + cipherText[]` using NaCl SecretBox:
  /// https://github.com/ilap/pinenacl-dart#a-secret-key-encryption-example
  static Uint8List decryptRaw(Uint8List encryptedBuffer, String passphrase) {
    return _decryptRaw([encryptedBuffer, passphrase]);
  }

  /// Decrypts a byte array containing `nonce[24] + cipherText[]` using NaCl SecretBox:
  /// https://github.com/ilap/pinenacl-dart#a-secret-key-encryption-example
  static Future<Uint8List> decryptRawAsync(
      Uint8List encryptedBuffer, String passphrase) {
    return wrap2ParamFunc<Uint8List, Uint8List, String>(
        _decryptRaw, encryptedBuffer, passphrase);
  }

  /// Decrypts a byte array containing `nonce[24] + cipherText[]` using NaCl SecretBox:
  /// https://github.com/ilap/pinenacl-dart#a-secret-key-encryption-example
  static Uint8List decryptBytes(String encryptedBase64, String passphrase) {
    return _decryptBytes([encryptedBase64, passphrase]);
  }

  /// Decrypts a byte array containing `nonce[24] + cipherText[]` using NaCl SecretBox:
  /// https://github.com/ilap/pinenacl-dart#a-secret-key-encryption-example
  static Future<Uint8List> decryptBytesAsync(
      String encryptedBase64, String passphrase) {
    return wrap2ParamFunc<Uint8List, String, String>(
        _decryptBytes, encryptedBase64, passphrase);
  }

  /// Decrypts a byte array containing `nonce[24] + cipherText[]` into a String using NaCl SecretBox:
  /// https://github.com/ilap/pinenacl-dart#a-secret-key-encryption-example
  static String decryptString(String encryptedBase64, String passphrase) {
    return _decryptString([encryptedBase64, passphrase]);
  }

  /// Decrypts a byte array containing `nonce[24] + cipherText[]` into a String Future using NaCl SecretBox:
  /// https://github.com/ilap/pinenacl-dart#a-secret-key-encryption-example
  static Future<String> decryptStringAsync(
      String encryptedBase64, String passphrase) {
    return wrap2ParamFunc<String, String, String>(
        _decryptString, encryptedBase64, passphrase);
  }
}

// TODO: Implement for vote encryption
class Asymmetric {
  static String encryptString(String strPayload, String hexPublicKey) {
    throw Exception("Unimplemented");
  }

  static String decryptString(String strPayload, String hexPrivateKey) {
    throw Exception("Unimplemented");
  }
}

// ////////////////////////////////////////////////////////////////////////////
// / IMPLEMENTATION
// ////////////////////////////////////////////////////////////////////////////

// The helpers below will be called within compute<T, R>(...) and only accept one parameter

/// Encrypts the given data using NaCl SecretBox and returns a Uint8List containing `nonce[24] + cipherText[]`.
/// The 24 first bytes represent the nonce, and the rest of the buffer contains the cipher text.
Uint8List _encryptRaw(List<dynamic> args) {
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
String _encryptBytes(List<dynamic> args) {
  assert(args.length == 2);
  final buffer = args[0];
  assert(buffer is Uint8List);
  final passphrase = args[1];
  assert(passphrase is String);

  final encryptedBuffer = _encryptRaw([buffer, passphrase]);
  return base64.encode(encryptedBuffer);
}

/// Encrypts the given string using NaCl SecretBox and returns a Base64 string containing `nonce[24] + cipherText[]`.
/// The 24 first bytes must contain the nonce, and the rest of the buffer needs to contain the cipher text.
String _encryptString(List<dynamic> args) {
  assert(args.length == 2);
  final message = args[0];
  assert(message is String);
  final passphrase = args[1];
  assert(passphrase is String);

  final messageBytes = Uint8List.fromList(utf8.encode(message));
  final encryptedBuffer = _encryptRaw([messageBytes, passphrase]);

  return base64.encode(encryptedBuffer);
}

/// Decrypts a byte array containing `nonce[24] + cipherText[]` using NaCl SecretBox:
/// https://github.com/ilap/pinenacl-dart#a-secret-key-encryption-example
Uint8List _decryptRaw(List<dynamic> args) {
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
Uint8List _decryptBytes(List<dynamic> args) {
  assert(args.length == 2);
  final encryptedBase64 = args[0];
  assert(encryptedBase64 is String);
  final passphrase = args[1];
  assert(passphrase is String);

  final encryptedBuffer = base64.decode(encryptedBase64);
  return _decryptRaw([encryptedBuffer, passphrase]);
}

/// Decrypts a byte array containing `nonce[24] + cipherText[]` into a String using NaCl SecretBox:
/// https://github.com/ilap/pinenacl-dart#a-secret-key-encryption-example
String _decryptString(List<dynamic> args) {
  assert(args.length == 2);
  final encryptedBase64 = args[0];
  assert(encryptedBase64 is String);
  final passphrase = args[1];
  assert(passphrase is String);

  final encryptedBuffer = base64.decode(encryptedBase64);
  final strBytes = _decryptRaw([encryptedBuffer, passphrase]);

  return utf8.decode(strBytes);
}

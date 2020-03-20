import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:hex/hex.dart';
// import 'package:web3dart/web3dart.dart';
import 'package:web3dart/crypto.dart' as crypto;
import 'package:web3dart/src/utils/typed_data.dart' as typed;

const SIGNATURE_MESSAGE_PREFIX = '\u0019Ethereum Signed Message:\n';

/// Sign the given payload using the private key and return a hex signature
String signString(String payload, String hexPrivateKey, {int chainId}) {
  if (payload == null)
    throw Exception("The payload is empty");
  else if (hexPrivateKey == null) throw Exception("The privateKey is empty");

  try {
    // Async version with Web3Dart

    // final signerPrivKey = EthPrivateKey.fromHex(hexPrivateKey.startsWith("0x")
    //     ? hexPrivateKey.substring(2)
    //     : hexPrivateKey);
    // final payloadBytes = Uint8List.fromList(utf8.encode(payload));
    // final signature =
    //     await signerPrivKey.signPersonalMessage(payloadBytes, chainId: chainId);
    // return "0x" + HEX.encode(signature);

    final hashedPayload = _hashPayloadForSignature(payload);

    final privKeyBytes = hexPrivateKey.startsWith("0x")
        ? Uint8List.fromList(HEX.decode(hexPrivateKey.substring(2)))
        : Uint8List.fromList(HEX.decode(hexPrivateKey));

    final signature =
        crypto.sign(crypto.keccak256(hashedPayload), privKeyBytes);

    // https://github.com/ethereumjs/ethereumjs-util/blob/8ffe697fafb33cefc7b7ec01c11e3a7da787fe0e/src/signature.ts#L26
    // be aware that signature.v already is recovery + 27
    final chainIdV =
        chainId != null ? (signature.v - 27 + (chainId * 2 + 35)) : signature.v;

    final r = typed.padUint8ListTo32(crypto.intToBytes(signature.r));
    final s = typed.padUint8ListTo32(crypto.intToBytes(signature.s));
    final v = crypto.intToBytes(BigInt.from(chainIdV));

    final sigBytes = typed.uint8ListFromList(r + s + v);
    return "0x" + HEX.encode(sigBytes);
  } catch (err) {
    throw Exception("The signature could not be computed");
  }
}

/// Recover the public key that signed the given message into the given signature
String recoverSignerPubKey(String hexSignature, String strPayload,
    {int chainId}) {
  if (hexSignature == null ||
      hexSignature.length < 130 ||
      hexSignature.length > 132)
    throw Exception("The hexSignature is invalid");
  else if (strPayload == null) throw Exception("The payload is empty");

  // TODO: CHAIN ID IS NOT USED

  try {
    final hashedPayload = _hashPayloadForSignature(strPayload);
    final messageHashBytes = crypto.keccak256(hashedPayload);

    String rStr, sStr, vStr;
    if (hexSignature.startsWith("0x")) {
      rStr = hexSignature.substring(0 + 2, 64 + 2);
      sStr = hexSignature.substring(64 + 2, 128 + 2);
      vStr = hexSignature.substring(128 + 2, 130 + 2);
    } else {
      rStr = hexSignature.substring(0, 64);
      sStr = hexSignature.substring(64, 128);
      vStr = hexSignature.substring(128, 130);
    }

    final r = BigInt.parse(rStr, radix: 16);
    final s = BigInt.parse(sStr, radix: 16);
    final v = int.parse(vStr, radix: 16);

    final signatureData = crypto.MsgSignature(r, s, v);
    final pubKey = crypto.ecRecover(messageHashBytes, signatureData);
    return "0x04" + HEX.encode(pubKey);
  } catch (err) {
    throw Exception("The signature could not be verified");
  }
}

/// Check whether the given signature is valid and belongs to the given message and
/// public key
bool isValidSignature(
    String hexSignature, String strPayload, String hexPublicKey,
    {int chainId}) {
  if (hexSignature == null ||
      hexSignature.length < 130 ||
      hexSignature.length > 132)
    throw Exception("The hexSignature is invalid");
  else if (strPayload == null)
    throw Exception("The payload is empty");
  else if (hexPublicKey == null ||
      hexPublicKey.length != 132 ||
      !hexPublicKey.startsWith("0x04"))
    throw Exception(
        "The hexPublicKey should be an expanded hex string starting by 0x04");

  // TODO: CHAIN ID IS NOT USED

  try {
    final pubKeyBytes =
        Uint8List.fromList(HEX.decode(hexPublicKey.substring(4))); // Strip 0x04

    final hashedPayload = _hashPayloadForSignature(strPayload);
    final messageHashBytes = crypto.keccak256(hashedPayload);

    String rStr, sStr, vStr;
    if (hexSignature.startsWith("0x")) {
      rStr = hexSignature.substring(0 + 2, 64 + 2);
      sStr = hexSignature.substring(64 + 2, 128 + 2);
      vStr = hexSignature.substring(128 + 2, 130 + 2);
    } else {
      rStr = hexSignature.substring(0, 64);
      sStr = hexSignature.substring(64, 128);
      vStr = hexSignature.substring(128, 130);
    }

    final r = BigInt.parse(rStr, radix: 16);
    final s = BigInt.parse(sStr, radix: 16);
    final v = int.parse(vStr, radix: 16);

    final signatureData = crypto.MsgSignature(r, s, v);
    return crypto.isValidSignature(
        messageHashBytes, signatureData, pubKeyBytes);
  } catch (err) {
    throw Exception("The signature could not be verified");
  }
}

///////////////////////////////////////////////////////////////////////////////
// WRAPPERS
///////////////////////////////////////////////////////////////////////////////

/// Async version of signString
Future<String> signStringAsync(String payload, String hexPrivateKey,
    {int chainId}) {
  return compute<List<dynamic>, String>(
      _signStringAsync, [payload, hexPrivateKey, chainId]);
}

String _signStringAsync(List<dynamic> args) {
  if (!(args is List) || args.length != 3)
    throw Exception("The function expects a list of three arguments");
  else if (!(args[0] is String))
    throw Exception(
        "The first argument must be a String with the payload to sign");
  else if (!(args[1] is String))
    throw Exception(
        "The second argument must be a hex String with the private key");
  else if (!(args[2] is int) && args[2] != null)
    throw Exception("The third argument must be either the chainId or null");

  return signString(args[0], args[1], chainId: args[2]);
}

Future<String> recoverSignerPubKeyAsync(String hexSignature, String strPayload,
    {int chainId}) {
  return compute<List<dynamic>, String>(
      _recoverSignerPubKeyAsyncAsync, [hexSignature, strPayload, chainId]);
}

String _recoverSignerPubKeyAsyncAsync(List<dynamic> args) {
  if (!(args is List) || args.length != 3)
    throw Exception("The function expects a list of three arguments");
  else if (!(args[0] is String))
    throw Exception(
        "The first argument must be a String with the hex signature");
  else if (!(args[1] is String))
    throw Exception(
        "The second argument must be a String with the signed payload");
  else if (!(args[2] is int) && args[2] != null)
    throw Exception("The third argument must be either the chainId or null");

  return recoverSignerPubKey(args[0], args[1], chainId: args[2]);
}

Future<bool> isValidSignatureAsync(
    String hexSignature, String strPayload, String hexPublicKey,
    {int chainId}) {
  return compute<List<dynamic>, bool>(_isValidSignatureAsync,
      [hexSignature, strPayload, hexPublicKey, chainId]);
}

bool _isValidSignatureAsync(List<dynamic> args) {
  if (!(args is List) || args.length != 4)
    throw Exception("The function expects a list of three arguments");
  else if (!(args[0] is String))
    throw Exception(
        "The first argument must be a hex String with the signature");
  else if (!(args[1] is String))
    throw Exception(
        "The second argument must be a String with the signed payload");
  else if (!(args[2] is String))
    throw Exception(
        "The first argument must be a hex String with the expected public key");
  else if (!(args[3] is int) && args[3] != null)
    throw Exception("The third argument must be either the chainId or null");

  return isValidSignature(args[0], args[1], args[2], chainId: args[3]);
}

///////////////////////////////////////////////////////////////////////////////
// INTERNAL
///////////////////////////////////////////////////////////////////////////////

Uint8List _hashPayloadForSignature(String payload) {
  final payloadBytes = Uint8List.fromList(utf8.encode(payload));
  final prefix = SIGNATURE_MESSAGE_PREFIX + payloadBytes.length.toString();
  final prefixBytes = ascii.encode(prefix);
  return typed.uint8ListFromList(prefixBytes + payloadBytes);
}

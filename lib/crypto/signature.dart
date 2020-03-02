import 'dart:convert';
import 'dart:typed_data';

import 'package:hex/hex.dart';
import 'package:web3dart/web3dart.dart';
// import 'package:web3dart/crypto.dart';
import 'package:dvote_native/dvote_native.dart' as dvoteNative;

/// Sign the given payload using the private key and return a hex signature
Future<String> signString(String payload, String privateKey,
    {int chainId}) async {
  if (payload == null)
    throw Exception("The payload is empty");
  else if (privateKey == null) throw Exception("The privateKey is empty");

  try {
    // Async version using Web3Dart

    final signerPrivKey = EthPrivateKey.fromHex(
        privateKey.startsWith("0x") ? privateKey.substring(2) : privateKey);
    final signature = await signerPrivKey.signPersonalMessage(
        Uint8List.fromList(utf8.encode(payload)),
        chainId: chainId);

    return "0x" + HEX.encode(signature);

    // Sync version

    // final privKeyBytes = privateKey.startsWith("0x")
    //     ? Uint8List.fromList(HEX.decode(privateKey.substring(2)))
    //     : Uint8List.fromList(HEX.decode(privateKey));

    // final _messagePrefix = '\u0019Ethereum Signed Message:\n';
    // final prefix = _messagePrefix + payload.length.toString();
    // final prefixBytes = ascii.encode(prefix);

    // final payloadBytes = Uint8List.fromList(utf8.encode(payload));
    // // will be a Uint8List, see the documentation of Uint8List.+
    // final concat = Uint8List.fromList(prefixBytes + payloadBytes);
    // final signature = sign(keccak256(concat), privKeyBytes);

    // TO DO: Pad the output values r, s, v

    // // https://ethereum.github.io/yellowpaper/paper.pdf > (290)
    // // Tw is either the recovery identifier or ‘chain identifier doubled plus 35 or 36’. In the second case, where v is the chain
    // // identifier doubled plus 35 or 36, the values 35 and 36 assume the role of the ‘recovery identifier’ by specifying the parity
    // // of y, with the value 35 representing an even value and 36 representing an odd val
    // //
    // // signature.v already is recovery + 0x1b
    // final chainIdV = chainId != null
    //     ? (signature.v - 0x1b + (chainId * 2 + 35))
    //     : signature.v;

    // return "0x" +
    //     signature.r.toRadixString(16) +
    //     signature.s.toRadixString(16) +
    //     chainIdV.toRadixString(16);
  } catch (err) {
    throw Exception("The signature could not be computed");
  }
}

/// Check whether the given signature is valid and belongs to the given message and
/// public key
Future<bool> verifySignature(
    String hexSignature, String strPayload, String hexPublicKey,
    {int chainId}) {
  if (hexSignature == null)
    throw Exception("The hexSignature is empty");
  else if (strPayload == null)
    throw Exception("The payload is empty");
  else if (hexPublicKey == null) throw Exception("The hexPublicKey is empty");

  // TODO: CHAIN ID IS NOT USED

  try {
    // TODO: USE FROM WEB3DART WHEN AVAILABLE
    return dvoteNative.verifySignature(hexSignature, strPayload, hexPublicKey);
  } catch (err) {
    throw Exception("The signature could not be verified");
  }
}

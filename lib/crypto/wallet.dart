import 'dart:typed_data';

import 'package:dvote/crypto/asyncify.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/crypto.dart';
import "package:hex/hex.dart";
import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;

class EthereumWallet {
  final String mnemonic;
  final String hdPath;

  EthereumWallet.fromMnemonic(this.mnemonic,
      {String hdPath = "m/44'/60'/0'/0/0"})
      : this.hdPath = hdPath {
    if (!bip39.validateMnemonic(mnemonic))
      throw Exception("The provided mnemonic is not valid");
  }

  /// Returns a new Ethereum wallet with a random seed phrase
  EthereumWallet.random({int size = 192, String hdPath = "m/44'/60'/0'/0/0"})
      : mnemonic = _randomMnemonic(size),
        this.hdPath = hdPath;

  /// Returns a new Ethereum wallet with a random seed phrase
  static Future<EthereumWallet> randomAsync(
      {int size = 192, String hdPath = "m/44'/60'/0'/0/0"}) async {
    final mnemonic = await wrap1ParamFunc<String, int>(_randomMnemonic, size);

    return EthereumWallet.fromMnemonic(mnemonic, hdPath: hdPath);
  }

  /// Returns a byte array representation of the private key
  /// derived from the current mnemonic
  Uint8List get privateKeyBytes {
    return _privateKeyBytes([mnemonic, hdPath]);
  }

  /// Returns a byte array representation of the private key
  /// derived from the current mnemonic
  Future<Uint8List> get privateKeyBytesAsync {
    return wrap2ParamFunc<Uint8List, String, String>(
        _privateKeyBytes, mnemonic, hdPath);
  }

  /// Returns an Hexadecimal representation of the private key
  /// derived from the current mnemonic
  String get privateKey {
    return "0x" + HEX.encode(privateKeyBytes);
  }

  /// Returns an Hexadecimal representation of the private key
  /// derived from the current mnemonic
  Future<String> get privateKeyAsync {
    return this
        .privateKeyBytesAsync
        .then((privKeyBytes) => "0x" + HEX.encode(privKeyBytes));
  }

  /// Returns a byte array representation of the public key
  /// derived from the current mnemonic
  Uint8List get publicKeyBytes {
    return _publicKeyBytes(this.privateKey);
  }

  /// Returns a byte array representation of the public key
  /// derived from the current mnemonic
  Future<Uint8List> get publicKeyBytesAsync {
    return wrap1ParamFunc<Uint8List, String>(_publicKeyBytes, this.privateKey);
  }

  /// Returns an Hexadecimal representation of the public key
  /// derived from the current mnemonic
  String get publicKey {
    return "0x04" + HEX.encode(this.publicKeyBytes);
  }

  /// Returns an Hexadecimal representation of the public key
  /// derived from the current mnemonic
  Future<String> get publicKeyAsync {
    return this
        .publicKeyBytesAsync
        .then((pubKeyBytes) => "0x04" + HEX.encode(pubKeyBytes));
  }

  String get address {
    return _address(this.privateKey);
  }

  Future<String> get addressAsync {
    return wrap1ParamFunc(_address, this.privateKey);
  }
}

// ////////////////////////////////////////////////////////////////////////////
// / IMPLEMENTATION
// ////////////////////////////////////////////////////////////////////////////

String _randomMnemonic(int size) {
  assert(size is int);
  return bip39.generateMnemonic(strength: size);
}

/// Returns a byte array representation of the private key
/// derived from the current mnemonic
Uint8List _privateKeyBytes(List<dynamic> args) {
  assert(args.length == 2);
  final mnemonic = args[0];
  assert(mnemonic is String);
  final hdPath = args[1];
  assert(hdPath is String);

  final seed = bip39.mnemonicToSeedHex(mnemonic);
  final root = bip32.BIP32.fromSeed(HEX.decode(seed));
  final child = root.derivePath(hdPath);
  return child.privateKey;
}

/// Returns a byte array representation of the public key
/// derived from the current mnemonic
Uint8List _publicKeyBytes(String privateKey) {
  final privKeyBigInt = hexToInt(privateKey);
  return privateKeyToPublic(privKeyBigInt);
}

String _address(String privateKey) {
  final privKeyBigInt = hexToInt(privateKey);
  final pubKeyBytes = privateKeyToPublic(privKeyBigInt);

  final addrBytes = publicKeyToAddress(pubKeyBytes);
  final addr = EthereumAddress(addrBytes);
  return addr.hexEip55;
}

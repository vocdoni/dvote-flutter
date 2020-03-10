import 'dart:typed_data';

import 'package:web3dart/credentials.dart';
import 'package:web3dart/crypto.dart';
import "package:hex/hex.dart";
import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;

class EthereumWallet {
  final String mnemonic;
  final String hdPath;

  EthereumWallet.random({int size = 192, String hdPath = "m/44'/60'/0'/0/0"})
      : mnemonic = bip39.generateMnemonic(strength: size),
        this.hdPath = hdPath;

  EthereumWallet.fromMnemonic(this.mnemonic,
      {String hdPath = "m/44'/60'/0'/0/0"})
      : this.hdPath = hdPath {
    if (!bip39.validateMnemonic(mnemonic))
      throw Exception("The provided mnemonic is not valid");
  }

  /// Returns a byte array representation of the private key
  /// derived from the current mnemonic
  Uint8List get privateKeyBytes {
    final seed = bip39.mnemonicToSeedHex(mnemonic);
    final root = bip32.BIP32.fromSeed(HEX.decode(seed));
    final child = root.derivePath(hdPath);
    return child.privateKey;
  }

  /// Returns an Hexadecimal representation of the private key
  /// derived from the current mnemonic
  String get privateKey {
    return "0x" + HEX.encode(privateKeyBytes);
  }

  /// Returns a byte array representation of the public key
  /// derived from the current mnemonic
  Uint8List get publicKeyBytes {
    final privKeyBigInt = hexToInt(this.privateKey);
    return privateKeyToPublic(privKeyBigInt);
  }

  /// Returns an Hexadecimal representation of the public key
  /// derived from the current mnemonic
  String get publicKey {
    return "0x04" + HEX.encode(this.publicKeyBytes);
  }

  String get address {
    final privKeyBigInt = hexToInt(this.privateKey);
    final pubKeyBytes = privateKeyToPublic(privKeyBigInt);

    final addrBytes = publicKeyToAddress(pubKeyBytes);
    final addr = EthereumAddress(addrBytes);
    return addr.hexEip55;
  }
}

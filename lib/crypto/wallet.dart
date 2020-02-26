import 'dart:typed_data';

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
    final addrHex = HEX.encode(addrBytes);

    // TODO: CHECKSUM CASE

    // address = address.toLowerCase();

    // let chars = address.substring(2).split('');

    // let hashed = new Uint8Array(40);
    // for (let i = 0; i < 40; i++) {
    //   hashed[i] = chars[i].charCodeAt(0);
    // }
    // hashed = arrayify(keccak256(hashed));

    // for (var i = 0; i < 40; i += 2) {
    //   if ((hashed[i >> 1] >> 4) >= 8) {
    //     chars[i] = chars[i].toUpperCase();
    //   }
    //   if ((hashed[i >> 1] & 0x0f) >= 8) {
    //     chars[i + 1] = chars[i + 1].toUpperCase();
    //   }
    // }

    // return '0x' + chars.join('');

    return '0x' + addrHex;
  }
}

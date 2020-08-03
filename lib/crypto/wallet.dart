import 'dart:typed_data';

import 'package:dvote/crypto/asyncify.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/crypto.dart';
import "package:hex/hex.dart";
import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;

const DEFAULT_HD_PATH = "m/44'/60'/0'/0/0";
const MAX_PRIV_KEY_VALUE =
    "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141";

class EthereumWallet {
  final String mnemonic;
  final String hdPath;
  final Uint8List entityAddressBytes; // HEX without 0x (may be null)

  EthereumWallet.fromMnemonic(this.mnemonic,
      {String hdPath = DEFAULT_HD_PATH, String entityAddress})
      : this.hdPath = hdPath,
        this.entityAddressBytes = entityAddress is String
            ? HEX.decode(
                entityAddress.replaceAll(RegExp(r"^0x"), "").toLowerCase())
            : null {
    if (!bip39.validateMnemonic(mnemonic))
      throw Exception("The provided mnemonic is not valid");
    else if (entityAddressBytes is Uint8List && entityAddressBytes.length != 20)
      throw Exception("Invalid address length");
  }

  /// Returns a new Ethereum wallet with a random seed phrase
  EthereumWallet.random(
      {int size = 192, String hdPath = DEFAULT_HD_PATH, String entityAddress})
      : this.mnemonic = _randomMnemonic(size),
        this.hdPath = hdPath,
        this.entityAddressBytes = entityAddress is String
            ? HEX.decode(
                entityAddress.replaceAll(RegExp(r"^0x"), "").toLowerCase())
            : null {
    if (entityAddressBytes is Uint8List && entityAddressBytes.length != 20)
      throw Exception("Invalid address length");
  }

  /// Returns a new Ethereum wallet with a random seed phrase
  static Future<EthereumWallet> randomAsync(
      {int size = 192,
      String hdPath = DEFAULT_HD_PATH,
      String entityAddress}) async {
    final mnemonic = await wrap1ParamFunc<String, int>(_randomMnemonic, size);

    return EthereumWallet.fromMnemonic(mnemonic,
        hdPath: hdPath, entityAddress: entityAddress);
  }

  /// Returns a byte array representation of the private key derived from the current mnemonic.
  /// If entityAddress is set, its bytes will be used to derive a new private key, unique to this entity.
  Uint8List get privateKeyBytes {
    final privKeyBytes = _privateKeyBytes([mnemonic, hdPath]);
    assert(privKeyBytes.length == 32, "Invalid private key length");
    assert(entityAddressBytes is! Uint8List || entityAddressBytes.length == 20,
        "Invalid entity address length");

    // XOR the last 20 bytes of the generated private key using the entity address
    if (entityAddressBytes is Uint8List) {
      for (int i = entityAddressBytes.length - 1; i >= 0; i--) {
        privKeyBytes[12 + i] = privKeyBytes[12 + i] ^ entityAddressBytes[i];
      }
      if (!_isValidPrivateKey(privKeyBytes))
        throw Exception("The derived private key for the entity is not valid");
    }
    return privKeyBytes;
  }

  /// Returns a byte array representation of the private key derived from the current mnemonic.
  /// If entityAddress is set, its bytes will be used to derive a new private key, unique to this entity.
  Future<Uint8List> get privateKeyBytesAsync {
    return wrap2ParamFunc<Uint8List, String, String>(
            _privateKeyBytes, mnemonic, hdPath)
        .then((privKeyBytes) {
      assert(privKeyBytes.length == 32, "Invalid private key length");
      assert(
          entityAddressBytes is! Uint8List || entityAddressBytes.length == 20,
          "Invalid entity address length");

      // XOR the last 20 bytes of the generated private key using the entity address
      if (entityAddressBytes is Uint8List) {
        for (int i = entityAddressBytes.length - 1; i >= 0; i--) {
          privKeyBytes[12 + i] = privKeyBytes[12 + i] ^ entityAddressBytes[i];
        }
        if (!_isValidPrivateKey(privKeyBytes))
          throw Exception(
              "The derived private key for the entity is not valid");
      }
      return privKeyBytes;
    });
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

bool _isValidPrivateKey(Uint8List privKey) {
  if (privKey.length != 32)
    return false;
  else if (privKey.every((byte) => byte == 0x0)) return false;

  final maxInt = hexToInt(MAX_PRIV_KEY_VALUE);
  final privKeyInt = hexToInt(HEX.encode(privKey));
  return privKeyInt <= maxInt;
}

import 'dart:typed_data';

import "package:dvote_native/dvote_native.dart" as dvoteNative;
import 'package:dvote/util/asyncify.dart';
import 'package:web3dart/crypto.dart';
import "package:hex/hex.dart";

import "../constants.dart";

// ////////////////////////////////////////////////////////////////////////////
// / DART WALLET
// ////////////////////////////////////////////////////////////////////////////

class EthereumNativeWallet {
  final String mnemonic;
  final String hdPath;
  final Uint8List entityAddressHashBytes; // HEX without 0x (may be null)

  /// Creates an Ethereum wallet for the given mnemonic, using the (optional) HD path.
  /// If an entityAddress is defined, the results private key, public key and address will
  /// be a unique derivation for the given entity that no one else will be able to correlate.
  EthereumNativeWallet.fromMnemonic(this.mnemonic,
      {String hdPath = DEFAULT_HD_PATH, String entityAddressHash})
      : this.hdPath = hdPath,
        this.entityAddressHashBytes = entityAddressHash is String
            ? HEX.decode(entityAddressHash.replaceAll(RegExp(r"^0x"), ""))
            : null {
    try {
      dvoteNative.Wallet.computePrivateKey(mnemonic);
    } catch (err) {
      throw Exception("The provided mnemonic is not valid");
    }

    if (entityAddressHashBytes is Uint8List &&
        entityAddressHashBytes.length != 32) {
      throw Exception("Invalid address hash length");
    }
  }

  /// Creates a new Ethereum wallet using a random mnemonic and the (optional) HD path.
  /// If an entityAddress is defined, the results private key, public key and address will
  /// be a unique derivation for the given entity that no one else will be able to correlate.
  EthereumNativeWallet.random(
      {int size = 192,
      String hdPath = DEFAULT_HD_PATH,
      String entityAddressHash})
      : this.mnemonic = _randomMnemonic(size),
        this.hdPath = hdPath,
        this.entityAddressHashBytes = entityAddressHash is String
            ? HEX.decode(entityAddressHash.replaceAll(RegExp(r"^0x"), ""))
            : null {
    if (entityAddressHashBytes is Uint8List &&
        entityAddressHashBytes.length != 32)
      throw Exception("Invalid address hash length");
  }

  /// Creates a new Ethereum wallet using a random mnemonic and the (optional) HD path.
  /// If an entityAddress is defined, the results private key, public key and address will
  /// be a unique derivation for the given entity that no one else will be able to correlate.
  static Future<EthereumNativeWallet> randomAsync(
      {int size = 192,
      String hdPath = DEFAULT_HD_PATH,
      String entityAddressHash}) async {
    final mnemonic = await wrap1ParamFunc<String, int>(
        dvoteNative.Wallet.generateMnemonic, size);

    return EthereumNativeWallet.fromMnemonic(mnemonic,
        hdPath: hdPath, entityAddressHash: entityAddressHash);
  }

  /// Returns a byte array representation of the private key derived from the current mnemonic.
  /// If entityAddress is set, its bytes will be used to derive a new private key, unique to this entity.
  Uint8List get privateKeyBytes {
    final privKeyBytes = _privateKeyBytes([mnemonic, hdPath]);
    assert(privKeyBytes.length == 32, "Invalid private key length");
    assert(
        entityAddressHashBytes is! Uint8List ||
            entityAddressHashBytes.length == 32,
        "Invalid entity address hash length");

    // XOR the 32 bytes of the generated private key using the entity address hash
    if (entityAddressHashBytes is Uint8List) {
      for (int i = entityAddressHashBytes.length - 1; i >= 0; i--) {
        privKeyBytes[i] = privKeyBytes[i] ^ entityAddressHashBytes[i];
      }
      if (!_isValidPrivateKey(privKeyBytes))
        throw Exception("The private key derived for the entity is not valid");
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
          entityAddressHashBytes is! Uint8List ||
              entityAddressHashBytes.length == 32,
          "Invalid entity address hash length");

      // XOR the 32 bytes of the generated private key using the entity address hash
      if (entityAddressHashBytes is Uint8List) {
        for (int i = entityAddressHashBytes.length - 1; i >= 0; i--) {
          privKeyBytes[i] = privKeyBytes[i] ^ entityAddressHashBytes[i];
        }
        if (!_isValidPrivateKey(privKeyBytes))
          throw Exception(
              "The private key derived for the entity is not valid");
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
  Uint8List publicKeyBytes({bool uncompressed = false}) {
    return _publicKeyBytes([this.privateKey, uncompressed]);
  }

  /// Returns a byte array representation of the public key
  /// derived from the current mnemonic
  Future<Uint8List> publicKeyBytesAsync({bool uncompressed = false}) {
    return wrap2ParamFunc<Uint8List, String, bool>(
        _publicKeyBytes, this.privateKey, uncompressed);
  }

  /// Returns an Hexadecimal representation of the public key
  /// derived from the current mnemonic
  String publicKey({bool uncompressed = false}) {
    return "0x" + HEX.encode(this.publicKeyBytes(uncompressed: uncompressed));
  }

  /// Returns an Hexadecimal representation of the public key
  /// derived from the current mnemonic
  Future<String> publicKeyAsync({bool uncompressed = false}) {
    return this
        .publicKeyBytesAsync(uncompressed: uncompressed)
        .then((pubKeyBytes) => "0x" + HEX.encode(pubKeyBytes));
  }

  String get address {
    return _address(this.privateKey);
  }

  Future<String> get addressAsync {
    return wrap1ParamFunc(_address, this.privateKey);
  }

  // ////////////////////////////////////////////////////////////////////////////
  // / INTERNAL HELPERS
  // ////////////////////////////////////////////////////////////////////////////

  static String _randomMnemonic(int size) {
    assert(size is int);
    return dvoteNative.Wallet.generateMnemonic(size);
  }

  /// Returns a byte array representation of the private key
  /// derived from the current mnemonic
  static Uint8List _privateKeyBytes(List<dynamic> args) {
    assert(args.length == 2);
    final mnemonic = args[0];
    assert(mnemonic is String);
    final hdPath = args[1];
    assert(hdPath is String);

    final privKey = dvoteNative.Wallet.computePrivateKey(mnemonic, hdPath ?? "")
        .replaceFirst("0x", "");
    return HEX.decode(privKey);
  }

  /// Returns a byte array representation of the public key
  /// derived from the current mnemonic
  static Uint8List _publicKeyBytes(List<dynamic> args) {
    assert(args.length == 2);
    final hexPrivateKey = args[0];
    assert(hexPrivateKey is String);
    final uncompressed = args[1];
    assert(uncompressed is bool);

    final pubKey = dvoteNative.Wallet.computePublicKey(hexPrivateKey,
            uncompressed: uncompressed)
        .replaceFirst("0x", "");
    return HEX.decode(pubKey);
  }

  static String _address(String hexPrivateKey) {
    return dvoteNative.Wallet.computeAddress(hexPrivateKey);
  }

  static bool _isValidPrivateKey(Uint8List privKey) {
    if (privKey.length != 32)
      return false;
    else if (privKey.every((byte) => byte == 0x0)) return false;

    final maxInt = hexToInt(MAX_PRIV_KEY_VALUE);
    final privKeyInt = hexToInt(HEX.encode(privKey));
    return privKeyInt <= maxInt;
  }
}

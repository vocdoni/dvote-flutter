import 'package:flutter/material.dart';

import 'package:dvote_crypto/dvote_crypto.dart';
import './constants.dart';

class WalletScreen extends StatefulWidget {
  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  String _mnemonic = "-", _privKey = "-", _pubKey = "-", _addr = "-";
  String _status;
  DateTime _start, _mid, _end;
  String _error;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String error;
    String mnemonic, privKey, pubKey, addr;

    try {
      _start = DateTime.now();

      // Native computation
      final wallet = EthereumWallet.random(hdPath: HD_PATH);
      mnemonic = wallet.mnemonic;
      privKey = wallet.privateKey;
      pubKey = wallet.publicKey(uncompressed: false);
      addr = wallet.address;

      _mid = DateTime.now();

      // Dart computation
      final pureWallet = EthereumWallet.fromMnemonic(mnemonic, hdPath: HD_PATH);

      final purePrivKey = pureWallet.privateKey;
      assert(purePrivKey == privKey,
          "Keys should equal: Pure Dart PK: $purePrivKey - Native PK: $privKey - Mnemonic: '$mnemonic'");
      assert(pureWallet.publicKey(uncompressed: false) == pubKey);
      assert(pureWallet.address == addr);

      _end = DateTime.now();
    } catch (err) {
      error = err.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    if (error != null) {
      setState(() {
        _error = error;

        _mnemonic = mnemonic;
        _privKey = privKey;
        _pubKey = pubKey;
        _addr = addr;
      });
      return;
    }

    setState(() {
      _mnemonic = mnemonic;
      _privKey = privKey;
      _pubKey = pubKey;
      _addr = addr;
      _status =
          """Native computation: ${_mid.difference(_start).inMilliseconds}ms
Dart computation: ${_end.difference(_mid).inMilliseconds}ms
      """;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                _error != null
                    ? Text(
                        "ERROR: $_error\n\n-----\n\n",
                        style: TextStyle(color: Colors.red),
                      )
                    : Container(),
                Text("Mnemonic '$_mnemonic'\n"),
                Text("Private key\n$_privKey\n"),
                Text("Public key\n$_pubKey\n"),
                Text("Address\n$_addr\n"),
                Text(_status ?? "")
              ],
            ),
          ),
        ],
      ),
    );
  }
}

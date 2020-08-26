import 'package:flutter/material.dart';

import 'package:dvote/dvote.dart';
import './constants.dart';

class WalletScreen extends StatefulWidget {
  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  String _mnemonic = "-", _privKey = "-", _pubKey = "-", _addr = "-";
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
      final wallet = EthereumNativeWallet.random(hdPath: HD_PATH);
      mnemonic = wallet.mnemonic;
      privKey = wallet.privateKey;
      pubKey = wallet.publicKey;
      addr = wallet.address;

      final pureWallet = EthereumDartWallet.fromMnemonic(mnemonic);
      assert(pureWallet.privateKey == privKey);
      assert(pureWallet.publicKey == pubKey);
      assert(pureWallet.address == addr);
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
      });
      return;
    }

    setState(() {
      _mnemonic = mnemonic;
      _privKey = privKey;
      _pubKey = pubKey;
      _addr = addr;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Wallet'),
        ),
        body: Container(
          child: Text("Error: " + _error),
        ),
      );
    }

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
                Text("Mnemonic '$_mnemonic'"),
                Text("Private key\n$_privKey"),
                Text("Public key\n$_pubKey"),
                Text("Address\n$_addr"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

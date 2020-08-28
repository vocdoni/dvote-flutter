import 'package:flutter/material.dart';
import 'package:dvote/dvote.dart';

const MESSAGE = "hello";
const PRIVATE_KEY =
    "fad9c8855b740a0b7ed4c221dbad0f33a83a49cad6b3fe8d5817ac83d38b6a19";
const PUBLIC_KEY =
    "0x049a7df67f79246283fdc93af76d4f8cdd62c4886e8cd870944e817dd0b97934fdd7719d0810951e03418205868a5c1b40b192451367f28e0088dd75e15de40c05";

class SignatureScreen extends StatefulWidget {
  @override
  _SignatureScreenState createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  String _signature = "-";
  String _recoveredPubKey = "-";
  bool _valid = false;
  String _error;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String error;
    String signature, recoveredPubKey;
    bool valid;

    try {
      signature = await SignatureNative.signStringAsync(MESSAGE, PRIVATE_KEY);
      recoveredPubKey =
          await SignatureNative.recoverSignerPubKeyAsync(signature, MESSAGE);
      valid = await SignatureNative.isValidSignatureAsync(
          signature, MESSAGE, PUBLIC_KEY);
    } catch (err) {
      error = err.toString();
    }

    assert(signature == SignatureNative.signString(MESSAGE, PRIVATE_KEY));
    assert(recoveredPubKey ==
        SignatureNative.recoverSignerPubKey(signature, MESSAGE));
    assert(valid ==
        SignatureNative.isValidSignature(signature, MESSAGE, PUBLIC_KEY));

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
      _signature = signature;
      _recoveredPubKey = recoveredPubKey;
      _valid = valid;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Signature'),
        ),
        body: Container(
          child: Text("Error: " + _error),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Signature'),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                Text("Signing '$MESSAGE'\n"),
                Text("From private key\n$PRIVATE_KEY\n"),
                Text("From public key\n$PUBLIC_KEY\n"),
                Text("Signature\n$_signature\n"),
                Text("Recovered public key (compressed)\n$_recoveredPubKey\n"),
                Text("Valid\n$_valid"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

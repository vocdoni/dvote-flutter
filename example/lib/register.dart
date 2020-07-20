import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:faker/faker.dart';
import 'package:uuid/uuid.dart';

import 'package:dvote/dvote.dart';
import './constants.dart';

import 'constants.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String _reply = "-";
  String _error;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String error;
    DVoteGateway dvoteGw;
    EntityReference entity = EntityReference();
    entity.entityId = ENTITY_ID;
    entity.entryPoints.addAll(["https://rpc.slock.it/goerli"]);
    // var faker;
    Map<String, dynamic> reply;
    const String RESISTRY_URL = "ws://manager.dev.vocdoni.net/api/registry";

    try {
      var uuid = Uuid();
      dvoteGw = DVoteGateway(RESISTRY_URL, skipHealthCheck: true);
      final wallet = EthereumWallet.random(hdPath: "m/44'/60'/0'/0/5");

      var token = uuid.v4();
      reply = await validateRegistrationToken(
          ENTITY_ID, token, dvoteGw, wallet.privateKey);
      dvoteGw.disconnect();
    } on PlatformException catch (err) {
      error = err.message;
      dvoteGw.disconnect();
    } catch (err) {
      error = err.toString();
      dvoteGw.disconnect();
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
      _reply = reply.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Register'),
        ),
        body: Container(
          child: Text("Error: " + _error),
        ),
      );
    }

    final reply = '''Response:\n
$_reply''';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Metadata'),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: <Widget>[Text(reply)],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:dvote/dvote.dart';
import './constants.dart';

class GatewayScreen extends StatefulWidget {
  @override
  _GatewayScreenState createState() => _GatewayScreenState();
}

class _GatewayScreenState extends State<GatewayScreen> {
  String _dvoteGwStr = "-";
  String _web3GwStr = "-";
  String _error;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String error;
    GatewayPool gw;

    try {
      gw = await GatewayPool.discover(NETWORK_ID,
          bootnodeUri: BOOTNODES_URL_RW, maxGatewayCount: 5, timeout: 10);
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
      _dvoteGwStr = "URI: " +
          gw.current.dvote.uri +
          "\nHealth: " +
          gw.current.dvote.health.toString() +
          "\nSupported APIs: " +
          gw.current.dvote.supportedApis.join(", ");
      _web3GwStr = "URI: " + gw.current.web3.uri;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Gateway Discovery'),
        ),
        body: Container(
          child: Text("Error: " + _error),
        ),
      );
    }

    final dvoteGw = "DvoteGateway info:\n$_dvoteGwStr\n";
    final web3Gw = "Web3Gateway info:\n$_web3GwStr\n";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gateway info'),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: <Widget>[Text(dvoteGw), Text(web3Gw)],
            ),
          ),
        ],
      ),
    );
  }
}

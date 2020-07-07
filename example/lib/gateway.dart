import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:dvote/dvote.dart';
import './constants.dart';
import 'dart:convert';

class GatewayScreen extends StatefulWidget {
  @override
  _GatewayScreenState createState() => _GatewayScreenState();
}

class _GatewayScreenState extends State<GatewayScreen> {
  String _gwInfoStr = "-";
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
    GatewayInfo gwInfo;
    DVoteGateway dvoteGw;
    Web3Gateway web3Gw;
    String dvoteGwStr;
    String web3GwStr;
    EntityReference entity = EntityReference();
    entity.entityId = ENTITY_ID;
    entity.entryPoints.addAll(["https://rpc.slock.it/goerli"]);

    try {
      gwInfo = await getRandomGatewayDetails(BOOTNODES_URL_RW, NETWORK_ID);
      dvoteGw = DVoteGateway(gwInfo.dvote, publicKey: gwInfo.publicKey);
      web3Gw = Web3Gateway(gwInfo.web3);
      // web3Gw
      dvoteGwStr = dvoteGw.uri;
      web3GwStr = web3Gw.rpcUri;
    } on PlatformException catch (err) {
      error = err.message;
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
      _gwInfoStr = gwInfo.toString();
      _dvoteGwStr = dvoteGwStr;
      _web3GwStr = web3GwStr;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Gateway\'s Metadata'),
        ),
        body: Container(
          child: Text("Error: " + _error),
        ),
      );
    }

    final gwInfo = '''GatawayInfo:\n
$_gwInfoStr''';
    final dvoteGw = '''DvoteGateway:\n
$_dvoteGwStr''';
    final web3Gw = '''Web3Gateway:\n
$_web3GwStr''';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Metadata'),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: <Widget>[Text(gwInfo), Text(dvoteGw), Text(web3Gw)],
            ),
          ),
        ],
      ),
    );
  }
}

// Future<void> metadata() async {
//   EntityReference entity = EntityReference();
//   entity.entityId = ENTITY_ID;
//   entity.entryPoints.addAll(["https://rpc.slock.it/goerli"]);

//   try {
//     final gwInfo = await getRandomGatewayDetails(BOOTNODES_URL_RW, NETWORK_ID);
//     final dvoteGw = DVoteGateway(gwInfo.dvote, publicKey: gwInfo.publicKey);
//     final web3Gw = Web3Gateway(gwInfo.web3);

//     final entityMeta = await fetchEntity(entity, dvoteGw, web3Gw);

//     final String pid = entityMeta.votingProcesses?.active?.first;
//     if (pid is String) {
//       final processMeta = await getProcessMetadata(pid, dvoteGw, web3Gw);
//       print(jsonEncode(processMeta));
//     }
//   } catch (err) {
//     print(err);
//   }
// }

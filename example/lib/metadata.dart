import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:dvote/dvote.dart';
import './constants.dart';
import 'dart:convert';

class MetadataScreen extends StatefulWidget {
  @override
  _MetadataScreenState createState() => _MetadataScreenState();
}

class _MetadataScreenState extends State<MetadataScreen> {
  String _processMetaStr = "-";
  String _entityMetaStr = "-";
  String _error;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String error;
    String processMetaStr;
    String entityMetaStr;
    EntityReference entity = EntityReference();
    entity.entityId = ENTITY_ID;

    try {
      final gwInfo =
          await getRandomGatewayDetails(BOOTNODES_URL_RW, NETWORK_ID);
      final dvoteGw = DVoteGateway(gwInfo.dvote, publicKey: gwInfo.publicKey);
      final web3Gw = Web3Gateway(gwInfo.web3);

      final entityMeta = await fetchEntity(entity, dvoteGw, web3Gw);
      entityMetaStr = jsonEncode(entityMeta.toString());

      if ((entityMeta.votingProcesses?.active?.length is int) &&
          entityMeta.votingProcesses.active.length > 0) {
        final pid = entityMeta.votingProcesses?.active?.first;
        final processMeta = await getProcessMetadata(pid, dvoteGw, web3Gw);
        processMetaStr = processMeta.toString();
        // print(processMetaStr);
      }
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
      _entityMetaStr = entityMetaStr;
      _processMetaStr = processMetaStr;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Process Metadata'),
        ),
        body: Container(
          child: Text("Error: " + _error),
        ),
      );
    }

    final entityMeta = '''Entity Metadata:\n
$_entityMetaStr''';
    final processMeta = '''Process Metadata:\n
$_processMetaStr''';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Metadata'),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                Text(entityMeta),
                Text(processMeta),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

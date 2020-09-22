import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:dvote/dvote.dart';
import './constants.dart';
import 'dart:convert';

class ResultsScreen extends StatefulWidget {
  @override
  _ResultsScreenState createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  String _rawResultStr = "-";
  String _error;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String rawResultStr;
    String error;

    try {
      print("Discovering nodes");
      final gw = await GatewayPool.discover(NETWORK_ID,
          bootnodeUri: BOOTNODES_URL_RW, maxGatewayCount: 5, timeout: 10);

      print("Fetching process results");
      final rawResults = await getRawResults(RESULTS_PROCESS_ID, gw);
      rawResultStr = rawResults.toString();
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
      _rawResultStr = rawResultStr;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Process Results'),
        ),
        body: Container(
          child: Text("Error: " + _error),
        ),
      );
    }

    final rawResults = '''Results for process $RESULTS_PROCESS_ID:\n
$_rawResultStr''';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                Text(rawResults),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

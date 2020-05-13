import 'package:flutter/material.dart';
import "./metadata.dart";
import "./gateway.dart";
import "./wallets.dart";
import "./signatures.dart";
import "./vote.dart";

// void main() async {
//   await metadata();
//   wallets();
//   // signatures();
//   await vote();
// }




void main() async {
  runApp(MaterialApp(
    title: 'DVote Flutter Native',
    home: ExampleApp(),
  ));
}

class ExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DVote Flutter Native'),
      ),
      body: ListView(
        children: <Widget>[
          Card(
            child: ListTile(
              leading: FlutterLogo(size: 72.0),
              title: Text('Gateway'),
              subtitle: Text(
                  'Showing Gateways Info'),
              isThreeLine: true,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => GatewayScreen())),
            ),
          ),
          Card(
            child: ListTile(
              leading: FlutterLogo(size: 72.0),
              title: Text('Metadata'),
              subtitle:
                  Text('Get Entity Metadata'),
              isThreeLine: true,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MetadataScreen())),
            ),
          ),
        ],
      ),
    );
  }
}
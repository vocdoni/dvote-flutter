import 'package:flutter/material.dart';
import 'package:dvote_example/gateway.dart';
import 'package:dvote_example/metadata.dart';
import "package:dvote_example/register.dart";
import "package:dvote_example/wallets.dart";
import "package:dvote_example/signatures.dart";
import "package:dvote_example/hashing.dart";
// import "./vote.dart";

void main() async {
  runApp(MaterialApp(
    title: 'DVote Flutter',
    home: ExampleApp(),
  ));
}

class ExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DVote Flutter'),
      ),
      body: ListView(
        children: <Widget>[
          Card(
            child: ListTile(
              leading: FlutterLogo(size: 72.0),
              title: Text('Wallet'),
              subtitle: Text('Generating Ethereum wallets'),
              isThreeLine: true,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => WalletScreen())),
            ),
          ),
          Card(
            child: ListTile(
              leading: FlutterLogo(size: 72.0),
              title: Text('Signature'),
              subtitle: Text('Signing and recovering signer keys'),
              isThreeLine: true,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SignatureScreen())),
            ),
          ),
          Card(
            child: ListTile(
              leading: FlutterLogo(size: 72.0),
              title: Text('Hashing'),
              subtitle: Text('Generating Poseidon hashes'),
              isThreeLine: true,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => HashingScreen())),
            ),
          ),
          Card(
            child: ListTile(
              leading: FlutterLogo(size: 72.0),
              title: Text('Gateway'),
              subtitle: Text('Showing Gateways Info'),
              isThreeLine: true,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => GatewayScreen())),
            ),
          ),
          Card(
            child: ListTile(
              leading: FlutterLogo(size: 72.0),
              title: Text('Metadata'),
              subtitle: Text('Get Entity Metadata'),
              isThreeLine: true,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MetadataScreen())),
            ),
          ),
          Card(
            child: ListTile(
              leading: FlutterLogo(size: 72.0),
              title: Text('Register'),
              subtitle: Text('Register User to Backend'),
              isThreeLine: true,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => RegisterScreen())),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:dvote/dvote.dart';

const MESSAGE = "Hello world";
const PUBLIC_KEY =
    "0x049a7df67f79246283fdc93af76d4f8cdd62c4886e8cd870944e817dd0b97934fdd7719d0810951e03418205868a5c1b40b192451367f28e0088dd75e15de40c05";

class HashingScreen extends StatefulWidget {
  @override
  _HashingScreenState createState() => _HashingScreenState();
}

class _HashingScreenState extends State<HashingScreen> {
  String _digestedHexClaim = "-", _digestedStringClaim = "-";
  Duration _duration1;
  Duration _duration2;
  String _error;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    DateTime start, mid, end;
    String digestedHexClaim, digestedStringClaim;
    String error;

    try {
      start = DateTime.now();
      // sync
      digestedHexClaim = Hashing.digestHexClaim(PUBLIC_KEY);
      digestedStringClaim = Hashing.digestStringClaim(MESSAGE);

      mid = DateTime.now();

      // async
      await Hashing.digestHexClaimAsync(PUBLIC_KEY);
      await Hashing.digestStringClaimAsync(MESSAGE);

      end = DateTime.now();
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
      _digestedHexClaim = digestedHexClaim;
      _digestedStringClaim = digestedStringClaim;
      _duration1 = mid.difference(start);
      _duration2 = end.difference(mid);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Hashing'),
        ),
        body: Container(
          child: Text("Error: " + _error),
        ),
      );
    }

    final info = '''Hashing '$PUBLIC_KEY'
$_digestedHexClaim

Hashing '$MESSAGE'
$_digestedStringClaim

---

Sync: ${_duration1?.inMilliseconds}ms
Async: ${_duration2?.inMilliseconds}ms''';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hashing'),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                Text(info),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

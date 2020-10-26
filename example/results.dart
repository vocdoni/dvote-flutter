import 'package:dvote/dvote.dart';
import './constants.dart';

// Platform messages are asynchronous, so we initialize in an async method.
Future<void> initPlatformState() async {
  try {
    print("Discovering nodes");
    final gw = await GatewayPool.discover(NETWORK_ID,
        bootnodeUri: BOOTNODES_URL_RW, maxGatewayCount: 5, timeout: 10);

    print("Fetching process results");
    final resultsDigest = await getResultsDigest(RESULTS_PROCESS_ID, gw);
    final rawResults = await getRawResults(RESULTS_PROCESS_ID, gw);

    print(rawResults.toString());
    print(resultsDigest.toString());
  } catch (err) {
    print(err);
  }
}

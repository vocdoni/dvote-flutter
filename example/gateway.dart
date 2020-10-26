import 'package:dvote/dvote.dart';
import './constants.dart';

Future<void> main() async {
  return GatewayPool.discover(NETWORK_ID,
          bootnodeUri: BOOTNODES_URL_RW, maxGatewayCount: 5, timeout: 10)
      .then((gw) {
    print("GW info: ${gw}");
  }).catchError((err) {
    print(err);
  });
}

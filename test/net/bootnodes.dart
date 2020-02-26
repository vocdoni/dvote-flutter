import 'package:flutter_test/flutter_test.dart';
import 'package:dvote/dvote.dart';

const NETWORK_ID = "goerli";

void bootnodes() {
  test("Boot nodes URI from the blockchain", () async {
    final result = await getDefaultBootnodeContentUri(NETWORK_ID);
    expect(result is ContentURI, true,
        reason: "The Boot nodes URI should be a a Content URI");
    expect(result.toString().length > 0, true,
        reason: "The Boot nodes toString() should be not be empty");
  });
  test("Gateway Boot nodes", () async {
    final gws = await getDefaultGatewaysDetails(NETWORK_ID);
    expect(gws.goerli.dvote.length > 0, true);
    expect(gws.goerli.web3.length > 0, true);

    expect(gws.goerli.dvote[0].uri.length > 0, true);
    expect(gws.goerli.dvote[0].apis.length > 0, true);
    expect(gws.goerli.dvote[0].pubKey.length > 0, true);
    expect(gws.goerli.web3[0].uri.length > 0, true);
  });
}

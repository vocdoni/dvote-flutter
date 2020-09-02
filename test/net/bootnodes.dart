import 'package:flutter_test/flutter_test.dart';
import 'package:dvote/net/bootnodes.dart';

const NETWORK_ID = "goerli";

void bootnodes() {
  test("Boot nodes URI from the blockchain", () async {
    final result = await resolveWellKnownBootnodeUri(NETWORK_ID);
    expect(result is String, true,
        reason: "The Boot nodes URI should be a String");
    expect(result.length > 0, true,
        reason: "The Boot nodes URI should not be empty");
  });
  test("Gateway Boot nodes", () async {
    final uri = await resolveWellKnownBootnodeUri(NETWORK_ID);
    final gws = await fetchBootnodeInfo(uri);

    // Goerli
    expect(gws.goerli.dvote.length > 0, true);
    expect(gws.goerli.web3.length > 0, true);

    expect(gws.goerli.dvote[0].uri.length > 0, true);
    expect(gws.goerli.dvote[0].apis.length > 0, true);
    expect(gws.goerli.dvote[0].pubKey.length > 0, true);
    expect(gws.goerli.web3[0].uri.length > 0, true);

    // XDAI
    expect(gws.xdai.dvote.length > 0, true);
    expect(gws.xdai.web3.length > 0, true);

    expect(gws.xdai.dvote[0].uri.length > 0, true);
    expect(gws.xdai.dvote[0].apis.length > 0, true);
    expect(gws.xdai.dvote[0].pubKey.length > 0, true);
    expect(gws.xdai.web3[0].uri.length > 0, true);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:dvote/net/bootnodes.dart';

const MAIN_NETWORK_ID = "xdai";
const DEV_NETWORK_ID = "sokol";

void bootnodes() {
  test("Boot nodes URI from the blockchain", () async {
    final result1 =
        await resolveWellKnownBootnodeUri(MAIN_NETWORK_ID, testing: false);
    expect(result1 is String, true,
        reason: "The Boot nodes URI should be a String");
    expect(result1.length > 0, true,
        reason: "The Boot nodes URI should not be empty");

    final result2 =
        await resolveWellKnownBootnodeUri(MAIN_NETWORK_ID, testing: true);
    expect(result2 is String, true,
        reason: "The Boot nodes URI should be a String");
    expect(result2.length > 0, true,
        reason: "The Boot nodes URI should not be empty");

    // final result3 = await resolveWellKnownBootnodeUri(DEV_NETWORK_ID);
    // expect(result3 is String, true,
    //     reason: "The Boot nodes URI should be a String");
    // expect(result3.length > 0, true,
    //     reason: "The Boot nodes URI should not be empty");
  });
  test("Gateway Boot nodes", () async {
    // XDAI
    final uri1 =
        await resolveWellKnownBootnodeUri(MAIN_NETWORK_ID, testing: false);
    final gws1 = await fetchBootnodeInfo(uri1);

    expect(gws1.xdai.dvote.length > 0, true);
    expect(gws1.xdai.web3.length > 0, true);

    expect(gws1.xdai.dvote[0].uri.length > 0, true);
    expect(gws1.xdai.dvote[0].apis.length > 0, true);
    expect(gws1.xdai.dvote[0].pubKey.length > 0, true);
    expect(gws1.xdai.web3[0].uri.length > 0, true);

    // Test
    final uri2 =
        await resolveWellKnownBootnodeUri(MAIN_NETWORK_ID, testing: true);
    final gws2 = await fetchBootnodeInfo(uri2);

    expect(gws2.xdai.dvote.length > 0, true);
    expect(gws2.xdai.web3.length > 0, true);

    expect(gws2.xdai.dvote[0].uri.length > 0, true);
    expect(gws2.xdai.dvote[0].apis.length > 0, true);
    expect(gws2.xdai.dvote[0].pubKey.length > 0, true);
    expect(gws2.xdai.web3[0].uri.length > 0, true);

    // // SOKOL
    // final uri3 = await resolveWellKnownBootnodeUri(DEV_NETWORK_ID);
    // final gws3 = await fetchBootnodeInfo(uri3);

    // expect(gws3.xdai.dvote.length > 0, true);
    // expect(gws3.xdai.web3.length > 0, true);

    // expect(gws3.xdai.dvote[0].uri.length > 0, true);
    // expect(gws3.xdai.dvote[0].apis.length > 0, true);
    // expect(gws3.xdai.dvote[0].pubKey.length > 0, true);
    // expect(gws3.xdai.web3[0].uri.length > 0, true);
  });
}

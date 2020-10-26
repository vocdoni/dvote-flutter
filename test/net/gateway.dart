import 'dart:convert';
import 'package:test/test.dart';
// import 'package:dvote/dvote.dart';

void dvoteGateway() {
  //   final origin = "ipfs://Qmaisz6NMhDB51cCvNWa1GMS7LU1pAxdF4Ld6Ft9kZEP2a";

  //   test('fetchFile', () async {
  //     final gwInfo = await getRandomDefaultGatewayInfo(NETWORK_ID);
  //     final res = await fetchFileString(ContentURI(origin), gwInfo.dvote,
  //         gatewayPublicKey: gwInfo.publicKey);
  //     expect(res, "Hello from IPFS Gateway Checker");
  //   });

  test("getAverageBlockTime", () {
    final response =
        '{"id":"req-2345679","response":{"ok":true,"avgBlockTime":10.4,"request":"req-2345679","timestamp":1556110672},"signature":"0x1234"}';
    final res = jsonDecode(response);
    expect(res is Map, true);
    expect(res["response"] is Map, true);
    expect(res["response"]["avgBlockTime"] is double, true);
    expect(res["response"]["avgBlockTime"], 10.4);
  });
}

void web3Gateway() {
  //   test('web3Gateway', () async {
  //     final gwInfo = await getRandomDefaultGatewayInfo(NETWORK_ID);
  //     EntityReference entity = EntityReference();
  //     entity.entityId =
  //         "0x180dd5765d9f7ecef810b565a2e5bd14a3ccd536c442b3de74867df552855e85";
  //     entity.entryPoints.addAll([gwInfo.web3]);

  //     final gwInfo = await getRandomDefaultGatewayInfo(networkId);
  //     final DVoteGateway dvoteGw = DVoteGateway(gwInfo.dvote, publicKey: gwInfo.publicKey);
  //     final Web3Gateway web3Gw = Web3Gateway(gwInfo.web3);

  //     final result = await fetchEntity(entity, gwInfo.dvote, gwInfo.web3);

  //     print(result.writeToJson());
  //   });
}

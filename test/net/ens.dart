import 'package:flutter_test/flutter_test.dart';
import 'package:dvote/blockchain/ens.dart';

void ens() {
  test("ENS resolver client", () async {
    String nodeHash = hashDomainName("entity-resolver.vocdoni.eth");
    expect(nodeHash,
        "0xff303c4eb585eb0d6908e9126a7e44a57c960397578695b4e8c684ff964e21bd");

    nodeHash = hashDomainName("voting-process.vocdoni.eth");
    expect(nodeHash,
        "0x9008634c9b4659734d1f50350becdc7ad401d7e49020ae341322ed4338b3be52");

    final RegExp addressRegExp = new RegExp(r"^0x[0-9A-Fa-f]{40}$");
    String data = await resolveName(
        "entity-resolver.vocdoni.eth", "https://dai.poa.network");
    expect(addressRegExp.hasMatch(data), true,
        reason: "The result should be a valid address");

    data = await resolveName(
        "voting-process.vocdoni.eth", "https://dai.poa.network");
    expect(addressRegExp.hasMatch(data), true,
        reason: "The result should be a valid address");
  });
}

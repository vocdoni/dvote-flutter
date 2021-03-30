import 'package:flutter_test/flutter_test.dart';
import 'package:dvote/blockchain/ens.dart';

void ens() {
  test("ENS resolver client", () async {
    String nodeHash = hashDomainName("entities.vocdoni.eth");
    expect(nodeHash,
        "0xff303c4eb585eb0d6908e9126a7e44a57c960397578695b4e8c684ff964e21bd");

    nodeHash = hashDomainName("processes.vocdoni.eth");
    expect(nodeHash,
        "0x9008634c9b4659734d1f50350becdc7ad401d7e49020ae341322ed4338b3be52");

    final addressRegExp = RegExp(r"^0x[0-9A-Fa-f]{40}$");

    // XDAI Main contract
    final addr1 =
        await resolveName("entities.vocdoni.eth", "https://dai.poa.network");
    expect(addressRegExp.hasMatch(addr1), true,
        reason: "The result should be a valid address");

    final addr2 =
        await resolveName("processes.vocdoni.eth", "https://dai.poa.network");
    expect(addressRegExp.hasMatch(addr2), true,
        reason: "The result should be a valid address");

    // XDAI testing
    final addr3 =
        await resolveName("entities.vocdoni.eth", "https://dai.poa.network");
    expect(addressRegExp.hasMatch(addr3), true,
        reason: "The result should be a valid address");

    final addr4 =
        await resolveName("processes.vocdoni.eth", "https://dai.poa.network");
    expect(addressRegExp.hasMatch(addr4), true,
        reason: "The result should be a valid address");

    // SOKOL
    final addr5 =
        await resolveName("entities.vocdoni.eth", "https://sokol.poa.network");
    expect(addressRegExp.hasMatch(addr5), true,
        reason: "The result should be a valid address");

    final addr6 =
        await resolveName("processes.vocdoni.eth", "https://sokol.poa.network");
    expect(addressRegExp.hasMatch(addr6), true,
        reason: "The result should be a valid address");
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:dvote/dvote.dart';

void pollVoting() {
  test("Poll nullifier", () {
    String address = "424797Ed6d902E17b9180BFcEF452658e148e0Ab";
    String processId =
        "74394b43b2d3f1c4df79fe5a4a67d07cfdab053f586253286d515d36e89db3e7";

    final nullifier1 = getPollNullifier(address, processId);
    expect(nullifier1,
        "0x1b131b6f4e099ebb77b5886f606f5f9af1f20837c45945482e0af2b1df46fe86");
  });
}

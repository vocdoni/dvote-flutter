import 'package:dvote/dvote.dart';
import 'package:dvote/net/gateway-pool.dart';

Future waitVochainBlocks(int blocks, GatewayPool gw) async {
  if (gw == null) throw Exception("Invalid parameters");

  final targetBlock = blocks + await getBlockHeight(gw);
  var future = new Future.delayed(const Duration(milliseconds: 2000), () {
    int lastBlock;
    getBlockHeight(gw).then((currentBlock) {
      if (currentBlock != lastBlock) {
        lastBlock = currentBlock;
      }
      if (currentBlock >= targetBlock) {
        return;
      }
    });
  });
  return future;
}

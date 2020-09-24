import 'dart:async';

import 'package:dvote/dvote.dart';
import 'package:dvote/net/gateway-pool.dart';

Future waitVochainBlocks(int blockCount, GatewayPool gw) async {
  if (gw == null) throw Exception("Invalid parameters");

  int lastBlock = await getBlockHeight(gw);
  final targetBlock = blockCount + lastBlock;

  final compl = Completer<void>();

  // runs every 2000 ms
  Timer.periodic(Duration(milliseconds: 2000), (timer) {
    getBlockHeight(gw).then((currentBlock) {
      if (compl.isCompleted)
        return;
      else if (currentBlock >= targetBlock) {
        compl.complete();
        timer.cancel();
        return;
      } else if (currentBlock != lastBlock) {
        lastBlock = currentBlock;
      }
    });
  });

  return compl.future;
}

Future waitUntilVochainBlock(int block, GatewayPool gw) async {
  final currentBlock = await getBlockHeight(gw);
  if (currentBlock >= block) return;
  return waitVochainBlocks(block - currentBlock, gw);
}

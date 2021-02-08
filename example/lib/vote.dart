import 'package:dvote/dvote.dart';
import 'package:dvote/models/build/dart/common/vote.pb.dart';
import './constants.dart';
import 'package:dvote_crypto/dvote_crypto.dart';

Future<void> vote() async {
  GatewayPool gw;
  EntityMetadata entityMeta;
  ProcessMetadata processMeta;
  ProcessData processData;
  EnvelopePackage pollVoteEnvelope;
  String merkleProof;
  int blockHeight, censusSize, envelopeHeight;
  DateTime dateAtBlock;
  // bool envelopeSent;

  final wallet = EthereumWallet.fromMnemonic(MNEMONIC, hdPath: HD_PATH);
  // final wallet = EthereumNativeWallet.fromMnemonic(MNEMONIC, hdPath: HD_PATH);

  final String privateKey = wallet.privateKey;
  final entityId = ENTITY_ID;
  final String address = wallet.address;
  final String pubKey = wallet.publicKey(uncompressed: false);
  final String pubKeyClaim = Hashing.digestHexClaim(pubKey);
  // final String pubKeyClaim = CENSUS_PUB_KEY_CLAIM;
  // final String censusMerkleRoot = CENSUS_MERKLE_ROOT;

  EntityReference entityRef = EntityReference();
  entityRef.entityId = entityId;

  try {
    gw = await GatewayPool.discover(NETWORK_ID,
        bootnodeUri: BOOTNODES_URL_RW, maxGatewayCount: 5, timeout: 10);

    // Get some metadata
    entityMeta = await fetchEntity(entityRef, gw);
    print("\nLoading process metadata");

    final pid = entityMeta.votingProcesses?.active?.firstWhere(
        (id) => id == PROCESS_ID,
        orElse: () => entityMeta.votingProcesses.active.first ?? null);
    if (!(pid is String)) {
      print("There are no active processes");
      return;
    }
    processData = await getProcess(pid, gw);
    processMeta = await getProcessMetadata(pid, gw, data: processData);
    processMeta.meta["id"] = pid;
    print("Process ID: $pid");
  } catch (err) {
    print(err);
    return;
  }

  // Prepare the vote
  try {
    // Block height
    print("\nQuerying the block height");
    blockHeight = await getBlockHeight(gw);
    if (!(blockHeight is int)) throw Exception("The census size is not valid");
    print("Block height: $blockHeight");

    // Census size
    print("\nQuerying for the Census size");
    censusSize = await getCensusSize(processData.getCensusRoot, gw);
    // censusSize = await getCensusSize(censusMerkleRoot, gw);
    if (!(censusSize is int)) throw Exception("The census size is not valid");
    print("Census size: $censusSize");

    // Envelope height
    print("\nQuerying for the Envelope height");
    envelopeHeight = await getEnvelopeHeight(processMeta.meta["id"], gw);
    if (!(envelopeHeight is int))
      throw Exception("The envelope height is not valid");
    print("Envelope height: $envelopeHeight");

    // Remaining seconds
    print("\nEstimating");
    dateAtBlock = await estimateDateAtBlock(processData.getStartBlock, gw);
    print("Process start block: $dateAtBlock");
    dateAtBlock = await estimateDateAtBlock(
        processData.getStartBlock + processData.getBlockCount, gw);
    print("Process end block: $dateAtBlock");

    // Merkle Proof
    print("\nRequesting Merkle Proof");
    final isDigested = true;
    merkleProof = await generateProof(
        processData.getCensusRoot, pubKeyClaim, isDigested, gw);
    // merkleProof = await generateProof(censusMerkleRoot, pubKeyClaim, gw);
    if (!(merkleProof is String))
      throw Exception("The Merkle Proof is not valid");
    print("Merkle Proof:   $merkleProof");

    // Generate Envelope
    print("\nGenerating the Vote Envelope");
    final voteValues = [1, 2, 1];
    pollVoteEnvelope = await packageSignedEnvelope(
        voteValues,
        merkleProof,
        processMeta.meta["id"],
        privateKey,
        ProcessCensusOrigin(ProcessCensusOrigin.OFF_CHAIN_TREE));
    print("Poll vote envelope:  $pollVoteEnvelope");

    // Submit Envelope
    print("\nSubmitting the vote");
    await submitEnvelope(pollVoteEnvelope.envelope, gw,
        hexSignature: pollVoteEnvelope.signature);

    // Get envelope status
    final nullifier =
        await getSignedVoteNullifier(address, processMeta.meta["id"]);
    print("Nullifier: $nullifier");
    final registered =
        await getEnvelopeStatus(processMeta.meta["id"], nullifier, gw);
    print("Registered: $registered");
  } catch (err) {
    print(err);
  }
}

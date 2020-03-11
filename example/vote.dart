import 'package:dvote/dvote.dart';
import './constants.dart';

Future<void> vote() async {
  EntityMetadata entityMeta;
  ProcessMetadata processMeta;
  Map<String, dynamic> pollVoteEnvelope;
  String merkleProof;
  int blockHeight, censusSize, envelopeHeight, remainingSeconds;
  // bool envelopeSent;

  final wallet = EthereumWallet.fromMnemonic(MNEMONIC, hdPath: PATH);

  final String privateKey = wallet.privateKey;
  final networkId = NETWORK_ID;
  final entityId = ENTITY_ID;
  final entityEntryPoint = ENTITY_ENTRY_POINT;
  final String address = wallet.address;
  final String pubKey = wallet.publicKey;
  final String pubKeyClaim = await digestHexClaim(pubKey);
  // final String pubKeyClaim = CENSUS_PUB_KEY_CLAIM;
  // final String censusMerkleRoot = CENSUS_MERKLE_ROOT;

  EntityReference entityRef = EntityReference();
  entityRef.entityId = entityId;
  entityRef.entryPoints.addAll([entityEntryPoint]);

  GatewayInfo gwInfo = await getRandomDefaultGatewayDetails(networkId);
  final dvoteGw = DVoteGateway(gwInfo.dvote, publicKey: gwInfo.publicKey);
  final web3Gw = Web3Gateway(gwInfo.web3);

  // Get some metadata
  try {
    final isUp = await DVoteGateway.isUp(dvoteGw.uri);
    if (!isUp) throw Exception("The gateway is down");

    entityMeta = await fetchEntity(entityRef, dvoteGw, web3Gw);
    print("\nLoading process metadata");

    final pid = entityMeta.votingProcesses?.active?.firstWhere(
        (id) => id == PROCESS_ID,
        orElse: () => entityMeta.votingProcesses.active.first ?? null);
    if (!(pid is String)) {
      print("There are no active processes");
      return;
    }
    processMeta = await getProcessMetadata(pid, dvoteGw, web3Gw);
    processMeta.meta["id"] = pid;
    print("Process ID: $pid");
  } catch (err) {
    print(err);
    return;
  }

  // Prepare the vote
  try {
    final isUp = await DVoteGateway.isUp(dvoteGw.uri);
    if (!isUp) throw Exception("The gateway is down");

    // Block height
    print("\nQuerying the block height");
    blockHeight = await getBlockHeight(dvoteGw);
    if (!(blockHeight is int)) throw Exception("The census size is not valid");
    print("Block height: $blockHeight");

    // Census size
    print("\nQuerying for the Census size");
    censusSize = await getCensusSize(processMeta.census.merkleRoot, dvoteGw);
    // censusSize = await getCensusSize(censusMerkleRoot, dvoteGw);
    if (!(censusSize is int)) throw Exception("The census size is not valid");
    print("Census size: $censusSize");

    // Envelope height
    print("\nQuerying for the Envelope height");
    envelopeHeight = await getEnvelopeHeight(processMeta.meta["id"], dvoteGw);
    if (!(envelopeHeight is int))
      throw Exception("The envelope height is not valid");
    print("Envelope height: $envelopeHeight");

    // Remaining seconds
    print("\nRequesting the remaining time amount");
    // await getTimeUntilStart(processMeta.meta["id"], 1000, dvoteGw);
    remainingSeconds = await getTimeUntilEnd(1000, 2000, dvoteGw);
    if (!(remainingSeconds is int))
      throw Exception("The remaining seconds amount is not valid");
    print("Remaining seconds: $remainingSeconds");

    // Merkle Proof
    print("\nRequesting Merkle Proof");
    merkleProof = await generateProof(
        processMeta.census.merkleRoot, pubKeyClaim, dvoteGw);
    // merkleProof = await generateProof(censusMerkleRoot, pubKeyClaim, dvoteGw);
    if (!(merkleProof is String))
      throw Exception("The Merkle Proof is not valid");
    print("Merkle Proof:   $merkleProof");

    // Generate Envelope
    print("\nGenerating the Vote Envelope");
    final voteValues = [1, 2, 1];
    pollVoteEnvelope = packagePollEnvelope(
        voteValues, merkleProof, processMeta.meta["id"], privateKey);
    print("Poll vote envelope:  $pollVoteEnvelope");

    // Submit Envelope
    print("\nSubmitting the vote");
    await submitEnvelope(pollVoteEnvelope, dvoteGw);

    // Get envelope status
    final nullifier = getPollNullifier(address, processMeta.meta["id"]);
    print("Nullifier: $nullifier");
    final registered =
        await getEnvelopeStatus(processMeta.meta["id"], nullifier, dvoteGw);
    print("Registered: $registered");
  } catch (err) {
    print(err);
  }
}

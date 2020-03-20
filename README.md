# DVote Flutter

A Flutter plugin that provides cryptographic and communication capabilities to interact with decentralized governance processes running on the Vocdoni platform.

It provides Dart libraries as well as native modules written in Go.

More details: https://pub.dev/packages/dvote

# DVote example

* [Getting Started](#getting-started)
* [HD Wallet management](#hd-wallet-management)
* [Signing](#signing)
* [Encryption](#encryption)
* [Entity API](#entity-api)
* [File API](#file-api)
* [Data models](#data-models)

## Getting Started
Import the Dart library on your project and use the static functions available on the `Dvote` class

```dart
import 'package:dvote/dvote.dart';
```

## HD Wallet management
Generating mnemonics and computing private/public keys

```dart
final wallet = EthereumWallet.random(hdPath: "m/44'/60'/0'/0/5");
final mnemonic = wallet.mnemonic;
final privKey = wallet.privateKey;
final pubKey = wallet.publicKey;
final addr = wallet.address;
```

## Signing
Computing signatures using ECDSA cryptography

```dart
// Signing plain text
final hexSignature = signString(messageToSign, privateKey);
final recoveredPubKey = recoverSignerPubKey(hexSignature, messageToSign);
final valid = isValidSignature(hexSignature, messageToSign, publicKey);

// Signing reproduceable JSON data
final hexSignature2 = signJsonPayload({"hello": 1234}, privateKey);
final recoveredPubKey = recoverJsonSignerPubKey(hexSignature2, {"hello": 1234});
final valid2 = isValidJsonSignature(hexSignature2, {"hello": 1234}, publicKey);
```

Also available as async non-UI blocking functions:

```dart
// Signing plain text
final hexSignature = await signStringAsync(messageToSign, privateKey);
final recoveredPubKey = await recoverSignerPubKeyAsync(hexSignature, messageToSign);
final valid = await isValidSignatureAsync(hexSignature, messageToSign, publicKey);

// Signing reproduceable JSON data
final hexSignature2 = await signJsonPayloadAsync({"hello": 1234}, privateKey);
final recoveredPubKey = await recoverJsonSignerPubKeyAsync(hexSignature2, {"hello": 1234});
final valid2 = await isValidJsonSignatureAsync(hexSignature2, {"hello": 1234}, publicKey);
```

## Entity API
Use a Vocdoni Gateway to fetch the metadata of an Entity

```dart
import 'package:dvote/dvote.dart';

EntityReference entityRef = EntityReference();
entityRef.entityId = "0x1234...";

final gwInfo = await getRandomDefaultGatewayInfo("goerli");
final DVoteGateway dvoteGw = DVoteGateway(gwInfo.dvote, publicKey: gwInfo.publicKey);
final Web3Gateway web3Gw = Web3Gateway(gwInfo.web3);

final entityMeta = await fetchEntity(entityRef, dvoteGw, web3Gw);
dvoteGw.disconnect();
```

## Process API
Use a Vocdoni Gateway to fetch the active voting processes of an Entity

```dart
import 'package:dvote/dvote.dart';

EntityReference entityRef = EntityReference();
entityRef.entityId = "0x1234...";

final gwInfo = await getRandomDefaultGatewayInfo("goerli");
final DVoteGateway dvoteGw = DVoteGateway(gwInfo.dvote, publicKey: gwInfo.publicKey);
final Web3Gateway web3Gw = Web3Gateway(gwInfo.web3);

// All active from an Entity
final List<ProcessMetadata>> processes = await fetchActiveProcesses(entityRef, dvoteGw, web3Gw);

// A specific Voting Process
final pid = "0x1234...";
final ProcessMetadataprocessMeta = await getProcessMetadata(pid, dvoteGw, web3Gw);

dvoteGw.disconnect();
```

## File API
Use a Vocdoni Gateway to fetch static content from the net

```dart
import 'package:dvote/dvote.dart';

final gwInfo = await getRandomDefaultGatewayInfo("goerli");
final DVoteGateway dvoteGw = DVoteGateway(gwInfo.dvote, publicKey: gwInfo.publicKey);
final Web3Gateway web3Gw = Web3Gateway(gwInfo.web3);

final contentUri = ContentURI("ipfs://QmSsfizN4rpSDLRZw3X3WooCPpnBktZ5bEShvmLZuf88iw,https://my-server/file.txt");

final content = await fetchFileString(contentUri, dvoteGw, web3Gw);
```

## Data models and storage

DVote Flutter exports multiple Dart classes that allow to wrap, parse, serialize and deserialize the most relevant data schemes used within the platform.

```dart
import 'package:dvote/dvote.dart';

// Parse from JSON
Entity entity = parseEntityMetadata("{ ... }");
print(entity.name["en"]);
print(entity.media.avatar);

// Serialize into a binary file
File file1 = File("./my-entity.dat");
file1.writeAsBytes(entity.writeToBuffer());

// Reading back from a file
File file3 = File("./my-entity.dat");
final entityBytes = await file3.readAsBytes();
Entity entity2 = Entity.fromBuffer(entityBytes);
print(entity2.name["en"]);

// Storing a collection of entities
EntitiesStore store = EntitiesStore();
store.entities.addAll([entity, entity2]);
File file2 = File("./entities.dat");
await file2.writeAsBytes(store.writeToBuffer());
```

### Classes

The following classes are exported:

- Entity
  - EntityStore
  - Entity_VotingProcesses
  - Entity_Media
  - Entity_Action_ImageSource
  - Entity_Action
  - Entity_GatewayBootNode
  - Entity_GatewyUpdate
  - Entity_Relay
  - Entity_EntityReference
  - EntitySummary
- Process
  - Process_Census
  - Process_Details
  - Process_Details_Question
  - Process_Details_Question_VoteOption
- Feed
  - FeedsStore
  - FeedPost_Author
  - FeedPost
- Gateway
  - GatewaysStore
- Identity
  - IdentitiesStore
  - Identity_Claim
- Key

### Parsers

Raw JSON data can't be directly serialized into a Protobuf object. For this reason, several parsers are provided:

- `Entity parseEntityMetadata(String json)`
  - `List<Entity_Action> parseEntityActions(List actions)`
  - `List<Entity_GatewayBootNode> parseBootNodes(List bootNodes)`
  - `List<Entity_EntityReference> parseEntityReferences(List entities)`
- `Process parseProcessMetadata(String json)`
  - `List<Process_Details_Question> parseQuestions(List items)`
- `Feed parseFeed(String json)`

## Example

- See `example/lib/main.dart` for a usage example.

## TO DO

- [ ] Document examples of Poseidon hash, generate Merkle Proofs and ZK proofs

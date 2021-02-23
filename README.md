# DVote Flutter

A Flutter plugin that provides communication capabilities to interact with decentralized governance processes running on the Vocdoni platform.

It provides Dart libraries as well as native modules written in Go.

More details: https://pub.dev/packages/dvote

# DVote example

- [DVote Flutter](#dvote-flutter)
- [DVote example](#dvote-example)
  - [Getting Started](#getting-started)
  - [Entity API](#entity-api)
  - [Process API](#process-api)
  - [File API](#file-api)
  - [Data models and storage](#data-models-and-storage)
    - [Classes](#classes)
    - [Parsers](#parsers)
  - [Example](#example)
  - [Development](#development)

## Getting Started
Import the Dart library on your project and use the static functions available on the `Dvote` class

```dart
import 'package:dvote/dvote.dart';
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
  - EntityMetadataStore
  - EntityMetadata
  - EntityMetadata_VotingProcesses
  - EntityMetadata_Media
  - EntityMetadata_Action
  - EntityMetadata_Action_ImageSource
  - EntityMetadata_EntityReference
- Process
  - ProcessMetadataStore
  - ProcessMetadata
  - ProcessMetadata_Census
  - ProcessMetadata_Details
  - ProcessMetadata_Details_Question
  - ProcessMetadata_Details_Question_VoteOption
- Feed
  - FeedsStore
  - Feed
  - FeedPost
  - FeedPost_Author
- Gateway
  - BootNodeGateways
  - BootNodeGateways_NetworkNodes
  - BootNodeGateways_NetworkNodes_DVote
  - BootNodeGateways_NetworkNodes_Web3
- Identity
  - IdentitiesStore
  - Identity
  - Identity_Peers
  - Identity_Claim
  - PeerIdentity
- Key

### Parsers

Raw JSON data can't be directly serialized into a Protobuf object. For this reason, several parsers are provided:

- `EntityMetadata parseEntityMetadata(String json)`
  - `List<Entity_Action> parseEntityActions(List actions)`
  - `List<Entity_EntityReference> parseEntityReferences(List entities)`
- `ProcessMetadata parseProcessMetadata(String json)`
  - `List<Process_Details_Question> _parseQuestions(List items)`
- `ProcessResults parseProcessResults(Map<String, dynamic> response)`
- `ProcessResultsDigested parseProcessResultsDigestedSingleQuestion(ProcessResults rawResults, ProcessMetadata processMetadata, ProcessData processData)`
- `Feed parseFeed(String json)`
- `BootNodeGateways parseBootnodeInfo(String json)`
  - `BootNodeGateways_NetworkNodes _parseBootnodeNetworkItems(Map item)` 

## Example

- See `example/lib/main.dart` for a usage example.

## Development

- Clone the git repo
- Run `flutter pub get`
- Run `git submodule update --init --recursive` to fetch the protobuf subrepo

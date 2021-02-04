- Update `getGatewayInfo` to `getInfo`
- Update Ens public resolver
- Update Process contract artifacts
- Hash entity address for ENS call

## 0.19.0
- Update process contract wrappers to smart contracts v2
- Use ProcessCensusOrigin wrapper
- Update generateProof
- parseRawResults uses String for result values
- parseProcessResultsDigested uses BigInt for result values

## 0.18.9

- Enable synchronous date estimation
  
## 0.18.8

- Update dvote-protobuf
  
## 0.18.7

- Update dvote-protobuf
## 0.18.6

- Update dvote-protobuf
  
## 0.18.5

- Allow client to use cached BlockStatus to estimate date

## 0.18.4

- Setting the base block time to 12 seconds

## 0.18.3

- Remove buggy log statement in bootnodes.dart

## 0.18.2

- Ensure that signed messages are sorted the same way that they are signed

## 0.18.1

- Temporary dvote-crypto backoff: Using pure Dart until an iOS issue is addressed, failing to bundle native code when packaged for app store distribution

## 0.18.0

- Using `dvote_crypto` instead of `dvote_native`
- Refactoring code to only depend on a single crypto interface with dynamic implementation (native/Dart)
- Flutter speficics and Native bindings now live on separate packages. Check [dvote_native](https://pub.dev/packages/dvote_native) to make use of the native code.

## 0.17.8

- Dependency upgrades
- Decoupling the timeout from HTTP requests and turning it into a Dart extension

## 0.17.7

- Minor fix on the results handler

## 0.17.6

- Allow to reuse the existing metadata of a process in `getResultsDigest`

## 0.17.5

- Extend the staging environment flags to the gateway discovery functions

## 0.17.4

- Adding support for the xDAI staging environment

## 0.17.3

- Gateway discovery fix

## 0.17.2

- Allowing to the the results of a voting process

## 0.17.1

- Adding support for the Sokol network

## 0.17.0

- Updating the registration handler endpoints to use DVoteGateways

## 0.16.0

- Providing symmetric encryption using native bindings (SecretBox)
- Providing sync and async versions of the Poseidon hashing function

## 0.15.0

- DVoteGateway now uses HTTP
- Adding the Gateway wrapper for DVoteGateway and Web3Gateway
- Adding the GatewayPool class
- Adding Gateway discovery capabilities
- Renamed `packageSnarkEnvelope` into `packageAnonymousEnvelope`
- Renamed `packagePollEnvelope` into `packageSignedEnvelope`
- Merged `packageSnarkVote` and `packagePollVote` into `packageVoteContent`
- Renamed `getPollNullifier` into `getSignedVoteNullifier`

## 0.14.1

- Dependency version bump

## 0.14.0

- **Breaking**: Using uncompressed public keys by default
- **Breaking**: `Wallet.publicKey` and `Wallet.publicKeyAsync` are no longer a getter, but a function accepting parameters
- Supporting signatures with `v` values of `0x1b-0x1c` as well as `0x00-0x01`

## 0.13.0

- Using native primitives for wallet, signing and hashing from dvote-flutter-native
- Providing separate wrappers for pure dart and native versions

## 0.12.18

- Improving the error handling of `getBlockStatus()`

## 0.12.17

- Minor fix to `getBlockStatus()`

## 0.12.16

- Renaming a few deprecated fields and enum's

## 0.12.15

- Using the entity's address hash instead of the address itself. This allows for future proof behavior.

## 0.12.14

- Allowing to derive different Ethereum accounts for different entities
- Reporting gateway request timeout's right away, instead of waiting a bit
- Supporting xDai by default

## 0.12.13-xdai

- Using dvote-flutter-native@0.5.0

## 0.12.12-xdai

- Uses an updated dvote-flutter-native version

## 0.12.11-xdai

- Skipping "pid" as a variable name.
- Also, accept canceled process as still valid.

## 0.12.10-xdai

- Adapting the Web3 Gateway client to support the xDAI blockchain
- Providing an xDAI example
- Updated smart contract definitions

## 0.12.9

- Adding the `registrationStatus` method

## 0.12.8

- Minor change on the wrapper field names

## 0.12.7

- Splitting the registration function into `register` and `validateRegistrationToken`

## 0.12.6

- Sending the same JSON payload as the one signed (Gateway)
- Adding a wrapper to validate registration tokens to a certain backend

## 0.12.5

- Providing accurate block time estimation using average times
  - Introducing `estimateBlockAtDateTime` and `estimateDateAtBlock`
  - Removing `getTimeUntilStart` and `getTimeUntilEnd`

## 0.12.4

- Improving support for encrypted vote submission

## 0.12.3

- Internal format rollback to support the current contract version

## 0.12.2

* Adapt the gateway response handler to the current protocol
* Fix a mismatch the could alter encrypted votes when using more than one key
* Increase the timestamp mismatch tolerance

## 0.12.1

* Implementing Poll package Encryption
* Adding getProcessKeys()

## 0.12.0

* Breaking change: Poseidon hashes are now little-endian

## 0.11.0

* Breaking change on a few crypto functions that are now async, for the UI thread to get control back

## 0.10.4

* Providing consistent non-blocking async versions of the cryptographic functions (wallet, signing, encryption, hashing and ZK proofs)

## 0.10.3

* Updating dvote-flutter-native to support iOS ARMv7 targets
* Update the metadata to reference the docs

## 0.10.2

* Use the new process metadata scheme from dvote-protobuf

## 0.10.1

* Submitting vote packages with an updated format

## 0.10.0

* Updating the API to generate and check census proofs

## 0.9.3

* Handling Ethereum signatures with a version byte below 0x1b

## 0.9.2

* Verifying signatures against compressed public keys

## 0.9.1

* Adding async versions of ECDSA signing functions

## 0.9.0

* Importing the native poseidon hash and ZK proofs generators

## 0.8.2

- Extracting symmetric encryption into the library

## 0.8.1

- Using synchronous signing primitives

## 0.8.0

- Publishing the library as a pure Dart Package instead of a Flutter Plugin
- Stripping off the native bindings (will be shipped in a dedicated plugin)

## 0.7.8

- Perform a deeper health check when calling `isUp`

## 0.7.7

- Adapting the parsers to use the new Action scheme from Protobuf

## 0.7.6

- Using a different WebSocket client

## 0.7.5

- Turning `isUp()` into a static function

## 0.7.4

- Allow to check the status of a Gateway

## 0.7.3

- Allow optional process metadata values

## 0.7.2

- Using a single timeout checker

## 0.7.1

- Ensure that the IPFS fallback works
- Better network issues handling

## 0.7.0

- Adding support for Flutter 1.12 and AndroidX

## 0.6.1

- Updating the ENS registry address
- Throwing Exceptions instead of plain strings
- Fetching remote files with timeout
- Updating the License to be compatible with the Apple App Store

## 0.6.0

- Using tighter timeouts on GW requests

## 0.5.32

- Using the new build system for the native dependencies
- Fixing an issue on response handling

## 0.5.31

- Adding support for getEnvelopeStatus

## 0.5.30

- Updating to the latest version of the voting process contract

## 0.5.29

- Fix on genProof

## 0.5.28

- Minor change on the census

## 0.5.27

- Adding `checkProof`

## 0.5.26

- Polishing the envelope helpers

## 0.5.25

- Updating the Process contract return indexes

## 0.5.24

- Updating the time estimation functions form the Vote API

## 0.5.23

- Updating the Voting Process smart contract definition

## 0.5.22

- Adding `getTimeUntilStart` and `getTimeUntilEnd`

## 0.5.21

- Internal improvements

## 0.5.20

- Adding `getSize` to the Census API

## 0.5.19

- Integrating Poseidon hashes from Go DVote Mobile
- Restructuring the example project

## 0.5.18

- Allowing to fetch voting processes from an Entity

## 0.5.17

- Allowing to fetch the boot nodes URI from the blockchain

## 0.5.16

- Fetching gateway info from boot nodes

## 0.5.15

- Republishing

## 0.5.14

- Republishing

## 0.5.13

- Adding support for for ENS domain resolution

## 0.5.12

- Updating the Entity data models

## 0.5.11

- Allowing to parse and fetch process metadata
- Updating the data models

## 0.5.10

- Improving the Metadata parser

## 0.5.9

- Adding support for register entity actions

## 0.5.8

- Adding a JSON Feed protobuf parser
- Simplifying the JSON Feed model

## 0.5.7

- Correcting the identity data model

## 0.5.6

- Improving the data model

## 0.5.5

- Updated data models

## 0.5.4

- Updated data models

## 0.5.3

- Parsing Entity metadata for use with protobuf

## 0.5.2

- Export the Gateway data model

## 0.5.1

- Improve the data models

## 0.5.0

- Rearranging the structure of methods and how functions are invoked
- Adding the definitions of identity management operations

## 0.4.2

- Checking response timestamps from Gateways

## 0.4.1

- Exporting EntityAction and classes extended from it
- Allowing to define entryPoints

## 0.4.0

- Signing using the Ethereum prefix for web compatibility
- Allowing to set the origin of the metadata of an Entity

## 0.3.1
## 0.3.0

- Allowing to fetch Entity metadata from ENS+IPFS
- Providing a class to wrap the metadata of an Entity
- Arranging the API methods so they can be used by just importing `dvote.dart`

## 0.2.3

- Adding the missing bindings from 0.2.2
- Provide a better `example/Readme.md`

## 0.2.2

* Allow to sign and verify signatures using go-ethereum ECDSA

## 0.2.1

* Allow to sign messages using go-ethereum ECDSA

## 0.2.0

* Allow to encrypt/decrypt strings using AES-GCM

## 0.1.1

* Allow to use optional named parameters

## 0.1.0

* Provide support for mnemonic to private/public key and address conversion

## 0.0.1

* Initial scaffold of the plugin

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

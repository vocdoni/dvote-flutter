# DVote Protobuf

Protobuf definitions for data types used by Vocdoni voting processes

Check out the source code generated for each of the available languages.

## Important note

- In protobuf, new fields can be added, renamed and removed with future-compatibility.
- However, **once an ID has been used, it can't never be reused by any other field again**

## Models provided

- Entity
  - Used to send and store the metadata of an Entity
- News Feed
  - Implements the structure of a JSON Feed
- Identity
  - Used to serialize and store identities created by a user
- Key
  - Used to keep track of encrypted key pairs

///
//  Generated code. Do not modify.
//  source: entity.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

const EntityMetadataStore$json = const {
  '1': 'EntityMetadataStore',
  '2': const [
    const {'1': 'items', '3': 1, '4': 3, '5': 11, '6': '.dvote.EntityMetadata', '10': 'items'},
  ],
};

const EntityMetadata$json = const {
  '1': 'EntityMetadata',
  '2': const [
    const {'1': 'version', '3': 1, '4': 1, '5': 9, '10': 'version'},
    const {'1': 'languages', '3': 2, '4': 3, '5': 9, '10': 'languages'},
    const {'1': 'name', '3': 3, '4': 3, '5': 11, '6': '.dvote.EntityMetadata.NameEntry', '10': 'name'},
    const {'1': 'description', '3': 4, '4': 3, '5': 11, '6': '.dvote.EntityMetadata.DescriptionEntry', '10': 'description'},
    const {'1': 'votingProcesses', '3': 5, '4': 1, '5': 11, '6': '.dvote.EntityMetadata.VotingProcesses', '10': 'votingProcesses'},
    const {'1': 'newsFeed', '3': 6, '4': 3, '5': 11, '6': '.dvote.EntityMetadata.NewsFeedEntry', '10': 'newsFeed'},
    const {'1': 'media', '3': 7, '4': 1, '5': 11, '6': '.dvote.EntityMetadata.Media', '10': 'media'},
    const {'1': 'actions', '3': 8, '4': 3, '5': 11, '6': '.dvote.EntityMetadata.Action', '10': 'actions'},
    const {'1': 'bootEntities', '3': 9, '4': 3, '5': 11, '6': '.dvote.EntityReference', '10': 'bootEntities'},
    const {'1': 'fallbackBootNodeEntities', '3': 10, '4': 3, '5': 11, '6': '.dvote.EntityReference', '10': 'fallbackBootNodeEntities'},
    const {'1': 'trustedEntities', '3': 11, '4': 3, '5': 11, '6': '.dvote.EntityReference', '10': 'trustedEntities'},
    const {'1': 'censusServiceManagedEntities', '3': 12, '4': 3, '5': 11, '6': '.dvote.EntityReference', '10': 'censusServiceManagedEntities'},
    const {'1': 'meta', '3': 100, '4': 3, '5': 11, '6': '.dvote.EntityMetadata.MetaEntry', '10': 'meta'},
  ],
  '3': const [EntityMetadata_NameEntry$json, EntityMetadata_DescriptionEntry$json, EntityMetadata_VotingProcesses$json, EntityMetadata_NewsFeedEntry$json, EntityMetadata_Media$json, EntityMetadata_Action$json, EntityMetadata_MetaEntry$json],
};

const EntityMetadata_NameEntry$json = const {
  '1': 'NameEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': const {'7': true},
};

const EntityMetadata_DescriptionEntry$json = const {
  '1': 'DescriptionEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': const {'7': true},
};

const EntityMetadata_VotingProcesses$json = const {
  '1': 'VotingProcesses',
  '2': const [
    const {'1': 'active', '3': 1, '4': 3, '5': 9, '10': 'active'},
    const {'1': 'ended', '3': 2, '4': 3, '5': 9, '10': 'ended'},
  ],
};

const EntityMetadata_NewsFeedEntry$json = const {
  '1': 'NewsFeedEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': const {'7': true},
};

const EntityMetadata_Media$json = const {
  '1': 'Media',
  '2': const [
    const {'1': 'avatar', '3': 1, '4': 1, '5': 9, '10': 'avatar'},
    const {'1': 'header', '3': 2, '4': 1, '5': 9, '10': 'header'},
  ],
};

const EntityMetadata_Action$json = const {
  '1': 'Action',
  '2': const [
    const {'1': 'type', '3': 1, '4': 1, '5': 9, '10': 'type'},
    const {'1': 'actionKey', '3': 7, '4': 1, '5': 9, '10': 'actionKey'},
    const {'1': 'name', '3': 2, '4': 3, '5': 11, '6': '.dvote.EntityMetadata.Action.NameEntry', '10': 'name'},
    const {'1': 'visible', '3': 3, '4': 1, '5': 9, '10': 'visible'},
    const {'1': 'url', '3': 4, '4': 1, '5': 9, '10': 'url'},
    const {'1': 'imageSources', '3': 5, '4': 3, '5': 11, '6': '.dvote.EntityMetadata.Action.ImageSource', '10': 'imageSources'},
  ],
  '3': const [EntityMetadata_Action_NameEntry$json, EntityMetadata_Action_ImageSource$json],
};

const EntityMetadata_Action_NameEntry$json = const {
  '1': 'NameEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': const {'7': true},
};

const EntityMetadata_Action_ImageSource$json = const {
  '1': 'ImageSource',
  '2': const [
    const {'1': 'type', '3': 1, '4': 1, '5': 9, '10': 'type'},
    const {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'orientation', '3': 3, '4': 1, '5': 9, '10': 'orientation'},
    const {'1': 'overlay', '3': 4, '4': 1, '5': 9, '10': 'overlay'},
    const {'1': 'caption', '3': 5, '4': 3, '5': 11, '6': '.dvote.EntityMetadata.Action.ImageSource.CaptionEntry', '10': 'caption'},
  ],
  '3': const [EntityMetadata_Action_ImageSource_CaptionEntry$json],
};

const EntityMetadata_Action_ImageSource_CaptionEntry$json = const {
  '1': 'CaptionEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': const {'7': true},
};

const EntityMetadata_MetaEntry$json = const {
  '1': 'MetaEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': const {'7': true},
};

const EntityReference$json = const {
  '1': 'EntityReference',
  '2': const [
    const {'1': 'entityId', '3': 1, '4': 1, '5': 9, '10': 'entityId'},
    const {'1': 'entryPoints', '3': 2, '4': 3, '5': 9, '10': 'entryPoints'},
  ],
};


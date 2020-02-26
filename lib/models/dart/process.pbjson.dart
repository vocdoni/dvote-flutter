///
//  Generated code. Do not modify.
//  source: process.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

const ProcessMetadataStore$json = const {
  '1': 'ProcessMetadataStore',
  '2': const [
    const {'1': 'items', '3': 1, '4': 3, '5': 11, '6': '.dvote.ProcessMetadata', '10': 'items'},
  ],
};

const ProcessMetadata$json = const {
  '1': 'ProcessMetadata',
  '2': const [
    const {'1': 'version', '3': 1, '4': 1, '5': 9, '10': 'version'},
    const {'1': 'type', '3': 2, '4': 1, '5': 9, '10': 'type'},
    const {'1': 'startBlock', '3': 3, '4': 1, '5': 5, '10': 'startBlock'},
    const {'1': 'numberOfBlocks', '3': 4, '4': 1, '5': 5, '10': 'numberOfBlocks'},
    const {'1': 'census', '3': 5, '4': 1, '5': 11, '6': '.dvote.ProcessMetadata.Census', '10': 'census'},
    const {'1': 'details', '3': 6, '4': 1, '5': 11, '6': '.dvote.ProcessMetadata.Details', '10': 'details'},
    const {'1': 'meta', '3': 100, '4': 3, '5': 11, '6': '.dvote.ProcessMetadata.MetaEntry', '10': 'meta'},
  ],
  '3': const [ProcessMetadata_Census$json, ProcessMetadata_Details$json, ProcessMetadata_MetaEntry$json],
};

const ProcessMetadata_Census$json = const {
  '1': 'Census',
  '2': const [
    const {'1': 'merkleRoot', '3': 1, '4': 1, '5': 9, '10': 'merkleRoot'},
    const {'1': 'merkleTree', '3': 2, '4': 1, '5': 9, '10': 'merkleTree'},
  ],
};

const ProcessMetadata_Details$json = const {
  '1': 'Details',
  '2': const [
    const {'1': 'entityId', '3': 1, '4': 1, '5': 9, '10': 'entityId'},
    const {'1': 'encryptionPublicKey', '3': 2, '4': 1, '5': 9, '10': 'encryptionPublicKey'},
    const {'1': 'title', '3': 3, '4': 3, '5': 11, '6': '.dvote.ProcessMetadata.Details.TitleEntry', '10': 'title'},
    const {'1': 'description', '3': 4, '4': 3, '5': 11, '6': '.dvote.ProcessMetadata.Details.DescriptionEntry', '10': 'description'},
    const {'1': 'headerImage', '3': 5, '4': 1, '5': 9, '10': 'headerImage'},
    const {'1': 'questions', '3': 6, '4': 3, '5': 11, '6': '.dvote.ProcessMetadata.Details.Question', '10': 'questions'},
  ],
  '3': const [ProcessMetadata_Details_TitleEntry$json, ProcessMetadata_Details_DescriptionEntry$json, ProcessMetadata_Details_Question$json],
};

const ProcessMetadata_Details_TitleEntry$json = const {
  '1': 'TitleEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': const {'7': true},
};

const ProcessMetadata_Details_DescriptionEntry$json = const {
  '1': 'DescriptionEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': const {'7': true},
};

const ProcessMetadata_Details_Question$json = const {
  '1': 'Question',
  '2': const [
    const {'1': 'type', '3': 1, '4': 1, '5': 9, '10': 'type'},
    const {'1': 'question', '3': 2, '4': 3, '5': 11, '6': '.dvote.ProcessMetadata.Details.Question.QuestionEntry', '10': 'question'},
    const {'1': 'description', '3': 3, '4': 3, '5': 11, '6': '.dvote.ProcessMetadata.Details.Question.DescriptionEntry', '10': 'description'},
    const {'1': 'voteOptions', '3': 4, '4': 3, '5': 11, '6': '.dvote.ProcessMetadata.Details.Question.VoteOption', '10': 'voteOptions'},
  ],
  '3': const [ProcessMetadata_Details_Question_QuestionEntry$json, ProcessMetadata_Details_Question_DescriptionEntry$json, ProcessMetadata_Details_Question_VoteOption$json],
};

const ProcessMetadata_Details_Question_QuestionEntry$json = const {
  '1': 'QuestionEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': const {'7': true},
};

const ProcessMetadata_Details_Question_DescriptionEntry$json = const {
  '1': 'DescriptionEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': const {'7': true},
};

const ProcessMetadata_Details_Question_VoteOption$json = const {
  '1': 'VoteOption',
  '2': const [
    const {'1': 'title', '3': 1, '4': 3, '5': 11, '6': '.dvote.ProcessMetadata.Details.Question.VoteOption.TitleEntry', '10': 'title'},
    const {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '3': const [ProcessMetadata_Details_Question_VoteOption_TitleEntry$json],
};

const ProcessMetadata_Details_Question_VoteOption_TitleEntry$json = const {
  '1': 'TitleEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': const {'7': true},
};

const ProcessMetadata_MetaEntry$json = const {
  '1': 'MetaEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': const {'7': true},
};


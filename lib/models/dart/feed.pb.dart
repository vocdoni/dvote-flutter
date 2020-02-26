///
//  Generated code. Do not modify.
//  source: feed.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class FeedStore extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('FeedStore', package: const $pb.PackageName('dvote'), createEmptyInstance: create)
    ..pc<Feed>(1, 'items', $pb.PbFieldType.PM, subBuilder: Feed.create)
    ..hasRequiredFields = false
  ;

  FeedStore._() : super();
  factory FeedStore() => create();
  factory FeedStore.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FeedStore.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  FeedStore clone() => FeedStore()..mergeFromMessage(this);
  FeedStore copyWith(void Function(FeedStore) updates) => super.copyWith((message) => updates(message as FeedStore));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static FeedStore create() => FeedStore._();
  FeedStore createEmptyInstance() => create();
  static $pb.PbList<FeedStore> createRepeated() => $pb.PbList<FeedStore>();
  @$core.pragma('dart2js:noInline')
  static FeedStore getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FeedStore>(create);
  static FeedStore _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<Feed> get items => $_getList(0);
}

class Feed extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('Feed', package: const $pb.PackageName('dvote'), createEmptyInstance: create)
    ..aOS(1, 'version')
    ..aOS(2, 'title')
    ..aOS(3, 'homePageUrl')
    ..aOS(4, 'description')
    ..aOS(5, 'feedUrl')
    ..aOS(6, 'icon')
    ..aOS(7, 'favicon')
    ..aOB(8, 'expired')
    ..pc<FeedPost>(9, 'items', $pb.PbFieldType.PM, subBuilder: FeedPost.create)
    ..m<$core.String, $core.String>(100, 'meta', entryClassName: 'Feed.MetaEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('dvote'))
    ..hasRequiredFields = false
  ;

  Feed._() : super();
  factory Feed() => create();
  factory Feed.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Feed.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  Feed clone() => Feed()..mergeFromMessage(this);
  Feed copyWith(void Function(Feed) updates) => super.copyWith((message) => updates(message as Feed));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Feed create() => Feed._();
  Feed createEmptyInstance() => create();
  static $pb.PbList<Feed> createRepeated() => $pb.PbList<Feed>();
  @$core.pragma('dart2js:noInline')
  static Feed getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Feed>(create);
  static Feed _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get version => $_getSZ(0);
  @$pb.TagNumber(1)
  set version($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearVersion() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get title => $_getSZ(1);
  @$pb.TagNumber(2)
  set title($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTitle() => $_has(1);
  @$pb.TagNumber(2)
  void clearTitle() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get homePageUrl => $_getSZ(2);
  @$pb.TagNumber(3)
  set homePageUrl($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasHomePageUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearHomePageUrl() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get description => $_getSZ(3);
  @$pb.TagNumber(4)
  set description($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasDescription() => $_has(3);
  @$pb.TagNumber(4)
  void clearDescription() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get feedUrl => $_getSZ(4);
  @$pb.TagNumber(5)
  set feedUrl($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasFeedUrl() => $_has(4);
  @$pb.TagNumber(5)
  void clearFeedUrl() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get icon => $_getSZ(5);
  @$pb.TagNumber(6)
  set icon($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasIcon() => $_has(5);
  @$pb.TagNumber(6)
  void clearIcon() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get favicon => $_getSZ(6);
  @$pb.TagNumber(7)
  set favicon($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasFavicon() => $_has(6);
  @$pb.TagNumber(7)
  void clearFavicon() => clearField(7);

  @$pb.TagNumber(8)
  $core.bool get expired => $_getBF(7);
  @$pb.TagNumber(8)
  set expired($core.bool v) { $_setBool(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasExpired() => $_has(7);
  @$pb.TagNumber(8)
  void clearExpired() => clearField(8);

  @$pb.TagNumber(9)
  $core.List<FeedPost> get items => $_getList(8);

  @$pb.TagNumber(100)
  $core.Map<$core.String, $core.String> get meta => $_getMap(9);
}

class FeedPost_Author extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('FeedPost.Author', package: const $pb.PackageName('dvote'), createEmptyInstance: create)
    ..aOS(1, 'name')
    ..aOS(2, 'url')
    ..hasRequiredFields = false
  ;

  FeedPost_Author._() : super();
  factory FeedPost_Author() => create();
  factory FeedPost_Author.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FeedPost_Author.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  FeedPost_Author clone() => FeedPost_Author()..mergeFromMessage(this);
  FeedPost_Author copyWith(void Function(FeedPost_Author) updates) => super.copyWith((message) => updates(message as FeedPost_Author));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static FeedPost_Author create() => FeedPost_Author._();
  FeedPost_Author createEmptyInstance() => create();
  static $pb.PbList<FeedPost_Author> createRepeated() => $pb.PbList<FeedPost_Author>();
  @$core.pragma('dart2js:noInline')
  static FeedPost_Author getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FeedPost_Author>(create);
  static FeedPost_Author _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get url => $_getSZ(1);
  @$pb.TagNumber(2)
  set url($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUrl() => $_has(1);
  @$pb.TagNumber(2)
  void clearUrl() => clearField(2);
}

class FeedPost extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('FeedPost', package: const $pb.PackageName('dvote'), createEmptyInstance: create)
    ..aOS(1, 'id')
    ..aOS(2, 'title')
    ..aOS(3, 'summary')
    ..aOS(4, 'contentText')
    ..aOS(5, 'contentHtml')
    ..aOS(6, 'url')
    ..aOS(7, 'image')
    ..pPS(8, 'tags')
    ..aOS(9, 'datePublished')
    ..aOS(10, 'dateModified')
    ..aOM<FeedPost_Author>(11, 'author', subBuilder: FeedPost_Author.create)
    ..hasRequiredFields = false
  ;

  FeedPost._() : super();
  factory FeedPost() => create();
  factory FeedPost.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FeedPost.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  FeedPost clone() => FeedPost()..mergeFromMessage(this);
  FeedPost copyWith(void Function(FeedPost) updates) => super.copyWith((message) => updates(message as FeedPost));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static FeedPost create() => FeedPost._();
  FeedPost createEmptyInstance() => create();
  static $pb.PbList<FeedPost> createRepeated() => $pb.PbList<FeedPost>();
  @$core.pragma('dart2js:noInline')
  static FeedPost getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FeedPost>(create);
  static FeedPost _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get title => $_getSZ(1);
  @$pb.TagNumber(2)
  set title($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTitle() => $_has(1);
  @$pb.TagNumber(2)
  void clearTitle() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get summary => $_getSZ(2);
  @$pb.TagNumber(3)
  set summary($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSummary() => $_has(2);
  @$pb.TagNumber(3)
  void clearSummary() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get contentText => $_getSZ(3);
  @$pb.TagNumber(4)
  set contentText($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasContentText() => $_has(3);
  @$pb.TagNumber(4)
  void clearContentText() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get contentHtml => $_getSZ(4);
  @$pb.TagNumber(5)
  set contentHtml($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasContentHtml() => $_has(4);
  @$pb.TagNumber(5)
  void clearContentHtml() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get url => $_getSZ(5);
  @$pb.TagNumber(6)
  set url($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasUrl() => $_has(5);
  @$pb.TagNumber(6)
  void clearUrl() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get image => $_getSZ(6);
  @$pb.TagNumber(7)
  set image($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasImage() => $_has(6);
  @$pb.TagNumber(7)
  void clearImage() => clearField(7);

  @$pb.TagNumber(8)
  $core.List<$core.String> get tags => $_getList(7);

  @$pb.TagNumber(9)
  $core.String get datePublished => $_getSZ(8);
  @$pb.TagNumber(9)
  set datePublished($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasDatePublished() => $_has(8);
  @$pb.TagNumber(9)
  void clearDatePublished() => clearField(9);

  @$pb.TagNumber(10)
  $core.String get dateModified => $_getSZ(9);
  @$pb.TagNumber(10)
  set dateModified($core.String v) { $_setString(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasDateModified() => $_has(9);
  @$pb.TagNumber(10)
  void clearDateModified() => clearField(10);

  @$pb.TagNumber(11)
  FeedPost_Author get author => $_getN(10);
  @$pb.TagNumber(11)
  set author(FeedPost_Author v) { setField(11, v); }
  @$pb.TagNumber(11)
  $core.bool hasAuthor() => $_has(10);
  @$pb.TagNumber(11)
  void clearAuthor() => clearField(11);
  @$pb.TagNumber(11)
  FeedPost_Author ensureAuthor() => $_ensure(10);
}


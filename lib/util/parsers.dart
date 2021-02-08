import 'dart:convert';
import 'dart:developer';

import 'package:dvote/api/voting.dart';
import 'package:dvote/models/build/dart/metadata/entity.pb.dart';
import 'package:dvote/models/build/dart/metadata/feed.pb.dart';
import 'package:dvote/models/build/dart/metadata/process.pb.dart';
import 'package:dvote/models/build/dart/client-store/gateway.pb.dart';
import 'package:dvote/wrappers/process-results.dart';

// ////////////////////////////////////////////////////////////////////////////
// ENTITY
// ////////////////////////////////////////////////////////////////////////////

EntityMetadata parseEntityMetadata(String json) {
  try {
    final mapEntity = jsonDecode(json);
    if (!(mapEntity is Map)) throw Exception("The entity metadata is invalid");

    final EntityMetadata entity = EntityMetadata();
    entity.version = mapEntity["version"] ?? "";
    if (mapEntity["languages"] != null)
      entity.languages.addAll(mapEntity["languages"]?.cast<String>() ?? []);
    if (mapEntity["name"] is Map)
      entity.name.addAll(mapEntity["name"]?.cast<String, String>() ?? {});
    if (mapEntity["description"] is Map)
      entity.description
          .addAll(mapEntity["description"]?.cast<String, String>() ?? {});

    if (mapEntity["votingProcesses"] != null) {
      EntityMetadata_VotingProcesses votingProcesses =
          EntityMetadata_VotingProcesses();
      if (mapEntity["votingProcesses"]["active"] != null)
        votingProcesses.active.addAll(
            mapEntity["votingProcesses"]["active"]?.cast<String>() ?? []);
      if (mapEntity["votingProcesses"]["ended"] != null)
        votingProcesses.ended.addAll(
            mapEntity["votingProcesses"]["ended"]?.cast<String>() ?? []);
      entity.votingProcesses = votingProcesses;
    }

    if (mapEntity["newsFeed"] is Map)
      entity.newsFeed
          .addAll(mapEntity["newsFeed"]?.cast<String, String>() ?? {});

    if (mapEntity["media"] != null) {
      EntityMetadata_Media media = EntityMetadata_Media();
      if (mapEntity["media"]["avatar"] != null)
        media.avatar = mapEntity["media"]["avatar"] ?? "";
      if (mapEntity["media"]["header"] != null)
        media.header = mapEntity["media"]["header"] ?? "";
      entity.media = media;
    }

    final actions = parseEntityActions(mapEntity["actions"]);
    entity.actions.addAll(actions);

    final bootEntities = parseEntityReferences(mapEntity["bootEntities"]);
    entity.bootEntities.addAll(bootEntities);

    final fallbackBootNodeEntities =
        parseEntityReferences(mapEntity["fallbackBootNodeEntities"]);
    entity.fallbackBootNodeEntities.addAll(fallbackBootNodeEntities);

    final trustedEntities = parseEntityReferences(mapEntity["trustedEntities"]);
    entity.trustedEntities.addAll(trustedEntities);

    final censusServiceManagedEntities =
        parseEntityReferences(mapEntity["censusServiceManagedEntities"]);
    entity.censusServiceManagedEntities.addAll(censusServiceManagedEntities);

    return entity;
  } catch (err) {
    throw Exception("The entity metadata could not be parsed");
  }
}

List<EntityMetadata_Action> parseEntityActions(List actions) {
  if (!(actions is List)) return [];
  return actions.whereType<Map>().map((action) {
    EntityMetadata_Action result = EntityMetadata_Action();
    try {
      // IMPORTANT: Assume that values may be empty

      result.type = action["type"] ?? "";
      result.actionKey = action["actionKey"] ?? "";
      result.name.addAll(action["name"]?.cast<String, String>() ?? {});
      result.visible = action["visible"] ?? "true";
      // type = register / browser / image
      if (action["url"] is String) result.url = action["url"];
      // type = image
      if (action["imageSources"] is List) {
        final sources = action["imageSources"].whereType<Map>().map((source) {
          EntityMetadata_Action_ImageSource result =
              EntityMetadata_Action_ImageSource();
          result.type = source["type"] ?? "";
          result.name = source["name"] ?? "";
          result.orientation = source["orientation"] ?? "";
          result.overlay = source["overlay"] ?? "";
          result.caption
              .addAll(source["caption"]?.cast<String, String>() ?? {});
          return result;
        });
        result.imageSources.addAll(sources);
      }
    } catch (err) {
      log(err);
    }
    return result;
  }).toList();
}

List<EntityReference> parseEntityReferences(List entities) {
  if (!(entities is List)) return [];
  return entities.whereType<Map>().map((entity) {
    EntityReference result = EntityReference();
    result.entityId = entity["entityId"] ?? "";
    result.entryPoints.addAll(entity["entryPoints"]?.cast<String>() ?? []);
    return result;
  }).toList();
}

// ////////////////////////////////////////////////////////////////////////////
// VOTING PROCESS
// ////////////////////////////////////////////////////////////////////////////

ProcessMetadata parseProcessMetadata(String json) {
  try {
    ProcessMetadata result = ProcessMetadata();
    final Map<String, dynamic> mapProcess = jsonDecode(json);
    if (!(mapProcess is Map)) return null;

    result.version = mapProcess["version"] ?? "";
    result.title.addAll(mapProcess["title"]?.cast<String, String>() ?? {});
    result.description
        .addAll(mapProcess["description"]?.cast<String, String>() ?? {});
    result.media.addAll(mapProcess["media"]?.cast<String, String>() ?? {});

    final Map meta = mapProcess["meta"];
    meta.forEach((key, value) => result.meta.addAll({key: value.toString()}));

    if (mapProcess["questions"] is List) {
      final questions = _parseQuestions(mapProcess["questions"]);

      result.questions.addAll(questions);
    }
    return result;
  } catch (err) {
    throw Exception("The process metadata could not be parsed: $err");
  }
}

// Parse raw results Map into ProcessResults object
ProcessResults parseProcessResults(Map<String, dynamic> response) {
  try {
    ProcessResults processResults = ProcessResults.empty();
    if (response["results"] is List) {
      processResults.results = (response["results"] as List)
          .whereType<List>()
          .map((list) => list.whereType<String>().toList())
          .toList();
    }
    if (response["state"] is String) {
      processResults.state = response["state"];
    }
    if (response["type"] is String) {
      processResults.type = response["type"];
    }
    return processResults;
  } catch (err) {
    throw Exception("The process results could not be retrieved: $err");
  }
}

ProcessResultsDigested parseProcessResultsDigested(ProcessResults rawResults,
    ProcessMetadata processMetadata, ProcessData processData) {
  if (rawResults == null || processMetadata == null) {
    return null;
  }
  if (processMetadata.questions?.isEmpty ?? true) {
    return ProcessResultsDigested(rawResults.state, rawResults.type);
  }
  final resultsDigest =
      ProcessResultsDigested(rawResults.state, rawResults.type);
  resultsDigest.questions = new List<ProcessResultItem>();

  for (int i = 0; i < processMetadata.questions.length; i++) {
    if (processMetadata.questions[i] == null) {
      throw Exception("Metadata question is null");
    }

    resultsDigest.questions.add(ProcessResultItem(
        // processMetadata.questions[i].type,
        processData.getEnvelopeType,
        processMetadata.questions[i],
        processMetadata.questions[i].description));
    resultsDigest.questions[i].voteResults = new List<VoteResults>();

    for (int j = 0; j < processMetadata.questions[i].choices.length; j++) {
      String votes;
      if ((i >= (rawResults.results?.length ?? 0)) ||
          (j >= (rawResults.results[i]?.length ?? 0))) {
        votes = "0";
      } else {
        votes = rawResults.results[i][j];
      }
      BigInt numberVotes;
      try {
        numberVotes = BigInt.parse(votes);
      } catch (err) {
        log("Could not parse results: $err");
        numberVotes = BigInt.zero;
      }
      resultsDigest.questions[i].voteResults.add(VoteResults(
          processMetadata.questions[i].choices[j].title, numberVotes));
    }
  }
  return resultsDigest;
}

List<ProcessMetadata_Question> _parseQuestions(List items) {
  return items.whereType<Map>().map((item) {
    final ProcessMetadata_Question result = ProcessMetadata_Question();
    if (item["title"] is Map)
      result.title.addAll(item["title"]?.cast<String, String>() ?? {});
    if (item["description"] is Map) {
      result.description
          .addAll(item["description"].cast<String, String>() ?? {});
    }

    final choices = (item["choices"] as List).whereType<Map>().map((item) {
      final result = ProcessMetadata_Question_VoteOption();
      if (item["title"] is Map)
        result.title.addAll(item["title"]?.cast<String, String>() ?? {});
      if (item["value"] is int)
        result.value = item["value"];
      else if (item["value"] is String)
        result.value = int.parse(item["value"]);
      else
        throw Exception("The vote value is not valid");

      return result;
    }).toList();
    result.choices.addAll(choices);

    return result;
  }).toList();
}

// ////////////////////////////////////////////////////////////////////////////
// FEED
// ////////////////////////////////////////////////////////////////////////////

Feed parseFeed(String json) {
  try {
    Feed result = Feed();
    final mapFeed = jsonDecode(json);
    if (!(mapFeed is Map)) return null;

    if (mapFeed["version"] != null) result.version = mapFeed["version"];
    if (mapFeed["title"] != null) result.title = mapFeed["title"];
    if (mapFeed["home_page_url"] != null)
      result.homePageUrl = mapFeed["home_page_url"];
    if (mapFeed["description"] != null)
      result.description = mapFeed["description"];
    if (mapFeed["feed_url"] != null) result.feedUrl = mapFeed["feed_url"];
    if (mapFeed["icon"] != null) result.icon = mapFeed["icon"];
    if (mapFeed["favicon"] != null) result.favicon = mapFeed["favicon"];
    result.expired = mapFeed["expired"] ?? false;

    if (mapFeed["items"] is List) {
      List<FeedPost> items =
          (mapFeed["items"] as List).whereType<Map>().map((item) {
        FeedPost post = FeedPost();
        if (item["id"] != null) post.id = item["id"];
        if (item["title"] != null) post.title = item["title"];
        if (item["summary"] != null) post.summary = item["summary"];
        if (item["content_text"] != null)
          post.contentText = item["content_text"];
        if (item["content_html"] != null)
          post.contentHtml = item["content_html"];
        if (item["url"] != null) post.url = item["url"];
        if (item["image"] != null) post.image = item["image"];
        if (item["tags"] != null)
          post.tags.addAll((item["tags"] as List).cast<String>());
        if (item["date_published"] != null)
          post.datePublished = item["date_published"];
        if (item["date_modified"] != null)
          post.dateModified = item["date_modified"];

        FeedPost_Author author = FeedPost_Author();
        if (item["author"] != null) {
          if (item["author"]["name"] != null)
            author.name = item["author"]["name"];
          if (item["author"]["url"] != null) author.url = item["author"]["url"];
          post.author = author;
        }
        return post;
      }).toList();
      result.items.addAll(items);
    }

    return result;
  } catch (err) {
    throw Exception("The boot nodes could not be parsed");
  }
}

// ////////////////////////////////////////////////////////////////////////////
// GATEWAY BOOT NODES
// ////////////////////////////////////////////////////////////////////////////

BootNodeGateways parseBootnodeInfo(String json) {
  try {
    BootNodeGateways result = BootNodeGateways();
    final networkIdMap = jsonDecode(json);
    if (networkIdMap is! Map) return null;

    (networkIdMap as Map).forEach((k, value) {
      switch (k) {
        case "mainnet":
        case "homestead":
          result.homestead = _parseBootnodeNetworkItems(value);
          break;
        case "goerli":
          result.goerli = _parseBootnodeNetworkItems(value);
          break;
        case "xdai":
          result.xdai = _parseBootnodeNetworkItems(value);
          break;
        case "sokol":
          result.sokol = _parseBootnodeNetworkItems(value);
          break;
      }
    });
    return result;
  } catch (err) {
    throw Exception("The boot nodes data could not be parsed");
  }
}

BootNodeGateways_NetworkNodes _parseBootnodeNetworkItems(Map item) {
  if (item["dvote"] is! List && item["web3"] is! List) return null;

  BootNodeGateways_NetworkNodes result = BootNodeGateways_NetworkNodes();
  if (item["dvote"] is List) {
    List<BootNodeGateways_NetworkNodes_DVote> items =
        (item["dvote"] as List).cast<Map>().map((item) {
      final result = BootNodeGateways_NetworkNodes_DVote();
      result.uri = item["uri"];
      result.apis.addAll((item["apis"] as List).cast<String>());
      result.pubKey = item["pubKey"];
      return result;
    }).toList();
    result.dvote.addAll(items);
  }
  if (item["web3"] is List) {
    List<BootNodeGateways_NetworkNodes_Web3> items =
        (item["web3"] as List).cast<Map>().map((item) {
      final result = BootNodeGateways_NetworkNodes_Web3();
      result.uri = item["uri"];
      return result;
    }).toList();
    result.web3.addAll(items);
  }
  return result;
}

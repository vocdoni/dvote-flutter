import 'package:flutter_test/flutter_test.dart';
import 'package:dvote/util/parsers.dart';
import 'package:dvote/dvote.dart';
import 'package:web3dart/web3dart.dart';

void dataModels() {
  test("Entity metadata model", () {
    String meta =
        """{"version":"1.0","languages":["default"],"name":{"default":"My official entity","fr":"Mon organisation officielle"},"description":{"default":"The description of my entity goes here","fr":"La description officielle de mon organisation est ici"},"votingProcesses":{"active":[],"ended":[]},"newsFeed":{"default":"https://hipsterpixel.co/feed.json","fr":"https://feed2json.org/convert?url=http://www.intertwingly.net/blog/index.atom"},"media":{"avatar":"https://hipsterpixel.co/assets/favicons/apple-touch-icon.png","header":"https://images.unsplash.com/photo-1557518016-299b3b3c2e7f?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=80"},"actions":[{"type":"register","actionKey":"register","name":{"default":"Sign up to The Entity","fr":"S'inscrire à l'organisation"},"url":"https://cloudflare-ipfs.com/ipfs/QmZ56Z2kpG5QjJcWfhxFD4ac3DhfX21hrQ2gCTrWxzTAse","visible":"always"}],"bootEntities":[],"fallbackBootNodeEntities":[],"trustedEntities":[],"censusServiceManagedEntities":[]}""";
    EntityMetadata entity = parseEntityMetadata(meta);
    expect(entity.name["default"], "My official entity",
        reason: "The name should equal My official entity");

    meta =
        """{"version":"1.0","languages":["fr","en"],"name":{"default":"My official entity","fr":"Bonjour","en":"Good morning"},"description":{"default":"The description of my entity goes here","fr":"Bonjour 123","en":"Good morning 123"},"votingProcesses":{"active":[],"ended":[]},"newsFeed":{"default":"https://hipsterpixel.co/feed.json"},"media":{"avatar":"https://hipsterpixel.co/assets/favicons/apple-touch-icon.png","header":"https://images.unsplash.com/photo-1557518016-299b3b3c2e7f?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=80"},"actions":[{"type":"register","actionKey":"register","name":{"default":"Sign up to The Entity"},"url":"https://cloudflare-ipfs.com/ipfs/QmZ56Z2kpG5QjJcWfhxFD4ac3DhfX21hrQ2gCTrWxzTAse","visible":"always"},{"type":"register","actionKey":"register2","name":{"default":"Sign up"},"register":true,"url":"https://registry.vocdoni.net/register.html?entityId=0x180dd5765d9f7ecef810b565a2e5bd14a3ccd536c442b3de74867df552855e85","visible":"https://registry.vocdoni.net/api/actions/status?action=register?action=register"}],"bootEntities":[],"fallbackBootNodeEntities":[],"trustedEntities":[],"censusServiceManagedEntities":[]}""";
    entity = parseEntityMetadata(meta);
    expect(entity.actions[0].type, "register",
        reason: "The action type should be register");
    expect(entity.actions[0].actionKey, "register",
        reason: "The actionKey should be register");
    expect(entity.actions[1].type, "register",
        reason: "The action type should be register");
    expect(entity.actions[1].actionKey, "register2",
        reason: "The actionKey should be register2");
  });

  test("Process metadata model", () {
    String meta =
        """{"version":"1.1","title":{"default":"Board election"},"description":{"default":"Process description"},"media":{"header":"https://ipfs.io/ipfs/1234...","streamUri":""},"meta":{"my":"custom-field","value":1234},"questions":[{"title":{"default":"Should universal basic income become a human right?"},"description":{"default":"## Markdown text goes here### Abstract"},"choices":[{"title":{"en":"Yes", "ca": "Sí"},"value":0},{"title":{"en":"No", "ca": "No"},"value":1}]}]}""";
    ProcessMetadata process = parseProcessMetadata(meta);
    expect(process.version, "1.1", reason: "The version should equal 1.1");
    expect(process.title['default'], "Board election",
        reason: "The title should equal \"Board election\"");
    expect(process.description['default'], "Process description",
        reason: "The description should equal \"Process description\"");
    expect(process.media['header'], "https://ipfs.io/ipfs/1234...",
        reason:
            "The media header should equal \"https://ipfs.io/ipfs/1234...\"");
    expect(process.meta['my'], "custom-field",
        reason: "The meta field \'my\' should equal \"custom-field\"");
    expect(process.meta['value'], "1234",
        reason: "The meta field \'value\' should equal 1234");

    expect(process.questions[0].title["default"],
        "Should universal basic income become a human right?");
    expect(process.questions[0].description["default"],
        "## Markdown text goes here### Abstract");

    expect(process.questions[0].choices[0].title["en"], "Yes");
    expect(process.questions[0].choices[0].title["ca"], "Sí");
    expect(process.questions[0].choices[0].value, 0);

    expect(process.questions[0].choices[1].title["en"], "No");
    expect(process.questions[0].choices[1].title["ca"], "No");
    expect(process.questions[0].choices[1].value, 1);
  });

  test("Process data model", () {
    final jsonData = ProcessData.fromJsonString(
        """[["1","0","1"],"0x63c1452cf8f2fed7ead5e6c222c41e96c6ec1e0f",["ipfs://QmVBUKa6xUitCSmf5fnghJUhEXXoY4qjW79LkUntpwDY9s","0x0000000000000000000000000000000000000000000000000000000000000000","ipfs://1234"],["14500","100"],"0",["0","2","1","5","1"],["0","1000","1"],"0"]""");
    final data = ProcessData([
      [BigInt.from(1), BigInt.from(0), BigInt.from(1)],
      EthereumAddress.fromHex("63c1452cf8f2fed7ead5e6c222c41e96c6ec1e0f"),
      [
        "ipfs://QmVBUKa6xUitCSmf5fnghJUhEXXoY4qjW79LkUntpwDY9s",
        "0x0000000000000000000000000000000000000000000000000000000000000000",
        "ipfs://1234"
      ],
      [BigInt.from(14500), BigInt.from(100)],
      BigInt.from(0),
      [
        BigInt.from(0),
        BigInt.from(2),
        BigInt.from(1),
        BigInt.from(5),
        BigInt.from(1)
      ],
      [BigInt.from(0), BigInt.from(1000), BigInt.from(1)],
      BigInt.from(0),
    ]);

    expect(data.mode.value, jsonData.mode.value,
        reason:
            "ProcessData should parse getMode correctly from jsonString and list");
    expect(data.envelopeType.hasAnonymousVoters,
        jsonData.envelopeType.hasAnonymousVoters,
        reason:
            "ProcessData should parse getEnvelopeType correctly from jsonString and list");
    expect(data.envelopeType.hasEncryptedVotes,
        jsonData.envelopeType.hasEncryptedVotes,
        reason:
            "ProcessData should parse getEnvelopeType correctly from jsonString and list");
    expect(data.envelopeType.hasSerialVoting,
        jsonData.envelopeType.hasSerialVoting,
        reason:
            "ProcessData should parse getEnvelopeType correctly from jsonString and list");
    expect(data.envelopeType.hasUniqueValues,
        jsonData.envelopeType.hasUniqueValues,
        reason:
            "ProcessData should parse getEnvelopeType correctly from jsonString and list");
    expect(data.censusOrigin.value, jsonData.censusOrigin.value,
        reason:
            "ProcessData should parse getCensusOrigin correctly from jsonString and list");
    expect(data.entityAddress.toString(), jsonData.entityAddress.toString(),
        reason:
            "ProcessData should parse getEntityAddress correctly from jsonString and list");
    expect(data.metadata, jsonData.metadata,
        reason:
            "ProcessData should parse getMetadata correctly from jsonString and list");
    expect(data.censusRoot, jsonData.censusRoot,
        reason:
            "ProcessData should parse getCensusRoot correctly from jsonString and list");
    expect(data.censusUri, jsonData.censusUri,
        reason:
            "ProcessData should parse getCensusUri correctly from jsonString and list");
    expect(data.startBlock, jsonData.startBlock,
        reason:
            "ProcessData should parse getStartBlock correctly from jsonString and list");
    expect(data.blockCount, jsonData.blockCount,
        reason:
            "ProcessData should parse getBlockCount correctly from jsonString and list");
    expect(data.status.value, jsonData.status.value,
        reason:
            "ProcessData should parse getStatus correctly from jsonString and list");
    expect(data.questionIndex, jsonData.questionIndex,
        reason:
            "ProcessData should parse getQuestionIndex correctly from jsonString and list");
    expect(data.questionCount, jsonData.questionCount,
        reason:
            "ProcessData should parse getQuestionCount correctly from jsonString and list");
    expect(data.maxCount, jsonData.maxCount,
        reason:
            "ProcessData should parse getMaxCount correctly from jsonString and list");
    expect(data.maxValue, jsonData.maxValue,
        reason:
            "ProcessData should parse getMaxValue correctly from jsonString and list");
    expect(data.maxVoteOverwrites, jsonData.maxVoteOverwrites,
        reason:
            "ProcessData should parse getMaxVoteOverwrites correctly from jsonString and list");
    expect(data.maxTotalCost, jsonData.maxTotalCost,
        reason:
            "ProcessData should parse getMaxTotalCost correctly from jsonString and list");
    expect(data.costExponent, jsonData.costExponent,
        reason:
            "ProcessData should parse getCostExponent correctly from jsonString and list");
    expect(data.evmBlockHeight.toInt(), jsonData.evmBlockHeight.toInt(),
        reason:
            "ProcessData should parse getEvmBlockHeight correctly from jsonString and list");
  });

  test("Feed model", () {
    final meta = '''{
  "version": "https://jsonfeed.org/version/1",
  "title": "My Entity Feed",
  "home_page_url": "https://hipsterpixel.co/",
  "description": "I am the description of the entity",
  "feed_url": "https://hipsterpixel.co/feed.json",
  "icon": "https://hipsterpixel.co/assets/favicons/apple-touch-icon.png",
  "favicon": "https://hipsterpixel.co/assets/favicons/favicon.ico",
  "expired": false,
  "items": [
    {
      "id": "900e5aa6896c53a40745acac8ca00c3c0ae4f7c3",
      "title": "China's latest weapon in the trade war: Karaoke",
      "summary": "A Chinese propaganda song about the ongoing Sino-US trade war is getting a lot of interest - and raising a few eyebrows - on Chinese social media.",
      "content_text": "Many cameras nowadays come with a nice screen, often high resolution with a high brightness, but not always swivelling and always too small to fully rely on. I cannot tell how many times a bad picture on the small camera display was actually pretty decent once I opened it on the computer. And when you’re doing video, you really need to get that focus right, at all times. This is hard, but I have a solution that will help you out tremendously!",
      "content_html": "<h1>I'm an H1</h1> <h2>I'm an H2</h2> <h3>I'm an H3</h3> <img src=\\"https://i.udemycdn.com/course/750x422/59535_1f48_6.jpg\\" alt=\\"Girl in a jacket\\">",
      "url": "https://hipsterpixel.co/2019/05/10/smallhd-5-5-focus-oled-monitor-review/",
      "image": "https://ichef.bbci.co.uk/news/768/cpsprodpb/E24F/production/_107053975_tradewar.png",
      "tags": [
        "smallhd",
        "oled",
        "monitor",
        "camera",
        "review",
        "test",
        "videography",
        "photography",
        "filmmaking",
        "sonycamera",
        "workflow",
        "gearhead"
      ],
      "date_published": "2019-05-10T19:10:00+00:00",
      "date_modified": "2019-05-10T19:10:00+00:00",
      "author": {
        "name": "Alexandre Vallières-Lagacé",
        "url": "http://vallier.es"
      }
    },
    {
      "id": "962e46254d1527862c1d81574000e58b295aca8b",
      "title": "Logi Circle 2 Camera and Ecosystem Review",
      "summary": "The Logi Circle 2 security camera has a ton of features and a great accessory ecosystem that could make it the most versatile camera on the market!",
      "content_text": "There I am reviewing another security camera, but this one is peculiar. Most of the time a security camera is a standalone, all-inclusive thing that you set and forget. It has a single precise function and does it on day one until its last day. But what if you could get something modular? Something that can be moved around the house. This is where the Logi Circle 2 camera comes in the picture!DesignThis camera is as small as a hockey puck albeit with a conical shape, ...",
      "content_html": "<p>There I am reviewing another security camera, but this one is peculiar. Most of the time a security camera is a standalone, all-inclusive thing that you set and forget. It has a single precise function and does it on day one until its last day. But what if you could get something modular? Something that can be moved around the house. This is where the <a href=\\"https://hipsterpixel.co/r/az/B0711V3LSQ/logi+circle+2+wired\\">Logi Circle 2 camera</a> comes in the picture!</p>",
      "url": "https://hipsterpixel.co/2019/04/29/logi-circle-2-camera-and-ecosystem-review/",
      "image": "https://ad3d98360fa0de008220-e893b890b8e259a099f8456bf1578245.ssl.cf5.rackcdn.com/logi-circle-2-camera-review-573-c-3nsh3.jpg",
      "tags": [
        "logi",
        "logitech",
        "circle 2",
        "security camera",
        "camera",
        "video recording",
        "thieves",
        "caught on camera",
        "ecosystem",
        "accessories",
        "review",
        "test",
        "benchmark"
      ],
      "date_published": "2019-04-29T12:12:00+00:00",
      "date_modified": "2019-04-29T12:12:00+00:00",
      "author": {
        "name": "Alexandre Vallières-Lagacé",
        "url": "http://vallier.es"
      }
    },
    {
      "id": "946429b6cf42bd1691c3d2da50a9bceaa3aaa452",
      "title": "ElevationLab BatteryPro, a Battery Pack With Integrated Apple Watch Charger [Review]",
      "summary": "Take a battery pack, add a nice design and sprinkle original features on top, you get the BatteryPro by ElevationLab, let's see the result!",
      "content_text": "When we are talking about great design and battery pack, well, we are never mixing both. Most battery packs on the market are what they are, energy in a pack. But never, or extremely rarely, is it a work of product design. That was until, ElevationLab took a crack at it! With the BatteryPro, ElevationLab are cramming a big 8,000 mAh inside a nicely designed power brick with the added touch of having an Apple Watch charger built-in.",
      "content_html": "<p>When we are talking about great design and battery pack, well, we are never mixing both. Most battery packs on the market are what they are, energy in a pack. But never, or extremely rarely, is it a work of product design. That was until, ElevationLab took a crack at it! With the <a href=\\"https://www.elevationlab.com/products/battery-pro-for-iphone-apple-watch\\">BatteryPro</a>",
      "url": "https://hipsterpixel.co/2019/04/23/elevationlab-batterypro-a-battery-pack-with-integrated-apple-watch-charger-review/",
      "image": "https://ad3d98360fa0de008220-e893b890b8e259a099f8456bf1578245.ssl.cf5.rackcdn.com/elevationlab-batterypro-battery-pack-apple-watch-iphone-review-859-6i7yf.jpg",
      "tags": [
        "elevationlab",
        "batterypro",
        "battery pack",
        "external battery",
        "review",
        "test",
        "apple watch",
        "made for iphone"
      ],
      "date_published": "2019-04-23T12:20:00+00:00",
      "date_modified": "2019-04-23T12:20:00+00:00",
      "author": {
        "name": "Alexandre Vallières-Lagacé",
        "url": "http://vallier.es"
      }
    }
  ]
}''';
    Feed feed = parseFeed(meta);
    expect(feed.title, "My Entity Feed",
        reason: "The title should equal My Entity Feed");
    expect(feed.description, "I am the description of the entity",
        reason:
            "The description should equal I am the description of the entity");
    expect(feed.items.length, 3, reason: "The feed should have 3 items");
  });
}

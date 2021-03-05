import 'dart:convert';
import 'dart:async';
import 'dart:developer';
import 'package:dvote/util/json-content.dart';
import 'package:dvote/util/json-signature.dart';
import 'package:dvote/util/random.dart';
import 'package:dvote/util/timestamp.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import "../constants.dart";

/// Enumerates the API's available to the protocol
class DVoteApiList {
  static const file = <String>[
    "fetchFile",
    "addFile",
    "pinList",
    "pinFile",
    "unpinFile"
  ];
  static const vote = <String>[
    "submitEnvelope",
    "getEnvelopeStatus",
    "getEnvelope",
    "getEnvelopeHeight",
    "getProcessKeys",
    "getProcessList",
    "getEnvelopeList",
    "getBlockHeight",
    "getBlockStatus",
    "getResults",
    "submitRawTx"
  ];
  static const census = <String>[
    "addCensus",
    "addClaim",
    "addClaimBulk",
    "getRoot",
    "genProof",
    "getSize",
    "checkProof",
    "dump",
    "dumpPlain",
    "importDump",
    "publish",
    "importRemote"
  ];
  static const results = <String>[
    "getProcListResults",
    "getProcListLiveResults",
    "getResults",
    "getScrutinizerEntities"
  ];
}

/// Client class to send HTTP requests to a DVote Gateway
class DVoteGateway {
  String _gatewayUri;
  final String publicKey;
  int _health;
  List<String> _supportedApis;

  String get uri => _gatewayUri;
  int get health => _health;
  List<String> get supportedApis => _supportedApis;

  /// Creates a new DVoteGateway instance.
  /// NOTE: URI's using the websocket protocol will be rewritten into using http/s
  DVoteGateway(String gatewayUri, {this.publicKey}) {
    this._gatewayUri = gatewayUri.startsWith("ws")
        ? gatewayUri.replaceFirst("ws", "http")
        : gatewayUri;
  }

  /// Perform a raw request to the Vocdoni Gateway and wait for a response to
  /// arrive within a given timeout
  Future<Map<String, dynamic>> sendRequest(Map<String, dynamic> body,
      {int timeout = 20, String privateKey}) async {
    final id = makeRandomId();

    final comp = Completer<Map<String, dynamic>>();

    final Map<String, dynamic> requestBody = Map.from(body);
    if (!(requestBody["timestamp"] is int)) {
      requestBody["timestamp"] = getTimestampForGateway();
    }

    Map<String, dynamic> requestPayload = {
      "id": id,
      // Important: Sorting the JSON data itself, the same way that it will be signed later on
      "request": sortJsonFields(requestBody),
      "signature": ""
    };

    // Sign if needed
    if (privateKey is String && privateKey.length > 0) {
      requestPayload["signature"] =
          await JSONSignature.signJsonPayloadAsync(requestBody, privateKey);
    }

    // Launch the request and report the result if not already completed
    http
        .post(
          _gatewayUri,
          body: jsonEncode(requestPayload),
          headers: {"Content-Type": "application/json"},
        )
        .then((response) => this._digestResponse(response, comp, id))
        .catchError((err) {
          log("[Gateway] Response error from $_gatewayUri: $err");
          if (!comp.isCompleted) comp.completeError(err);
        });

    // Trigger a timeout after N seconds
    Future.delayed(Duration(seconds: timeout)).then((_) {
      if (comp.isCompleted) return;
      comp.completeError(TimeoutException("Time out"));
    });

    return comp.future;
  }

  Future<void> _digestResponse(
      Response response, Completer comp, String requestId) async {
    // Already handled?
    if (comp.isCompleted) {
      throw Exception("Got a response for an already completed (timed out)");
    }

    Map<String, dynamic> decodedMessage;
    try {
      decodedMessage = jsonDecode(response.body);
    } catch (err) {
      throw Exception("Received a non-JSON message");
    }

    if (!(decodedMessage is Map)) {
      throw Exception("Received an invalid response");
    }

    final nowTimestampBase = getTimestampForGateway();
    final signatureValidFrom =
        nowTimestampBase - SIGNATURE_TIMESTAMP_TOLERANCE_GW;
    final signatureValidUntil =
        nowTimestampBase + SIGNATURE_TIMESTAMP_TOLERANCE_GW;

    final String givenId = decodedMessage["id"];
    final String givenSignature = decodedMessage["signature"];
    final Map<String, dynamic> jsonResponse = decodedMessage["response"];

    // Check the response field
    if (givenId != requestId)
      throw Exception("Received a different request ID");
    else if (jsonResponse is! Map)
      throw Exception("Received an invalid response");
    else if (givenId != jsonResponse["request"])
      throw Exception("The signed request ID does not match the expected one");
    else if (!(jsonResponse["timestamp"] is int) ||
        jsonResponse["timestamp"] < signatureValidFrom ||
        jsonResponse["timestamp"] > signatureValidUntil) {
      throw Exception("The response timestamp is invalid");
    }

    final valid = await JSONSignature.isValidJsonSignatureAsync(
        givenSignature, jsonResponse, publicKey);

    if (!valid)
      throw Exception("The response signature is not valid");
    else if (jsonResponse["ok"] is! bool || jsonResponse["ok"] != true) {
      throw Exception(jsonResponse["message"] is String
          ? jsonResponse["message"]
          : "The request failed");
    }

    // Already handled? (2)
    if (comp.isCompleted) {
      throw Exception("Got a response for an already completed (timed out)");
    }

    comp.complete(jsonResponse);
  }

  /// Calls `getInfo` on the current node and updates the internal state.
  Future<void> updateStatus({int timeout = 6}) {
    return DVoteGateway.getStatus(this._gatewayUri, timeout: timeout)
        .then((result) {
      if (result.isUp != true) throw Exception("The gateway is down");

      this._health = result.health ?? 0;
      this._supportedApis = result.supportedApis ?? <String>[];
    });
  }

  /// Calls `getInfo` on the current node.
  static Future<DVoteGatewayStatus> getStatus(String gatewayUri,
      {int timeout = 6}) async {
    final req = {"method": "getInfo", "timestamp": getTimestampForGateway()};
    return DVoteGateway(gatewayUri)
        .sendRequest(req, timeout: timeout)
        .then((result) {
      if (result["apiList"] is! List) throw Exception("Invalid response");

      final List apis = result["apiList"] ?? [];
      return DVoteGatewayStatus(
          true, result["health"] ?? 0, apis.cast<String>().toList());
    }).catchError((err) {
      print(err.toString());
      return DVoteGatewayStatus(false, 0, <String>[]);
    });
  }

  /// Determines whether the given URL responds to `HTTP GET /ping`
  static Future<bool> _checkPing(String gatewayUri, {int timeout = 6}) {
    final uri = Uri.parse(gatewayUri);
    final completer = Completer<bool>();
    final pingUrl = uri.hasPort
        ? "https://${uri.host}:${uri.port}/ping"
        : "https://${uri.host}/ping";

    // Request
    http.get(pingUrl).then((response) {
      completer.complete(response != null &&
          response.statusCode == 200 &&
          response.body == "pong");
    }).catchError((err) {
      completer.complete(false);
    });

    // Fail after timeout
    Timer(Duration(seconds: timeout), () {
      if (!completer.isCompleted) completer.complete(false);
    });

    return completer.future;
  }

  /// Determines whether the current DVote Gateway supports the API set that includes the given method.
  /// NOTE: `updateStatus()` must have been called on the GW instnace previously.
  bool supportsMethod(String method) {
    if (DVoteApiList.file.contains(method))
      return this.supportedApis.contains("file");
    else if (DVoteApiList.census.contains(method))
      return this.supportedApis.contains("census");
    else if (DVoteApiList.vote.contains(method))
      return this.supportedApis.contains("vote");
    else if (DVoteApiList.results.contains(method))
      return this.supportedApis.contains("results");
    return false;
  }
}

class DVoteGatewayStatus {
  int health;
  List<String> supportedApis;
  bool isUp;
  DVoteGatewayStatus(this.isUp, this.health, this.supportedApis);
}

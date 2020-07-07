import "dart:io";
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:dvote/util/timestamp.dart';
import 'package:http/http.dart' as http;
import 'package:dvote/util/dev.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import '../util/json-signature.dart';
import "../constants.dart";

import 'package:web3dart/web3dart.dart';
import '../blockchain/ens.dart';
import '../blockchain/entity-contract.dart';
// import '../blockchain/namespace-contract.dart';
import '../blockchain/process-contract.dart';

final _random = Random.secure();

/// Invoke `_onTimeout` when `TIMEOUT_COUNT_THRESHOLD` requests expire
/// within a period of `TIMEOUT_TIME_FRAME` seconds
const TIMEOUT_COUNT_THRESHOLD = 2;
const TIMEOUT_TIME_FRAME = Duration(seconds: 15);
const TIMEOUT_CHECK_INTERVAL = Duration(seconds: 2);

// TODO: Use the non-dev domain
final entityResolverDomain = "entities.dev.vocdoni.eth";
final processDomain = "process.dev.vocdoni.eth";

final entityResolverDomainDev = "entities.dev.vocdoni.eth";
final processDomainDev = "process.dev.vocdoni.eth";

String entityResolverAddress; // Lazy load
String processAddress; // Lazy load

enum Web3ContractType { EntityResolver, Process }

// ----------------------------------------------------------------------------
// Exported classes
// ----------------------------------------------------------------------------

/// Client class to send WS requests to a DVote Gateway
class DVoteGateway {
  final String _gatewayUri;
  final String _publicKey;

  /// The WebSocket "open" channel
  bool _socketConnecting = false;
  WebSocket _socket;
  StreamSubscription<dynamic> _socketSubscription;
  List<DVoteGatewayRequest> _requests = [];

  /// Callback to invoke when N attempts expire for a period of T seconds
  void Function() _onTimeout;
  List<DateTime> _timeoutTimestamps = [];
  Timer _timeoutDetectorTimer;

  // /// List of callbacks to invoke when an unrelated message is received.
  // ObserverList<Function> _listeners = new ObserverList<Function>();

  DVoteGateway(this._gatewayUri, {String publicKey, void Function() onTimeout})
      : this._publicKey = publicKey {
    this._onTimeout = onTimeout ?? () {};
  }

  bool get isConnected => _socket != null && _socketSubscription != null;
  String get uri => _gatewayUri;
  String get publicKey => _publicKey;

  /// Opens a WebSocket connection with the Gateway, starts listening for incoming
  /// messages from it and starts the periodic timeout checker.
  /// Closes any previous connection.
  Future<void> connect() {
    if (_socketConnecting) return Future.error(Exception("Already connecting"));
    _socketConnecting = true;

    // Ensure that we close any previous connection
    if (isConnected) disconnect();
    assert(_socket == null, "Socket should be previously closed");
    assert(_socketSubscription == null,
        "Socket subscription should be previously canceled");

    // Ensure that we check for timeout's
    assert(_timeoutDetectorTimer == null,
        "Timeout checker should already be null");
    _timeoutDetectorTimer =
        Timer.periodic(TIMEOUT_CHECK_INTERVAL, (_) => _checkTimeouts());

    return WebSocket.connect(this._gatewayUri).then((socket) {
      _socket = socket;
      _socketSubscription = _socket.listen(_onSocketData,
          onDone: _onSocketDone, onError: _onSocketError);

      // Send a test flight request
      return this.getInfo();
    }).then((_) {
      // DONE
      _socketConnecting = false;
    }).catchError((err) {
      _socketConnecting = false;
      throw err;
    });
  }

  /// Disconnects the WebSocket communication
  void disconnect() {
    if (!isConnected) return;

    // By isConnected == true we know that _socket and _socketSubscription are non-null
    if (_socket is WebSocket) _socket.close();
    _socket = null;
    if (_socketSubscription is StreamSubscription) _socketSubscription.cancel();
    _socketSubscription = null;

    // Tear down the time out checker
    if (_timeoutDetectorTimer is Timer && _timeoutDetectorTimer.isActive) {
      _timeoutDetectorTimer.cancel();
    }
    _timeoutDetectorTimer = null;
  }

  /// Perform a raw request to the Vocdoni Gateway and wait for a response to
  /// arrive within a given timeout
  Future<Map<String, dynamic>> sendRequest(Map<String, dynamic> body,
      {int timeout = 20, String privateKey}) async {
    if (!isConnected) await this.connect();

    final id = makeRandomId();

    final comp = Completer<Map<String, dynamic>>();
    final req = DVoteGatewayRequest(id, comp,
        originalRequest: kReleaseMode ? null : jsonEncode(body));
    _requests.add(req);

    final Map<String, dynamic> requestBody = Map.from(body);
    if (!(requestBody["timestamp"] is int)) {
      requestBody["timestamp"] = getTimestampForGateway();
    }

    Map<String, dynamic> requestPayload;

    // Sign if needed
    if (privateKey == null || privateKey == "") {
      requestPayload = {"id": id, "request": requestBody, "signature": ""};
    } else {
      final signature = await signJsonPayloadAsync(requestBody, privateKey);
      requestPayload = {
        "id": id,
        "request": requestBody,
        "signature": signature
      };
    }

    _socket.add(jsonEncode(requestPayload));

    // Trigger a timeout after N seconds
    Future.delayed(Duration(seconds: timeout)).then((_) {
      if (comp.isCompleted) return;
      comp.completeError(Exception("The request timed out"));
      _reportTimeout(req.created);
    });

    return comp.future;
  }

  /// Try to match the incoming message to a previous request
  void _onSocketData(dynamic message) async {
    // Handle potential error events
    if (!(message is Uint8List)) {
      return devPrint(
          "GW: Received a message of type ${message.runtimeType}. Skipping.");
    }

    Map<String, dynamic> decodedMessage;

    try {
      decodedMessage = jsonDecode(String.fromCharCodes(message));
    } catch (err) {
      return devPrint("ERR: Received a non-JSON message");
    }

    if (!(decodedMessage is Map)) {
      return devPrint("ERR: Received an invalid message");
    } else if (!(decodedMessage["id"] is String)) {
      return _handleUnrelatedMessage(decodedMessage);
    }

    final req = _requests.firstWhere((req) => req.id == decodedMessage["id"],
        orElse: () => null);
    if (req == null) {
      return _handleUnrelatedMessage(decodedMessage);
    }

    _requests.remove(req);

    // Already handled?
    if (req.completer.isCompleted) {
      _reportTimeout(req.created);

      return devPrint(
          "Got a response for an already completed (timed out) request: ${req.originalRequest}");
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
    if (jsonResponse == null) {
      return req.completer
          .completeError(Exception("Received an empty response"));
    } else if (!(jsonResponse is Map)) {
      return req.completer
          .completeError(Exception("Received an invalid response"));
    }

    // SUCCESS RESPONSE CASE
    if (givenId != jsonResponse["request"]) {
      return req.completer.completeError(
          Exception("The signed request ID does not match the expected one"));
    } else if (!(jsonResponse["timestamp"] is int) ||
        jsonResponse["timestamp"] < signatureValidFrom ||
        jsonResponse["timestamp"] > signatureValidUntil) {
      return req.completer
          .completeError(Exception("The response timestamp is invalid"));
    } else if (!await isValidJsonSignatureAsync(
        givenSignature, jsonResponse, publicKey)) {
      return req.completer
          .completeError(Exception("The response signature is not valid"));
    } else if (!(jsonResponse["ok"] is bool) || jsonResponse["ok"] != true) {
      return jsonResponse["message"] is String
          ? req.completer.completeError(Exception(jsonResponse["message"]))
          : req.completer.completeError(Exception("The request failed"));
    }

    // DONE
    if (req.completer.isCompleted) {
      _reportTimeout(req.created);

      return devPrint(
          "Received a response for an already completed (timed out) request");
    }
    req.completer.complete(jsonResponse);
  }

  void _onSocketDone() {
    if (this.isConnected) this.disconnect();
  }

  void _onSocketError(error) {
    devPrint("WEB SOCKET ERROR: $error");
  }

  /// Calls `getGatewayInfo` on the currently connected node.
  /// Connects to it if not already.
  Future<Map<String, dynamic>> getInfo() {
    return this.sendRequest(
        {"method": "getGatewayInfo", "timestamp": getTimestampForGateway()});
  }

  // /// Adds a callback to be invoked in case of incoming notification
  // addListener(Function callback) {
  //   _listeners.add(callback);
  // }

  // removeListener(Function callback) {
  //   _listeners.remove(callback);
  // }

  _handleUnrelatedMessage(Map decodedMessage) {
    devPrint("WEB SOCKET: Unrelated message " + decodedMessage.toString());
    // _listeners.forEach((Function callback) {
    //   callback(message);
    // });
  }

  _reportTimeout(DateTime createdTime) {
    _timeoutTimestamps.add(createdTime);
  }

  _checkTimeouts() {
    // Already above the limit?
    if (_timeoutTimestamps.length >= TIMEOUT_COUNT_THRESHOLD) {
      _timeoutTimestamps.removeWhere((_) => true);
      _onTimeout();
    }

    // Keep only recent timeouts
    final now = DateTime.now();
    _timeoutTimestamps = _timeoutTimestamps
        .where((item) {
          final diff = item.difference(now).abs();
          return diff.inMilliseconds < TIMEOUT_TIME_FRAME.inMilliseconds;
        })
        .cast<DateTime>()
        .toList();
  }

  /// Checks the health of the given GW by calling https://<host>/ping or http://<host>/ping.
  /// Returns false if the response is invalid or after 5 seconds of inactivity.
  static Future<bool> isUp(String gatewayUri) {
    final uri = Uri.parse(gatewayUri);
    if (!(uri is Uri) || !(uri.host is String) || uri.host.length == 0)
      return Future.value(false);

    final completer = Completer<bool>();

    // Check ping and then status
    DVoteGateway._checkPing(uri).then((isUp) {
      if (completer.isCompleted)
        return null;
      else if (isUp != true) {
        completer.complete(false);
        return null;
      }

      return DVoteGateway(gatewayUri).sendRequest({"method": "getGatewayInfo"},
          timeout: 4).then((response) {
        if (completer.isCompleted) return;
        completer.complete(response is Map && response["ok"] == true);
      });
    }).catchError((_) {
      if (!completer.isCompleted) completer.complete(false);
    });

    // Fail after timeout
    Timer(Duration(seconds: 4), () {
      if (!completer.isCompleted) completer.complete(false);
    });

    return completer.future;
  }

  static Future<bool> _checkPing(Uri uri) async {
    String pingUrl = uri.hasPort
        ? "https://${uri.host}:${uri.port}/ping"
        : "https://${uri.host}/ping";

    try {
      Response response = await http.get(pingUrl);
      if (response != null &&
          response.statusCode == 200 &&
          response.body == "pong") {
        return true;
      }

      // HTTP fallback
      pingUrl = uri.hasPort
          ? "http://${uri.host}:${uri.port}/ping"
          : "http://${uri.host}/ping";

      response = await http.get(pingUrl);
      return (response != null &&
          response.statusCode == 200 &&
          response.body == "pong");
    } catch (err) {
      return false;
    }
  }
}

/// Client class to wrap calls to Ethereum Smart Contracts using a (Vocdoni) Gateway
class Web3Gateway {
  final String _gatewayUri;
  ContractAbi _contractAbi;
  DeployedContract _contract;
  String _contractAddress;
  Web3Client _client;

  String get rpcUri => _gatewayUri.replaceFirst(RegExp("^ws"), "http");
  String get wsUri => _gatewayUri.replaceFirst(RegExp("^http"), "ws");

  Web3Gateway(this._gatewayUri) {
    if (_gatewayUri == null || _gatewayUri == "")
      throw Exception("Invalid Gateway URI");
  }

  Future<Web3Gateway> getEntityResolverClient() async {
    Web3Gateway client = Web3Gateway(this._gatewayUri);

    client._contractAbi =
        ContractAbi.fromJson(jsonEncode(entityResolverAbi), 'EntityResolver');

    if (entityResolverAddress == null)
      await Web3Gateway._resolveEntityResolverDomain(this._gatewayUri);

    client._contractAddress = entityResolverAddress;

    client.connect();
    return client;
  }

  Future<Web3Gateway> getProcessClient() async {
    Web3Gateway client = Web3Gateway(this._gatewayUri);

    client._contractAbi =
        ContractAbi.fromJson(jsonEncode(processAbi), 'Process');

    if (processAddress == null)
      await Web3Gateway._resolveProcessDomain(this._gatewayUri);

    client._contractAddress = processAddress;

    client.connect();
    return client;
  }

  /// Initialization the WebSockets connection with the Gateway
  connect() {
    disconnect();

    _contract = DeployedContract(
        _contractAbi, EthereumAddress.fromHex(this._contractAddress));

    _client = Web3Client(rpcUri, Client());
  }

  /// Disconnects the WebSocket communication
  disconnect() {
    if (_client == null) return;

    _client.dispose();
    _client = null;
    _contract = null;
    _contractAddress = null;
  }

  /// Perform a call request to Ethereum
  Future<List<dynamic>> callMethod(String method, List<dynamic> params) async {
    if (_client == null || _contract == null)
      throw Exception("You are not attached to a contract");

    final methodFunc = this._contract.function(method);
    if (methodFunc == null)
      throw Exception(
          "Method not found. Did you attach to the appropriate contract?");

    try {
      return _client.call(
          contract: this._contract, function: methodFunc, params: params ?? []);
    } on FormatException catch (err) {
      devPrint("WEB3 CALL METHOD ERROR: $err");
      throw Exception("Invalid response from the Web3 Gateway: $rpcUri");
    } catch (err) {
      throw err;
    }
  }

  /// Send a transaction to a contract
  Future<String> sendTransaction(
      String method, List<dynamic> params, Credentials credentials) {
    if (_client == null || _contract == null)
      throw Exception("You are not attached to a contract");
    else if (credentials == null)
      throw Exception("Credentials are required to send a transaction");

    final methodFunc = this._contract.function(method);
    if (methodFunc == null)
      throw Exception(
          "Method not found. Did you attach to the appropriate contract?");

    return _client.sendTransaction(
        credentials,
        Transaction.callContract(
            contract: this._contract,
            function: methodFunc,
            parameters: params ?? []));
  }

  // HELPERS

  static Future<void> _resolveEntityResolverDomain(String gatewayUri) async {
    if (kReleaseMode) {
      entityResolverAddress =
          await resolveName(entityResolverDomain, gatewayUri);
    } else {
      entityResolverAddress =
          await resolveName(entityResolverDomainDev, gatewayUri);
    }

    if (!(entityResolverAddress is String))
      throw Exception("The domain name does not exist");
  }

  static Future<void> _resolveProcessDomain(String gatewayUri) async {
    if (kReleaseMode) {
      processAddress = await resolveName(processDomain, gatewayUri);
    } else {
      processAddress = await resolveName(processDomainDev, gatewayUri);
    }
    if (!(processAddress is String))
      throw Exception("The domain name does not exist");
  }
}

// ----------------------------------------------------------------------------
// Internal classes
// ----------------------------------------------------------------------------

class DVoteGatewayRequest {
  DateTime created;
  String id;
  Completer completer;
  String originalRequest; // debug only

  DVoteGatewayRequest(this.id, this.completer, {this.originalRequest}) {
    created = DateTime.now();
  }
}

String makeRandomId() {
  final values = List<int>.generate(16, (i) => _random.nextInt(256));
  return base64.encode(values);
}

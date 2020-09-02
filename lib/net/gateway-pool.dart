import 'package:dvote/net/gateway-discovery.dart';
import 'package:dvote/net/gateway-dvote.dart';
import 'package:dvote/net/gateway.dart';
import 'package:dvote/util/dev.dart';
import 'package:web3dart/credentials.dart';

import 'gateway-web3.dart';

class GatewayPool {
  List<Gateway> _pool = List<Gateway>();
  final String bootnodeUri;
  final String networkId;
  final int maxGatewayCount;
  final int timeout;
  int errorCount = 0;

  GatewayPool(this._pool, this.networkId,
      {this.bootnodeUri, this.maxGatewayCount = 5, this.timeout = 6});

  Gateway get current {
    return (_pool is List && _pool.length >= 1) ? _pool[0] : null;
  }

  /// Populates a GatewayPool instance using the healthiest gateways available
  static Future<GatewayPool> discover(String networkId,
      {String bootnodeUri, int maxGatewayCount = 5, int timeout = 6}) {
    // Get a list of gateways from discover
    return discoverGateways(
            bootnodeUri: bootnodeUri, // may be null
            networkId: networkId,
            maxGatewayCount: maxGatewayCount)
        .then((gws) {
      if (gws.length == 0)
        throw Exception("The network has no gateways available");

      // Create a GatewayPool object
      return GatewayPool(gws, networkId,
          bootnodeUri: bootnodeUri,
          maxGatewayCount: maxGatewayCount,
          timeout: timeout);
    });
  }

  /// Generated a new gateway list
  Future<bool> refresh() async {
    this.current?.dispose();

    // Get a list of gateways from discover
    return discoverGateways(
            bootnodeUri: bootnodeUri, // may be null
            networkId: networkId,
            maxGatewayCount: maxGatewayCount)
        .then((gws) {
      this._pool = gws;
      this.errorCount = 0;
      return true;
    }).catchError((err) {
      devPrint("[GW Pool] refresh error: $err");
      return false;
    });
  }

  /// Disconnects the currently active gateway and connects using the next one
  Future<void> shift() {
    assert(this.current is Gateway);

    if (current.web3 is Web3Gateway) {
      devPrint("[GW Pool] Disconnecting from ${current.web3.uri}");
      this.current?.dispose();
    }

    if (this.errorCount >= this._pool.length) {
      return this.refresh();
    }

    final newPool = this._pool.sublist(1);
    newPool.add(this.current);

    this._pool = newPool;
    return Future.value();
  }

  // DVOTE METHODS

  String get publicKey {
    return this.current.dvote.publicKey;
  }

  List<String> get supportedApis {
    return this.current.dvote.supportedApis;
  }

  /// The current status of the DVote node
  Future<DVoteGatewayStatus> get info {
    return this.current.getInfo();
  }

  /// Perform a raw request to the Vocdoni Gateway and wait for a response to
  /// arrive within a given timeout
  Future<Map<String, dynamic>> sendRequest(Map<String, dynamic> body,
      {int timeout = 10, String privateKey}) async {
    if (this.current is! Gateway)
      throw Exception("The pool has no gateways available");
    else if (!this.current.dvote.supportsMethod(body["method"])) {
      errorCount++;
      await this.shift();

      // Recall ourselves
      return this.sendRequest(body, timeout: timeout, privateKey: privateKey);
    }

    return this
        .current
        .sendRequest(body, timeout: timeout, privateKey: privateKey)
        .then((result) {
      errorCount = 0;
      return result;
    }).catchError((err) {
      errorCount++;
      if (this.errorCount >= this._pool.length) {
        // We have tried on all gateways, throw an exception before retrying indefinitely
        throw err;
      }

      // Shift and retry
      return this.shift().then((_) {
        return this.sendRequest(body, timeout: timeout, privateKey: privateKey);
      });
    });
  }

  // WEB3 METHODS

  /// Perform a call request to Ethereum
  Future<List<dynamic>> callMethod(
      String method, List<dynamic> params, ContractEnum contractEnum,
      {int timeout = 5}) {
    return this
        .current
        .web3
        .callMethod(method, params, contractEnum, timeout: timeout);
  }

  /// Send a transaction to a contract
  Future<String> sendTransaction(String method, List<dynamic> params,
      ContractEnum contractEnum, Credentials credentials) {
    return this
        .current
        .web3
        .sendTransaction(method, params, contractEnum, credentials);
  }
}

import 'dart:async';
import 'package:http/http.dart';
import "../constants.dart";

import 'package:web3dart/web3dart.dart';
import '../blockchain/ens.dart';
import '../blockchain/index.dart';

enum ContractEnum { EntityResolver, Process }

/// Client class to wrap calls to Ethereum Smart Contracts using a Web3 endpoint
class Web3Gateway {
  final String _gatewayUri;
  final String alternateEnvironment;
  Web3Client _client;

  String _entityResolverAddress; // Lazy loaded
  String _processAddress; // Lazy loaded

  DeployedContract _entityResolverInstance; // Loaded on init()
  DeployedContract _processInstance; // Loaded on init()

  String get uri => _gatewayUri;

  Web3Gateway(this._gatewayUri, {this.alternateEnvironment = ""}) {
    if (_gatewayUri == null || _gatewayUri == "")
      throw Exception("Invalid Gateway URI");

    _client = Web3Client(this._gatewayUri, Client());
  }

  /// Request the gateway status
  static Future<bool> isSyncing(String gatewayUri, {int timeout = 5}) async {
    final Completer<bool> completer = Completer<bool>();

    final w3Client = Web3Client(gatewayUri, Client());

    w3Client.getSyncStatus().then((result) {
      if (completer.isCompleted) return null;
      completer.complete(result.isSyncing);
      w3Client.dispose();
    }).catchError((err) {
      if (completer.isCompleted) return;
      completer.completeError(err);
      w3Client.dispose();
    });

    // Trigger a timeout after N seconds
    Future.delayed(Duration(seconds: timeout)).then((_) {
      if (completer.isCompleted) return;
      completer.completeError(TimeoutException("The call request timed out"));
      w3Client.dispose();
    });

    return completer.future;
  }

  bool get isReady {
    return _client != null &&
        _entityResolverInstance != null &&
        _processInstance != null;
  }

  /// Initialize the contract addresses
  Future<void> init() async {
    // Check contract address availability
    if (_entityResolverAddress is! String ||
        _entityResolverAddress.length == 0) {
      _entityResolverAddress = await Web3Gateway.resolveEntityResolverDomain(
          this._gatewayUri,
          alternateEnvironment: alternateEnvironment ?? "");
    }
    if (_processAddress is! String || _processAddress.length == 0) {
      _processAddress = await Web3Gateway.resolveProcessDomain(this._gatewayUri,
          alternateEnvironment: alternateEnvironment ?? "");
    }

    // Define contract instances
    _entityResolverInstance = DeployedContract(
        EnsPublicResolverContract.contractAbi,
        EthereumAddress.fromHex(_entityResolverAddress));

    _processInstance = DeployedContract(
        ProcessContract.contractAbi, EthereumAddress.fromHex(_processAddress));
  }

  void dispose() {
    this._client?.dispose();
  }

  /// Perform a call request to Ethereum
  Future<List<dynamic>> callMethod(
      String method, List<dynamic> params, ContractEnum contractEnum,
      {int timeout = 5}) async {
    if (!isReady) await this.init();

    DeployedContract contractInstance;
    switch (contractEnum) {
      case ContractEnum.EntityResolver:
        contractInstance = _entityResolverInstance;
        break;
      case ContractEnum.Process:
        contractInstance = _processInstance;
        break;
      default:
        throw Exception("Invalid contract enum value");
    }

    final methodFunc = contractInstance.function(method);
    if (methodFunc == null) throw Exception("Method not found");

    final Completer<List<dynamic>> completer = Completer<List<dynamic>>();
    // Launch the request
    _client
        .call(
            contract: contractInstance,
            function: methodFunc,
            params: params ?? [])
        .then((result) {
      if (!completer.isCompleted) completer.complete(result);
    }).catchError((err) {
      if (!completer.isCompleted) completer.completeError(err);
    });

    // Trigger a timeout after N seconds
    Future.delayed(Duration(seconds: timeout)).then((_) {
      if (completer.isCompleted) return;
      completer.completeError(TimeoutException("The call request timed out"));
    });

    return completer.future;
  }

  /// Send a transaction to a contract
  Future<String> sendTransaction(String method, List<dynamic> params,
      ContractEnum contractEnum, Credentials credentials) async {
    if (!isReady) await this.init();

    DeployedContract contractInstance;
    switch (contractEnum) {
      case ContractEnum.EntityResolver:
        contractInstance = _entityResolverInstance;
        break;
      case ContractEnum.Process:
        contractInstance = _processInstance;
        break;
      default:
        throw Exception("Invalid contract enum value");
    }

    final methodFunc = contractInstance.function(method);
    if (methodFunc == null) throw Exception("Method not found");

    return _client.sendTransaction(
        credentials,
        Transaction.callContract(
            contract: contractInstance,
            function: methodFunc,
            parameters: params ?? []));
  }

  // HELPERS

  static Future<String> resolveEntityResolverDomain(String gatewayUri,
      {String alternateEnvironment = ""}) {
    String domain = ENS_PUBLIC_RESOLVER_DOMAIN;
    if (alternateEnvironment.length > 0) {
      domain = domain.replaceFirst(".", "." + alternateEnvironment + ".");
    }
    return resolveName(domain, gatewayUri).then((address) {
      if (address is! String)
        throw Exception(
            "The domain $domain does not resolve using $gatewayUri");

      return address;
    });
  }

  static Future<String> resolveProcessDomain(String gatewayUri,
      {String alternateEnvironment = ""}) {
    String domain = PROCESS_DOMAIN;
    if (alternateEnvironment.length > 0) {
      domain = domain.replaceFirst(".", "." + alternateEnvironment + ".");
    }
    return resolveName(domain, gatewayUri).then((address) {
      if (address is! String)
        throw Exception(
            "The domain $domain does not resolve using $gatewayUri");

      return address;
    });
  }
}

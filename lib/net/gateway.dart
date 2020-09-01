import 'package:dvote/net/gateway-web3.dart';
import 'package:dvote/net/gateway-dvote.dart';
import 'package:dvote/wrappers/gateway-info.dart';
import 'package:web3dart/credentials.dart';

/// This is class, addressed to the end user, is a wrapper of DvoteGateway and Web3Gateway
class Gateway {
  DVoteGateway _dvote;
  Web3Gateway _web3;

  DVoteGateway get dvote => _dvote;
  Web3Gateway get web3 => _web3;

  // Constructors

  Gateway(this._dvote, this._web3) {
    if (this._dvote is! DVoteGateway)
      throw Exception("Invalid DVote gateway");
    else if (this._web3 is! Web3Gateway)
      throw Exception("Invalid Web3 gateway");
  }

  Gateway.fromInfo(GatewayInfo info) {
    this._dvote = DVoteGateway(info.dvoteUri, publicKey: info.publicKey);
    this._web3 = Web3Gateway(info.web3Uri);
  }

  // DVOTE METHODS

  String get publicKey {
    return this._dvote.publicKey;
  }

  List<String> get supportedApis {
    return this._dvote.supportedApis;
  }

  Future<Map<String, dynamic>> sendRequest(Map<String, dynamic> body,
      {int timeout = 20, String privateKey}) {
    return this
        ._dvote
        .sendRequest(body, timeout: timeout, privateKey: privateKey);
  }

  Future<DVoteGatewayStatus> getInfo() {
    return this._dvote.updateStatus().then((_) {
      return DVoteGatewayStatus(
          true, this._dvote.health, this._dvote.supportedApis);
    });
  }

  // WEB3 METHODS

  /// Perform a call request to Ethereum
  Future<List<dynamic>> callMethod(
      String method, List<dynamic> params, ContractEnum contractEnum,
      {int timeout = 5}) {
    return this.web3.callMethod(method, params, contractEnum, timeout: timeout);
  }

  /// Send a transaction to a contract
  Future<String> sendTransaction(String method, List<dynamic> params,
      ContractEnum contractEnum, Credentials credentials) {
    return this.web3.sendTransaction(method, params, contractEnum, credentials);
  }

  void dispose() {
    this.web3?.dispose();
  }
}

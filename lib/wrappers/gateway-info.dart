/// Wrapper for information about a web3 or vocdoni node gateway
class GatewayInfo {
  String dvoteUri;
  List<String> supportedApis;
  String web3Uri;
  String networkId; // Needed?
  String publicKey; // Secp256k1 public key

  GatewayInfo(this.dvoteUri, this.supportedApis, this.web3Uri, this.networkId,
      this.publicKey);
}

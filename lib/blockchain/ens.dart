import 'dart:typed_data';
import 'package:web3dart/json_rpc.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'package:web3dart/crypto.dart';

// Adapted from https://github.com/ethers-io/ethers.js/blob/b0bd9ee162f27fb2bc51ab6a0c0694c3b48dc95f/src.ts/providers/base-provider.ts

// CONSTANTS

class NetworkInfo {
  final String name;
  final int chainId;
  final String ensAddress;
  NetworkInfo(this.name, this.chainId, this.ensAddress);
}

final RegExp domainRegExp = new RegExp(r"^[a-zA-Z0-9-\.]+$");
final RegExp addressRegExp = new RegExp(r"^0x[0-9A-Fa-f]{40}$");

// FUNCTIONS

Future<String> resolveName(String domain, String gatewayUri,
    {bool useTestingContracts = false}) async {
  if (!domainRegExp.hasMatch(domain)) return null;

  final nodeHash = hashDomainName(domain);

  // Get the resolver from the registry
  final resolverAddress = await getResolver(domain, gatewayUri,
      useTestingContracts: useTestingContracts);
  if (resolverAddress == null) return null;

  // keccak256('addr(bytes32)')
  final hexDataStr = '0x3b3b57de' + nodeHash.substring(2);
  final data = hexToBytes(hexDataStr);

  final value = await _callContract(gatewayUri, resolverAddress, data);

  if (value.length != 66) return null;
  final result = _extractAddress(value);

  if (result == "0x0000000000000000000000000000000000000000") return null;
  return result;
}

/// Returns the entity resolver contract that corresponds to the given settings
Future<String> getResolver(String domain, String gatewayUri,
    {bool useTestingContracts = true}) async {
  if (!domainRegExp.hasMatch(domain)) return null;

  final nodeHash = hashDomainName(domain);

  // Detect the network
  final client = JsonRPC(gatewayUri, Client());
  final response = await client.call("net_version");

  NetworkInfo networkInfo;
  switch (response.result) {
    case "1":
      networkInfo = NetworkInfo(
          "homestead", 1, "0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e");
      break;
    case "2":
      networkInfo = NetworkInfo(
          "modern", 2, "0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e");
      break;
    case "3":
      networkInfo = NetworkInfo(
          "ropsten", 3, "0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e");
      break;
    case "4":
      networkInfo = NetworkInfo(
          "rinkeby", 4, "0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e");
      break;
    case "5":
      networkInfo = NetworkInfo(
          "goerli", 5, "0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e");
      break;
    case "100":
      networkInfo = useTestingContracts
          ? NetworkInfo(
              "xdai", 100, "0x9e638E90c8CdFaC1297EF261859E25c9d8438F1a")
          : NetworkInfo(
              "xdai", 100, "0x00cEBf9E1E81D3CC17fbA0a49306EBA77a8F26cD");
      break;
    case "77":
      networkInfo = NetworkInfo(
          "sokol", 77, "0x43541c49308bF2956d3893836F5AF866fd78A295");
      break;
    default:
      throw Exception("Unsupported network: ${response.result}");
  }

  if (networkInfo == null) return null;
  final ensAddress = networkInfo.ensAddress;

  // keccak256('resolver(bytes32)')
  final hexDataStr = '0x0178b8bf' + nodeHash.substring(2);
  final data = hexToBytes(hexDataStr);

  final value = await _callContract(gatewayUri, ensAddress, data);

  if (value.length != 66) return null;
  final resolverAddress = _extractAddress(value);

  if (resolverAddress == "0x0000000000000000000000000000000000000000")
    return null;
  return resolverAddress;
}

String hashDomainName(String domain) {
  domain = domain.toLowerCase();

  List<int> result = List<int>(32);
  for (int i = 0; i < 32; i++) result[i] = 0;

  final terms = domain.split(".");

  for (String strTerm in terms.reversed) {
    var catenatedBytes = result + keccakUtf8(strTerm);
    var catenatedBytesHashed = keccak256(Uint8List.fromList(catenatedBytes));
    result = catenatedBytesHashed.toList();
  }
  return "0x" + bytesToHex(result);
}

String _extractAddress(String hexHash) {
  hexHash = hexHash.replaceFirst(new RegExp(r'^0x'), '');

  if (hexHash.length != 64) return null;

  var addressDigits = hexHash.substring(24).toLowerCase();
  final chars = addressDigits.split('');
  final hashed = keccakUtf8(addressDigits);

  for (int i = 0; i < 40; i += 2) {
    if ((hashed[i >> 1] >> 4) >= 8) {
      chars[i] = addressDigits[i].toUpperCase();
    }
    if ((hashed[i >> 1] & 0x0f) >= 8) {
      chars[i + 1] = addressDigits[i + 1].toUpperCase();
    }
  }

  return "0x" + chars.join();
}

Future<String> _callContract(String gatewayUri, String to, Uint8List data) {
  if (!(gatewayUri is String))
    throw Exception("Invalid Gateway URI");
  else if (!(to is String))
    throw Exception("Invalid contract address");
  else if (!(data is Uint8List)) throw Exception("Invalid data");

  final client = Web3Client(gatewayUri, Client());
  return client.callRaw(contract: EthereumAddress.fromHex(to), data: data);
}

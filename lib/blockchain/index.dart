import 'dart:convert';
import './ens-public-resolver-contract.dart';
import './vote-contract.dart';
import '../net/gateway.dart';
import '../blockchain/ens.dart';

final ensPublicResolverDomain = "entity-resolver.vocdoni.eth";
final votingProcessDomain = "voting-process.vocdoni.eth";

String ensPublicResolverAddress;
String votingProcessAddress;

/// Call a method on the given contract instance using the given Gateway URI
/// and using the given parameters
Future<List<dynamic>> callEntityResolverMethod(
    String gatewayUri, String method, List<dynamic> params) async {
  final gw = Web3Gateway(gatewayUri);
  if (ensPublicResolverAddress == null) {
    ensPublicResolverAddress =
        await resolveName(ensPublicResolverDomain, gatewayUri);

    if (!(ensPublicResolverAddress is String))
      throw Exception("The domain name does not exist");
  }

  return gw.callMethod(jsonEncode(ensPublicResolverResolverAbi),
      ensPublicResolverAddress, method, params);
}

/// Call a method on the given contract instance using the given Gateway URI
/// and using the given parameters
Future<List<dynamic>> callVotingProcessMethod(
    String gatewayUri, String method, List<dynamic> params) async {
  final gw = Web3Gateway(gatewayUri);
  if (votingProcessAddress == null) {
    votingProcessAddress = await resolveName(votingProcessDomain, gatewayUri);

    if (!(votingProcessAddress is String))
      throw Exception("The domain name does not exist");
  }

  return gw.callMethod(
      jsonEncode(votingProcessAbi), votingProcessAddress, method, params);
}

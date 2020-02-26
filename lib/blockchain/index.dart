import 'dart:convert';
import './entity-contract.dart';
import './vote-contract.dart';
import '../net/gateway.dart';
import '../blockchain/ens.dart';

final entityResolverDomain = "entity-resolver.vocdoni.eth";
final votingProcessDomain = "voting-process.vocdoni.eth";

String resolvedEntityResolverAddress;
String resolvedVotingProcessAddress;

/// Call a method on the given contract instance using the given Gateway URI
/// and using the given parameters
Future<List<dynamic>> callEntityResolverMethod(
    String gatewayUri, String method, List<dynamic> params) async {
  Web3Gateway gw = Web3Gateway(gatewayUri);
  if (resolvedEntityResolverAddress == null) {
    resolvedEntityResolverAddress =
        await resolveName(entityResolverDomain, gatewayUri);
  }

  return gw.callMethod(jsonEncode(entityResolverAbi),
      resolvedEntityResolverAddress, method, params);
}

/// Call a method on the given contract instance using the given Gateway URI
/// and using the given parameters
Future<List<dynamic>> callVotingProcessMethod(
    String gatewayUri, String method, List<dynamic> params) async {
  Web3Gateway gw = Web3Gateway(gatewayUri);
  if (resolvedVotingProcessAddress == null) {
    resolvedVotingProcessAddress =
        await resolveName(votingProcessDomain, gatewayUri);
  }

  return gw.callMethod(jsonEncode(votingProcessAbi),
      resolvedVotingProcessAddress, method, params);
}

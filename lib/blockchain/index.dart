import 'dart:convert';
import './entity-contract.dart';
import './vote-contract.dart';
import '../net/gateway.dart';
import '../blockchain/ens.dart';

final entityResolverDomain = "entity-resolver.vocdoni.eth";
final votingProcessDomain = "voting-process.vocdoni.eth";

String entityResolverAddress;
String votingProcessAddress;

/// Call a method on the given contract instance using the given Gateway URI
/// and using the given parameters
Future<List<dynamic>> callEntityResolverMethod(
    String gatewayUri, String method, List<dynamic> params) async {
  final gw = Web3Gateway(gatewayUri);
  if (entityResolverAddress == null) {
    entityResolverAddress = await resolveName(entityResolverDomain, gatewayUri);

    if (!(entityResolverAddress is String))
      throw Exception("The domain name does not exist");
  }

  return gw.callMethod(
      jsonEncode(entityResolverAbi), entityResolverAddress, method, params);
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

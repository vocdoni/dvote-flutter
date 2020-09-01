import 'dart:convert';
import 'package:dvote/blockchain/contract-ens-public-resolver.dart';
import 'package:dvote/blockchain/contract-process.dart';
import 'package:web3dart/contracts.dart';

class EnsPublicResolverContract {
  static final List<Map<String, Object>> jsonAbi =
      EnsPublicResolverContractArtifacts['abi'];
  static final contractAbi = ContractAbi.fromJson(
      jsonEncode(EnsPublicResolverContractArtifacts['abi']), 'EntityResolver');
  static final String bytecode = EnsPublicResolverContractArtifacts['bytecode'];
}

class ProcessContract {
  static final List<Map<String, Object>> jsonAbi =
      ProcessContractArtifacts['abi'];
  static final contractAbi = ContractAbi.fromJson(
      jsonEncode(ProcessContractArtifacts['abi']), 'Process');
  static final String bytecode = ProcessContractArtifacts['bytecode'];
}

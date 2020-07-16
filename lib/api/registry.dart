import 'package:dvote/dvote.dart';

import '../net/gateway.dart';
import '../models/dart/entity.pb.dart';

// HANDLERS
Future<Map<String, dynamic>> validateRegistrationToken(
    EntityReference entityRef,
    String token,
    Map<String, dynamic> userInfo,
    DVoteGateway dvoteGw,
    String privateKey) async {
  if (!(userInfo is Map) || !(dvoteGw is DVoteGateway) || (dvoteGw == null)) {
    throw Exception("Invalid parameters");
  } else if (!(token is String) ||
      !(userInfo["firstName"] is String) ||
      !(userInfo["lastName"] is String) ||
      !(userInfo["email"] is String) ||
      !(userInfo["phone"] is String) ||
      !(userInfo["dateOfBirth"] is String) ||
      !(privateKey is String && privateKey != "")) {
    throw Exception("Invalid parameters");
  }

  try {
    Map<String, dynamic> reqParams = {
      "method": "register",
      "token": token,
      "entityId": entityRef.entityId,
      "member": userInfo
    };
    Map<String, dynamic> response = await dvoteGw.sendRequest(reqParams,
        timeout: 7, privateKey: privateKey);
    if (!(response is Map)) {
      throw Exception("Invalid response received from the gateway");
    }
    return response;
  } catch (err) {
    throw Exception(
        "The registration token could not be validated: " + err.toString());
  }
}

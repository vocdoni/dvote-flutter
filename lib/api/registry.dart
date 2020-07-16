import 'package:dvote/dvote.dart';

import '../net/gateway.dart';
import '../models/dart/entity.pb.dart';

// HANDLERS
Future<Map<String, dynamic>> validateRegistrationToken(
    EntityReference entityRef,
    String token,
    Map<String, dynamic> userData,
    DVoteGateway dvoteGw,
    String privateKey) async {
  if (!(userData is Map) || !(dvoteGw is DVoteGateway) || (dvoteGw == null)) {
    throw Exception("Invalid parameters");
  } else if (!(token is String) ||
      !(userData["firstName"] is String) ||
      !(userData["lastName"] is String) ||
      !(userData["email"] is String) ||
      !(userData["phone"] is String) ||
      !(userData["dateOfBirth"] is String) ||
      !(privateKey is String && privateKey != "")) {
    throw Exception("Invalid parameters");
  }

  try {
    Map<String, dynamic> memberInfo = {
      "firstName": userData["firstName"],
      "lastName": userData["lastName"],
      "email": userData["email"],
      "phone": userData["phone"],
      "dateOfBirth": userData["dateOfBirth"],
    };
    Map<String, dynamic> reqParams = {
      "method": "register",
      "token": token,
      "entityId": entityRef.entityId,
      "member": memberInfo
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

import 'package:dvote/dvote.dart';
import '../net/gateway.dart';

// HANDLERS
Future<Map<String, dynamic>> register(
    String entityId,
    String firstName,
    String lastName,
    String email,
    String phone,
    DateTime dateOfBirth,
    DVoteGateway dvoteGw,
    String privateKey) async {
  try {
    Map<String, dynamic> reqParams = {
      "method": "register",
      "memberInfo": {
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "phone": phone,
        "dateOfBirth": dateOfBirth.toUtc().toIso8601String(),
      },
      "entityId": entityId
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

Future<Map<String, dynamic>> validateRegistrationToken(String entityId,
    String validationToken, DVoteGateway dvoteGw, String privateKey) async {
  if (!(entityId is String) ||
      !(validationToken is String) ||
      !(dvoteGw is DVoteGateway) ||
      !(privateKey is String)) {
    throw Exception("Invalid parameters");
  }

  try {
    Map<String, dynamic> reqParams = {
      "method": "validateToken",
      "token": validationToken,
      "entityId": entityId
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

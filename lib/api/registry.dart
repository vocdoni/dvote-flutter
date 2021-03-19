import 'package:dvote/dvote.dart';

// HANDLERS

/// Connects to the backend using the given HTTP DVoteGateway connection
/// and registers the given user with the given signing key.
Future<Map<String, dynamic>> register(
    String entityId,
    String firstName,
    String lastName,
    String email,
    String phone,
    DateTime dateOfBirth,
    DVoteGateway registryGw,
    String privateKey) async {
  try {
    final Map<String, dynamic> reqParams = {
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
    final response = await registryGw.sendRequest(reqParams,
        timeout: 16, privateKey: privateKey);
    if (!(response is Map)) {
      throw Exception("Invalid response");
    }
    return response;
  } catch (err) {
    throw Exception(
        "The registration could not be completed: " + err.toString());
  }
}

/// Connects to the backend using the given HTTP DVoteGateway connection
/// and uses the given token to verify the user.
Future<Map<String, dynamic>> validateRegistrationToken(String entityId,
    String validationToken, DVoteGateway registryGw, String privateKey) async {
  if (entityId is! String ||
      validationToken is! String ||
      registryGw is! DVoteGateway ||
      privateKey is! String) {
    throw Exception("Invalid parameters");
  }

  try {
    final Map<String, dynamic> reqParams = {
      "method": "validateToken",
      "token": validationToken,
      "entityId": entityId
    };
    final response = await registryGw.sendRequest(reqParams,
        timeout: 12, privateKey: privateKey);
    if (response is! Map) throw Exception("Invalid response");
    return response;
  } catch (err) {
    throw Exception(
        "The registration token could not be validated: " + err.toString());
  }
}

/// Connects to the backend using the given HTTP DVoteGateway connection
/// and checks whether the given public key is already registered on the entity.
/// Returns `{ "registered": bool, "needsUpdate": bool }`.
Future<Map<String, dynamic>> registrationStatus(
    String entityId, DVoteGateway registryGw, String privateKey) async {
  if (entityId is! String ||
      registryGw is! DVoteGateway ||
      privateKey is! String) {
    throw Exception("Invalid parameters");
  }

  try {
    final Map<String, dynamic> reqParams = {
      "method": "registrationStatus",
      "entityId": entityId
    };
    final response = await registryGw.sendRequest(reqParams,
        timeout: 10, privateKey: privateKey);
    if (!(response is Map) || !(response["status"] is Map)) {
      throw Exception("Invalid response");
    }
    return response["status"];
  } catch (err) {
    throw Exception("The status could not be checked: " + err.toString());
  }
}

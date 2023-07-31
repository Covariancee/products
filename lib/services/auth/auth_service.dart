import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:products/model/auth/auth_error_model.dart';
import 'package:products/model/auth/auth_model.dart';
import 'package:products/services/auth/api_value_service.dart';

class AuthServiceResponse {
  int id = 0;
  String userName = '';
  String email = '';
  String firstName = '';
  String lastName = '';
  String gender = '';
  String image = '';
  String token = '';
  int statusCode = 0;
  String error = '';
}

class AuthServiceError {
  String message = '';
}

class AuthService {
  static Future<AuthServiceResponse> login() async {
    AuthServiceResponse authServiceResponse = AuthServiceResponse();
    Uri url = Uri.http(
      ApiServiceValues.authBaseUrl,
      ApiServiceValues.authBaseUrlPath,
    );

    await http
        .post(
      url,
      headers: {
        'Connection': 'keep-alive',
        'connect-Type': 'application-json',
      },
      body: jsonEncode({
        'username': ApiServiceValues.userName,
        'password': ApiServiceValues.password,
      }),
    )
        .then((response) async {
      authServiceResponse.statusCode = response.statusCode;

      if (response.statusCode == 200) {
        final authModel = AuthModel.fromRawJson(response.body);
        authServiceResponse.token = authModel.token;
        return AuthServiceResponse;
      }

      if (response.statusCode == 404) {
        authServiceResponse.error = 'Failed to authorize\n404 Not Found ';
      } else if (response.statusCode == 400) {
        authServiceResponse.error =
            AuthErrorModel.fromRawJson(response.body).message;
      } else {
        authServiceResponse.error = 'Failed to Auth\nUnknown Error';
      }
      return authServiceResponse;
    });
    return authServiceResponse;
  }
}

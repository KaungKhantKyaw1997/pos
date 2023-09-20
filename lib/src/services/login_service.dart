import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pos/api_constants.dart';

class LoginService {
  Future<Map<String, dynamic>> loginData(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse(ApiConstants.loginUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to log in: ${response.statusCode}');
    }
  }
}

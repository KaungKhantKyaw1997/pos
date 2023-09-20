import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pos/api_constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CategoriesService {
  final storage = FlutterSecureStorage();

  Future<Map<String, dynamic>> getCategoriesData() async {
    var token = await storage.read(key: 'token');
    final response = await http.get(
      Uri.parse(ApiConstants.categoriesUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to log in: ${response.statusCode}');
    }
  }
}

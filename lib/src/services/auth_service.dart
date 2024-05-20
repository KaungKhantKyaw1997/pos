import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:pos/src/constants/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:pos/routes.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pos/src/providers/bottom_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final storage = FlutterSecureStorage();

  final Dio dio = Dio();
  CancelToken _cancelToken = CancelToken();

  Future<Map<String, dynamic>?> loginData(Map<String, dynamic> body) async {
    final response = await dio.post(
      ApiConstants.loginUrl,
      options: Options(
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ),
      data: jsonEncode(body),
    );

    return response.data;
  }

  logout(context) async {
    clearData(context);
    Navigator.pushNamed(context, Routes.login);
  }

  clearData(context) async {
    BottomProvider bottomProvider =
        Provider.of<BottomProvider>(context, listen: false);
    bottomProvider.selectIndex(0);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    await storage.delete(key: "token");
  }

  void cancelRequest() {
    _cancelToken.cancel('Request canceled');
  }
}

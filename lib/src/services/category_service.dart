import 'package:dio/dio.dart';
import 'package:pos/src/constants/api_constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CategoryService {
  final storage = FlutterSecureStorage();

  final Dio dio = Dio();
  CancelToken _cancelToken = CancelToken();

  Future<Map<String, dynamic>?> getCategoriesData() async {
    var token = await storage.read(key: "token");
    try {
      final response = await dio.get(
        ApiConstants.categoriesUrl,
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
        ),
        cancelToken: _cancelToken,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to get items: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  void cancelRequest() {
    _cancelToken.cancel('Request canceled');
  }
}

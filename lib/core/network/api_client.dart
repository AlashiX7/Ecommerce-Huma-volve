import 'package:dio/dio.dart';

class ApiClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.escuelajs.co/api/v1/',
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );
}
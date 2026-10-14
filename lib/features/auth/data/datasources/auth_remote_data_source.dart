import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';

class AuthRemoteDataSource {
  final Dio dio;

  const AuthRemoteDataSource(this.dio);

  Future<dynamic> login(String email, String password) async {
    final response = await dio.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    return response.data;
  }

  Future<dynamic> signUp(String name, String email, String password) async {
    final response = await dio.post(
      ApiEndpoints.users,
      data: {
        'name': name,
        'email': email,
        'password': password,
        'avatar': 'https://i.pravatar.cc/300',
      },
    );
    return response.data;
  }
}

import 'package:ecommerce_app_huma_volve/core/network/api_client.dart';

class LoginService {
  Future<dynamic> login(String email, String password) async {
    final response = await ApiClient.dio.post(
      'auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    return response.data;
  }
}
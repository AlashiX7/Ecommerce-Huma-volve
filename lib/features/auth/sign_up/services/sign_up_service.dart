import '../../../../core/network/api_client.dart';

class SignUpService {
  Future<dynamic> signUp(String name, String email, String password) async {
    final response = await ApiClient.dio.post(
      'users/',
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

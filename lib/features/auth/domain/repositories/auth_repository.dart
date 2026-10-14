import '../entities/auth_tokens.dart';
import '../entities/registered_user.dart';

abstract interface class AuthRepository {
  Future<AuthTokens> login(String email, String password);

  Future<RegisteredUser> signUp(String name, String email, String password);
}

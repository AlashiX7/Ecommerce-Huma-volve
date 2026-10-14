import '../entities/auth_tokens.dart';
import '../repositories/auth_repository.dart';

class Login {
  final AuthRepository repository;

  const Login(this.repository);

  Future<AuthTokens> call(String email, String password) =>
      repository.login(email, password);
}

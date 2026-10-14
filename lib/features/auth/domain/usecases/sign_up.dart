import '../entities/registered_user.dart';
import '../repositories/auth_repository.dart';

class SignUp {
  final AuthRepository repository;

  const SignUp(this.repository);

  Future<RegisteredUser> call(String name, String email, String password) =>
      repository.signUp(name, email, password);
}

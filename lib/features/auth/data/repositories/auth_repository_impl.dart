import 'package:dio/dio.dart';

import '../../../../core/errors/app_failure.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/registered_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_tokens_model.dart';
import '../models/registered_user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  const AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<AuthTokens> login(String email, String password) async {
    try {
      return AuthTokensModel.fromJson(
        await remoteDataSource.login(email, password),
      ).toEntity();
    } on DioException catch (error) {
      throw _mapDioFailure(error, isLogin: true);
    } on FormatException {
      throw const AppFailure(FailureType.unexpected);
    }
  }

  @override
  Future<RegisteredUser> signUp(
    String name,
    String email,
    String password,
  ) async {
    try {
      return RegisteredUserModel.fromJson(
        await remoteDataSource.signUp(name, email, password),
      ).toEntity();
    } on DioException catch (error) {
      throw _mapDioFailure(error);
    } on FormatException {
      throw const AppFailure(FailureType.unexpected);
    }
  }

  AppFailure _mapDioFailure(DioException error, {bool isLogin = false}) {
    final status = error.response?.statusCode;
    if (isLogin && status == 401) {
      return const AppFailure(FailureType.invalidCredentials);
    }
    if (status == null) return const AppFailure(FailureType.connection);
    if (status >= 500) return const AppFailure(FailureType.server);
    return const AppFailure(FailureType.rejected);
  }
}

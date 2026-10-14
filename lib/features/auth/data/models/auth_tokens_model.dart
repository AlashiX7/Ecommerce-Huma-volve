import '../../domain/entities/auth_tokens.dart';

class AuthTokensModel {
  final String accessToken;
  final String refreshToken;

  const AuthTokensModel({
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthTokensModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic> ||
        json['access_token'] is! String ||
        json['refresh_token'] is! String) {
      throw const FormatException('Unexpected login response.');
    }
    return AuthTokensModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
    );
  }

  AuthTokens toEntity() =>
      AuthTokens(accessToken: accessToken, refreshToken: refreshToken);
}

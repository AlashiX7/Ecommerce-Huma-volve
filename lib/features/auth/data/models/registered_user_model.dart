import '../../domain/entities/registered_user.dart';

class RegisteredUserModel {
  final int id;
  final String name;
  final String email;
  final String avatar;

  const RegisteredUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
  });

  factory RegisteredUserModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic> ||
        int.tryParse('${json['id']}') == null ||
        json['name'] is! String ||
        json['email'] is! String ||
        json['avatar'] is! String) {
      throw const FormatException('Unexpected registration response.');
    }
    return RegisteredUserModel(
      id: int.parse('${json['id']}'),
      name: json['name'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String,
    );
  }

  RegisteredUser toEntity() =>
      RegisteredUser(id: id, name: name, email: email, avatar: avatar);
}

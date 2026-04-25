import '../../core/constants/app_constants.dart';

class AppUser {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final UserRole role;
  final String? avatarEmoji;

  const AppUser({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.role,
    this.avatarEmoji,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        name: json['full_name'] as String,
        phone: json['phone'] as String,
        email: json['email'] as String?,
        role: UserRole.values.firstWhere(
          (r) => r.name == (json['role'] as String),
          orElse: () => UserRole.parent,
        ),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': name,
        'phone': phone,
        if (email != null) 'email': email,
        'role': role.name,
      };
}

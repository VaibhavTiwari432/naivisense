class UserResponse {
  final String id;
  final String fullName;
  final String phone;
  final String? email;
  final String role;
  final bool isActive;
  final bool isVerified;
  final DateTime? createdAt;

  const UserResponse({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    required this.role,
    required this.isActive,
    this.isVerified = false,
    this.createdAt,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) => UserResponse(
        id: json['id'] as String,
        fullName: (json['name'] ?? json['full_name']) as String,
        phone: json['phone'] as String,
        email: json['email'] as String?,
        role: json['role'] as String,
        isActive: json['is_active'] as bool? ?? true,
        isVerified: json['is_verified'] as bool? ?? false,
        createdAt: json['created_at'] == null
            ? null
            : DateTime.tryParse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': fullName,
        'phone': phone,
        'email': email,
        'role': role,
        'is_active': isActive,
        'is_verified': isVerified,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      };
}

class TokenResponse {
  final String accessToken;
  final String tokenType;
  final UserResponse user;

  const TokenResponse({
    required this.accessToken,
    required this.tokenType,
    required this.user,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) => TokenResponse(
        accessToken: json['access_token'] as String,
        tokenType: json['token_type'] as String,
        user: UserResponse.fromJson(json['user'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'token_type': tokenType,
        'user': user.toJson(),
      };
}

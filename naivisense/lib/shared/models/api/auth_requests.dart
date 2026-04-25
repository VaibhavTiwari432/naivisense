class LoginRequest {
  final String phone;
  final String password;

  const LoginRequest({required this.phone, required this.password});

  Map<String, dynamic> toJson() => {'phone': phone, 'password': password};
}

class RegisterRequest {
  final String fullName;
  final String phone;
  final String password;
  final String role;
  final String? email;

  const RegisterRequest({
    required this.fullName,
    required this.phone,
    required this.password,
    required this.role,
    this.email,
  });

  Map<String, dynamic> toJson() => {
        'name': fullName,
        'phone': phone,
        'password': password,
        'role': role,
        if (email != null) 'email': email,
      };
}

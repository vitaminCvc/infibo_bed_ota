class LoginResult {
  const LoginResult({
    required this.id,
    required this.email,
    required this.role,
  });

  final int id;
  // 当前登录账号的邮箱，用于恢复登录状态。
  final String email;
  final String role;

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    return LoginResult(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
    );
  }
}

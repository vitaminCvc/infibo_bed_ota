//创建注册相关模型

enum RegisterRole { admin, operator, user }

extension RegisterRoleValue on RegisterRole {
  String get apiValue {
    switch (this) {
      case RegisterRole.admin:
        return 'admin';
      case RegisterRole.operator:
        return 'operator';
      case RegisterRole.user:
        return 'user';
    }
  }
}

class RegisterResult {
  const RegisterResult({required this.userId, this.token});

  final String userId;
  final String? token;

  factory RegisterResult.fromJson(Map<String, dynamic> json) {
    return RegisterResult(
      userId: json['userId']?.toString() ?? '',
      token: json['token']?.toString(),
    );
  }
}

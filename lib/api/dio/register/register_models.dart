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

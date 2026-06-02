// 邮箱相关工具函数。
//
// 登录页和注册页共用这里的邮箱校验规则，避免在多个页面里重复维护正则表达式。

final RegExp _emailPattern = RegExp(
  r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$",
);

// 校验常见邮箱格式，例如 name@example.com。
bool isValidEmail(String email) {
  return _emailPattern.hasMatch(email.trim());
}

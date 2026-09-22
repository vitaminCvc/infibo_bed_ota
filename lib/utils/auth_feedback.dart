import 'package:get/get.dart';

enum AuthFailure {
  accountAlreadyRegistered,
  accountNotRegistered,
  invalidPassword,
  invalidVerificationCode,
  unknown,
}

class AuthFailureClassifier {
  const AuthFailureClassifier._();

  static AuthFailure classify(String message) {
    final String text = message.trim().toLowerCase();
    if (text.isEmpty) return AuthFailure.unknown;

    if (_containsAny(text, const <String>[
      'already registered',
      'already exists',
      'account exists',
      'email exists',
      'user exists',
      '账号已注册',
      '已注册过',
      '账号已存在',
      '邮箱已存在',
      '用户已存在',
    ])) {
      return AuthFailure.accountAlreadyRegistered;
    }

    if (_containsAny(text, const <String>[
      'not registered',
      'does not exist',
      'not exist',
      'account not found',
      'user not found',
      '账号未注册',
      '账号不存在',
      '邮箱不存在',
      '用户不存在',
    ])) {
      return AuthFailure.accountNotRegistered;
    }

    if (_containsAny(text, const <String>[
      'incorrect password',
      'wrong password',
      'invalid password',
      'password is incorrect',
      '密码错误',
      '密码不正确',
      '密码无效',
    ])) {
      return AuthFailure.invalidPassword;
    }

    if (_containsAny(text, const <String>[
      'invalid code',
      'incorrect code',
      'wrong code',
      'code has expired',
      'code expired',
      'verification code expired',
      '验证码错误',
      '验证码无效',
      '验证码过期',
    ])) {
      return AuthFailure.invalidVerificationCode;
    }

    return AuthFailure.unknown;
  }

  static bool _containsAny(String text, List<String> candidates) {
    return candidates.any(text.contains);
  }
}

String resolveAuthApiMessage(String message, {required String fallbackKey}) {
  switch (AuthFailureClassifier.classify(message)) {
    case AuthFailure.accountAlreadyRegistered:
      return _authFailureText(
        chinese: '该账号已注册过，请直接登录',
        fallback: 'This account is already registered. Please sign in.',
      );
    case AuthFailure.accountNotRegistered:
      return _authFailureText(
        chinese: '该账号尚未注册',
        fallback: 'This account is not registered.',
      );
    case AuthFailure.invalidPassword:
      return _authFailureText(
        chinese: '密码错误，请重新输入',
        fallback: 'Incorrect password. Please try again.',
      );
    case AuthFailure.invalidVerificationCode:
      return _authFailureText(
        chinese: '验证码无效或已过期，请重新获取',
        fallback:
            'The verification code is invalid or expired. Please request a new one.',
      );
    case AuthFailure.unknown:
      return fallbackKey.tr;
  }
}

String verificationCodeSentMessage() {
  return _authFailureText(
    chinese: '验证码发送成功',
    fallback: 'Verification code sent successfully.',
  );
}

String _authFailureText({required String chinese, required String fallback}) {
  return Get.locale?.languageCode == 'zh' ? chinese : fallback;
}

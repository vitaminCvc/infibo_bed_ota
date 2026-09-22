import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/utils/auth_feedback.dart';

void main() {
  group('AuthFailureClassifier', () {
    test('classifies duplicate registration responses', () {
      expect(
        AuthFailureClassifier.classify('This account is already registered'),
        AuthFailure.accountAlreadyRegistered,
      );
      expect(
        AuthFailureClassifier.classify('该账号已注册过'),
        AuthFailure.accountAlreadyRegistered,
      );
    });

    test('classifies invalid password responses', () {
      expect(
        AuthFailureClassifier.classify('Password is incorrect'),
        AuthFailure.invalidPassword,
      );
      expect(
        AuthFailureClassifier.classify('密码错误'),
        AuthFailure.invalidPassword,
      );
    });

    test('classifies accounts that cannot reset a password', () {
      expect(
        AuthFailureClassifier.classify('Account is not registered'),
        AuthFailure.accountNotRegistered,
      );
      expect(
        AuthFailureClassifier.classify('账号不存在'),
        AuthFailure.accountNotRegistered,
      );
    });

    test('classifies invalid and expired verification codes', () {
      expect(
        AuthFailureClassifier.classify('Verification code has expired'),
        AuthFailure.invalidVerificationCode,
      );
      expect(
        AuthFailureClassifier.classify('验证码错误'),
        AuthFailure.invalidVerificationCode,
      );
    });
  });
}

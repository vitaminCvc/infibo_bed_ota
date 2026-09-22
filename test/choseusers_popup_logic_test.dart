import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/pages/choseusers/Popup/user_Popup_logic.dart';

void main() {
  group('UserPopupLogic.submit', () {
    test('returns trimmed user data for valid required fields', () {
      final UserPopupSubmitResult result = UserPopupLogic.submit(
        name: ' Alice ',
        ageText: ' 35 ',
        phone: ' 13800138000 ',
        email: ' alice@example.com ',
        remark: ' regular user ',
        gender: '女',
        requiredFieldsMessage: 'required',
        invalidAgeMessage: 'invalid age',
      );

      expect(result.isSuccess, isTrue);
      expect(result.user?.name, 'Alice');
      expect(result.user?.age, 35);
      expect(result.user?.phone, '13800138000');
      expect(result.user?.email, 'alice@example.com');
      expect(result.user?.remark, 'regular user');
      expect(result.user?.gender, '女');
    });

    test('rejects missing required fields', () {
      final UserPopupSubmitResult result = UserPopupLogic.submit(
        name: '',
        ageText: '35',
        phone: '13800138000',
        email: '',
        remark: '',
        gender: '男',
        requiredFieldsMessage: 'required',
        invalidAgeMessage: 'invalid age',
      );

      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, 'required');
    });

    test('rejects non-positive ages', () {
      final UserPopupSubmitResult result = UserPopupLogic.submit(
        name: 'Alice',
        ageText: '0',
        phone: '13800138000',
        email: '',
        remark: '',
        gender: '女',
        requiredFieldsMessage: 'required',
        invalidAgeMessage: 'invalid age',
      );

      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, 'invalid age');
    });
  });
}

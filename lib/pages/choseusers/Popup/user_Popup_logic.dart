// ignore_for_file: file_names

/// 添加用户弹窗提交的数据。
class UserPopupData {
  const UserPopupData({
    required this.name,
    required this.gender,
    required this.age,
    required this.phone,
    required this.email,
    required this.remark,
  });

  final String name;
  final String gender;
  final int age;
  final String phone;
  final String email;
  final String remark;
}

class UserPopupSubmitResult {
  const UserPopupSubmitResult._({this.user, this.errorMessage});

  const UserPopupSubmitResult.success(UserPopupData user) : this._(user: user);

  const UserPopupSubmitResult.failure(String message)
    : this._(errorMessage: message);

  final UserPopupData? user;
  final String? errorMessage;

  bool get isSuccess => user != null;
}

class UserPopupLogic {
  const UserPopupLogic._();

  static UserPopupSubmitResult submit({
    required String name,
    required String ageText,
    required String phone,
    required String email,
    required String remark,
    required String gender,
    required String requiredFieldsMessage,
    required String invalidAgeMessage,
  }) {
    final String trimmedName = name.trim();
    final String trimmedAge = ageText.trim();
    final String trimmedPhone = phone.trim();

    if (trimmedName.isEmpty || trimmedAge.isEmpty || trimmedPhone.isEmpty) {
      return UserPopupSubmitResult.failure(requiredFieldsMessage);
    }

    final int? age = int.tryParse(trimmedAge);
    if (age == null || age <= 0) {
      return UserPopupSubmitResult.failure(invalidAgeMessage);
    }

    return UserPopupSubmitResult.success(
      UserPopupData(
        name: trimmedName,
        gender: gender,
        age: age,
        phone: trimmedPhone,
        email: email.trim(),
        remark: remark.trim(),
      ),
    );
  }
}

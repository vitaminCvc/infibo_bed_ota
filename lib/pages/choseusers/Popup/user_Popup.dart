// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infibo_app/constants/layout.dart';
import 'package:infibo_app/pages/choseusers/Popup/user_PopUp_textfield.dart';
import 'package:infibo_app/pages/choseusers/Popup/user_Popup_button.dart';
import 'package:infibo_app/pages/choseusers/Popup/user_Popup_gender.dart';
import 'package:infibo_app/pages/choseusers/Popup/user_Popup_logic.dart';

/// 打开添加用户模态弹窗。
///
/// 弹窗外部和系统返回键均不能关闭弹窗，只能通过取消或确认按钮关闭。
Future<UserPopupData?> showAddUserPopup(BuildContext context) {
  return showDialog<UserPopupData>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    useSafeArea: false,
    builder: (BuildContext dialogContext) {
      return PopScope(
        canPop: false,
        child: ScaffoldMessenger(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: false,
            body: const _PopupDesignCanvas(child: Center(child: Popup())),
          ),
        ),
      );
    },
  );
}

/// 透明的弹窗设计画布，保持当前项目 800 像素设计宽度的缩放规则。
class _PopupDesignCanvas extends StatelessWidget {
  const _PopupDesignCanvas({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final Size designSize = AppLayout.forHostSize(
          constraints.biggest,
        ).designSize;
        return SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.center,
            child: SizedBox.fromSize(size: designSize, child: child),
          ),
        );
      },
    );
  }
}

/// 添加用户弹窗。
class Popup extends StatefulWidget {
  const Popup({super.key});

  @override
  State<Popup> createState() => _PopupState();
}

class _PopupState extends State<Popup> {
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _remarkController;
  String _gender = '男';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _ageController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _remarkController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 380,
      height: 425,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/Choseusers/UserPopup.png', fit: BoxFit.fill),
          Padding(
            padding: const EdgeInsets.all(40),
            child: Center(
              child: _Content(
                nameController: _nameController,
                ageController: _ageController,
                phoneController: _phoneController,
                gender: _gender,
                onGenderChanged: _handleGenderChanged,
                onCancel: _handleCancel,
                onConfirm: _handleConfirm,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleGenderChanged(String value) {
    setState(() => _gender = value);
  }

  void _handleCancel() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop();
  }

  void _showValidationMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
          behavior: SnackBarBehavior.fixed,
        ),
      );
  }

  void _handleConfirm() {
    FocusScope.of(context).unfocus();
    final UserPopupSubmitResult result = UserPopupLogic.submit(
      name: _nameController.text,
      ageText: _ageController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      remark: _remarkController.text,
      gender: _gender,
      requiredFieldsMessage: 'user_required_fields'.tr,
      invalidAgeMessage: 'user_invalid_age'.tr,
    );

    if (!result.isSuccess) {
      _showValidationMessage(result.errorMessage!);
      return;
    }

    Navigator.of(context).pop(result.user!);
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.nameController,
    required this.ageController,
    required this.phoneController,
    required this.gender,
    required this.onGenderChanged,
    required this.onCancel,
    required this.onConfirm,
  });

  final TextEditingController nameController;
  final TextEditingController ageController;
  final TextEditingController phoneController;
  final String gender;
  final ValueChanged<String> onGenderChanged;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      height: 350,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AddUserTextField(
            label: 'user_name_label'.tr,
            required: true,
            hintText: 'name'.tr,
            controller: nameController,
          ),
          const SizedBox(height: 36),
          GenderSelector(value: gender, onChanged: onGenderChanged),
          const SizedBox(height: 36),
          AddUserTextField(
            label: 'user_age_label'.tr,
            required: true,
            hintText: 'age'.tr,
            controller: ageController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 36),
          AddUserTextField(
            label: 'user_phone_label'.tr,
            required: true,
            hintText: 'phone'.tr,
            controller: phoneController,
            keyboardType: TextInputType.phone,
          ),

          const SizedBox(height: 36),
          Align(
            alignment: Alignment.center,
            child: PopupActionButtons(
              onCancel: onCancel,
              onConfirm: onConfirm,
              cancelLabel: 'cancel'.tr,
              confirmLabel: 'confirm'.tr,
            ),
          ),
        ],
      ),
    );
  }
}

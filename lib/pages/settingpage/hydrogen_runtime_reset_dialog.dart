import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'settings_panel_style.dart';

/// 返回 true 表示用户已输入正确密码并确认维护清零。
class HydrogenRuntimeResetDialog extends StatefulWidget {
  const HydrogenRuntimeResetDialog({super.key});

  @override
  State<HydrogenRuntimeResetDialog> createState() =>
      _HydrogenRuntimeResetDialogState();
}

class _HydrogenRuntimeResetDialogState
    extends State<HydrogenRuntimeResetDialog> {
  final _passwordController = TextEditingController();
  bool _invalidPassword = false;
  bool _closing = false;
  static const _error = Color.fromARGB(255, 212, 67, 67);

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _confirm() {
    if (_closing) return;
    if (_passwordController.text != 'infibo') {
      setState(() => _invalidPassword = true);
      return;
    }
    _close(true);
  }

  void _close(bool confirmed) {
    if (_closing) return;
    _closing = true;
    Navigator.of(context).pop(confirmed);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: const Color(0xFF25262D),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    title: Text(
      'status_hydrogen_reset_title'.tr,
      style: const TextStyle(
        color: Colors.white,
        fontFamily: settingsFontFamily,
      ),
    ),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'status_hydrogen_reset_message'.tr,
            style: const TextStyle(
              color: Color(0xFFBFBFBF),
              fontFamily: settingsFontFamily,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            key: const ValueKey('status_hydrogen_reset_password'),
            controller: _passwordController,
            autofocus: true,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            textInputAction: TextInputAction.done,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: settingsFontFamily,
            ),
            decoration: InputDecoration(
              labelText: 'status_hydrogen_reset_password'.tr,
              labelStyle: const TextStyle(color: Color(0xFFBFBFBF)),
              border: const OutlineInputBorder(),
              errorText: _invalidPassword
                  ? 'status_hydrogen_reset_password_incorrect'.tr
                  : null,
              errorStyle: const TextStyle(color: _error),
              errorMaxLines: 3,
            ),
            onChanged: (_) {
              if (_invalidPassword) setState(() => _invalidPassword = false);
            },
            onSubmitted: (_) => _confirm(),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        key: const ValueKey('status_hydrogen_reset_cancel'),
        onPressed: () => _close(false),
        child: Text('status_hydrogen_reset_cancel'.tr),
      ),
      TextButton(
        key: const ValueKey('status_hydrogen_reset_confirm'),
        onPressed: _confirm,
        style: TextButton.styleFrom(foregroundColor: _error),
        child: Text('status_hydrogen_reset_confirm'.tr),
      ),
    ],
  );
}

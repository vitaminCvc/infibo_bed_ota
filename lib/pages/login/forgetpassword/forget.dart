// 忘记密码页。
//
// 用户在这里输入邮箱、验证码、新密码和确认新密码，用于重置登录密码。

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:infibo_app/api/dio/api/api_response.dart';
import 'package:infibo_app/api/dio/reset_password/reset_password_api.dart';
import 'package:infibo_app/components/designCanvas/design.dart';
import 'package:infibo_app/config/app_brand.dart';
import 'package:infibo_app/constants/assets.dart';
import 'package:infibo_app/constants/color.dart';
import 'package:infibo_app/constants/layout.dart';
import 'package:infibo_app/utils/auth_feedback.dart';
import 'package:infibo_app/utils/email_utils.dart';

// 忘记密码页UI
class ForgetPage extends StatefulWidget {
  const ForgetPage({super.key});

  // 忘记密码页UI状态管理
  @override
  State<ForgetPage> createState() => _ForgetPageState();
}

// 忘记密码页UI状态管理
class _ForgetPageState extends State<ForgetPage> {
  // 邮箱输入框控制器：注册账号和接收验证码都使用这个邮箱。
  final TextEditingController _emailController = TextEditingController();

  // 验证码输入框控制器
  final TextEditingController _codeController = TextEditingController();

  // 新密码输入框控制器
  final TextEditingController _newPasswordController = TextEditingController();

  // 确认新密码输入框控制器
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // 邮箱输入框焦点：点击整个玻璃背景时也能聚焦输入框。
  final FocusNode _emailFocusNode = FocusNode();

  // 验证码输入框焦点
  final FocusNode _codeFocusNode = FocusNode();

  // 新密码输入框焦点
  final FocusNode _newPasswordFocusNode = FocusNode();

  // 确认新密码输入框焦点
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  // 是否可以点击确认按钮
  final ValueNotifier<bool> _canConfirmNotifier = ValueNotifier<bool>(false);

  // 是否正在重置密码，防止用户重复点击确认按钮
  bool _resetting = false;

  // 重置密码接口
  final ResetPasswordApi _resetPasswordApi = ResetPasswordApi();

  ///防止用户重复点击验证码。请求多次接口
  // 是否正在发送验证码
  bool _sendingCode = false;
  Timer? _codeTimer;
  int _codeCountdown = 0;

  bool get _canSendCode => !_sendingCode && _codeCountdown == 0;
  // 是否已经预缓存了图片
  bool _didPrecache = false;

  @override
  void initState() {
    super.initState();
    //监听输入框的变化，判断是否可以点击确认重置按钮（邮箱、验证码、新密码、确认新密码）
    _emailController.addListener(_updateCanConfirmState);
    _codeController.addListener(_updateCanConfirmState);
    _newPasswordController.addListener(_updateCanConfirmState);
    _confirmPasswordController.addListener(_updateCanConfirmState);

    _updateCanConfirmState();
  }

  @override
  // 预缓存图片（减少机器的卡顿）
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didPrecache) return;
    _didPrecache = true;

    precacheImage(AssetImage(Assets.logo), context);
    precacheImage(const AssetImage(Assets.glassLogo), context);
    precacheImage(const AssetImage(Assets.passwordLogo), context);
  }

  @override
  // 释放资源
  void dispose() {
    _emailController.removeListener(_updateCanConfirmState);
    _codeController.removeListener(_updateCanConfirmState);
    _newPasswordController.removeListener(_updateCanConfirmState);
    _confirmPasswordController.removeListener(_updateCanConfirmState);

    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();

    _emailFocusNode.dispose();
    _codeFocusNode.dispose();
    _newPasswordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _canConfirmNotifier.dispose();
    _codeTimer?.cancel();
    super.dispose();
  }

  ///////////////////////////////////////////////////忘记密码页界面布局///////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    final bool is16x9 = AppLayoutScope.of(context).is16x9;

    return Scaffold(
      // 当键盘弹出来时，页面不自动调整大小，保持原样显示
      resizeToAvoidBottomInset: false,
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        child: Stack(
          children: [
            //返回按钮
            Positioned(
              left: 50,
              top: 40,
              child: // 构建返回按钮
              ExpandBackButton(
                onTap: () => Get.back(),
              ),
            ),
            Align(
              alignment: is16x9 ? Alignment.topCenter : Alignment.center,
              child: SingleChildScrollView(
                padding: is16x9
                    ? const EdgeInsets.fromLTRB(
                        32,
                        AppLayout.authBrandLogoTop,
                        32,
                        0,
                      )
                    : const EdgeInsets.symmetric(horizontal: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 构建品牌页头
                      if (is16x9)
                        const SizedBox(
                          width: AppLayout.authBrandLogoWidth,
                          height: AppLayout.authBrandLogoHeight,
                        )
                      else
                        _buildBrandHeader(),
                      SizedBox(height: is16x9 ? 145 : 80),

                      // 构建邮箱输入框容器。
                      _buildInputEmail(),
                      SizedBox(height: is16x9 ? 44 : 38),

                      // 构建验证码输入框容器
                      _buildInputCode(),
                      SizedBox(height: is16x9 ? 44 : 38),

                      // 构建新密码输入框容器
                      _buildPasswordInput(
                        controller: _newPasswordController,
                        focusNode: _newPasswordFocusNode,
                        hintText: 'new_password_hint'.tr,
                      ),
                      SizedBox(height: is16x9 ? 44 : 38),

                      // 构建确认密码输入框容器
                      _buildPasswordInput(
                        controller: _confirmPasswordController,
                        focusNode: _confirmPasswordFocusNode,
                        hintText: 'confirm_new_password_hint'.tr,
                      ),
                      SizedBox(height: is16x9 ? 82 : 70),

                      // 确认重置密码按钮
                      _buildConfirmButton(),
                      SizedBox(height: is16x9 ? 125 : 100),
                    ],
                  ),
                ),
              ),
            ),
            if (is16x9)
              Positioned(
                top: AppLayout.authBrandLogoTop,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Center(
                    child: SizedBox(
                      width: AppLayout.authBrandLogoWidth,
                      height: AppLayout.authBrandLogoHeight,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: _buildBrandHeader(
                          key: const ValueKey<String>('auth-brand-logo'),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  ///////////////////////////////////////////////////注册页组件构建///////////////////////////////////////////////////

  /// 构建品牌页头
  Widget _buildBrandHeader({Key? key}) {
    final Size logoSize = AppBrand.current.loginLogoSize;

    return Image.asset(
      Assets.logo,
      key: key,
      width: logoSize.width,
      height: logoSize.height,
      fit: BoxFit.contain,
    );
  }

  //-----------------------------------------邮箱------------------------------------//

  /// 构建邮箱输入框容器。
  Widget _buildInputEmail() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).requestFocus(_emailFocusNode),
      child: Stack(
        children: [
          // 毛玻璃背景
          Image.asset(Assets.glassLogo),

          // 邮箱输入框。
          Positioned(
            left: 22,
            right: 22,
            top: 0,
            bottom: 0,
            child: _inputEmail(),
          ),
        ],
      ),
    );
  }

  /// 构建邮箱输入框。
  Widget _inputEmail() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 使用 Material 邮箱图标，与邮箱账号语义保持一致。
        const Icon(Icons.email_outlined, color: Color(0xFF696969), size: 24),
        const SizedBox(width: 12),

        // 宽度撑开
        Expanded(
          child: TextField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            enableSuggestions: false,
            cursorColor: const Color(0xFF1464DF),
            style: const TextStyle(color: Colors.white, fontSize: 18),
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              isCollapsed: true,
              hintText: 'login_email_hint'.tr,
              hintStyle: const TextStyle(
                color: Color.fromARGB(255, 129, 133, 145),
                fontSize: 18,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  //-----------------------------------------验证码------------------------------------//

  /// 构建验证码输入框容器
  Widget _buildInputCode() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).requestFocus(_codeFocusNode),
      child: Stack(
        children: [
          // 毛玻璃背景
          Image.asset(Assets.glassLogo),

          // 验证码输入框
          Positioned(
            left: 22,
            right: 22,
            top: 0,
            bottom: 0,
            child: _inputCode(),
          ),
        ],
      ),
    );
  }

  /// 构建验证码输入框
  Widget _inputCode() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 暂时使用密码图标，后面有验证码图标后再替换
        Image.asset(Assets.passwordLogo),
        const SizedBox(width: 12),

        Expanded(
          child: TextField(
            controller: _codeController,
            focusNode: _codeFocusNode,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            cursorColor: const Color(0xFF1464DF),
            style: const TextStyle(color: Colors.white, fontSize: 18),
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              isCollapsed: true,
              hintText: 'verify_code'.tr,
              hintStyle: const TextStyle(
                color: Color.fromARGB(255, 129, 133, 145),
                fontSize: 18,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),

        Container(width: 1, height: 20, color: const Color(0xFF1464DF)),
        const SizedBox(width: 12),

        GestureDetector(
          behavior: HitTestBehavior.opaque,
          // 点击获取验证码按钮，发送验证码
          onTap: _canSendCode ? _getVerifyCode : null,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2, vertical: 8),
            child: Text(
              _sendingCode
                  ? 'send_code'.tr
                  : _codeCountdown > 0
                  ? '${_codeCountdown}s'
                  : 'get_code'.tr,
              style: TextStyle(
                color: Color(0xFF1464DF),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  //-----------------------------------------密码------------------------------------//

  /// 构建新密码输入框容器
  Widget _buildPasswordInput({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).requestFocus(focusNode),
      child: Stack(
        children: [
          // 毛玻璃背景
          Image.asset(Assets.glassLogo),

          // 密码输入框
          Positioned(
            left: 22,
            right: 22,
            top: 0,
            bottom: 0,
            child: _passwordInputContent(
              controller: controller,
              focusNode: focusNode,
              hintText: hintText,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建密码输入框内容
  Widget _passwordInputContent({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 密码图标
        Image.asset(Assets.passwordLogo),
        const SizedBox(width: 12),
        // 宽度撑开
        Expanded(
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: TextInputType.text,
            obscureText: false, // 是否显示密码
            cursorColor: const Color(0xFF1464DF),
            style: const TextStyle(color: Colors.white, fontSize: 18),
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              //使TextField 的输入区域变得更紧凑，去掉 InputDecoration 默认自带的上下内边距。
              isCollapsed: true,
              hintText: hintText,
              hintStyle: const TextStyle(
                color: Color.fromARGB(255, 129, 133, 145),
                fontSize: 18,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  //------------------------------------注册按钮------------------------------------//

  /// 构建确认重置密码按钮
  Widget _buildConfirmButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: _canConfirmNotifier,
      builder: (BuildContext context, bool canConfirm, _) {
        return SizedBox(
          width: 480,
          height: 56,
          child: ElevatedButton(
            // 注册按钮点击事件
            onPressed: canConfirm && !_resetting ? _confirmResetPassword : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1464DF),
              disabledBackgroundColor: const Color.fromARGB(255, 2, 43, 106),
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.grey,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            child: Text(
              _resetting ? 'resetting_password'.tr : 'confirm_reset'.tr,
            ),
          ),
        );
      },
    );
  }

  //------------------------------------逻辑判断------------------------------------//

  /// 判断是否可以确认重置密码
  bool _canConfirm() {
    //1. 同意协议
    //2. 邮箱不为空
    //3. 验证码不为空
    //4. 密码不为空
    //5. 确认密码与密码密码一致
    return _emailController.text.trim().isNotEmpty &&
        _codeController.text.trim().isNotEmpty &&
        _newPasswordController.text.trim().isNotEmpty &&
        _confirmPasswordController.text.trim().isNotEmpty;
  }

  /// 更新确认按钮状态
  void _updateCanConfirmState() {
    final bool nextValue = _canConfirm();

    if (_canConfirmNotifier.value == nextValue) return;

    _canConfirmNotifier.value = nextValue;
  }

  void _startCodeCountdown() {
    _codeTimer?.cancel();

    setState(() {
      _codeCountdown = 60;
    });

    _codeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_codeCountdown <= 1) {
        timer.cancel();
        setState(() {
          _codeCountdown = 0;
        });
        return;
      }

      setState(() {
        _codeCountdown--;
      });
    });
  }

  /// 获取重置密码验证码
  Future<void> _getVerifyCode() async {
    if (_sendingCode) return;

    final String email = _emailController.text.trim();

    if (email.isEmpty) {
      /////Get.snackbar风格修改：
      /////保留 Get.snackbar，参数加 snackPosition: SnackPosition.BOTTOM、backgroundColor: const Color(0xFF323232)、colorText: Colors.white、margin: const EdgeInsets.all(16)、borderRadius: 4；原有 backgroundColor: Colors.white 要替换掉。
      Get.snackbar(
        'prompt'.tr,
        'email_empty'.tr,
        backgroundColor: const Color(0xFF323232),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 4,
      );
      return;
    }

    // 发送验证码前先校验邮箱，避免把明显无效的地址提交给后端。
    if (!isValidEmail(email)) {
      /////Get.snackbar风格修改：
      /////保留 Get.snackbar，参数加 snackPosition: SnackPosition.BOTTOM、backgroundColor: const Color(0xFF323232)、colorText: Colors.white、margin: const EdgeInsets.all(16)、borderRadius: 4；原有 backgroundColor: Colors.white 要替换掉。
      Get.snackbar(
        'prompt'.tr,
        'email_invalid'.tr,
        backgroundColor: const Color(0xFF323232),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 4,
      );
      return;
    }

    setState(() {
      _sendingCode = true;
    });

    final ApiResponse<String> result = await _resetPasswordApi.sendResetCode(
      email: email,
    );

    if (!mounted) return;

    setState(() {
      _sendingCode = false;
    });

    if (result.isSuccess) {
      _startCodeCountdown();
      debugPrint('后端返回的邮箱：${result.data}');

      /////Get.snackbar风格修改：
      /////保留 Get.snackbar，参数加 snackPosition: SnackPosition.BOTTOM、backgroundColor: const Color(0xFF323232)、colorText: Colors.white、margin: const EdgeInsets.all(16)、borderRadius: 4；原有 backgroundColor: Colors.white 要替换掉。
      Get.snackbar(
        'prompt'.tr,
        verificationCodeSentMessage(),
        backgroundColor: const Color(0xFF323232),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 4,
      );
    } else {
      /////Get.snackbar风格修改：
      /////保留 Get.snackbar，参数加 snackPosition: SnackPosition.BOTTOM、backgroundColor: const Color(0xFF323232)、colorText: Colors.white、margin: const EdgeInsets.all(16)、borderRadius: 4；原有 backgroundColor: Colors.white 要替换掉。
      Get.snackbar(
        'prompt'.tr,
        resolveAuthApiMessage(result.message, fallbackKey: 'code_send_failed'),

        backgroundColor: const Color(0xFF323232),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 4,
      );
    }
  }

  /// 确认重置密码
  Future<void> _confirmResetPassword() async {
    if (_resetting) return;

    final String email = _emailController.text.trim();
    final String code = _codeController.text.trim();
    final String newPassword = _newPasswordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty) {
      /////Get.snackbar风格修改：
      /////保留 Get.snackbar，参数加 snackPosition: SnackPosition.BOTTOM、backgroundColor: const Color(0xFF323232)、colorText: Colors.white、margin: const EdgeInsets.all(16)、borderRadius: 4；原有 backgroundColor: Colors.white 要替换掉。
      Get.snackbar(
        'prompt'.tr,
        'email_required'.tr,
        backgroundColor: const Color(0xFF323232),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 4,
      );
      return;
    }

    if (!isValidEmail(email)) {
      /////Get.snackbar风格修改：
      /////保留 Get.snackbar，参数加 snackPosition: SnackPosition.BOTTOM、backgroundColor: const Color(0xFF323232)、colorText: Colors.white、margin: const EdgeInsets.all(16)、borderRadius: 4；原有 backgroundColor: Colors.white 要替换掉。
      Get.snackbar(
        'prompt'.tr,
        'email_invalid'.tr,
        backgroundColor: const Color(0xFF323232),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 4,
      );
      return;
    }

    if (code.isEmpty) {
      /////Get.snackbar风格修改：
      /////保留 Get.snackbar，参数加 snackPosition: SnackPosition.BOTTOM、backgroundColor: const Color(0xFF323232)、colorText: Colors.white、margin: const EdgeInsets.all(16)、borderRadius: 4；原有 backgroundColor: Colors.white 要替换掉。
      Get.snackbar(
        'prompt'.tr,
        'verify_code_required'.tr,
        backgroundColor: const Color(0xFF323232),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 4,
      );
      return;
    }

    if (newPassword.isEmpty) {
      /////Get.snackbar风格修改：
      /////保留 Get.snackbar，参数加 snackPosition: SnackPosition.BOTTOM、backgroundColor: const Color(0xFF323232)、colorText: Colors.white、margin: const EdgeInsets.all(16)、borderRadius: 4；原有 backgroundColor: Colors.white 要替换掉。
      Get.snackbar(
        'prompt'.tr,
        'new_password_required'.tr,

        backgroundColor: const Color(0xFF323232),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 4,
      );
      return;
    }

    if (confirmPassword.isEmpty) {
      /////Get.snackbar风格修改：
      /////保留 Get.snackbar，参数加 snackPosition: SnackPosition.BOTTOM、backgroundColor: const Color(0xFF323232)、colorText: Colors.white、margin: const EdgeInsets.all(16)、borderRadius: 4；原有 backgroundColor: Colors.white 要替换掉。
      Get.snackbar(
        'prompt'.tr,
        'confirm_new_password_required'.tr, //确认新密码不能为空

        backgroundColor: const Color(0xFF323232), //背景色
        colorText: Colors.white, //文本颜色
        margin: const EdgeInsets.all(16), //外边距
        borderRadius: 4, //圆角半径
      );
      return;
    }

    if (newPassword != confirmPassword) {
      /////Get.snackbar风格修改：
      /////保留 Get.snackbar，参数加 snackPosition: SnackPosition.BOTTOM、backgroundColor: const Color(0xFF323232)、colorText: Colors.white、margin: const EdgeInsets.all(16)、borderRadius: 4；原有 backgroundColor: Colors.white 要替换掉。
      Get.snackbar(
        'prompt'.tr, //提示
        'passwords_not_match'.tr, //两次输入的密码不一致

        backgroundColor: const Color(0xFF323232),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 4,
      );
      return;
    }

    setState(() {
      _resetting = true; //设置为正在重置密码
    });

    try {
      // 对接后端“重置密码”接口。
      //
      // final ApiResponse<void> result = await _registerApi.resetPassword(
      //   email: email,
      //   code: code,
      //   newPassword: newPassword,
      // );

      final ApiResponse<void> result = await _resetPasswordApi.resetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
      );

      if (!mounted) return;

      if (result.isSuccess) {
        /////Get.snackbar风格修改：
        /////保留 Get.snackbar，参数加 snackPosition: SnackPosition.BOTTOM、backgroundColor: const Color(0xFF323232)、colorText: Colors.white、margin: const EdgeInsets.all(16)、borderRadius: 4；原有 backgroundColor: Colors.white 要替换掉。
        Get.snackbar(
          'prompt'.tr,
          'password_reset_success'.tr,

          backgroundColor: const Color(0xFF323232),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 4,
        );

        await Future.delayed(const Duration(milliseconds: 1200));

        if (!mounted) return;

        Get.offNamed('/login');
      } else {
        /////Get.snackbar风格修改：
        /////保留 Get.snackbar，参数加 snackPosition: SnackPosition.BOTTOM、backgroundColor: const Color(0xFF323232)、colorText: Colors.white、margin: const EdgeInsets.all(16)、borderRadius: 4；原有 backgroundColor: Colors.white 要替换掉。
        Get.snackbar(
          'prompt'.tr,
          resolveAuthApiMessage(
            result.message,
            fallbackKey: 'password_reset_failed',
          ),

          backgroundColor: const Color(0xFF323232),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 4,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _resetting = false;
        });
      }
    }
  }
}

//构建返回按钮
class ExpandBackButton extends StatelessWidget {
  const ExpandBackButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        onTap();
      },
      child: Container(
        width: 110,
        height: 45,
        decoration: BoxDecoration(
          color: const Color(0xFF202127),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(Assets.chakraReturnIcon, width: 20, height: 20),
            const SizedBox(width: 10),
            Text(
              'back'.tr,
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

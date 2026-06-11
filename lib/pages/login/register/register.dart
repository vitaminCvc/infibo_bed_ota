// 注册页。
//
// 用户在这里选择注册角色，输入邮箱、验证码、密码并勾选协议。

import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infibo_app/api/dio/api/api_response.dart';
import 'package:infibo_app/api/dio/register/register_api.dart';
import 'package:infibo_app/api/dio/register/register_models.dart';
import 'package:infibo_app/constants/assets.dart';
import 'package:infibo_app/constants/color.dart';
import 'package:infibo_app/utils/email_utils.dart';
import 'package:infibo_app/utils/localized_api_message.dart';

// 注册页UI
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  // 注册页UI状态管理
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

// 注册页UI状态管理
class _RegisterPageState extends State<RegisterPage> {
  // 注册角色，默认值为管理员
  RegisterRole _role = RegisterRole.admin;

  // 是否同意协议，默认值为 false（未同意）
  bool _agreed = false;

  // 邮箱输入框控制器：注册账号和接收验证码都使用这个邮箱。
  final TextEditingController _emailController = TextEditingController();

  // 验证码输入框控制器
  final TextEditingController _codeController = TextEditingController();

  // 密码输入框控制器
  final TextEditingController _passwordController = TextEditingController();

  // 邮箱输入框焦点：点击整个玻璃背景时也能聚焦输入框。
  final FocusNode _emailFocusNode = FocusNode();

  // 验证码输入框焦点
  final FocusNode _codeFocusNode = FocusNode();

  // 密码输入框焦点
  final FocusNode _passwordFocusNode = FocusNode();

  // 是否可以注册
  final ValueNotifier<bool> _canRegisterNotifier = ValueNotifier<bool>(false);

  // 注册接口
  final RegisterApi _registerApi = RegisterApi();

  ///防止用户重复点击验证码。请求多次接口
  // 是否正在发送验证码
  bool _sendingCode = false;
  // 是否正在注册
  bool _registering = false;

  // 是否已经预缓存了图片
  bool _didPrecache = false;

  late final TapGestureRecognizer _userAgreementRecognizer;
  late final TapGestureRecognizer _privacyPolicyRecognizer;

  @override
  void initState() {
    super.initState();

    _userAgreementRecognizer = TapGestureRecognizer()
      ..onTap = () {
        _showAgreementDialog(
          title: 'user_agreement'.tr,
          content: _userAgreementContent,
        );
      };
    _privacyPolicyRecognizer = TapGestureRecognizer()
      ..onTap = () {
        _showAgreementDialog(
          title: 'privacy_policy'.tr,
          content: _privacyPolicyContent,
        );
      };

    _emailController.addListener(_updateCanRegisterState);
    _codeController.addListener(_updateCanRegisterState);
    _passwordController.addListener(_updateCanRegisterState);

    _updateCanRegisterState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didPrecache) return;
    _didPrecache = true;

    precacheImage(const AssetImage(Assets.logo), context);
    precacheImage(const AssetImage(Assets.glassLogo), context);
    precacheImage(const AssetImage(Assets.passwordLogo), context);
    precacheImage(const AssetImage(Assets.adminLogo), context);
    precacheImage(const AssetImage(Assets.operatorLogo), context);
    precacheImage(const AssetImage(Assets.userLogo), context);
  }

  @override
  void dispose() {
    _emailController.removeListener(_updateCanRegisterState);
    _codeController.removeListener(_updateCanRegisterState);
    _passwordController.removeListener(_updateCanRegisterState);

    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();

    _emailFocusNode.dispose();
    _codeFocusNode.dispose();
    _passwordFocusNode.dispose();

    _canRegisterNotifier.dispose();
    _userAgreementRecognizer.dispose();
    _privacyPolicyRecognizer.dispose();

    super.dispose();
  }

  ///////////////////////////////////////////////////注册页界面布局///////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 当键盘弹出来时，页面不自动调整大小，保持原样显示
      resizeToAvoidBottomInset: false,
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 构建品牌页头
                  _buildBrandHeader(),
                  const SizedBox(height: 120),

                  // 构建角色选择器
                  _buildRoleSelector(),
                  const SizedBox(height: 38),

                  // 构建邮箱输入框容器。
                  _buildInputEmail(),
                  const SizedBox(height: 38),

                  // 构建验证码输入框容器
                  _buildInputCode(),
                  const SizedBox(height: 38),

                  // 构建密码输入框容器
                  _buildInputPassword(),
                  const SizedBox(height: 70),

                  // 注册按钮
                  _buildRegisterButton(),
                  const SizedBox(height: 23),
                  _buildAlreadyHaveAccountRow(),
                  const SizedBox(height: 178),
                  // 用户协议
                  _buildAgreementRow(),
                  const SizedBox(height: 34),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  ///////////////////////////////////////////////////注册页组件构建///////////////////////////////////////////////////

  /// 构建品牌页头
  Widget _buildBrandHeader() {
    return Image.asset(Assets.logo, fit: BoxFit.cover);
  }

  /// 构建角色选择器
  Widget _buildRoleSelector() {
    return Stack(
      children: [
        // 毛玻璃背景
        Image.asset(Assets.glassLogo),

        Positioned(
          top: 8,
          bottom: 8,
          left: 10,
          right: 10,
          child: Row(
            children: [
              _buildRoleItem(
                iconAsset: Assets.adminLogo,
                label: 'Admin'.tr,
                role: RegisterRole.admin,
              ),
              _buildRoleItem(
                iconAsset: Assets.operatorLogo,
                label: 'Operator'.tr,
                role: RegisterRole.operator,
              ),
              _buildRoleItem(
                iconAsset: Assets.userLogo,
                label: 'User'.tr,
                role: RegisterRole.user,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建管理员、操作员、个人选择器项
  Widget _buildRoleItem({
    required String iconAsset,
    required String label,
    required RegisterRole role,
  }) {
    final bool selected = _role == role;

    // 选中为白色，未选中为灰色
    final Color color = selected ? Colors.white : const Color(0xFFB3B6C0);

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(23),
        onTap: () {
          setState(() {
            _role = role;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 45,
          decoration: BoxDecoration(
            color: selected
                ? const Color.fromARGB(255, 62, 62, 64)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(23),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(iconAsset, width: 22, height: 22, color: color),
              const SizedBox(width: 9),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
            cursorColor: const Color(0xFF1464DF),
            style: const TextStyle(color: Colors.white, fontSize: 18),
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              isCollapsed: true,
              hintText: 'verify_code'.tr,
              hintStyle: TextStyle(
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
          onTap: _sendingCode ? null : _getVerifyCode,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2, vertical: 8),
            child: Text(
              _sendingCode ? 'send_code'.tr : 'get_code'.tr,
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

  /// 构建密码输入框容器
  Widget _buildInputPassword() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).requestFocus(_passwordFocusNode),
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
            child: _inputPassword(),
          ),
        ],
      ),
    );
  }

  /// 构建密码输入框
  Widget _inputPassword() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 密码图标
        Image.asset(Assets.passwordLogo),
        const SizedBox(width: 12),

        // 宽度撑开
        Expanded(
          child: TextField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            keyboardType: TextInputType.text,
            obscureText: false, // 是否显示密码
            cursorColor: const Color(0xFF1464DF),
            style: const TextStyle(color: Colors.white, fontSize: 18),
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              isCollapsed: true,
              hintText: 'login_password_hint'.tr,
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

  /// 构建注册按钮
  Widget _buildRegisterButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: _canRegisterNotifier,
      builder: (BuildContext context, bool canRegister, _) {
        return SizedBox(
          width: 480,
          height: 64,
          child: ElevatedButton(
            // 注册按钮点击事件
            onPressed: canRegister && !_registering ? _register : null,
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
            child: Text(_registering ? 'registering'.tr : 'register'.tr),
          ),
        );
      },
    );
  }

  //构建已有账号登录行
  Widget _buildAlreadyHaveAccountRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'already_have_account'.tr,
          style: TextStyle(
            color: Color(0xffb3b6c0),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        GestureDetector(
          // 登录按钮点击事件,让整个 GestureDetector 占用的区域都可以点击，包括空白透明区域。
          behavior: HitTestBehavior.opaque,
          onTap: () {
            Get.back();
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text(
              'login_now'.tr,
              style: TextStyle(
                color: Color(0xff1464df),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建用户协议行
  Widget _buildAgreementRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            setState(() => _agreed = !_agreed);
            _updateCanRegisterState();
          },
          child: SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: Checkbox(
                  value: _agreed,
                  onChanged: (value) {
                    setState(() {
                      _agreed = value ?? false;
                    });
                    _updateCanRegisterState();
                  },
                  shape: const CircleBorder(),
                  side: const BorderSide(color: Color(0xFF7F8491)),
                  activeColor: const Color(0xFF1464DF),
                  checkColor: Colors.white,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ),
        ),
        Flexible(
          child: Text.rich(
            TextSpan(
              text: 'agree_prefix'.tr,
              children: [
                TextSpan(
                  text: 'user_agreement'.tr,
                  style: const TextStyle(color: Color(0xFF1464DF)),
                  recognizer: _userAgreementRecognizer,
                ),
                TextSpan(text: 'and'.tr),
                TextSpan(
                  text: 'privacy_policy'.tr,
                  style: const TextStyle(color: Color(0xFF1464DF)),
                  recognizer: _privacyPolicyRecognizer,
                ),
              ],
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFB3B6C0),
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  static const String _userAgreementContent =
      '''IMMORTAL CHAMBER – TERMS OF SERVICE

Last Updated: June 10, 2026

Welcome to the IMMORTAL CHAMBER smart longevity wellness system. This End-User License Agreement ("Agreement") is a legal agreement between you ("User" or "you") and Infibo （Guangzhou）Technology Co., Ltd. ("Company", "we", or "us") for the use of the IMMORTAL CHAMBER Android control software ("Software") and the operating of the immortal chamber hardware ("Device").

1. MEDICAL DISCLAIMER (CRITICAL)
1.1 NO MEDICAL ADVICE: The IMMORTAL CHAMBER, including its Software and hardware features (such as Photobiomodulation/Red Light Therapy, Pulsed Electromagnetic Fields (PEMF), Acoustic Vibration, and Molecular Hydrogen Therapy), is designed solely for general wellness, relaxation, and physical recovery purposes. It is NOT a medical device and is NOT intended to diagnose, treat, cure, or prevent any medical condition or disease.
1.2 USER RESPONSIBILITY: You should consult a qualified healthcare professional before using the Device, especially if you have pre-existing medical conditions, implanted medical devices (e.g., pacemakers), are pregnant, or are sensitive to thermal or light stimulation. You assume all risks associated with the use of the therapies provided by the Device.

2. ELIGIBILITY & USER ACCOUNT
2.1 AGE REQUIREMENT: You must be at least 18 years old to create an account and operate the Device.
2.2 ACCOUNT SECURITY: You are responsible for maintaining the confidentiality of your login credentials and for all activities that occur under your account.

3. LICENSE AND RESTRICTIONS
3.1 LICENSE GRANT: We grant you a limited, non-exclusive, non-transferable, revocable license to use the Software strictly for operating the Device.
3.2 PROHIBITED USES: You agree not to:
- Reverse engineer, decompile, or disassemble the Software.
- Modify or bypass any safety parameters, session timers, or hardware lockouts built into the Software.
- Use the Software or Device for any commercial purposes unless explicitly authorized via a commercial distributor agreement.

4. LIMITATION OF LIABILITY
To the maximum extent permitted by applicable law (including EU and US consumer laws), the Company shall not be liable for any indirect, incidental, special, or consequential damages arising out of or in connection with your use or inability to use the Software or Device, including but not limited to improper operation or failure to follow safety instructions.

5. GOVERNING LAW
This Agreement shall be governed by and construed in accordance with the laws of the jurisdiction where the commercial distributor agreement was executed, or as required under local consumer protection laws.''';

  static const String _privacyPolicyContent =
      '''IMMORTAL CHAMBER – PRIVACY POLICY

Last Updated: June 10, 2026

Your privacy is paramount to us. This Privacy Policy explains how Infibo （Guangzhou）Technology Co., Ltd. ("we", "us", or "our") collects, uses, discloses, and safeguards your information when you use the IMMORTAL CHAMBER Android application ("Software").

1. INFORMATION WE COLLECT
To provide a personalized wellness experience, we may collect the following categories of data:
1.1 ACCOUNT INFORMATION: Name, email address, password, and profile preferences.
1.2 WELLNESS & OPERATIONAL DATA (Sensitive Data): To customize session intensities for Red Light, PEMF, and Molecular Hydrogen therapies, the Software may process user-inputted physical indicators (e.g., age, weight, gender, wellness goals) and session history (e.g., duration, frequency, chosen programs).
1.3 TECHNICAL & DEVICE DATA: IP address, device hardware model, Android OS version, and system crash logs to ensure firmware stability and safety updates.

2. HOW WE USE YOUR INFORMATION
We use the collected data strictly for:
- Creating and managing your personalized wellness profile.
- Executing and optimizing customized therapy programs (AI-driven optimization).
- Providing firmware diagnostics, system safety checks, and technical support.
- Complying with applicable legal and safety certification standards (e.g., CE, ETL).

3. LEGAL BASIS FOR PROCESSING (FOR EU/UK USERS)
Based on relevant laws and regulations, we process your wellness and profile data based on your **explicit consent**, which you grant before initializing your first chamber session. You have the right to withdraw consent at any time.

4. DATA STORAGE AND SECURITY
4.1 LOCAL & CLOUD STORAGE: Operational data is processed locally on the Android system and securely synced to encrypted cloud servers.
4.2 SECURITY MEASURES: We implement industry-standard AES-256 encryption for data at rest and TLS encryption for data in transit to prevent unauthorized access.

5. DATA SHARING AND CROSS-BORDER TRANSFERS
We do not sell your personal or wellness data. Data may be shared only with certified cloud service providers or authorized technical partners under strict Data Processing Agreements (DPAs). For international transfers from the EU/UK to overseas servers, we utilize Standard Contractual Clauses (SCCs) to guarantee GDPR-equivalent protection.

6. YOUR RIGHTS (GDPR / CCPA / CPRA)
Depending on your location, you hold the following rights regarding your data:
- **Right to Access & Portability:** Request a copy of your stored profile and therapy history.
- **Right to Rectification:** Correct inaccurate data directly via the UI settings.
- **Right to Erasure:** Delete your account and all associated wellness history.
- **Opt-Out:** We do not sell personal info, but you retain the right to restrict the use of sensitive personal wellness data.

To exercise these rights, please contact our privacy compliance team at: [info@infibo.com.cn].
''';

  void _showAgreementDialog({required String title, required String content}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: title,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: _buildGlassCard(
              width: 400,
              height: 720,
              radius: 18,
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
              child: Column(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          content,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            height: 1.45,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  //------------------------------------逻辑判断------------------------------------//

  /// 判断是否可以注册
  bool _canRegister() {
    //1. 同意协议
    //2. 邮箱不为空
    //3. 验证码不为空
    //4. 密码不为空
    return _agreed &&
        _emailController.text.trim().isNotEmpty &&
        _codeController.text.trim().isNotEmpty &&
        _passwordController.text.trim().isNotEmpty;
  }

  /// 更新注册按钮状态
  void _updateCanRegisterState() {
    final bool nextValue = _canRegister();

    if (_canRegisterNotifier.value == nextValue) return;

    _canRegisterNotifier.value = nextValue;
  }

  /// 获取验证码
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

    final ApiResponse<String> result = await _registerApi.sendCode(
      email: email,
    );

    if (!mounted) return;

    setState(() {
      _sendingCode = false;
    });

    if (result.isSuccess) {
    } else {
      /////Get.snackbar风格修改：
      /////保留 Get.snackbar，参数加 snackPosition: SnackPosition.BOTTOM、backgroundColor: const Color(0xFF323232)、colorText: Colors.white、margin: const EdgeInsets.all(16)、borderRadius: 4；原有 backgroundColor: Colors.white 要替换掉。
      Get.snackbar(
        'prompt'.tr,
        localizedApiMessage(result.message, fallbackKey: 'code_send_failed'),

        backgroundColor: const Color(0xFF323232),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 4,
      );
    }
  }

  /// 注册
  Future<void> _register() async {
    if (_registering) return;

    final String email = _emailController.text.trim();
    final String code = _codeController.text.trim();
    final String password = _passwordController.text.trim();

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
      _registering = true;
    });

    final ApiResponse<void> result = await _registerApi.register(
      email: email,
      code: code,
      password: password,
      role: _role,
    );

    if (!mounted) return;

    setState(() {
      _registering = false;
    });

    if (result.isSuccess) {
      /////Get.snackbar风格修改：
      /////保留 Get.snackbar，参数加 snackPosition: SnackPosition.BOTTOM、backgroundColor: const Color(0xFF323232)、colorText: Colors.white、margin: const EdgeInsets.all(16)、borderRadius: 4；原有 backgroundColor: Colors.white 要替换掉。
      Get.snackbar(
        'prompt'.tr,
        localizedApiMessage(result.message, fallbackKey: 'register_success'),

        backgroundColor: const Color(0xFF323232),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 4,
      );
      await Future.delayed(const Duration(microseconds: 600));
      if (!mounted) return;

      Get.back();
    } else {
      /////Get.snackbar风格修改：
      /////保留 Get.snackbar，参数加 snackPosition: SnackPosition.BOTTOM、backgroundColor: const Color(0xFF323232)、colorText: Colors.white、margin: const EdgeInsets.all(16)、borderRadius: 4；原有 backgroundColor: Colors.white 要替换掉。
      Get.snackbar(
        'prompt'.tr,
        localizedApiMessage(result.message, fallbackKey: 'register_failed'),

        backgroundColor: const Color(0xFF323232),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 4,
      );
    }
  }
}

Widget _buildGlassCard({
  required Widget child,
  double width = 400,
  double height = 720,
  double radius = 18,
  EdgeInsets padding = const EdgeInsets.all(22),
  List<Color>? gradientColors,
}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.59, 0.99],
            colors: [
              const Color(0xFFF1F5FF).withValues(alpha: 0.12),
              const Color(0xFFDBE6FF).withValues(alpha: 0.28),
              const Color(0xFFF1F5FF).withValues(alpha: 0.12),
            ],
          ),
        ),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius - 1),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.48, 1.0],
              colors:
                  gradientColors ??
                  [
                    const Color(0xFF202634).withValues(alpha: 0.78),
                    const Color(0xFF151A24).withValues(alpha: 0.74),
                    const Color(0xFF0B0E15).withValues(alpha: 0.70),
                  ],
            ),
          ),
          child: child,
        ),
      ),
    ),
  );
}

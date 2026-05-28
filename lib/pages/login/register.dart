// 注册页。
//
// 用户在这里选择注册角色，输入手机号、验证码、密码并勾选协议。
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infibo_app/constants/assets.dart';
import 'package:infibo_app/pages/login/logic.dart';
import 'package:infibo_app/constants/color.dart';
import 'package:dio/dio.dart';

// 可选注册角色：管理员、操作员、用户
enum RegisterRole { admin, operator, user }

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

  // 手机号输入框控制器
  final TextEditingController _phoneController = TextEditingController();

  // 验证码输入框控制器
  final TextEditingController _codeController = TextEditingController();

  // 密码输入框控制器
  final TextEditingController _passwordController = TextEditingController();

  // 手机号输入框焦点
  final FocusNode _phoneFocusNode = FocusNode();

  // 验证码输入框焦点
  final FocusNode _codeFocusNode = FocusNode();

  // 密码输入框焦点
  final FocusNode _passwordFocusNode = FocusNode();

  final LoginLogic _logic = LoginLogic();

  // 是否可以注册
  final ValueNotifier<bool> _canRegisterNotifier = ValueNotifier<bool>(false);

  bool _didPrecache = false;

  @override
  void initState() {
    super.initState();

    _phoneController.addListener(_updateCanRegisterState);
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
    precacheImage(const AssetImage(Assets.phoneLogo), context);
    precacheImage(const AssetImage(Assets.passwordLogo), context);
    precacheImage(const AssetImage(Assets.adminLogo), context);
    precacheImage(const AssetImage(Assets.operatorLogo), context);
    precacheImage(const AssetImage(Assets.userLogo), context);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_updateCanRegisterState);
    _codeController.removeListener(_updateCanRegisterState);
    _passwordController.removeListener(_updateCanRegisterState);

    _phoneController.dispose();
    _codeController.dispose();
    _passwordController.dispose();

    _phoneFocusNode.dispose();
    _codeFocusNode.dispose();
    _passwordFocusNode.dispose();

    _canRegisterNotifier.dispose();

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

                  // 构建手机号输入框容器
                  _buildInputPhone(),
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
                label: '管理员',
                role: RegisterRole.admin,
              ),
              _buildRoleItem(
                iconAsset: Assets.operatorLogo,
                label: '操作员',
                role: RegisterRole.operator,
              ),
              _buildRoleItem(
                iconAsset: Assets.userLogo,
                label: '个人',
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

  //-----------------------------------------手机号------------------------------------//

  /// 构建手机号输入框容器
  Widget _buildInputPhone() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).requestFocus(_phoneFocusNode),
      child: Stack(
        children: [
          // 毛玻璃背景
          Image.asset(Assets.glassLogo),

          // 手机号输入框
          Positioned(
            left: 22,
            right: 22,
            top: 0,
            bottom: 0,
            child: _inputPhone(),
          ),
        ],
      ),
    );
  }

  /// 构建手机号输入框
  Widget _inputPhone() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 电话图标
        Image.asset(Assets.phoneLogo),
        const SizedBox(width: 12),

        // 宽度撑开
        Expanded(
          child: TextField(
            controller: _phoneController,
            focusNode: _phoneFocusNode,
            keyboardType: TextInputType.phone,
            cursorColor: const Color(0xFF1464DF),
            style: const TextStyle(color: Colors.white, fontSize: 18),
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              isCollapsed: true,
              hintText: 'login_phone_hint'.tr,
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
            decoration: const InputDecoration(
              isCollapsed: true,
              hintText: '输入验证码',
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
          onTap: _getVerifyCode,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 2, vertical: 8),
            child: Text(
              '获取验证码',
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
            onPressed: canRegister ? _register : null,
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
            child: const Text('注册'),
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
        const Text(
          '已有账号?',
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
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text(
              '立即登录',
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
                ),
                TextSpan(text: 'and'.tr),
                TextSpan(
                  text: 'privacy_policy'.tr,
                  style: const TextStyle(color: Color(0xFF1464DF)),
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

  //------------------------------------逻辑判断------------------------------------//

  /// 判断是否可以注册
  bool _canRegister() {
    return _agreed &&
        _phoneController.text.trim().isNotEmpty &&
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
  void _getVerifyCode() {
    // TODO: 后面这里接获取验证码接口
    // 模拟获取验证码
    final String phone = _phoneController.text.trim();

    debugPrint('获取验证码：${_phoneController.text.trim()}');
  }

  /// 注册
  void _register() {
    // TODO: 后面这里接注册接口
    debugPrint('注册手机号：${_phoneController.text.trim()}');
    debugPrint('验证码：${_codeController.text.trim()}');
    debugPrint('密码：${_passwordController.text.trim()}');
    debugPrint('注册角色：$_role');

    // 临时逻辑：注册成功后可以回到登录页
    // Get.back();

    // 如果你暂时想直接复用登录逻辑，可以打开下面这一行
    // _logic.login();
  }
}

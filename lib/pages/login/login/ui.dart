// 登录页。
//
// 用户在这里输入账号密码并勾选协议；当前版本点击登录后进入主页面。
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infibo_app/api/dio/api/api_response.dart';
import 'package:infibo_app/api/dio/login/login_api.dart';
import 'package:infibo_app/api/dio/login/login_models.dart';
import 'package:infibo_app/constants/assets.dart';
import 'package:infibo_app/pages/login/login/logic.dart';
import 'package:infibo_app/constants/color.dart';
import 'package:infibo_app/stores/user_store.dart';
import 'package:infibo_app/utils/email_utils.dart';

//可选登录角色（管理员、操作员、用户）
// enum LoginRole { admin, operator, user }
//登录页UI
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  //登录页UI状态管理
  @override
  State<LoginPage> createState() => _LoginPageState();
}

//登录页UI状态管理
class _LoginPageState extends State<LoginPage> {
  // 仅用于开发联调。密码仍由后端 /auth/login 校验。
  static const String _developmentLoginAccount = '00000000';

  // //登录角色 默认值为管理员
  // LoginRole _role = LoginRole.admin;
  //是否同意协议 默认值为false（未同意）
  bool _agreed = false;
  //是否显示密码  默认值为true（隐藏密码框）
  //bool _obscurePassword = true;
  // 邮箱输入框控制器：读取用户在登录页输入的邮箱。
  final TextEditingController _emailController = TextEditingController();
  //密码输入框控制器
  final TextEditingController _passwordController = TextEditingController();
  // 邮箱输入框焦点，用于点击整个玻璃背景时聚焦输入框。
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final LoginLogic _logic = LoginLogic();
  final ValueNotifier<bool> _canLoginNotifier = ValueNotifier<bool>(false);
  bool _didPrecache = false;
  //登录按钮点击事件
  final LoginApi _loginApi = LoginApi();
  //防止用户频繁点击登录按钮
  bool _loggingIn = false;

  ///////////////////////////////////////////////////登录页UI构建///////////////////////////////////////////////////

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_updateCanLoginState);
    _passwordController.addListener(_updateCanLoginState);
    _updateCanLoginState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPrecache) return;
    _didPrecache = true;

    precacheImage(const AssetImage(Assets.logo), context);
    precacheImage(const AssetImage(Assets.glassLogo), context);
    precacheImage(const AssetImage(Assets.passwordLogo), context);
  }

  @override
  //在组件被销毁时,清理资源
  void dispose() {
    _emailController.removeListener(_updateCanLoginState);
    _passwordController.removeListener(_updateCanLoginState);
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _canLoginNotifier.dispose();
    super.dispose();
  }

  ///////////////////////////////////////////////////登录页界面布局///////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //当键盘弹出来时，页面不自动调整大小，保持原样显示
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
                  ///构建品牌页头
                  _buildBrandHeader(),
                  const SizedBox(height: 120),
                  _buildInputEmail(),
                  const SizedBox(height: 30),
                  _buildInputPassword(),
                  const SizedBox(height: 30),
                  _buildForgotPassword(),
                  const SizedBox(height: 54),

                  ///构建登录按钮
                  _buildLoginButton(),
                  const SizedBox(height: 24),

                  ///构建注册按钮
                  _buildRegisterButton(),
                  const SizedBox(height: 88),
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

  ///////////////////////////////////////////////////登录页组件构建///////////////////////////////////////////////////
  ///构建品牌页头
  Widget _buildBrandHeader() {
    return Image.asset(Assets.logo, fit: BoxFit.cover);
  }

  /// 构建邮箱输入框容器。
  Widget _buildInputEmail() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).requestFocus(_emailFocusNode),
      child: Stack(
        children: [
          //毛玻璃
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
        // 使用 Material 邮箱图标，不再依赖旧的手机号图片资源。
        const Icon(Icons.email_outlined, color: Color(0xFF8B8E98), size: 22),
        const SizedBox(width: 12),
        // 宽度撑开（不加会报错）
        Expanded(
          child: TextField(
            cursorColor: Color(0xFF1464DF),
            controller: _emailController,
            focusNode: _emailFocusNode,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            enableSuggestions: false,
            //输入框内容样式
            style: const TextStyle(color: Colors.white, fontSize: 18),
            textAlignVertical: TextAlignVertical.center,
            //输入框装饰
            decoration: InputDecoration(
              isCollapsed: true,
              hintText: 'login_email_hint'.tr,
              hintStyle: const TextStyle(
                color: Color.fromARGB(255, 129, 133, 145),
                fontSize: 18,
              ),
              border: InputBorder.none, //
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  ///构建密码输入框容器
  Widget _buildInputPassword() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).requestFocus(_passwordFocusNode),
      child: Stack(
        children: [
          //毛玻璃
          Image.asset(Assets.glassLogo),
          //密码输入框
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

  ///构建密码输入框
  Widget _inputPassword() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        //密码图标
        Image.asset(Assets.passwordLogo),
        const SizedBox(width: 12),
        // 宽度撑开（不加会报错）
        Expanded(
          child: TextField(
            cursorColor: Color(0xFF1464DF),
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            keyboardType: TextInputType.text,
            //输入框内容样式
            style: const TextStyle(color: Colors.white, fontSize: 18),
            textAlignVertical: TextAlignVertical.center,
            //输入框装饰
            decoration: InputDecoration(
              isCollapsed: true,
              hintText: 'login_password_hint'.tr,
              hintStyle: const TextStyle(
                color: Color.fromARGB(255, 129, 133, 145),
                fontSize: 18,
              ),
              border: InputBorder.none, //
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  ///构建忘记密码按钮
  Widget _buildForgotPassword() {
    return Padding(
      padding: const EdgeInsets.only(right: 28),
      child: Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          //点击事件
          //点击忘记密码按钮，跳转到忘记密码页面
          onPressed: () {},
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            minimumSize: const Size(48, 48),
            tapTargetSize: MaterialTapTargetSize.padded,
          ),
          child: Text(
            'forgot_password'.tr,
            style: TextStyle(color: Color(0xFFC9CBD2), fontSize: 17),
          ),
        ),
      ),
    );
  }

  //////////////////////////////////////////登录按钮///////////////////////////////////////////////////
  ///构建登录按钮
  Widget _buildLoginButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: _canLoginNotifier,
      builder: (BuildContext context, bool canLogin, _) {
        return SizedBox(
          width: 480,
          height: 64,
          child: ElevatedButton(
            // canLogin 为 true 时可以点击，执行 _logic.login
            // canLogin 为 false 时按钮禁用
            onPressed: canLogin ? _login : null,
            style: ElevatedButton.styleFrom(
              // 登录按钮背景颜色
              backgroundColor: const Color(0xFF1464DF),

              // 登录按钮禁用背景颜色
              disabledBackgroundColor: const Color.fromARGB(255, 2, 43, 106),

              // 登录按钮文本颜色
              foregroundColor: Colors.white,

              // 登录按钮禁用文本颜色
              disabledForegroundColor: Colors.grey,

              // 登录按钮阴影
              elevation: 0,

              // 登录按钮形状
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),

              // 按钮内部边距
              padding: EdgeInsets.zero,

              // 文字样式
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            child: Text('login'.tr),
          ),
        );
      },
    );
  }

  //创建登录方法
  /// 登录
  Future<void> _login() async {
    if (_loggingIn) return;
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isEmpty) {
      Get.snackbar('提示', '请输入邮箱');
      return;
    }

    // 固定联调账号不是邮箱，但仍然必须走后端登录接口。
    if (email != _developmentLoginAccount && !isValidEmail(email)) {
      Get.snackbar('提示', '请输入正确的邮箱');
      return;
    }

    if (password.isEmpty) {
      Get.snackbar('提示', '请输入密码');
      return;
    }

    setState(() => _loggingIn = true);

    try {
      final ApiResponse<LoginResult> result = await _loginApi.login(
        email: email,
        password: password,
      );

      debugPrint('登录接口返回 code：${result.code}');
      debugPrint('登录接口返回 success：${result.isSuccess}');
      debugPrint('登录接口返回 message：${result.message}');

      if (result.isSuccess) {
        final LoginResult? user = result.data;
        if (user == null) {
          Get.snackbar('提示', '登录成功，但用户信息为空');
          return;
        }
        // 登录成功，保存用户信息到 UserStore
        // UserStore.instance.setUser(user);
        await UserStore.instance.setUser(user);

        debugPrint('当前用户ID:${user.id}');
        debugPrint('当前用户邮箱:${user.email}');
        debugPrint('当前用户角色:${user.role}');

        Get.snackbar('提示', result.message.isEmpty ? '登录成功' : result.message);

        // 登录成功后跳转主页。
        _logic.login();
      } else {
        Get.snackbar('提示', result.message.isEmpty ? '登录失败' : result.message);
      }
    } catch (e) {
      debugPrint('登录接口异常：$e');
      Get.snackbar('错误', '登录请求失败：$e');
    } finally {
      if (mounted) {
        setState(() => _loggingIn = false);
      }
    }
  }

  ///构建注册按钮
  Widget _buildRegisterButton() {
    return TextButton(
      onPressed: () => Get.toNamed('/register'),
      style: TextButton.styleFrom(
        minimumSize: const Size(96, 48),
        tapTargetSize: MaterialTapTargetSize.padded,
      ),
      child: Text(
        'register'.tr,
        style: TextStyle(
          color: Color(0xFFD9DAE0),
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  ///构建用户协议行
  Widget _buildAgreementRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            setState(() => _agreed = !_agreed);
            _updateCanLoginState();
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
                    _updateCanLoginState();
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
                  style: TextStyle(color: Color(0xFF1464DF)),
                ),
                TextSpan(text: 'and'.tr),
                TextSpan(
                  text: 'privacy_policy'.tr,
                  style: TextStyle(color: Color(0xFF1464DF)),
                ),
              ],
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFB3B6C0),
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  ///判断是否可以登录
  bool _canLogin() {
    //判断是否同意用户协议
    return _agreed &&
        _emailController.text.trim().isNotEmpty &&
        _passwordController.text.trim().isNotEmpty;
  }

  void _updateCanLoginState() {
    final bool nextValue = _canLogin();
    if (_canLoginNotifier.value == nextValue) return;
    _canLoginNotifier.value = nextValue;
  }
}

//   ///构建角色选择器
//   Widget _buildRoleSelector()
//   {
//     return Stack(
//       children: [
//         //毛玻璃
//         Image.asset(Assets.glassLogo),
//         Positioned(
//                   top: 8,
//                   bottom: 8,   // 距离底部10
//                   left: 10,//距离左侧15
//                   right: 10,//距离右侧15
//       child: Row(
//           children: [
//             _buildRoleItem(
//               iconAsset: Assets.adminLogo,
//               label: '管理员',
//               role: LoginRole.admin,
//             ),
//             _buildRoleItem(
//               iconAsset: Assets.operatorLogo,
//               label: '操作员',
//               role: LoginRole.operator,
//             ),
//             _buildRoleItem(
//               iconAsset: Assets.userLogo,
//               label: '个人',
//               role: LoginRole.user,
//             ),
//           ],
//         ),
//         )
//       ],
//     );
//   }
// //构建管理员，操作员，个人选择器项
//   Widget _buildRoleItem({
//     required String iconAsset,
//     required String label,
//     required LoginRole role,
//   }) {
//     final bool selected = _role == role;
//     //根据是否选中，设置颜色
//     final Color color = Colors.white;

//     return Expanded(
//       child: InkWell(
//         borderRadius: BorderRadius.circular(23),
//         onTap: () {
//           setState(() {
//             _role = role;
//           });
//         },
//         //根据是否选中，设置背景颜色
//         child: AnimatedContainer(
//           //duration 动画持续时间
//           duration: const Duration(milliseconds: 200),
//           height: 45,
//           decoration: BoxDecoration(
//             //根据是否选中，设置背景颜色
//             color: selected ? const Color.fromARGB(255, 62, 62, 64) : Colors.transparent,
//             borderRadius: BorderRadius.circular(23),
//           ),
//           child: Row(
//             //居中对齐
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               //图标
//               Image.asset(
//                 iconAsset,
//                 width: 22,
//                 height: 22,
//                 color: color,
//               ),
//               //文本间距
//               const SizedBox(width: 9),
//               Flexible(
//                 //文本
//                 child: Text(
//                   label,
//                   //文本溢出处理
//                   overflow: TextOverflow.ellipsis,
//                   //文本样式
//                   style: TextStyle(
//                     color: color,
//                     fontSize: 16,
//                     //根据是否选中，设置字体粗细
//                     //选中时，字体粗细为w800
//                     //未选中时，字体粗细为w400
//                     fontWeight: selected ? FontWeight.w800 : FontWeight.w400,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

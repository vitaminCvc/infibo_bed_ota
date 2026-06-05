// 登录页。
//
// 用户在这里输入账号密码并勾选协议；当前版本点击登录后进入主页面。
import 'dart:ui';

import 'package:flutter/gestures.dart';
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

                  ///构建邮箱输入框容器
                  _buildInputEmail(),
                  const SizedBox(height: 30),

                  ///构建密码输入框容器
                  _buildInputPassword(),
                  const SizedBox(height: 30),

                  ///构建忘记密码链接
                  _buildForgotPassword(),
                  const SizedBox(height: 54),

                  ///构建登录按钮
                  _buildLoginButton(),
                  const SizedBox(height: 24),

                  ///构建注册按钮
                  _buildRegisterButton(),
                  const SizedBox(height: 88),

                  ///构建同意协议行组件
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
        const Icon(Icons.email_outlined, color: Color(0xFF696969), size: 24),
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
          onPressed: () => Get.toNamed('/forgetpassword'),
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
      /////Get.snackbar风格修改：
      /////保留 Get.snackbar，参数加 snackPosition: SnackPosition.BOTTOM、backgroundColor: const Color(0xFF323232)、colorText: Colors.white、margin: const EdgeInsets.all(16)、borderRadius: 4。
      Get.snackbar(
        '提示',
        '请输入邮箱',

        backgroundColor: const Color(0xFF323232),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 4,
      );
      return;
    }

    // 固定联调账号不是邮箱，但仍然必须走后端登录接口。
    if (email != _developmentLoginAccount && !isValidEmail(email)) {
      /////Get.snackbar风格修改：
      /////保留 Get.snackbar，参数加 snackPosition: SnackPosition.BOTTOM、backgroundColor: const Color(0xFF323232)、colorText: Colors.white、margin: const EdgeInsets.all(16)、borderRadius: 4。
      Get.snackbar(
        '提示',
        '请输入正确的邮箱',

        backgroundColor: const Color(0xFF323232),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 4,
      );
      return;
    }

    if (password.isEmpty) {
      /////Get.snackbar风格修改：
      /////保留 Get.snackbar，参数加 snackPosition: SnackPosition.BOTTOM、backgroundColor: const Color(0xFF323232)、colorText: Colors.white、margin: const EdgeInsets.all(16)、borderRadius: 4。
      Get.snackbar(
        '提示',
        '请输入密码',

        backgroundColor: const Color(0xFF323232),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 4,
      );
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
          /////Get.snackbar风格修改：
          /////保留 Get.snackbar，参数加 snackPosition: SnackPosition.BOTTOM、backgroundColor: const Color(0xFF323232)、colorText: Colors.white、margin: const EdgeInsets.all(16)、borderRadius: 4。
          Get.snackbar(
            '提示',
            '登录成功，但用户信息为空',

            backgroundColor: const Color(0xFF323232),
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
            borderRadius: 4,
          );
          return;
        }
        // 登录成功，保存用户信息到 UserStore
        // UserStore.instance.setUser(user);
        await UserStore.instance.setUser(user);

        debugPrint('当前用户ID:${user.id}');
        debugPrint('当前用户邮箱:${user.email}');
        debugPrint('当前用户角色:${user.role}');

        /////Get.snackbar风格修改：
        /////保留 Get.snackbar，参数加 snackPosition: SnackPosition.BOTTOM、backgroundColor: const Color(0xFF323232)、colorText: Colors.white、margin: const EdgeInsets.all(16)、borderRadius: 4。
        Get.snackbar(
          '提示',
          result.message.isEmpty ? '登录成功' : result.message,

          backgroundColor: const Color(0xFF323232),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 4,
        );

        // 登录成功后跳转主页。
        _logic.login();
      } else {
        /////Get.snackbar风格修改：
        /////保留 Get.snackbar，参数加 snackPosition: SnackPosition.BOTTOM、backgroundColor: const Color(0xFF323232)、colorText: Colors.white、margin: const EdgeInsets.all(16)、borderRadius: 4。
        Get.snackbar(
          '提示',
          result.message.isEmpty ? '登录失败' : result.message,

          backgroundColor: const Color(0xFF323232),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 4,
        );
      }
    } catch (e) {
      debugPrint('登录接口异常：$e');
      /////Get.snackbar风格修改：
      /////保留 Get.snackbar，参数加 snackPosition: SnackPosition.BOTTOM、backgroundColor: const Color(0xFF323232)、colorText: Colors.white、margin: const EdgeInsets.all(16)、borderRadius: 4。
      Get.snackbar(
        '错误',
        '登录请求失败：$e',

        backgroundColor: const Color(0xFF323232),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 4,
      );
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

  ///构建用户协议弹窗（同意协议，隐私弹窗）
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
              text: 'agree_prefix'.tr, //我已阅读并同意
              children: [
                TextSpan(
                  text: 'user_agreement'.tr, //用户协议
                  style: TextStyle(color: Color(0xFF1464DF)),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      _showAgreementDialog(
                        title: '用户协议',
                        content: _userAgreementContent,
                      );
                    },
                ),
                TextSpan(text: 'and'.tr), //和
                TextSpan(
                  text: 'privacy_policy'.tr,
                  style: const TextStyle(color: Color(0xFF1464DF)),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      _showAgreementDialog(
                        title: '隐私政策',
                        content: _privacyPolicyContent,
                      );
                    },
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

  ////创建用户协议内容
  static const String _userAgreementContent = '''欢迎您使用本平台提供的产品与服务。

本《用户协议》是您与平台运营方之间就注册、登录、使用本平台相关服务所订立的协议。请您在使用本平台服务前，仔细阅读并充分理解本协议的全部内容。

一、服务说明

1.1 本平台为用户提供账号登录、用户管理、设备操作、疗程记录、数据展示等相关服务。

1.2 平台提供的部分功能可能需要您按照页面提示填写必要信息，或根据实际使用场景完成相关操作。

1.3 平台有权根据业务发展、产品升级或法律法规要求，对服务内容进行调整、更新或暂停。

二、用户账号

2.1 用户应当提供真实、准确、完整的信息完成注册或登录。

2.2 用户应妥善保管自己的账号、密码及验证码信息，不得将账号转让、出借或提供给他人使用。

2.3 因用户自身原因导致账号信息泄露、被他人使用或产生损失的，由用户自行承担相应责任。

三、使用规范

3.1 用户在使用本平台服务时，应遵守国家法律法规、社会公德以及平台相关规则。

3.2 用户不得利用本平台从事任何违法、违规、损害平台或第三方合法权益的行为。

3.3 用户不得通过非法方式干扰平台正常运行，包括但不限于恶意攻击、破解、篡改、反向工程等行为。

四、设备与数据

4.1 用户在使用设备相关功能时，应按照平台提示和实际使用规范进行操作。

4.2 平台展示的数据、记录或分析结果仅用于服务展示和辅助参考，不应作为唯一判断依据。

4.3 因用户误操作、设备异常、网络异常或其他不可抗力因素导致的服务异常，平台将在合理范围内协助处理。

五、知识产权

5.1 本平台中的界面设计、文字、图片、图标、程序代码、数据结构等内容，除法律另有规定或另有说明外，其知识产权归平台运营方或相关权利人所有。

5.2 未经平台书面许可，用户不得复制、修改、传播、出售或用于其他商业用途。

六、协议变更

6.1 平台有权根据业务发展或法律法规变化，对本协议内容进行更新。

6.2 协议更新后，平台将通过页面提示、公告或其他合理方式通知用户。

6.3 用户继续使用本平台服务，即视为接受更新后的协议内容。

七、免责声明

7.1 因网络故障、系统维护、设备故障、第三方服务异常、不可抗力等原因导致服务中断或数据异常的，平台将在合理范围内尽快修复。

7.2 在法律允许范围内，平台不对因用户自身原因或不可抗力造成的损失承担责任。

八、其他

8.1 本协议的解释、效力及纠纷处理，适用中华人民共和国法律。

8.2 如因本协议产生争议，双方应友好协商解决；协商不成的，可依法向有管辖权的人民法院提起诉讼。

感谢您使用本平台。''';
  ////创建隐私政策内容
  static const String _privacyPolicyContent = '''
欢迎您使用本平台。

我们非常重视您的个人信息和隐私保护。本《隐私政策》用于说明我们在您使用本平台服务时，如何收集、使用、存储、保护和处理您的相关信息。请您在使用本平台前，仔细阅读并充分理解本政策内容。

一、我们收集的信息

在您使用本平台服务过程中，我们可能会根据实际功能需要收集以下信息：

1.1 账号信息
包括手机号、账号、密码、验证码、用户角色等用于注册、登录和身份验证的信息。

1.2 用户资料
包括姓名、性别、年龄、联系方式等您主动填写或授权提供的信息。

1.3 设备与使用信息
包括设备型号、系统版本、应用版本、操作记录、功能使用记录、设备连接状态等信息。

1.4 疗程与记录信息
包括用户选择的疗程方案、设备参数、运行记录、疗程结果、历史记录等信息。

1.5 日志信息
当平台发生异常或需要排查问题时，我们可能会收集必要的运行日志、错误信息和操作记录。

二、我们如何使用信息

我们收集的信息将主要用于以下目的：

2.1 为您提供注册、登录、用户管理等基础服务。

2.2 为您提供设备控制、参数配置、疗程记录、数据展示等功能。

2.3 保障平台安全稳定运行，排查系统异常、设备异常或操作问题。

2.4 改进平台功能、优化用户体验和提升服务质量。

2.5 遵守法律法规、监管要求或处理相关争议。

三、信息的存储

3.1 我们会在实现服务目的所必要的期限内保存您的个人信息。

3.2 超出必要期限后，我们将根据法律法规要求删除或匿名化处理相关信息。

3.3 如法律法规对保存期限另有规定，我们将按照相关规定执行。

四、信息的保护

4.1 我们会采取合理的安全措施保护您的个人信息，防止信息被未经授权访问、使用、泄露、修改或损坏。

4.2 我们会对重要信息采取加密、权限控制、访问限制等方式进行保护。

4.3 尽管我们会尽力保护您的信息安全，但由于互联网环境并非绝对安全，我们无法保证信息传输或存储过程中的绝对安全。

五、信息的共享与披露

我们不会随意向第三方提供您的个人信息，但以下情况除外：

5.1 已获得您的明确同意或授权。

5.2 根据法律法规、司法机关或行政机关要求需要提供。

5.3 为实现平台服务所必需，与合作服务方进行必要的信息处理，但我们会要求其遵守保密和安全保护义务。

5.4 为保护平台、用户或其他第三方的合法权益，在合理必要范围内进行披露。

六、您的权利

您有权依法对您的个人信息进行查询、更正、删除或撤回授权。

如您需要注销账号、删除信息或反馈隐私相关问题，可通过平台提供的联系方式与我们联系。

七、未成年人信息保护

若您为未成年人，应在监护人指导和同意下使用本平台服务。

我们不会主动收集未成年人的个人信息。如发现未经监护人同意收集了未成年人信息，我们将依法及时处理。

八、政策更新

我们可能会根据法律法规变化、业务调整或产品功能变化，对本隐私政策进行更新。

更新后的隐私政策将在平台内进行提示或公告。您继续使用本平台服务，即视为接受更新后的政策内容。

九、联系我们

如您对本隐私政策或个人信息保护有任何疑问、意见或建议，可通过平台公布的联系方式与我们联系。

感谢您对本平台的信任。
''';

  ///毛玻璃方法
  void _showAgreementDialog({required String title, required String content}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: title,

      //控制弹窗外面背景变暗程度
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

// 通用毛玻璃方法
// 通用毛玻璃卡片
Widget _buildGlassCard({
  required Widget child,
  //卡片宽度
  //卡片高度
  double width = 400,
  double height = 720,
  //更改毛玻璃边框圆角
  double radius = 18,
  EdgeInsets padding = const EdgeInsets.all(22),
  List<Color>? gradientColors,
}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: BackdropFilter(
      //控制毛玻璃模糊度，数值越大，模糊度越高
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
            //
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

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
        _showAgreementDialog(title: '用户协议', content: _userAgreementContent);
      };
    _privacyPolicyRecognizer = TapGestureRecognizer()
      ..onTap = () {
        _showAgreementDialog(title: '隐私政策', content: _privacyPolicyContent);
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
          // 点击获取验证码按钮，发送验证码
          onTap: _sendingCode ? null : _getVerifyCode,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2, vertical: 8),
            child: Text(
              _sendingCode ? '发送中...' : '获取验证码',
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
            child: Text(_registering ? '注册中...' : '注册'),
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

  static const String _privacyPolicyContent = '''欢迎您使用本平台。

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
      Get.snackbar('提示', '请先输入邮箱', backgroundColor: Colors.white);
      return;
    }

    // 发送验证码前先校验邮箱，避免把明显无效的地址提交给后端。
    if (!isValidEmail(email)) {
      Get.snackbar('提示', '请输入正确的邮箱', backgroundColor: Colors.white);
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
      debugPrint('后端返回的邮箱：${result.data}');

      Get.snackbar(
        '提示',
        '验证码已发送，后端收到邮箱：${result.data}',
        backgroundColor: Colors.white,
      );
    } else {
      Get.snackbar(
        '提示',
        result.message.isEmpty ? '验证码发送失败' : result.message,
        backgroundColor: Colors.white,
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
      Get.snackbar('提示', '请输入正确的邮箱', backgroundColor: Colors.white);
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
      Get.snackbar(
        '提示',
        result.message.isEmpty ? '注册成功' : result.message,
        backgroundColor: Colors.white,
      );
    } else {
      Get.snackbar(
        '提示',
        result.message.isEmpty ? '注册  失败' : result.message,
        backgroundColor: Colors.white,
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

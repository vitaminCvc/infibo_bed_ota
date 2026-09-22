// 选择用户页面。
//
// 用户在这里选择或新增接受理疗的用户，然后带着当前模式或自定义方案进入启动理疗页。
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:infibo_app/components/designCanvas/design.dart';
import 'package:infibo_app/components/index.dart';
import 'package:infibo_app/constants/assets.dart';
import 'package:infibo_app/constants/layout.dart';
import 'package:infibo_app/pages/choseusers/Popup/user_Popup.dart';
import 'package:infibo_app/pages/choseusers/Popup/user_Popup_logic.dart';
import 'package:infibo_app/pages/choseusers/logic.dart';
import 'package:infibo_app/utils/age_utils.dart';
import 'package:infibo_app/utils/gender_utils.dart';
import 'package:infibo_app/utils/phone_utils.dart';

// 选择用户页面。
class ChoseUsersPage extends StatefulWidget {
  const ChoseUsersPage({super.key, this.logic});

  final ChoseUsersLogic? logic;

  @override
  State<ChoseUsersPage> createState() => _ChoseUsersPageState();
}

class _ChoseUsersPageState extends State<ChoseUsersPage> {
  static const double _designWidth = 800;
  static const double _minPageScale = 0.72;

  // 选择用户逻辑。
  late final ChoseUsersLogic _logic;
  // 用户列表滚动控制器。
  final ScrollController _listController = ScrollController();
  // 搜索框控制器。
  final TextEditingController _searchController = TextEditingController();
  // 是否准备就绪。
  bool _isReady = false;
  @override
  // 进行初始化
  void initState() {
    super.initState();
    _logic = widget.logic ?? ChoseUsersLogic();
    // 初始化用户列表
    _loadUsers();
  }

  @override
  // 销毁资源
  void dispose() {
    _listController.dispose();
    _searchController.dispose();
    // 释放数据库资源
    unawaited(_logic.dispose());
    super.dispose();
  }

  @override
  // 构建页面
  Widget build(BuildContext context) {
    final AppLayoutMetrics layout = AppLayoutScope.of(context);
    final double scale =
        ((MediaQuery.sizeOf(context).width - 32) / _designWidth)
            .clamp(_minPageScale, 1.0)
            .toDouble();
    final double planListHeight = layout.is16x9 ? 900 : 800;
    final double listBottom =
        layout.designHeight -
        75 -
        (layout.standardContentY(220) + planListHeight) * scale;
    //构建页表头
    return AppHeaderPage(
      resizeToAvoidBottomInset: false,
      // 点击添加用户按钮时调用
      children: [
        // 固定内容区域
        Positioned(
          left: 44,
          top: layout.viewportContentY(145 - layout.contentTopOffset),
          right: 44,
          child: _buildFixedContent(layout),
        ),
        Positioned(
          top: layout.viewportContentY(
            292 - layout.contentTopOffset,
          ), //用户列表顶部距离
          left: 44,
          right: 44,
          bottom: listBottom,
          child: _buildUserList(),
        ),
        _buildAddUserButtonLayer(layout, scale),
      ],
    );
  }

  /// 使用与自定义方案页相同的画布缩放和定位规则放置底部按钮。
  Widget _buildAddUserButtonLayer(AppLayoutMetrics layout, double scale) {
    return Positioned.fill(
      top: 75,
      child: Center(
        child: Column(
          children: [
            SizedBox(
              width: _designWidth * scale,
              height: layout.standardContentHeight * scale,
              child: FittedBox(
                fit: BoxFit.contain,
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: _designWidth,
                  height: layout.standardContentHeight,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 175,
                        bottom: layout.is16x9 ? 46 : 34,
                        child: _buildAddUserButton(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 从数据库加载用户。
  Future<void> _loadUsers() async {
    await _logic.init();
    if (!mounted) return;
    setState(() => _isReady = true);
  }

  /// 打开添加用户弹窗并保存新增用户。
  Future<void> _handleAddUser() async {
    if (!_isReady) return;
    final UserPopupData? user = await showAddUserPopup(context);
    if (!mounted || user == null) return;

    try {
      await _logic.addUser(
        name: user.name,
        gender: user.gender,
        age: user.age.toString(),
        phone: user.phone,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${'add_user_failed'.tr}: $error')),
      );
      return;
    }

    if (!mounted) return;
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToUser(0);
    });
  }

  /// 搜索并定位用户。
  void _searchUser(String keyword) {
    if (!_isReady) return;
    final int index = _logic.findUserIndex(keyword);
    if (index < 0) return;
    setState(() => _logic.highlightUser(index));
    _scrollToUser(index);
  }

  /// 删除用户。
  Future<void> _deleteUser(int index) async {
    await _logic.deleteUser(index);
    if (!mounted) return;
    setState(() {});
  }

  /// 滚动到指定用户。
  void _scrollToUser(int index) {
    if (!_listController.hasClients) return;
    const double itemHeight = 112;
    final double targetOffset = (index * itemHeight).toDouble();
    final double maxOffset = _listController.position.maxScrollExtent;
    _listController.animateTo(
      targetOffset.clamp(0, maxOffset),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  /// 构建固定区域，标题和搜索框不会跟着列表滚动。
  Widget _buildFixedContent(AppLayoutMetrics layout) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTitle(),
        SizedBox(height: layout.is16x9 ? 44 : 39),
        _buildSearchBar(),
      ],
    );
  }

  /// 构建页面标题。
  Widget _buildTitle() {
    return Text(
      'choose_therapy_user'.tr,
      style: TextStyle(
        color: Color.fromARGB(255, 255, 255, 255),
        fontSize: 26,
        fontFamily: 'Microsoft YaHei',
        fontWeight: FontWeight.w500,
        height: 1,
      ),
      textAlign: TextAlign.center,
      softWrap: true,
    );
  }

  /// 构建搜索框。
  Widget _buildSearchBar() {
    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.centerLeft, //居中对齐
        children: [
          // 搜索框背景铺满整个区域
          Positioned.fill(
            // 搜索框背景
            child: Image.asset(Assets.choseUserSearchBg, fit: BoxFit.fill),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 22, right: 22),
            child: Row(
              children: [
                // 搜索图标
                Image.asset(Assets.choseUserSearchIcon, width: 16, height: 16),
                const SizedBox(width: 10),
                Expanded(
                  // 搜索输入框
                  child: TextField(
                    controller: _searchController,
                    cursorColor: Colors.white,
                    textInputAction: TextInputAction.search, //搜索按钮
                    onSubmitted: _searchUser,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Microsoft YaHei',
                    ),
                    decoration: InputDecoration(
                      // 搜索输入框样式
                      isDense: true,
                      border: InputBorder.none,
                      hintText: 'search_user_hint'.tr,
                      hintStyle: const TextStyle(
                        color: Color(0xFF8B8E98),
                        fontSize: 16,
                        fontFamily: 'Microsoft YaHei',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建可滑动用户列表。
  Widget _buildUserList() {
    if (!_isReady) {
      return const SizedBox.shrink();
    }
    return ListView.separated(
      controller: _listController,
      padding: EdgeInsets.zero,
      itemCount: _logic.users.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final UserItemData item = _logic.users[index];
        return Slidable(
          key: ValueKey(item.id ?? '${item.name}-$index'),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.22,
            children: [
              CustomSlidableAction(
                onPressed: (_) => _deleteUser(index),
                backgroundColor: const Color(0xFFE8473B),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      Assets.customizedDeleteIcon,
                      width: 16,
                      height: 16,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'delete'.tr,
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          child: _buildUserCard(item, index, _logic.highlightedIndex == index),
        );
      },
    );
  }

  /// 构建底部添加用户按钮。
  Widget _buildAddUserButton() {
    return SizedBox(
      width: 450,
      height: 52,
      child: ElevatedButton(
        onPressed: _handleAddUser,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFF1F74E8),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontFamily: 'Microsoft YaHei',
            fontWeight: FontWeight.w800,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Baseline(
              baseline: 18,
              baselineType: TextBaseline.alphabetic,
              child: Image.asset(
                Assets.choseUserAddIcon,
                width: 20,
                height: 20,
              ),
            ),
            const SizedBox(width: 8),
            Text('add_user'.tr),
          ],
        ),
      ),
    );
  }

  /// 构建用户卡片。
  Widget _buildUserCard(UserItemData item, int index, bool isHighlighted) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 96,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: isHighlighted
            ? const [
                BoxShadow(
                  color: Color.fromARGB(102, 173, 182, 193),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Image.asset(Assets.choseUserItemBg, fit: BoxFit.fill),
          ),
          if (isHighlighted)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(width: 1.5),
                ),
              ),
            ),
          Positioned(left: 20, top: 24, child: _buildAvatar(item.name, index)),
          Positioned(
            left: 88,
            right: 124,
            top: 0,
            bottom: 0,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _buildUserInfo(item),
            ),
          ),
          Positioned(right: 20, top: 32, child: _buildSelectButton(item)),
        ],
      ),
    );
  }

  /// 构建用户头像。
  Widget _buildAvatar(String name, int index) {
    final List<Color> colors = [
      const Color(0xFF4A5B65),
      const Color(0xFF6A717D),
      const Color(0xFF4E6476),
      const Color(0xFF405D52),
      const Color(0xFF5A4A60),
    ];
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors[index % colors.length],
            ),
            child: Center(
              child: Text(
                name.characters.first,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontFamily: 'Microsoft YaHei',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Image.asset(Assets.choseUserAvatarFrame, fit: BoxFit.fill),
          ),
        ],
      ),
    );
  }

  /// 构建用户姓名、性别、年龄、手机号。
  Widget _buildUserInfo(UserItemData item) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            item.name,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Microsoft YaHei',
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        ),
        const SizedBox(width: 12),
        _buildInfoBadge(_localizedGender(item.gender)),
        const SizedBox(width: 8),
        _buildInfoBadge(_localizedAge(item.age)),
        const SizedBox(width: 16),
        Text(
          maskPhoneNumber(item.phone),
          style: const TextStyle(
            color: Color(0xFF8B8E98),
            fontSize: 13,
            fontFamily: 'Microsoft YaHei',
            height: 1,
          ),
        ),
      ],
    );
  }

  String _localizedGender(String genderRaw) {
    return localizedGenderText(genderRaw);
  }

  String _localizedAge(String ageRaw) {
    final String localeCode = Get.locale?.languageCode ?? 'zh';
    return formatAgeForLanguage(ageRaw, localeCode);
  }

  /// 构建性别、年龄标签。
  Widget _buildInfoBadge(String text) {
    return SizedBox(
      width: 48,
      height: 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Image.asset(Assets.choseUserInfoBg, fit: BoxFit.fill),
          ),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontFamily: 'Microsoft YaHei',
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建选择按钮。
  Widget _buildSelectButton(UserItemData item) {
    return SizedBox(
      width: 88,
      height: 32,
      child: ElevatedButton.icon(
        onPressed: () => _logic.selectUser(item),
        icon: const Icon(Icons.check_circle_outline, size: 16),
        label: Text('select'.tr),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          elevation: 0,
          backgroundColor: const Color(0xFF1876F2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontFamily: 'Microsoft YaHei',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

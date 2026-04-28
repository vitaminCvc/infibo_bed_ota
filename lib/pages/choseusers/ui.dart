import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:infibo_app/components/index.dart';
import 'package:infibo_app/constants/assets.dart';
import 'package:infibo_app/pages/choseusers/logic.dart';

// 选择用户页面。
class ChoseUsersPage extends StatefulWidget {
  const ChoseUsersPage({super.key});

  @override
  State<ChoseUsersPage> createState() => _ChoseUsersPageState();
}

class _ChoseUsersPageState extends State<ChoseUsersPage> {
  // 选择用户逻辑。
  final ChoseUsersLogic _logic = ChoseUsersLogic();
  // 用户列表滚动控制器。
  final ScrollController _listController = ScrollController();
  // 搜索框控制器。
  final TextEditingController _searchController = TextEditingController();
  // 姓名输入框控制器。
  final TextEditingController _nameController = TextEditingController();
  // 年龄输入框控制器。
  final TextEditingController _ageController = TextEditingController();
  // 手机号输入框控制器。
  final TextEditingController _phoneController = TextEditingController();

  // 添加用户弹窗是否显示。
  bool _showAddPopup = false;
  // 是否准备就绪。
  bool _isReady = false;
  //设置性别的默认值为男
  String _selectedGender = '男';

  @override
  //进行初始化
  void initState() {
    super.initState();
    // 初始化用户列表
    _loadUsers();
  }

  @override
  //
  void dispose() {
    _listController.dispose();
    _searchController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    // 释放数据库资源
    unawaited(_logic.dispose());
    super.dispose();
  }

  @override
  // 构建页面
  Widget build(BuildContext context) {
    //构建页表头
    return AppHeaderPage(
      // 点击添加用户按钮时调用
      onAddTap: _toggleAddPopup,
      children: [
        // 固定内容区域
        Positioned(left: 44, top: 145, right: 44, child: _buildFixedContent()),
        Positioned(
          top: 292,//用户列表顶部距离
          left: 44,
          right: 44,
          bottom: 24,
          child: _buildUserList(),
        ),
        if (_showAddPopup)
          Positioned(right: 40, top: 92, child: _buildAddUserPopup()),
      ],
    );
  }

  /// 显示或隐藏添加用户弹窗。
  void _toggleAddPopup() {
    setState(() {
      _showAddPopup = !_showAddPopup;
      if (_showAddPopup) _selectedGender = '男';
    });
  }

  /// 从数据库加载用户。
  Future<void> _loadUsers() async {
    await _logic.init();
    if (!mounted) return;

    setState(() => _isReady = true);
  }

  /// 保存新增用户。
  Future<void> _saveUser() async {
    if (!_isReady) return;

    final String name = _nameController.text.trim();
    final String age = _ageController.text.trim();
    final String phone = _phoneController.text.trim();

    if (name.isEmpty || age.isEmpty || phone.isEmpty) return;

    await _logic.addUser(
      name: name,
      gender: _selectedGender,
      age: age,
      phone: phone,
    );
    if (!mounted) return;

    setState(() {
      _showAddPopup = false;
      _selectedGender = '男';
      _nameController.clear();
      _ageController.clear();
      _phoneController.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToUser(_logic.users.length - 1);
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
  Widget _buildFixedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [_buildTitle(), const SizedBox(height: 39), _buildSearchBar()],
    );
  }

  /// 构建页面标题。
  Widget _buildTitle() {
    return const Text(
      '选择理疗用户',
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
        alignment: Alignment.centerLeft,//居中对齐
        children: [
          // 搜索框背景沾满整个区域
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
                    textInputAction: TextInputAction.search,//搜索按钮
                    onSubmitted: _searchUser,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Microsoft YaHei',
                    ),
                    decoration: const InputDecoration(
                      // 搜索输入框样式
                      //
                      isDense: true,
                      border: InputBorder.none,
                      hintText: '输入用户姓名或手机号',
                      hintStyle: TextStyle(
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

  /// 构建可滚动用户列表。
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
              SlidableAction(
                onPressed: (_) => _deleteUser(index),
                backgroundColor: const Color(0xFFE8473B),
                foregroundColor: Colors.white,
                icon: Icons.delete_outline,
                label: '删除',
                borderRadius: BorderRadius.circular(18),
              ),
            ],
          ),
          child: _buildUserCard(item, index, _logic.highlightedIndex == index),
        );
      },
    );
  }

  /// 构建添加用户弹窗。
  Widget _buildAddUserPopup() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 260,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2028),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF3A3D49)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x99000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPopupInput(controller: _nameController, hintText: '姓名'),
              const SizedBox(height: 10),
              _buildGenderSelector(),
              const SizedBox(height: 10),
              _buildPopupInput(
                controller: _ageController,
                hintText: '年龄',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 10),
              _buildPopupInput(
                controller: _phoneController,
                hintText: '手机号',
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 36,
                child: ElevatedButton(
                  onPressed: _saveUser,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF1876F2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontFamily: 'Microsoft YaHei',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('保存'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建性别点选。
  Widget _buildGenderSelector() {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2C35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF3A3D49)),
      ),
      child: Row(
        children: [
          const Text(
            '性别',
            style: TextStyle(
              color: Color(0xFF8B8E98),
              fontSize: 14,
              fontFamily: 'Microsoft YaHei',
            ),
          ),
          const Spacer(),
          _buildGenderOption('男'),
          const SizedBox(width: 8),
          _buildGenderOption('女'),
        ],
      ),
    );
  }

  /// 构建单个性别选项。
  Widget _buildGenderOption(String value) {
    final bool isSelected = _selectedGender == value;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _selectedGender = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 44,
        height: 26,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1876F2) : const Color(0xFF3A3D49),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1876F2)
                : const Color(0xFF4A4D59),
          ),
        ),
        child: Center(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Microsoft YaHei',
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }

  /// 构建弹窗输入框。
  Widget _buildPopupInput({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return SizedBox(
      height: 38,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        cursorColor: Colors.white,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontFamily: 'Microsoft YaHei',
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFF2A2C35),
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF8B8E98),
            fontSize: 14,
            fontFamily: 'Microsoft YaHei',
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF3A3D49)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF1876F2)),
          ),
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
        _buildInfoBadge(item.gender),
        const SizedBox(width: 8),
        _buildInfoBadge(item.age),
        const SizedBox(width: 16),
        Text(
          _maskPhone(item.phone),
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

  /// 手机号脱敏显示。
  String _maskPhone(String phone) {
    final String text = phone.trim();
    if (text.length <= 4) return text;
    return '****${text.substring(text.length - 4)}';
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
        label: const Text('选择'),
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

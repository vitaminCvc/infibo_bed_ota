// 閫夋嫨鐢ㄦ埛椤甸潰銆?
//
// 鐢ㄦ埛鍦ㄨ繖閲岄€夋嫨鎴栨柊澧炴帴鍙楃悊鐤楃殑鐢ㄦ埛锛岀劧鍚庡甫鐫€褰撳墠妯″紡鎴栬嚜瀹氫箟鏂规杩涘叆鍚姩鐞嗙枟椤点€?
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:infibo_app/components/userindex.dart';
import 'package:infibo_app/constants/assets.dart';
import 'package:infibo_app/pages/choseusers/logic.dart';
import 'package:infibo_app/utils/age_utils.dart';
import 'package:infibo_app/utils/gender_utils.dart';
import 'package:infibo_app/utils/phone_utils.dart';

// 閫夋嫨鐢ㄦ埛椤甸潰銆?
class ChoseUsersPage extends StatefulWidget {
  const ChoseUsersPage({super.key});

  @override
  State<ChoseUsersPage> createState() => _ChoseUsersPageState();
}

class _ChoseUsersPageState extends State<ChoseUsersPage> {
  // 閫夋嫨鐢ㄦ埛閫昏緫銆?
  final ChoseUsersLogic _logic = ChoseUsersLogic();
  // 鐢ㄦ埛鍒楄〃婊氬姩鎺у埗鍣ㄣ€?
  final ScrollController _listController = ScrollController();
  // 鎼滅储妗嗘帶鍒跺櫒銆?
  final TextEditingController _searchController = TextEditingController();
  // 濮撳悕杈撳叆妗嗘帶鍒跺櫒銆?
  final TextEditingController _nameController = TextEditingController();
  // 骞撮緞杈撳叆妗嗘帶鍒跺櫒銆?
  final TextEditingController _ageController = TextEditingController();
  // 鎵嬫満鍙疯緭鍏ユ鎺у埗鍣ㄣ€?
  final TextEditingController _phoneController = TextEditingController();

  // 娣诲姞鐢ㄦ埛寮圭獥鏄惁鏄剧ず銆?
  bool _showAddPopup = false;
  // 鏄惁鍑嗗灏辩华銆?
  bool _isReady = false;
  //璁剧疆鎬у埆鐨勯粯璁ゅ€间负鐢?
  String _selectedGender = '\u7537';

  @override
  //杩涜鍒濆鍖?
  void initState() {
    super.initState();
    // 鍒濆鍖栫敤鎴峰垪琛?
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
    // 閲婃斁鏁版嵁搴撹祫婧?
    unawaited(_logic.dispose());
    super.dispose();
  }

  @override
  // 鏋勫缓椤甸潰
  Widget build(BuildContext context) {
    //鏋勫缓椤佃〃澶?
    return AppUsersHeaderPage(
      // 鐐瑰嚮娣诲姞鐢ㄦ埛鎸夐挳鏃惰皟鐢?
      onAddTap: _toggleAddPopup,
      children: [
        // 鍥哄畾鍐呭鍖哄煙
        Positioned(left: 44, top: 145, right: 44, child: _buildFixedContent()),
        Positioned(
          top: 292, //鐢ㄦ埛鍒楄〃椤堕儴璺濈
          left: 44,
          right: 44,
          bottom: 24,
          child: _buildUserList(),
        ),
        if (_showAddPopup)
          Positioned(right: 125, top: 78, child: _buildAddUserPopup()),
      ],
    );
  }

  /// 鏄剧ず鎴栭殣钘忔坊鍔犵敤鎴峰脊绐椼€?
  void _toggleAddPopup() {
    setState(() {
      _showAddPopup = !_showAddPopup;
      if (_showAddPopup) _selectedGender = '\u7537';
    });
  }

  /// 浠庢暟鎹簱鍔犺浇鐢ㄦ埛銆?
  Future<void> _loadUsers() async {
    await _logic.init();
    if (!mounted) return;

    setState(() => _isReady = true);
  }

  /// 淇濆瓨鏂板鐢ㄦ埛銆?
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
      _selectedGender = '\u7537';
      _nameController.clear();
      _ageController.clear();
      _phoneController.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToUser(_logic.users.length - 1);
    });
  }

  /// 鎼滅储骞跺畾浣嶇敤鎴枫€?
  void _searchUser(String keyword) {
    if (!_isReady) return;

    final int index = _logic.findUserIndex(keyword);
    if (index < 0) return;

    setState(() => _logic.highlightUser(index));
    _scrollToUser(index);
  }

  /// 鍒犻櫎鐢ㄦ埛銆?
  Future<void> _deleteUser(int index) async {
    await _logic.deleteUser(index);
    if (!mounted) return;

    setState(() {});
  }

  /// 婊氬姩鍒版寚瀹氱敤鎴枫€?
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

  /// 鏋勫缓鍥哄畾鍖哄煙锛屾爣棰樺拰鎼滅储妗嗕笉浼氳窡鐫€鍒楄〃婊氬姩銆?
  Widget _buildFixedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [_buildTitle(), const SizedBox(height: 39), _buildSearchBar()],
    );
  }

  /// 鏋勫缓椤甸潰鏍囬銆?
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

  /// 鏋勫缓鎼滅储妗嗐€?
  Widget _buildSearchBar() {
    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.centerLeft, //灞呬腑宸﹀榻?
        children: [
          // 鎼滅储妗嗚儗鏅簿婊℃暣涓尯鍩?
          Positioned.fill(
            // 鎼滅储妗嗚儗鏅?
            child: Image.asset(Assets.choseUserSearchBg, fit: BoxFit.fill),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 22, right: 22),
            child: Row(
              children: [
                // 鎼滅储鍥炬爣
                Image.asset(Assets.choseUserSearchIcon, width: 16, height: 16),
                const SizedBox(width: 10),
                Expanded(
                  // 鎼滅储杈撳叆妗?
                  child: TextField(
                    controller: _searchController,
                    cursorColor: Colors.white,
                    textInputAction: TextInputAction.search, //鎼滅储鎸夐挳
                    onSubmitted: _searchUser,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Microsoft YaHei',
                    ),
                    decoration: InputDecoration(
                      // 鎼滅储杈撳叆妗嗘牱寮?
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

  /// 鏋勫缓鍙粴鍔ㄧ敤鎴峰垪琛ㄣ€?
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

  /// 鏋勫缓娣诲姞鐢ㄦ埛寮圭獥銆?
  Widget _buildAddUserPopup() {
    return SizedBox(
      width: 232,
      height: 240,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Image.asset(Assets.choseUserAddBg, fit: BoxFit.fill),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              const SizedBox(height: 36),
              Transform.translate(
                offset: const Offset(-10, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPopupInput(
                      controller: _nameController,
                      hintText: 'name'.tr,
                    ),
                    const SizedBox(height: 10),
                    _buildGenderSelector(),
                    _buildPopupInput(
                      controller: _ageController,
                      hintText: 'age'.tr,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 10),
                    _buildPopupInput(
                      controller: _phoneController,
                      hintText: 'phone'.tr,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: 190,
                height: 30,
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
                  child: Text('save'.tr),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 鏋勫缓鎬у埆鐐归€夈€?
  Widget _buildGenderSelector() {
    return Container(
      height: 30,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15),

      child: Row(
        children: [
          const SizedBox(width: 24),
          Text(
            'gender'.tr,
            style: TextStyle(
              color: Color(0xFF696969),
              fontSize: 14,
              fontFamily: 'Microsoft YaHei',
            ),
          ),
          const SizedBox(width: 12),
          const Spacer(),
          Transform.translate(
            offset: const Offset(-8, 0),
            child: Row(
              children: [
                SizedBox(width: 34, height: 30, child: _buildGenderOption('\u7537')),
                const SizedBox(width: 8),
                SizedBox(width: 34, height: 30, child: _buildGenderOption('\u5973')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 鏋勫缓鍗曚釜鎬у埆閫夐」銆?
  Widget _buildGenderOption(String value) {
    final bool isSelected = _selectedGender == value;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _selectedGender = value;
        });
      },
      child: SizedBox.expand(
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF1876F2)
                        : const Color(0xFF777A84),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    width: isSelected ? 6 : 0,
                    height: isSelected ? 6 : 0,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1876F2),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                value == '\u7537' ? 'male'.tr : 'female'.tr,
                maxLines: 1,
                overflow: TextOverflow.visible,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF696969),
                  fontSize: 14,
                  fontFamily: 'Microsoft YaHei',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 鏋勫缓寮圭獥杈撳叆妗嗐€?
  Widget _buildPopupInput({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return SizedBox(
      height: 30,
      width: 186,
      //閿洏绫诲瀷
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
          fillColor: const Color(0x00FFFFFF),
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF696969),
            fontSize: 14,
            fontFamily: 'Microsoft YaHei',
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: const BorderSide(color: Color(0x503A3D49)),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: const BorderSide(color: Color(0x503A3D49)),
          ),
        ),
      ),
    );
  }

  /// 鏋勫缓鐢ㄦ埛鍗＄墖銆?
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

  /// 鏋勫缓鐢ㄦ埛澶村儚銆?
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

  /// 鏋勫缓鐢ㄦ埛濮撳悕銆佹€у埆銆佸勾榫勩€佹墜鏈哄彿銆?
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

  /// 鏋勫缓鎬у埆銆佸勾榫勬爣绛俱€?
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

  /// 鏋勫缓閫夋嫨鎸夐挳銆?
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

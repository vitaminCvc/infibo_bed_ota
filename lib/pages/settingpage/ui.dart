import 'package:flutter/material.dart';
import 'package:infibo_app/components/settingindex.dart';
import 'package:infibo_app/pages/customized/customizedPage/setting_page_helpers.dart';

class SettingWidget extends StatefulWidget {
  const SettingWidget({super.key});

  @override
  State<SettingWidget> createState() => _SettingWidgetState();
}

class _SettingWidgetState extends State<SettingWidget> {
  // 默认高亮“历史记录”，和设计稿一致。
  int _selectedMenuIndex = 0;

  int _selectedLanguageIndex = 0;

  // 左侧菜单数据源：统一在这里维护标题和图标，避免在 UI 里写死重复内容。
  static const List<_SettingMenuItemData> _menuItems = [
    _SettingMenuItemData(title: '语言设置', icon: Icons.public),
    _SettingMenuItemData(title: '日期和时间', icon: Icons.schedule),
    _SettingMenuItemData(title: '设备信息', icon: Icons.layers_outlined),
    _SettingMenuItemData(title: '调试模式', icon: Icons.device_hub_outlined),
    _SettingMenuItemData(title: '历史记录', icon: Icons.event_note_outlined),
    _SettingMenuItemData(title: '用户管理', icon: Icons.person_outline),
  ];

  static const List<_LanguageOptionData> _languageOptions = [
    _LanguageOptionData(flag: '🇨🇳', name: '中文'), //中国
    _LanguageOptionData(flag: '🇺🇸', name: 'English'), //英语
    _LanguageOptionData(flag: '🇫🇷', name: 'Français'), //法语
    _LanguageOptionData(flag: '🇪🇸', name: 'Español'), //西班牙语
    _LanguageOptionData(flag: '🇵🇱', name: 'język polski'), //波兰语
    _LanguageOptionData(flag: '🇰🇷', name: '한국어'), //韩语
    _LanguageOptionData(flag: '🇷🇺', name: 'Русский'), //俄语
  ];

  @override
  Widget build(BuildContext context) {
    return AppSettingHeaderPage(
      children: [
        Positioned(
          left: 44,
          top: 115,
          child: ExpandBackButton(onTap: () => popExpandPage(context)),
        ),
        Positioned.fill(
          top: 226,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 44),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左侧菜单宽度按设计稿控制为固定值。
                SizedBox(width: 188, child: _buildLeftMenuPanel()),
                const SizedBox(width: 18),
                Expanded(child: _buildRightPanelHeader()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeftMenuPanel() {
    return Container(
      // 高度固定，确保左栏在不同屏幕下保持稳定比例，不被内容撑变形。
      height: 704,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2B2E39), Color(0xFF1D1F28)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              alignment: Alignment.centerLeft,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF2E323E), Color(0xFF242731)],
                ),
              ),
              child: const Text(
                '设置菜单',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: _menuItems.length,
                itemBuilder: (context, index) {
                  final _SettingMenuItemData item = _menuItems[index];
                  final bool selected = index == _selectedMenuIndex;
                  return _buildMenuItem(
                    item: item,
                    selected: selected,
                    onTap: () {
                      setState(() {
                        _selectedMenuIndex = index;
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建菜单项
  Widget _buildMenuItem({
    required _SettingMenuItemData item,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        // 每个菜单项固定高度，和截图中的行高一致，避免文字抖动。
        height: 70,
        decoration: BoxDecoration(
          // 选中项使用底色 + 左侧蓝条，突出当前菜单位置。
          color: selected ? const Color(0xFF3A3E49) : Colors.transparent,
          border: selected
              ? const Border(
                  left: BorderSide(color: Color(0xFF2E84FF), width: 2),
                )
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Row(
          children: [
            Icon(
              item.icon,
              color: Colors.white.withValues(alpha: 0.8),
              size: 23,
            ),
            const SizedBox(width: 18),
            Text(
              item.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建右侧面板标题
  Widget _buildRightPanelHeader() {
    // 右侧标题跟随左侧当前选中项，语言设置页显示专属内容。
    final String pageTitle = _menuItems[_selectedMenuIndex].title;
    return Container(
      height: 704,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2B2E39), Color(0xFF1D1F28)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: _selectedMenuIndex == 0
            ? _buildLanguagePanel()
            : Align(
                alignment: Alignment.topLeft,
                child: Text(
                  pageTitle,
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
      ),
    );
  }

  // 构建语言切换面板
  Widget _buildLanguagePanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '语言切换',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 34),
        Expanded(
          child: ListView.separated(
            itemCount: _languageOptions.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final _LanguageOptionData option = _languageOptions[index];
              final bool selected = index == _selectedLanguageIndex;
              return _buildLanguageItem(
                option: option,
                selected: selected,
                onTap: () {
                  setState(() {
                    _selectedLanguageIndex = index;
                  });
                },
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E84FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              '保存更改',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }

  //顶部标题“语言切换”
  //中间语言列表
  //底部“保存更改”按钮
  Widget _buildLanguageItem({
    required _LanguageOptionData option,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 411,
        height: 66,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF252935),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Text(option.flag, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                option.name,
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? const Color(0xFF2E84FF) : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? const Color(0xFF2E84FF)
                      : Colors.white.withValues(alpha: 0.2),
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingMenuItemData {
  const _SettingMenuItemData({required this.title, required this.icon});

  final String title;
  final IconData icon;
}

class _LanguageOptionData {
  const _LanguageOptionData({required this.flag, required this.name});

  final String flag;
  final String name;
}

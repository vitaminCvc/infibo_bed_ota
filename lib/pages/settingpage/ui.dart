import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infibo_app/components/settingindex.dart';
import 'package:infibo_app/pages/customized/customizedPage/setting_page_helpers.dart';

class SettingWidget extends StatefulWidget {
  const SettingWidget({super.key});

  @override
  State<SettingWidget> createState() => _SettingWidgetState();
}

class _SettingWidgetState extends State<SettingWidget> {
  // 榛樿楂樹寒鈥滃巻鍙茶褰曗€濓紝鍜岃璁＄涓€鑷淬€?
  int _selectedMenuIndex = 0;

  int _selectedLanguageIndex = 0;

  // 宸︿晶鑿滃崟鏁版嵁婧愶細缁熶竴鍦ㄨ繖閲岀淮鎶ゆ爣棰樺拰鍥炬爣锛岄伩鍏嶅湪 UI 閲屽啓姝婚噸澶嶅唴瀹广€?
  static const List<_SettingMenuItemData> _menuItems = [
    _SettingMenuItemData(titleKey: 'language_setting', icon: Icons.public),
    _SettingMenuItemData(titleKey: 'date_time', icon: Icons.schedule),
    _SettingMenuItemData(titleKey: 'device_info', icon: Icons.layers_outlined),
    _SettingMenuItemData(
      titleKey: 'debug_mode',
      icon: Icons.device_hub_outlined,
    ),
    _SettingMenuItemData(
      titleKey: 'history_record',
      icon: Icons.event_note_outlined,
    ),
    _SettingMenuItemData(
      titleKey: 'user_management',
      icon: Icons.person_outline,
    ),
  ];

  static const List<_LanguageOptionData> _languageOptions = [
    _LanguageOptionData(
      flag: '🇨🇳',
      name: '中文',
      locale: Locale('zh', 'CN'),
      enabled: true,
    ),
    _LanguageOptionData(
      flag: '🇺🇸',
      name: 'English',
      locale: Locale('en', 'US'),
      enabled: true,
    ),
    _LanguageOptionData(flag: '🇫🇷', name: 'Français'),
    _LanguageOptionData(
      flag: '🇪🇸',
      name: 'Español',
      locale: Locale('es', 'ES'),
      enabled: true,
    ),
    _LanguageOptionData(flag: '🇵🇱', name: 'język polski'),
    _LanguageOptionData(
      flag: '🇰🇷',
      name: '한국어',
      locale: Locale('ko', 'KR'),
      enabled: true,
    ),
    _LanguageOptionData(flag: '🇷🇺', name: 'Русский'),
  ];

  @override
  void initState() {
    super.initState();
    final Locale? current = Get.locale;
    final int matchedIndex = _languageOptions.indexWhere(
      (option) => option.locale == current,
    );
    _selectedLanguageIndex = matchedIndex >= 0 ? matchedIndex : 0;
  }

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
                // 宸︿晶鑿滃崟瀹藉害鎸夎璁＄鎺у埗涓哄浐瀹氬€笺€?
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
      // 楂樺害鍥哄畾锛岀‘淇濆乏鏍忓湪涓嶅悓灞忓箷涓嬩繚鎸佺ǔ瀹氭瘮渚嬶紝涓嶈鍐呭鎾戝彉褰€?
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
              child: Text(
                'setting_menu'.tr,
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

  // 鏋勫缓鑿滃崟椤?
  Widget _buildMenuItem({
    required _SettingMenuItemData item,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        // 姣忎釜鑿滃崟椤瑰浐瀹氶珮搴︼紝鍜屾埅鍥句腑鐨勮楂樹竴鑷达紝閬垮厤鏂囧瓧鎶栧姩銆?
        height: 70,
        decoration: BoxDecoration(
          // 閫変腑椤逛娇鐢ㄥ簳鑹?+ 宸︿晶钃濇潯锛岀獊鍑哄綋鍓嶈彍鍗曚綅缃€?
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
              item.titleKey.tr,
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

  // 鏋勫缓鍙充晶闈㈡澘鏍囬
  Widget _buildRightPanelHeader() {
    // 鍙充晶鏍囬璺熼殢宸︿晶褰撳墠閫変腑椤癸紝璇█璁剧疆椤垫樉绀轰笓灞炲唴瀹广€?
    final String pageTitle = _menuItems[_selectedMenuIndex].titleKey.tr;
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

  // 鏋勫缓璇█鍒囨崲闈㈡澘
  Widget _buildLanguagePanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'language_switch'.tr,
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
            onPressed: _confirmLanguageChange,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E84FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              'save_changes'.tr,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }

  //椤堕儴鏍囬鈥滆瑷€鍒囨崲鈥?
  //涓棿璇█鍒楄〃
  //搴曢儴鈥滀繚瀛樻洿鏀光€濇寜閽?
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

  void _confirmLanguageChange() {
    final _LanguageOptionData option = _languageOptions[_selectedLanguageIndex];
    final Locale? locale = option.locale;
    if (!option.enabled || locale == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('unsupported_language'.tr)));
      return;
    }
    Get.updateLocale(locale);
    Get.offAllNamed('/main');
  }
}

class _SettingMenuItemData {
  const _SettingMenuItemData({required this.titleKey, required this.icon});

  final String titleKey;
  final IconData icon;
}

class _LanguageOptionData {
  const _LanguageOptionData({
    required this.flag,
    required this.name,
    this.locale,
    this.enabled = false,
  });

  final String flag;
  final String name;
  final Locale? locale;
  final bool enabled;
}

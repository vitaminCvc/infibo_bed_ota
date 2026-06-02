// App 设置页面。
//
// 提供语言切换、日期时间设置以及后续设备信息等设置入口。
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infibo_app/components/settingindex.dart';
import 'package:infibo_app/pages/customized/customizedPage/setting_page_helpers.dart';
import 'package:infibo_app/stores/app_header_clock_store.dart';
import 'package:infibo_app/utils/date_time_utils.dart';

class SettingWidget extends StatefulWidget {
  const SettingWidget({super.key});

  @override
  State<SettingWidget> createState() => _SettingWidgetState();
}

class _SettingWidgetState extends State<SettingWidget> {
  ////////////////////////////// 日期时间选择器布局参数 //////////////////////////////

  // 日期时间滚轮整体左边距，数值越小越靠左
  static const double _dateTimePickerLeft = 18;

  // 滚轮高度
  static const double _dateTimeWheelHeight = 230;

  // 每一项的上下距离
  static const double _dateTimeItemExtent = 58;

  // 选中项字体大小
  static const double _dateTimeSelectedFontSize = 26;

  // 未选中项字体大小
  static const double _dateTimeNormalFontSize = 17;

  // 年这一列的总宽度
  static const double _dateTimeFirstColumnWidth = 126;

  // 月/小时这一列的总宽度
  static const double _dateTimeSecondColumnWidth = 96;

  // 日/分钟这一列的总宽度
  static const double _dateTimeThirdColumnWidth = 96;

  // 日期列之间的间距
  static const double _dateTimeGapWidth = 34;

  ////////////////////////////// 基础状态 //////////////////////////////

  // 默认高亮“语言设置”
  int _selectedMenuIndex = 0;

  int _selectedLanguageIndex = 0;

  // 增加年月日，am，pm
  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedDay;
  late int _selectedAmPmIndex; // 0为上午，1为下午

  // 增加小时分钟
  late int _selectedHour12;
  late int _selectedMinute;

  // 创建年份选项
  late final List<int> _yearOptions;

  // 创建滚动控制器
  late final FixedExtentScrollController _yearController;
  late final FixedExtentScrollController _monthController;
  late final FixedExtentScrollController _dayController;
  late final FixedExtentScrollController _amPmController;
  late final FixedExtentScrollController _hourController;
  late final FixedExtentScrollController _minuteController;

  // 左侧菜单数据源：统一在这里维护标题和图标，避免在 UI 里写死重复内容。
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
    ///////////////////////////////////////////////////////////英文语言////////////////////////////////////////////////
    _LanguageOptionData(
      flag: '🇺🇸',
      name: 'English',
      locale: Locale('en', 'US'),
    ),
    ///////////////////////////////////////////////////////////西班牙语语言////////////////////////////////////////////////
    _LanguageOptionData(
      flag: '🇪🇸',
      name: 'Español',
      locale: Locale('es', 'ES'),
    ),
    ///////////////////////////////////////////////////////////葡萄牙语语言////////////////////////////////////////////////
    _LanguageOptionData(
      flag: '🇵🇱',
      name: 'Português',
      locale: Locale('pt', 'PT'),
    ),
    ///////////////////////////////////////////////////////////俄语语言////////////////////////////////////////////////
    _LanguageOptionData(
      flag: '🇷🇺',
      name: 'Русский',
      locale: Locale('ru', 'RU'),
    ),
    ///////////////////////////////////////////////////////////法语语言////////////////////////////////////////////////
    _LanguageOptionData(
      flag: '🇫🇷',
      name: 'Français',
      locale: Locale('fr', 'FR'),
    ),
    ///////////////////////////////////////////////////////////韩语语言////////////////////////////////////////////////
    _LanguageOptionData(flag: '🇰🇷', name: '한국어', locale: Locale('ko', 'KR')),
    ///////////////////////////////////////////////////////////阿拉伯语言////////////////////////////////////////////////
    _LanguageOptionData(
      flag: '🇦🇪',
      name: 'العربية',
      locale: Locale('ar', 'SA'),
    ),
    //////////////////////////////////////////////////////////德语语言///////////////////////////////////////////////////
    _LanguageOptionData(
      flag: '🇩🇪',
      name: 'Deutsch',
      locale: Locale('de', 'DE'),
    ),
    ///////////////////////////////////////////////////////////土耳其语言////////////////////////////////////////////////
    _LanguageOptionData(
      flag: '🇹🇷',
      name: 'Türkçe',
      locale: Locale('tr', 'TR'),
    ),
    ///////////////////////////////////////////////////////////中文语言////////////////////////////////////////////////
    _LanguageOptionData(flag: '🇨🇳', name: '中文', locale: Locale('zh', 'CN')),
  ];

  @override
  void initState() {
    super.initState();

    final Locale? current = Get.locale;
    final int matchedIndex = _languageOptions.indexWhere(
      (option) => option.locale == current,
    );
    _selectedLanguageIndex = matchedIndex >= 0 ? matchedIndex : 0;

    final DateTime now = AppHeaderClockController.instance.currentTime;

    _yearOptions = List.generate(21, (index) => now.year - 10 + index);

    _selectedYear = now.year;
    _selectedMonth = now.month;
    _selectedDay = now.day;
    _selectedAmPmIndex = now.hour >= 12 ? 1 : 0;
    _selectedHour12 = toHour12(now.hour);
    _selectedMinute = now.minute;

    _yearController = FixedExtentScrollController(
      initialItem: _yearOptions.indexOf(_selectedYear),
    );
    _monthController = FixedExtentScrollController(
      initialItem: _selectedMonth - 1,
    );
    _dayController = FixedExtentScrollController(initialItem: _selectedDay - 1);
    _amPmController = FixedExtentScrollController(
      initialItem: _selectedAmPmIndex,
    );
    _hourController = FixedExtentScrollController(
      initialItem: _selectedHour12 - 1,
    );
    _minuteController = FixedExtentScrollController(
      initialItem: _selectedMinute,
    );
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    _amPmController.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
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
                // 左侧菜单宽度按设计稿控制为固定值。
                SizedBox(width: 224, child: _buildLeftMenuPanel()),
                const SizedBox(width: 18),
                Expanded(child: _buildRightPanelHeader()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  ////////////////////////////////////////左侧菜单栏///////////////////////////////
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
              child: Text(
                'setting_menu'.tr,
                style: const TextStyle(color: Colors.white, fontSize: 24),
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

  ///////////////////////////// 构建右侧面板标题/////////////////////////////////
  Widget _buildRightPanelHeader() {
    // 右侧标题跟随左侧当前选中项，语言设置页显示专属内容。
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
        child: _buildRightPanelContent(pageTitle),
      ),
    );
  }

  // 根据左侧菜单切换右侧内容
  Widget _buildRightPanelContent(String pageTitle) {
    if (_selectedMenuIndex == 0) {
      return _buildLanguagePanel();
    }

    if (_selectedMenuIndex == 1) {
      return _buildDateTimePanel();
    }

    return Align(
      alignment: Alignment.topLeft,
      child: Text(
        pageTitle,
        style: const TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }

  ////////////////////////////////////////语言设置页面///////////////////////////////

  // 构建语言切换面板
  Widget _buildLanguagePanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'language_switch'.tr,
          style: const TextStyle(
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
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }

  // 顶部标题“语言切换”
  // 中间语言列表
  // 底部“保存更改”按钮
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

  // 确认语言切换
  void _confirmLanguageChange() {
    final _LanguageOptionData option = _languageOptions[_selectedLanguageIndex];
    final Locale? locale = option.locale;
    if (locale == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('unsupported_language'.tr)));
      return;
    }
    Get.updateLocale(locale);
    Get.offAllNamed('/main');
  }

  ////////////////////////////////////////日期和时间页面///////////////////////////////

  // 新增日期时间页面
  Widget _buildDateTimePanel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 4, 6, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'date_time'.tr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 42),

          Padding(
            padding: const EdgeInsets.only(left: _dateTimePickerLeft),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 第一行：年 / 月 / 日
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNumberWheelWithUnit(
                      totalWidth: _dateTimeFirstColumnWidth,
                      valueWidth: 86,
                      unitWidth: 28,
                      controller: _yearController,
                      values: _yearOptions,
                      selectedValue: _selectedYear,
                      unit: '年',
                      onChanged: (value) {
                        setState(() {
                          _selectedYear = value;
                          _fixSelectedDay();
                        });
                      },
                    ),

                    const SizedBox(width: _dateTimeGapWidth),

                    _buildNumberWheelWithUnit(
                      totalWidth: _dateTimeSecondColumnWidth,
                      valueWidth: 48,
                      unitWidth: 28,
                      controller: _monthController,
                      values: List.generate(12, (index) => index + 1),
                      selectedValue: _selectedMonth,
                      unit: '月',
                      onChanged: (value) {
                        setState(() {
                          _selectedMonth = value;
                          _fixSelectedDay();
                        });
                      },
                    ),

                    const SizedBox(width: _dateTimeGapWidth),

                    _buildNumberWheelWithUnit(
                      totalWidth: _dateTimeThirdColumnWidth,
                      valueWidth: 48,
                      unitWidth: 28,
                      controller: _dayController,
                      values: List.generate(
                        daysInMonth(_selectedYear, _selectedMonth),
                        (index) => index + 1,
                      ),
                      selectedValue: _selectedDay,
                      unit: '日',
                      onChanged: (value) {
                        setState(() {
                          _selectedDay = value;
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // 第二行：上午/下午 / 时 / 分
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 上午/下午这一列和“年”这一列共用同样宽度
                    SizedBox(
                      width: _dateTimeFirstColumnWidth,
                      height: _dateTimeWheelHeight,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _buildTextWheel(
                          width: 90,
                          controller: _amPmController,
                          values: const ['上午', '下午'],
                          selectedIndex: _selectedAmPmIndex,
                          onChanged: (index) {
                            setState(() {
                              _selectedAmPmIndex = index;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(width: _dateTimeGapWidth),

                    // 小时：和上面的“月”上下对齐
                    _buildNumberWheelWithUnit(
                      totalWidth: _dateTimeSecondColumnWidth,
                      valueWidth: 48,
                      unitWidth: 28,
                      controller: _hourController,
                      values: List.generate(12, (index) => index + 1),
                      selectedValue: _selectedHour12,
                      unit: '时',
                      onChanged: (value) {
                        setState(() {
                          _selectedHour12 = value;
                        });
                      },
                    ),

                    // 冒号占用和日期行相同的列间距
                    SizedBox(
                      width: _dateTimeGapWidth,
                      height: _dateTimeWheelHeight,
                      child: const Center(
                        child: Text(
                          ':',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    // 分钟：和上面的“日”上下对齐
                    _buildNumberWheelWithUnit(
                      totalWidth: _dateTimeThirdColumnWidth,
                      valueWidth: 48,
                      unitWidth: 28,
                      controller: _minuteController,
                      values: List.generate(60, (index) => index),
                      selectedValue: _selectedMinute,
                      unit: '分',
                      twoDigits: true,
                      onChanged: (value) {
                        setState(() {
                          _selectedMinute = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Spacer(),

          Center(
            child: SizedBox(
              width: 360,
              height: 56,
              child: ElevatedButton(
                onPressed: _confirmDateTimeChange,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F74E8),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  '保存',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 新增数字滚轮组件
  // 数字在 CupertinoPicker 里滚动，单位单独放在右侧，所以“年/月/日/时/分”不会跟着滚动
  Widget _buildNumberWheelWithUnit({
    required double totalWidth,
    required double valueWidth,
    required double unitWidth,
    required FixedExtentScrollController controller,
    required List<int> values,
    required int selectedValue,
    required String unit,
    required ValueChanged<int> onChanged,
    bool twoDigits = false,
  }) {
    final int rawSelectedIndex = values.indexOf(selectedValue);
    final int selectedIndex = rawSelectedIndex < 0 ? 0 : rawSelectedIndex;

    return SizedBox(
      width: totalWidth,
      height: _dateTimeWheelHeight,
      child: Row(
        children: [
          SizedBox(
            width: valueWidth,
            height: _dateTimeWheelHeight,
            child: CupertinoPicker(
              scrollController: controller,
              itemExtent: _dateTimeItemExtent,
              diameterRatio: 100,
              useMagnifier: false,
              backgroundColor: Colors.transparent,
              selectionOverlay: const SizedBox.shrink(),
              onSelectedItemChanged: (index) {
                onChanged(values[index]);
              },
              children: [
                for (int index = 0; index < values.length; index++)
                  Center(
                    child: Text(
                      twoDigits
                          ? values[index].toString().padLeft(2, '0')
                          : values[index].toString(),
                      style: _buildWheelTextStyle(
                        distance: (index - selectedIndex).abs(),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(
            width: unitWidth,
            height: _dateTimeWheelHeight,
            child: Center(
              child: Text(
                unit,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 新增文字滚轮组件
  Widget _buildTextWheel({
    required double width,
    required FixedExtentScrollController controller,
    required List<String> values,
    required int selectedIndex,
    required ValueChanged<int> onChanged,
  }) {
    return SizedBox(
      width: width,
      height: _dateTimeWheelHeight,
      child: CupertinoPicker(
        scrollController: controller,
        itemExtent: _dateTimeItemExtent,
        diameterRatio: 100,
        useMagnifier: false,
        backgroundColor: Colors.transparent,
        selectionOverlay: const SizedBox.shrink(),
        onSelectedItemChanged: onChanged,
        children: [
          for (int index = 0; index < values.length; index++)
            Center(
              child: Text(
                values[index],
                style: _buildWheelTextStyle(
                  distance: (index - selectedIndex).abs(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 根据距离当前选中项的距离，控制未选中项的颜色深浅
  TextStyle _buildWheelTextStyle({required int distance}) {
    double alpha;
    double fontSize;
    FontWeight weight;

    if (distance == 0) {
      alpha = 1.0;
      fontSize = _dateTimeSelectedFontSize;
      weight = FontWeight.w600;
    } else if (distance == 1) {
      alpha = 0.48;
      fontSize = 20;
      weight = FontWeight.w500;
    } else if (distance == 2) {
      alpha = 0.24;
      fontSize = _dateTimeNormalFontSize;
      weight = FontWeight.w400;
    } else {
      alpha = 0.10;
      fontSize = 15;
      weight = FontWeight.w400;
    }

    return TextStyle(
      color: Colors.white.withValues(alpha: alpha),
      fontSize: fontSize,
      fontWeight: weight,
    );
  }

  // 新增日期计算和保存方法
  void _fixSelectedDay() {
    final int maxDay = daysInMonth(_selectedYear, _selectedMonth);

    if (_selectedDay > maxDay) {
      _selectedDay = maxDay;

      if (_dayController.hasClients) {
        _dayController.jumpToItem(maxDay - 1);
      }
    }
  }

  Future<void> _confirmDateTimeChange() async {
    final DateTime selectedDateTime = DateTime(
      _selectedYear,
      _selectedMonth,
      _selectedDay,
      toHour24(hour12: _selectedHour12, isPm: _selectedAmPmIndex == 1),
      _selectedMinute,
    );

    await AppHeaderClockController.instance.setManualTime(selectedDateTime);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('日期和时间已保存')));
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
  });

  final String flag;
  final String name;
  final Locale? locale;
}

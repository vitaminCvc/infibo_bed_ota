// App 设置页面。
//
// 提供语言切换、日期时间设置以及后续设备信息等设置入口。
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infibo_app/api/dio/therapy_report/therapy_report_models.dart';
import 'package:infibo_app/components/designCanvas/design.dart';
import 'package:infibo_app/components/settingindex.dart';
import 'package:infibo_app/pages/customized/customizedPage/setting_page_helpers.dart';
import 'package:infibo_app/pages/WifiBluetooth/connection_prompt_controller.dart';
import 'package:infibo_app/pages/settingpage/DeviceInfo.dart';
import 'package:infibo_app/pages/settingpage/logic.dart';
import 'package:infibo_app/pages/settingpage/prompt_volume_settings_panel.dart';
import 'package:infibo_app/pages/settingpage/wifi_ble_settings_panel.dart';
import 'package:infibo_app/pages/settingpage/status_detection_panel.dart';
import 'package:infibo_app/pages/settingpage/settings_panel_style.dart';
import 'package:infibo_app/stores/app_header_clock_store.dart';
import 'package:infibo_app/utils/date_time_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:infibo_app/config/app_brand.dart';
import 'package:infibo_app/ota/ota_controller.dart';
import 'system_update_panel.dart';

class SettingWidget extends StatefulWidget {
  const SettingWidget({
    super.key,
    this.connectionGateway,
    this.statusReadRegister,
    this.updateController,
    this.openUpdates = false,
  });

  /// 测试可注入连接网关；正式页面留空即可读取系统真实连接信息。
  final ConnectionDetailsGateway? connectionGateway;
  final Future<int> Function(int address)? statusReadRegister;
  final OtaController? updateController;
  final bool openUpdates;

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

  static const double _dateTimeTextBaseline = 20;

  static const double _dateTimeUnitFontSize = 16;

  static const TextStyle _dateTimeUnitTextStyle = TextStyle(
    color: Colors.white,
    fontSize: _dateTimeUnitFontSize,
    height: 1,
    fontWeight: FontWeight.w500,
  );

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

  // 治疗记录菜单索引
  static const int _historyMenuIndex = 4;

  // 治疗记录搜索框控制器
  final TextEditingController _historySearchController =
      TextEditingController();

  // 治疗记录列表滚动控制器
  final ScrollController _historyListController = ScrollController();

  // 治疗记录列表逻辑
  final HistoryRecordLogic _historyLogic = HistoryRecordLogic();

  // 治疗记录列表是否准备就绪
  bool _historyReady = false;

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
  static const List<_SettingMenuItemData> _baseMenuItems = [
    _SettingMenuItemData(titleKey: 'language_setting', icon: Icons.public),
    _SettingMenuItemData(titleKey: 'date_time', icon: Icons.schedule),
    _SettingMenuItemData(titleKey: 'device_info', icon: Icons.layers_outlined),
    _SettingMenuItemData(titleKey: 'wifi_ble', icon: Icons.wifi),
    _SettingMenuItemData(
      titleKey: 'history_record',
      icon: Icons.event_note_outlined,
    ),

    ///新增音量调节组件
    _SettingMenuItemData(
      titleKey: 'prompt_volume',
      icon: Icons.volume_up_outlined,
    ),
    _SettingMenuItemData(
      titleKey: 'status_detection',
      icon: Icons.monitor_heart_outlined,
    ),
  ];

  List<_SettingMenuItemData> get _menuItems => [
    ..._baseMenuItems,
    if (AppBrand.current.supportsOtaUpdates)
      const _SettingMenuItemData(
        titleKey: 'system_update',
        icon: Icons.system_update,
      ),
  ];

  static const List<_LanguageOptionData> _languageOptions = [
    ///////////////////////////////////////////////////////////英文语言////////////////////////////////////////////////
    _LanguageOptionData(name: 'English', locale: Locale('en', 'US')),
    ///////////////////////////////////////////////////////////西班牙语语言////////////////////////////////////////////////
    _LanguageOptionData(name: 'Español', locale: Locale('es', 'ES')),
    ///////////////////////////////////////////////////////////葡萄牙语语言////////////////////////////////////////////////
    _LanguageOptionData(name: 'Português', locale: Locale('pt', 'PT')),
    ///////////////////////////////////////////////////////////俄语语言////////////////////////////////////////////////
    _LanguageOptionData(name: 'Русский', locale: Locale('ru', 'RU')),
    ///////////////////////////////////////////////////////////波兰语语言////////////////////////////////////////////////
    // 波兰语
    _LanguageOptionData(name: 'Polski', locale: Locale('pl', 'PL')),
    ///////////////////////////////////////////////////////////法语语言////////////////////////////////////////////////
    _LanguageOptionData(name: 'Français', locale: Locale('fr', 'FR')),
    ///////////////////////////////////////////////////////////韩语语言////////////////////////////////////////////////
    _LanguageOptionData(name: '한국어', locale: Locale('ko', 'KR')),
    ///////////////////////////////////////////////////////////阿拉伯语言////////////////////////////////////////////////
    _LanguageOptionData(name: 'العربية', locale: Locale('ar', 'SA')),
    //////////////////////////////////////////////////////////德语语言///////////////////////////////////////////////////
    _LanguageOptionData(name: 'Deutsch', locale: Locale('de', 'DE')),
    ///////////////////////////////////////////////////////////土耳其语言////////////////////////////////////////////////
    _LanguageOptionData(name: 'Türkçe', locale: Locale('tr', 'TR')),
    ///////////////////////////////////////////////////////////中文语言////////////////////////////////////////////////
    _LanguageOptionData(name: '中文', locale: Locale('zh', 'CN')),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.openUpdates && AppBrand.current.supportsOtaUpdates) {
      _selectedMenuIndex = 7;
    }

    //历史记录列表滚动监听事件
    _historyListController.addListener(_handleHistoryScroll);

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
    //历史记录列表滚动监听事件释放controller
    _historySearchController.dispose();
    _historyListController.dispose();
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
          top: AppLayoutScope.of(context).viewportY(130),
          child: ExpandBackButton(onTap: () => popExpandPage(context)),
        ),
        Positioned.fill(
          top: AppLayoutScope.of(context).viewportContentY(226),
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
      height: 900,
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
              padding: const EdgeInsets.symmetric(
                horizontal: settingsCardHorizontalPadding,
              ),
              alignment: Alignment.centerLeft,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF2E323E), Color(0xFF242731)],
                ),
              ),
              child: Text(
                'settings_menu_title'.tr,
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
                      if ((widget.updateController ?? OtaController.instance)
                          .busy) {
                        return;
                      }
                      setState(() {
                        _selectedMenuIndex = index;
                      });
                      if (index == _historyMenuIndex) {
                        // 按需加载历史记录列表
                        _loadHistoryIfNeeded();
                      }
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
      enableFeedback: false,
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
        padding: const EdgeInsets.symmetric(
          horizontal: settingsCardHorizontalPadding,
        ),
        child: Row(
          children: [
            Icon(
              item.icon,
              color: Colors.white.withValues(alpha: 0.8),
              size: 23,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  'settings_menu_${item.titleKey}'.tr,
                  maxLines: 1,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
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
      height: 900,
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
        padding: const EdgeInsets.fromLTRB(
          settingsCardHorizontalPadding,
          30,
          settingsCardHorizontalPadding,
          14,
        ),
        child: DefaultTextStyle.merge(
          style: const TextStyle(fontFamily: settingsFontFamily),
          child: _buildRightPanelContent(pageTitle),
        ),
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
    if (_selectedMenuIndex == 2) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildRightPanelTitle(pageTitle),
          const SizedBox(height: 34),
          const Expanded(
            child: DeviceInfoPanel(showDeviceStatusHeading: false),
          ),
        ],
      );
    }
    if (_selectedMenuIndex == 3) {
      // 原“调试模式”占位页替换为连接详情页，保留后续历史记录索引不变。
      return WifiBleSettingsPanel(gateway: widget.connectionGateway);
    }
    if (_selectedMenuIndex == 4) {
      return _buildHistoryPanel();
    }
    if (_selectedMenuIndex == 5) {
      return const PromptVolumeSettingsPanel();
    }
    if (_selectedMenuIndex == 6) {
      return StatusDetectionPanel(readRegister: widget.statusReadRegister);
    }
    if (_selectedMenuIndex == 7) {
      return SystemUpdatePanel(controller: widget.updateController);
    }
    return Align(
      alignment: Alignment.topLeft,
      child: _buildRightPanelTitle(pageTitle),
    );
  }

  Widget _buildRightPanelTitle(String title) {
    return Text(title, style: settingsPanelTitleStyle);
  }

  ////////////////////////////////////////语言设置页面///////////////////////////////

  // 构建语言切换面板
  Widget _buildLanguagePanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildRightPanelTitle('language_switch'.tr),
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
        const SizedBox(height: 30),
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: 360,
            height: 48,
            child: ElevatedButton(
              onPressed: _confirmLanguageChange,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E84FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Text(
                'save_changes'.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
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
      enableFeedback: false,
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 411,
        height: 66,
        padding: const EdgeInsets.symmetric(
          horizontal: settingsCardHorizontalPadding,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF252935),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
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
  Future<void> _confirmLanguageChange() async {
    final _LanguageOptionData option = _languageOptions[_selectedLanguageIndex];
    final Locale? locale = option.locale;
    if (locale == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('unsupported_language'.tr)));
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language_code', locale.languageCode);
    await prefs.setString('app_country_code', locale.countryCode ?? '');

    // 保存后只刷新当前语言，继续停留在设置页。
    Get.updateLocale(locale);
  }

  ////////////////////////////////////////日期和时间页面///////////////////////////////

  // 新增日期时间页面
  Widget _buildDateTimePanel() {
    return Padding(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildRightPanelTitle('date_time'.tr),

          const SizedBox(height: 46),

          Padding(
            padding: EdgeInsets.only(left: _dateTimePickerLeft + 6),
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
                      unit: 'year_unit'.tr,
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
                      unit: 'month_unit'.tr,
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
                      unit: 'day_unit'.tr,
                      onChanged: (value) {
                        setState(() {
                          _selectedDay = value;
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 50),

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
                          values: ['am_label'.tr, 'pm_label'.tr],
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
                      unit: 'hour_unit'.tr,
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
                      unit: 'minutes_unit'.tr,
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
              height: 48,
              child: ElevatedButton(
                onPressed: _confirmDateTimeChange,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E84FF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: Text(
                  'save'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
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
                    child: SizedBox(
                      height: _dateTimeSelectedFontSize,
                      child: Baseline(
                        baseline: _dateTimeTextBaseline,
                        baselineType: TextBaseline.alphabetic,
                        child: Text(
                          twoDigits
                              ? values[index].toString().padLeft(2, '0')
                              : values[index].toString(),
                          style: _buildWheelTextStyle(
                            distance: (index - selectedIndex).abs(),
                          ),
                        ),
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
              child: SizedBox(
                height: _dateTimeSelectedFontSize,
                child: Baseline(
                  baseline: _dateTimeTextBaseline,
                  baselineType: TextBaseline.alphabetic,
                  child: Text(unit, style: _dateTimeUnitTextStyle),
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

  ////////////////////////////////////////历史记录列表页面///////////////////////////////
  Future<void> _loadHistoryIfNeeded() async {
    if (_historyReady || _historyLogic.isLoading) return;

    try {
      await _historyLogic.init();
      if (!mounted) return;
      setState(() {
        _historyReady = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _historyReady = true;
      });
      _showHistoryError(e.toString());
    }
  }

  Future<void> _searchHistory(String keyword) async {
    try {
      await _historyLogic.refresh(keyword: keyword);
      if (!mounted) return;
      setState(() {
        _historyReady = true;
      });
      if (_historyListController.hasClients) {
        _historyListController.jumpTo(0);
      }
    } catch (e) {
      if (!mounted) return;
      _showHistoryError(e.toString());
    }
  }

  Future<void> _loadMoreHistory() async {
    if (_historyLogic.isLoading || !_historyLogic.hasMore) return;

    try {
      await _historyLogic.loadNextPage();
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      _showHistoryError(e.toString());
    }
  }

  Future<void> _deleteHistoryUser(HistoryReportUserItemDto item) async {
    try {
      await _historyLogic.deleteUserReports(item.clientId);
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      _showHistoryError(e.toString());
    }
  }

  void _handleHistoryScroll() {
    if (_selectedMenuIndex != _historyMenuIndex) return;
    if (!_historyListController.hasClients) return;

    final ScrollPosition position = _historyListController.position;
    if (position.pixels >= position.maxScrollExtent - 80) {
      _loadMoreHistory();
    }
  }

  void _showHistoryError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildHistoryPanel() {
    if (!_historyReady && !_historyLogic.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadHistoryIfNeeded();
      });
    }

    return Padding(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _buildRightPanelTitle('history_record'.tr),
              const Spacer(),
              _buildHistorySearchBox(),
            ],
          ),
          const SizedBox(height: 35),
          Expanded(child: _buildHistoryList()),
        ],
      ),
    );
  }

  //创建历史记录详情面板
  Widget _buildHistorySearchBox() {
    return Container(
      width: 185,
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            size: 15,
            color: Colors.white.withValues(alpha: 0.45),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _historySearchController,
              cursorColor: Colors.white,
              textInputAction: TextInputAction.search,
              onSubmitted: _searchHistory,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'Microsoft YaHei',
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'search_user_hint'.tr,
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.36),
                  fontSize: 12,
                  fontFamily: 'Microsoft YaHei',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    if (!_historyReady && _historyLogic.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color.fromARGB(255, 52, 64, 81),
        ),
      );
    }

    if (_historyLogic.users.isEmpty) {
      return Center(
        child: Text(
          'no_history_records'.tr,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.55),
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.separated(
      controller: _historyListController,
      padding: EdgeInsets.zero,
      itemCount: _historyLogic.users.length + (_historyLogic.hasMore ? 1 : 0),
      separatorBuilder: (_, index) {
        if (index >= _historyLogic.users.length - 1) {
          return const SizedBox.shrink();
        }
        return Divider(height: 42, color: Colors.white.withValues(alpha: 0.05));
      },
      itemBuilder: (context, index) {
        if (index >= _historyLogic.users.length) {
          return const SizedBox(
            height: 48,
            child: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2E84FF),
                strokeWidth: 2,
              ),
            ),
          );
        }

        final HistoryReportUserItemDto item = _historyLogic.users[index];
        return _buildHistoryRow(item, index);
      },
    );
  }

  Widget _buildHistoryRow(HistoryReportUserItemDto item, int index) {
    return InkWell(
      enableFeedback: false,
      onTap: () {
        Get.toNamed('/setting/history-detail', arguments: item);
      },
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            _buildHistoryAvatar(item.userName, index),
            const SizedBox(width: 15),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      item.userName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Microsoft YaHei',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.history,
                    size: 14,
                    color: Colors.white.withValues(alpha: 0.42),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatHistoryTime(item.lastReportTime),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.56),
                      fontSize: 12,
                      fontFamily: 'Microsoft YaHei',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _buildHistoryDeleteButton(item),
          ],
        ),
      ),
    );
  }

  //调整头像大小
  Widget _buildHistoryAvatar(String name, int index) {
    final List<Color> colors = [
      const Color.fromARGB(255, 85, 105, 146),
      const Color.fromARGB(255, 125, 116, 71),
      const Color(0xFF4E6476),
      const Color.fromARGB(255, 104, 161, 139),
      const Color.fromARGB(255, 147, 115, 158),
    ];
    final String text = name.trim().isEmpty ? '?' : name.characters.first;

    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors[index % colors.length],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontFamily: 'Microsoft YaHei',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildHistoryDeleteButton(HistoryReportUserItemDto item) {
    return SizedBox(
      width: 72,
      height: 26,
      child: TextButton.icon(
        onPressed: () async {
          await _deleteHistoryUser(item);
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: Colors.white.withValues(alpha: 0.09),
          foregroundColor: Colors.white.withValues(alpha: 0.75),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
        icon: const Icon(Icons.delete_outline, size: 12),
        label: Text(
          'delete'.tr,
          style: const TextStyle(fontSize: 12, fontFamily: 'Microsoft YaHei'),
        ),
      ),
    );
  }

  String _formatHistoryTime(DateTime time) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${time.year}/${time.month}/${time.day} '
        '${two(time.hour)}:${two(time.minute)}:${two(time.second)}';
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
      height: 1,
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
    ).showSnackBar(SnackBar(content: Text('date_time_saved'.tr)));
  }
}

class _SettingMenuItemData {
  const _SettingMenuItemData({required this.titleKey, required this.icon});

  final String titleKey;
  final IconData icon;
}

class _LanguageOptionData {
  const _LanguageOptionData({required this.name, this.locale});

  final String name;
  final Locale? locale;
}

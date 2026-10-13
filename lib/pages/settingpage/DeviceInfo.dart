import 'package:flutter/material.dart';
import 'package:infibo_app/constants/assets.dart';

const double _deviceDetailsHeight = 1355;
const double _deviceInfoPanelScrollHeight = 1261;

class DeviceInfoPanel extends StatelessWidget {
  const DeviceInfoPanel({super.key, this.showDeviceStatusHeading = true});

  final bool showDeviceStatusHeading;

  @override
  Widget build(BuildContext context) {
    final double verticalOffset = showDeviceStatusHeading ? -38 : -80;
    return SingleChildScrollView(
      key: const ValueKey<String>('device-info-scroll-view'),
      physics: const ClampingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      child: SizedBox(
        height: _deviceInfoPanelScrollHeight,
        child: ClipRect(
          child: OverflowBox(
            alignment: Alignment.topLeft,
            minWidth: 463,
            maxWidth: 463,
            minHeight: _deviceDetailsHeight,
            maxHeight: _deviceDetailsHeight,
            child: Transform.translate(
              offset: Offset(-26, verticalOffset),
              child: const _DeviceDetailsPanel(decorated: false),
            ),
          ),
        ),
      ),
    );
  }
}

class DeviceInfoPage extends StatelessWidget {
  const DeviceInfoPage({super.key, this.onBack});

  static const double _designWidth = 800;
  static const double _designHeight = 1701;

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF010106),
      body: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: _designWidth,
            height: _designHeight,
            child: Stack(
              children: <Widget>[
                _buildHeader(),
                Positioned(
                  key: const ValueKey<String>('device-info-back-button'),
                  left: 44,
                  top: 135,
                  width: 115,
                  height: 49,
                  child: _BackButton(onTap: () => _handleBack(context)),
                ),
                const Positioned(
                  key: ValueKey<String>('device-info-menu-panel'),
                  left: 44,
                  top: 227,
                  width: 224,
                  height: 827,
                  child: _SettingsMenuPanel(),
                ),
                const Positioned(
                  key: ValueKey<String>('device-info-detail-panel'),
                  left: 292,
                  top: 227,
                  width: 463,
                  height: _deviceDetailsHeight,
                  child: _DeviceDetailsPanel(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: <Widget>[
        Positioned(
          left: 48,
          top: 38,
          child: Image.asset(
            Assets.mainLogo,
            width: 242,
            height: 44,
            fit: BoxFit.contain,
          ),
        ),
        const Positioned(left: 369, top: 40, child: _ClockBlock()),
        const Positioned(left: 647, top: 36, child: _AdminBadge()),
      ],
    );
  }

  void _handleBack(BuildContext context) {
    if (onBack != null) {
      onBack!();
      return;
    }
    Navigator.of(context).maybePop();
  }
}

class _ClockBlock extends StatelessWidget {
  const _ClockBlock();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 82,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '17:31',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              height: 1,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '2026.02.28',
            style: TextStyle(color: Color(0xFF9899A1), fontSize: 12, height: 1),
          ),
        ],
      ),
    );
  }
}

class _AdminBadge extends StatelessWidget {
  const _AdminBadge();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 108,
      height: 48,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.asset(Assets.adminMainLogo, fit: BoxFit.fill),
          ),
          const Positioned(
            left: 7,
            top: 6,
            child: CircleAvatar(
              radius: 17,
              backgroundColor: Color(0xFF393B43),
              child: Icon(Icons.person_outline, size: 21, color: Colors.white),
            ),
          ),
          const Positioned(
            left: 49,
            top: 14,
            child: Text(
              'Admin',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(25),
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFF202127),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: const Color(0xFF383940)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.arrow_back_rounded, color: Colors.white, size: 23),
              SizedBox(width: 8),
              Text(
                'Back',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  height: 1,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsMenuPanel extends StatelessWidget {
  const _SettingsMenuPanel();

  static const List<_MenuItemData> _items = <_MenuItemData>[
    _MenuItemData(Icons.language_outlined, 'Language Settings'),
    _MenuItemData(Icons.schedule_outlined, 'Date & Time'),
    _MenuItemData(Icons.layers_outlined, 'Device Information'),
    _MenuItemData(Icons.device_hub_outlined, 'Debug Mode'),
    _MenuItemData(Icons.calendar_month_outlined, 'History Records'),
    _MenuItemData(Icons.person_outline, 'User Management'),
    _MenuItemData(Icons.hub_outlined, 'Runtime Info'),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: _panelDecoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: <Widget>[
            const Positioned(
              left: 26,
              top: 35,
              child: Text(
                'Settings Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  height: 1,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 88,
              child: Column(
                children: List<Widget>.generate(
                  _items.length,
                  (int index) => _SettingsMenuItem(
                    item: _items[index],
                    selected: index == 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsMenuItem extends StatelessWidget {
  const _SettingsMenuItem({required this.item, required this.selected});

  final _MenuItemData item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 82,
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          key: selected
              ? const ValueKey<String>('device-info-selected-menu-item')
              : null,
          height: selected ? 74 : 82,
          decoration: selected
              ? const BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[Color(0xFF273243), Color(0xFF2A2B32)],
                  ),
                  border: Border(
                    left: BorderSide(color: Color(0xFF1688FF), width: 2),
                  ),
                )
              : null,
          padding: const EdgeInsets.only(left: 29),
          child: Row(
            children: <Widget>[
              Icon(item.icon, color: const Color(0xFFF2F3F7), size: 26),
              const SizedBox(width: 14),
              Text(
                item.label,
                style: const TextStyle(
                  color: Color(0xFFF5F5F7),
                  fontSize: 19,
                  height: 1,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeviceDetailsPanel extends StatelessWidget {
  const _DeviceDetailsPanel({this.decorated = true});

  final bool decorated;

  @override
  Widget build(BuildContext context) {
    final Widget content = Stack(
      children: <Widget>[
        const Positioned(
          left: 26,
          top: 38,
          child: _SectionHeading('Device Status'),
        ),
        Positioned(left: 26, top: 90, child: secondRow()),

        const Positioned(
          left: 26,
          top: 150,
          child: _DeviceInfoCell(
            icon: Icons.view_in_ar_outlined,
            label: 'Model',
            value: 'INMORTAL-MT-01',
          ),
        ),
        const Positioned(
          left: 242,
          top: 150,
          child: _DeviceInfoCell(
            icon: Icons.numbers_outlined,
            label: 'Device ID',
            value: 'IMM202607060001',
          ),
        ),
        const Positioned(
          left: 26,
          top: 260,
          child: _DeviceInfoCell(
            icon: Icons.calendar_month_outlined,
            label: 'Manufacture Year',
            value: '2026',
          ),
        ),
        const Positioned(
          left: 242,
          top: 260,
          child: _DeviceInfoCell(
            icon: Icons.power_settings_new_outlined,
            label: 'Input Power',
            value: 'AC 220V / 50Hz',
          ),
        ),
        const Positioned(
          left: 26,
          top: 391,
          child: _SectionHeading('Version Information'),
        ),
        const Positioned(
          left: 26,
          top: 449,
          child: _VersionInfoCell(label: 'Android App Version', value: 'V1.09'),
        ),
        const Positioned(
          left: 242,
          top: 449,
          child: _VersionInfoCell(
            label: 'Main Controller Firmware',
            value: 'V2.1.0',
          ),
        ),
        const Positioned(
          left: 26,
          top: 529,
          child: _VersionInfoCell(label: 'PEMF Firmware', value: 'V2.2.0'),
        ),
        const Positioned(
          left: 242,
          top: 529,
          child: _VersionInfoCell(label: 'Red Light Firmware', value: 'V1.3.5'),
        ),
        const Positioned(
          left: 26,
          top: 609,
          child: _VersionInfoCell(
            label: 'Communication Protocol',
            value: 'MODBUS V1.0',
          ),
        ),
        const Positioned(
          left: 242,
          top: 609,
          child: _VersionInfoCell(
            label: 'UI Resource Version',
            value: 'UI-20260706',
          ),
        ),
        const Positioned(
          left: 26,
          top: 710,
          child: _SectionHeading('Module Status'),
        ),
        const Positioned(
          left: 43,
          top: 769,
          child: Text('Module', style: _tableHeaderStyle),
        ),
        const Positioned(
          left: 211,
          top: 769,
          child: Text('Online Status', style: _tableHeaderStyle),
        ),
        const Positioned(
          right: 26,
          top: 769,
          child: Text('Health Status', style: _tableHeaderStyle),
        ),
        const Positioned(
          left: 26,
          right: 26,
          top: 795,
          child: Divider(height: 1, thickness: 1, color: Color(0xFF303139)),
        ),
        const Positioned(
          left: 26,
          right: 26,
          top: 796,
          child: _ModuleStatusTable(),
        ),
        // const Positioned(left: 26, top: 1114, child: _SectionHeading('运行统计')),
        // const Positioned(
        //   left: 26,
        //   right: 26,
        //   top: 1171,
        //   child: _RuntimeStatistics(),
        // ),
      ],
    );
    if (!decorated) {
      return content;
    }
    return DecoratedBox(
      decoration: _panelDecoration,
      child: ClipRRect(borderRadius: BorderRadius.circular(20), child: content),
    );
  }
}

class _ModuleStatusTable extends StatelessWidget {
  const _ModuleStatusTable();

  static const List<String> _modules = <String>[
    'Main Controller',
    'PEMF Controller',
    'Red Light Controller',
    'VAT Audio',
    'Molecular Hydrogen',
    'Temperature Monitor',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _modules
          .map((String module) => _ModuleStatusRow(module: module))
          .toList(),
    );
  }
}

// 多功能理疗仓 正常运行

Widget secondRow() {
  return Row(
    children: [
      const Text(
        '	Wellness Pod',
        style: TextStyle(color: Colors.white, fontSize: 20, height: 1),
      ),
      SizedBox(width: 24),
      _RunningBadge(),
    ],
  );
}

class _ModuleStatusRow extends StatelessWidget {
  const _ModuleStatusRow({required this.module});

  final String module;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF303139), width: 1)),
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: <Widget>[
          const Positioned(
            left: 0,
            child: SizedBox(
              width: 6,
              height: 6,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFF32DA82),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Positioned(left: 17, child: Text(module, style: _moduleTextStyle)),
          const Positioned(
            left: 200,
            child: Text('Online', style: _statusTextStyle),
          ),
          const Positioned(
            right: 12,
            child: Text('Normal', style: _statusTextStyle),
          ),
        ],
      ),
    );
  }
}

class _RuntimeStatistics extends StatelessWidget {
  const _RuntimeStatistics();

  static const List<_RuntimeStatData> _statistics = <_RuntimeStatData>[
    _RuntimeStatData('128', '设备累计运行'),
    _RuntimeStatData('45', 'PEMF累计运行'),
    _RuntimeStatData('56', '红光累计运行'),
    _RuntimeStatData('61', 'VAT累计运行'),
    _RuntimeStatData('23', '氢气累计运行'),
    _RuntimeStatData('352', '启动次数'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 174,
      child: Stack(
        children: <Widget>[
          for (int index = 0; index < _statistics.length; index++)
            Positioned(
              left: (index % 3) * 137,
              top: (index ~/ 3) * 87,
              width: 137,
              height: 75,
              child: _RuntimeStatCell(data: _statistics[index]),
            ),
          for (final double left in <double>[137, 274]) ...<Widget>[
            Positioned(
              left: left,
              top: 10,
              width: 1,
              height: 58,
              child: const ColoredBox(color: Color(0xFF2C2D35)),
            ),
            Positioned(
              left: left,
              top: 97,
              width: 1,
              height: 58,
              child: const ColoredBox(color: Color(0xFF2C2D35)),
            ),
          ],
        ],
      ),
    );
  }
}

class _RuntimeStatCell extends StatelessWidget {
  const _RuntimeStatCell({required this.data});

  final _RuntimeStatData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: <Widget>[
            Text(
              data.value,
              style: const TextStyle(
                color: Color(0xFFF7F7F8),
                fontSize: 24,
                height: 1,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 5),
            const Text(
              'h',
              style: TextStyle(
                color: Color(0xFFB9BAC0),
                fontSize: 12,
                height: 1,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 13),
        Text(data.label, style: _tableHeaderStyle),
      ],
    );
  }
}

class _RuntimeStatData {
  const _RuntimeStatData(this.value, this.label);

  final String value;
  final String label;
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SizedBox(
          width: 2,
          height: 20,
          child: ColoredBox(color: Color(0xFF1688FF)),
        ),
        const SizedBox(width: 7),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFF7F7F8),
            fontSize: 20,
            height: 1,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _RunningBadge extends StatelessWidget {
  const _RunningBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: const Color(0xFF244735),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: 6,
            height: 6,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFF32DA82),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(width: 7),
          Text(
            'Normal Operation',
            style: TextStyle(
              color: Color(0xFF32DA82),
              fontSize: 13,
              height: 1,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceInfoCell extends StatelessWidget {
  const _DeviceInfoCell({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 195,
      height: 90,
      child: Stack(
        children: <Widget>[
          Positioned(
            left: 0,
            top: 0,
            child: Icon(icon, size: 20, color: const Color(0xFFA8AAB1)),
          ),
          Positioned(left: 0, top: 31, child: Text(label, style: _labelStyle)),
          Positioned(
            left: 0,
            top: 59,
            child: Text(
              value,
              maxLines: 1,
              style: const TextStyle(
                color: Color(0xFFF4F4F6),
                fontSize: 17,
                height: 1,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VersionInfoCell extends StatelessWidget {
  const _VersionInfoCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 195,
      height: 62,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _labelStyle,
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFF4F4F6),
              fontSize: 17,
              height: 1,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItemData {
  const _MenuItemData(this.icon, this.label);

  final IconData icon;
  final String label;
}

const BoxDecoration _panelDecoration = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0xFF24252D), Color(0xFF1B1C22)],
  ),
  borderRadius: BorderRadius.all(Radius.circular(20)),
  border: Border.fromBorderSide(BorderSide(color: Color(0xFF44454E))),
);

const TextStyle _labelStyle = TextStyle(
  color: Color(0xFFA7A8AF),
  fontSize: 14,
  height: 1,
  fontWeight: FontWeight.w400,
);

const TextStyle _tableHeaderStyle = TextStyle(
  color: Color(0xFFA7A8AF),
  fontSize: 14,
  height: 1,
  fontWeight: FontWeight.w400,
);

const TextStyle _moduleTextStyle = TextStyle(
  color: Color(0xFFF0F0F3),
  fontSize: 14,
  height: 1,
  fontWeight: FontWeight.w400,
);

const TextStyle _statusTextStyle = TextStyle(
  color: Color(0xFF32DA82),
  fontSize: 14,
  height: 1,
  fontWeight: FontWeight.w400,
);

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infibo_app/pages/WifiBluetooth/connection_prompt_controller.dart';
import 'package:infibo_app/pages/WifiBluetooth/system_gateway.dart';

import 'wifi_ble_settings_controller.dart';
import 'settings_panel_style.dart';

/// 设置页中的 WIFI & BLE 连接详情面板。
///
/// 面板只在被选中时创建并轮询，离开该菜单后立即停止，避免在后台重复读取 Android
/// 的蓝牙 Profile。全局连接弹窗和这里共用 [SystemWifiBluetoothGateway] 的规则。
class WifiBleSettingsPanel extends StatefulWidget {
  const WifiBleSettingsPanel({
    super.key,
    this.gateway,
    this.refreshInterval = const Duration(seconds: 5),
  });

  /// 测试可注入网关；正式运行时使用系统网关读取真实连接详情。
  final ConnectionDetailsGateway? gateway;
  final Duration refreshInterval;

  @override
  State<WifiBleSettingsPanel> createState() => _WifiBleSettingsPanelState();
}

class _WifiBleSettingsPanelState extends State<WifiBleSettingsPanel>
    with WidgetsBindingObserver {
  late final ConnectionDetailsGateway _gateway;
  late final WifiBleSettingsController _controller;
  late final bool _ownsGateway;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _ownsGateway = widget.gateway == null;
    _gateway = widget.gateway ?? SystemWifiBluetoothGateway();
    _controller = WifiBleSettingsController(gateway: _gateway);
    WidgetsBinding.instance.addObserver(this);
    unawaited(_controller.initialize());
    _refreshTimer = Timer.periodic(
      widget.refreshInterval,
      (_) => unawaited(_controller.refresh()),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 用户从系统 Wi-Fi/蓝牙设置返回时立即刷新，不等待下一次定时轮询。
      unawaited(_controller.refresh());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    _controller.dispose();
    if (_ownsGateway && _gateway is SystemWifiBluetoothGateway) {
      unawaited(_gateway.dispose());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              // 右侧卡片已有 30px 顶部内边距；这里占 78px，使 Wi-Fi 行
              // 精确落在卡片顶部下方 108px，同时保持标题与其他设置页一致。
              height: 78,
              child: Align(
                alignment: AlignmentDirectional.topStart,
                child: Text('wifi_ble'.tr, style: settingsPanelTitleStyle),
              ),
            ),
            Padding(
              // 公共卡片已经提供左右 26px 内边距，无需额外叠加。
              padding: EdgeInsets.zero,
              child: _ConnectionDetailRow(
                key: const ValueKey<String>('settings_wifi_row'),
                iconAsset: 'assets/WifiBLE/wifi.png',
                title: 'connection_prompt_wifi'.tr,
                status: _controller.wifiStatus,
                detail: _wifiDetail,
                onTap: _controller.openWifiSettings,
              ),
            ),
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.zero,
              child: Divider(height: 1, thickness: 1, color: Color(0x12FFFFFF)),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: EdgeInsets.zero,
              child: _ConnectionDetailRow(
                key: const ValueKey<String>('settings_ble_row'),
                iconAsset: 'assets/WifiBLE/ble.png',
                title: 'connection_prompt_ble'.tr,
                status: _controller.bleStatus,
                detail: _bleDetail,
                onTap: _controller.openBluetoothSettings,
              ),
            ),
          ],
        );
      },
    );
  }

  String get _wifiDetail {
    if (_controller.wifiStatus == ConnectionCheckStatus.checking) {
      return 'connection_status_checking'.tr;
    }
    if (_controller.wifiStatus == ConnectionCheckStatus.disconnected) {
      return 'wifi_no_connected_network'.tr;
    }
    return _controller.wifiName ?? 'wifi_name_unavailable'.tr;
  }

  String get _bleDetail {
    if (_controller.bleStatus == ConnectionCheckStatus.checking) {
      return 'connection_status_checking'.tr;
    }
    return _controller.bluetoothName ?? 'ble_no_connected_device'.tr;
  }
}

class _ConnectionDetailRow extends StatelessWidget {
  const _ConnectionDetailRow({
    super.key,
    required this.iconAsset,
    required this.title,
    required this.status,
    required this.detail,
    required this.onTap,
  });

  final String iconAsset;
  final String title;
  final ConnectionCheckStatus status;
  final String detail;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    final (String statusText, Color statusColor) = _statusPresentation;
    // 连接行只保留最基础的点击能力：不使用 InkWell，避免水波纹、点击声和
    // 额外的视觉反馈；opaque 让整行空白区域仍可点击。
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => unawaited(onTap()),
      child: Row(
        children: <Widget>[
          Transform.translate(
            offset: const Offset(0, -14.5),
            child: SizedBox(
              width: 32,
              height: 32,
              child: Image.asset(
                iconAsset,
                fit: BoxFit.contain,
                // 与全局弹窗保持一致：断线置灰，检测中和已连接保持蓝色。
                color: status == ConnectionCheckStatus.disconnected
                    ? const Color(0xFFB6B6B6)
                    : null,
                colorBlendMode: BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontSize: 22),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          statusText,
                          maxLines: 1,
                          style: TextStyle(color: statusColor, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFB6B6B6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Transform.flip(
            flipX: Directionality.of(context) == TextDirection.rtl,
            child: Image.asset(
              'assets/WifiBLE/enter.png',
              width: 24,
              height: 24,
              color: const Color(0xFFB6B6B6),
              colorBlendMode: BlendMode.srcIn,
            ),
          ),
        ],
      ),
    );
  }

  (String, Color) get _statusPresentation => switch (status) {
    ConnectionCheckStatus.checking => (
      'connection_status_checking'.tr,
      // 检测中使用品牌蓝色，便于和灰色的未连接状态区分。
      const Color(0xFF42B7FF),
    ),
    ConnectionCheckStatus.connected => (
      'connection_status_connected'.tr,
      const Color(0xFF48F46D),
    ),
    ConnectionCheckStatus.disconnected => (
      'connection_status_disconnected'.tr,
      const Color(0xFFB6B6B6),
    ),
  };
}

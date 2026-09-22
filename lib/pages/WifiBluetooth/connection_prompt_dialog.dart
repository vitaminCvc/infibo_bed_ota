import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'connection_prompt_controller.dart';

class WifiBluetoothConnectionDialog extends StatelessWidget {
  const WifiBluetoothConnectionDialog({super.key, required this.controller});

  /// 连接提示对话框控制器。
  final ConnectionPromptController controller;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: 448,
        height: 480,
        child: Stack(
          children: <Widget>[
            // 背景和内容都使用 448 × 480 设计稿坐标，避免不同页面下发生偏移。
            Positioned.fill(
              child: Image.asset('assets/WifiBLE/bg.png', fit: BoxFit.fill),
            ),

            /// 标题
            Positioned(
              left: 0,
              right: 0,
              top: 34,
              height: 30,
              child: Center(
                child: FittedBox(
                  // 正常长度保持 24 号，仅在极端长译文超出宽度时缩小。
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'connection_prompt_title'.tr,
                    maxLines: 1,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      // 固定行高，避免字体默认上下留白触发 FittedBox 高度压缩。
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),

            /// 副标题
            Positioned(
              left: 0,
              right: 0,
              top: 80,
              height: 24,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'connection_prompt_subtitle'.tr,
                  maxLines: 1,
                  style: const TextStyle(
                    color: Color(0xFFB6B6B6),
                    fontSize: 18,
                    // 与主标题一致，正常文案按声明的 18 号字体渲染。
                    height: 1,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 32,
              top: 138,
              child: _ConnectionRow(
                key: const ValueKey<String>('connection_prompt_wifi_row'),
                iconBackgroundKey: const ValueKey<String>(
                  'connection_prompt_wifi_icon_bg',
                ),
                enterTransformKey: const ValueKey<String>(
                  'connection_prompt_wifi_enter_transform',
                ),
                iconAsset: 'assets/WifiBLE/wifi.png',
                label: 'connection_prompt_wifi'.tr,
                status: controller.wifiStatus,
                onTap: controller.openWifiSettings,
              ),
            ),
            Positioned(
              left: 32,
              top: 262,
              child: _ConnectionRow(
                key: const ValueKey<String>('connection_prompt_ble_row'),
                iconBackgroundKey: const ValueKey<String>(
                  'connection_prompt_ble_icon_bg',
                ),
                enterTransformKey: const ValueKey<String>(
                  'connection_prompt_ble_enter_transform',
                ),
                iconAsset: 'assets/WifiBLE/ble.png',
                label: 'connection_prompt_ble'.tr,
                status: controller.bleStatus,
                onTap: controller.openBluetoothSettings,
              ),
            ),
            const Positioned(
              left: 32,
              right: 32,
              top: 398,
              child: Divider(
                key: ValueKey<String>('connection_prompt_divider'),
                height: 1,
                thickness: 1,
                color: Color(0x1AFFFFFF),
              ),
            ),
            Positioned(
              left: 32,
              right: 32,
              top: 410,
              height: 46,
              child: TextButton(
                onPressed: controller.skipForCurrentRun,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFB6B6B6),
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                child: Text('connection_prompt_skip'.tr),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectionRow extends StatelessWidget {
  const _ConnectionRow({
    super.key,
    required this.iconBackgroundKey,
    required this.enterTransformKey,
    required this.iconAsset,
    required this.label,
    required this.status,
    required this.onTap,
  });

  final Key iconBackgroundKey;
  final Key enterTransformKey;
  final String iconAsset;
  final String label;
  final ConnectionCheckStatus status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (String statusLabel, Color statusColor) = _statusPresentation(status);

    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0x1AFFFFFF)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: 384,
          height: 104,
          child: Row(
            children: <Widget>[
              const SizedBox(width: 20),
              Container(
                key: iconBackgroundKey,
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  // 半透明浅色叠加在渐变背景上，保持参考图中的明暗变化。
                  color: Color(0x0FFFFFFF),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Image.asset(
                  iconAsset,
                  width: 30,
                  height: 30,
                  // 仅断线状态使用中性灰；检测中和已连接保留资源原本的蓝色。
                  color: status == ConnectionCheckStatus.disconnected
                      ? const Color(0xFFB6B6B6)
                      : null,
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: <Widget>[
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              statusLabel,
                              maxLines: 1,
                              // 参考图仅用圆点区分状态，文字始终保持中性灰色。
                              style: const TextStyle(
                                color: Color(0xFFB6B6B6),
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Transform.flip(
                key: enterTransformKey,
                flipX: Directionality.of(context) == TextDirection.rtl,
                child: Image.asset(
                  'assets/WifiBLE/enter.png',
                  width: 24,
                  height: 24,
                  // 弹窗两行共用灰色进入箭头，连接状态不改变箭头颜色。
                  color: const Color(0xFFB6B6B6),
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
        ),
      ),
    );
  }

  (String, Color) _statusPresentation(ConnectionCheckStatus status) {
    // 检测完成前沿用未连接色，避免用户误以为设备已经连接。
    return switch (status) {
      ConnectionCheckStatus.checking => (
        /// 检测中
        'connection_status_checking'.tr,
        const Color(0xFF42B7FF),
      ),

      /// 已连接
      ConnectionCheckStatus.connected => (
        'connection_status_connected'.tr,
        const Color(0xFF48F46D),
      ),

      /// 已断开
      ConnectionCheckStatus.disconnected => (
        'connection_status_disconnected'.tr,
        const Color(0xFFB6B6B6),
      ),
    };
  }
}

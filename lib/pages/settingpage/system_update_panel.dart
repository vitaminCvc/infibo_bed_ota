import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infibo_app/ota/ota_controller.dart';
import 'package:infibo_app/ota/ota_manifest.dart';
import 'settings_panel_style.dart';

String boardVersionText(int? value) => value == null
    ? 'ota_unknown'.tr
    : '${(value >> 8) & 15}.${(value >> 4) & 15}.${value & 15}';

class SystemUpdatePanel extends StatefulWidget {
  const SystemUpdatePanel({super.key, this.controller});
  final OtaController? controller;
  @override
  State<SystemUpdatePanel> createState() => _SystemUpdatePanelState();
}

class _SystemUpdatePanelState extends State<SystemUpdatePanel> {
  late final OtaController controller =
      widget.controller ?? OtaController.instance;
  @override
  void initState() {
    super.initState();
    if (controller.installed == null) unawaited(controller.refresh());
  }

  Future<void> _confirm(AppRelease release) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ota_confirm_app'.tr),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Text(
              '${release.version}\n\n${release.notes}\n\n${'ota_confirm_hint'.tr}',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('ota_later'.tr),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('ota_confirm'.tr),
          ),
        ],
      ),
    );
    if (accepted == true) await controller.updateApp();
  }

  Future<void> _confirmFirmware(FirmwareRelease release) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ota_confirm_board'.tr),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Text(
              '${release.version}\n\n${release.notes}\n\n${'ota_board_hint'.tr}',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('ota_later'.tr),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('ota_confirm'.tr),
          ),
        ],
      ),
    );
    if (accepted == true) await controller.updateFirmware();
  }

  Widget _card({
    required String title,
    required String current,
    required String? latest,
    required bool available,
    required Widget button,
    String notes = '',
  }) => Container(
    padding: const EdgeInsets.all(18),
    margin: const EdgeInsets.only(bottom: 18),
    decoration: BoxDecoration(
      color: const Color(0xff171923),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 21)),
        const SizedBox(height: 12),
        Text(
          'ota_current'.trParams({'version': current}),
          style: const TextStyle(color: Colors.white70, fontSize: 17),
        ),
        const SizedBox(height: 6),
        Text(
          'ota_latest'.trParams({'version': latest ?? '—'}),
          style: const TextStyle(color: Colors.white70, fontSize: 17),
        ),
        if (notes.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            notes,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white60, fontSize: 15),
          ),
        ],
        const SizedBox(height: 14),
        Text(
          (available
                  ? 'ota_available'
                  : latest == null
                  ? 'ota_unknown'
                  : 'ota_latest_installed')
              .tr,
          style: TextStyle(
            color: available ? const Color(0xff83b5ff) : Colors.white54,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 12),
        button,
      ],
    ),
  );
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) => SingleChildScrollView(
      child: DefaultTextStyle.merge(
        style: const TextStyle(fontFamily: settingsFontFamily),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'system_update'.tr,
                    style: settingsPanelTitleStyle,
                  ),
                ),
                TextButton(
                  onPressed:
                      controller.busy || controller.phase == OtaPhase.checking
                      ? null
                      : controller.refresh,
                  child: Text('ota_check'.tr),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _card(
              title: 'ota_app'.tr,
              current: controller.installed?.version ?? 'ota_unknown'.tr,
              latest: controller.manifest?.app?.version,
              available: controller.appAvailable,
              notes: controller.manifest?.app?.notes ?? '',
              button: FilledButton(
                key: const ValueKey('ota-app-update'),
                onPressed:
                    controller.busy ||
                        controller.checking ||
                        !controller.appAvailable
                    ? null
                    : () => _confirm(controller.manifest!.app!),
                child: Text('ota_update'.tr),
              ),
            ),
            _card(
              title: 'ota_board'.tr,
              current: boardVersionText(controller.boardVersion),
              latest: controller.manifest?.firmware?.version,
              available: controller.firmwareAvailable,
              button: FilledButton(
                key: const ValueKey('ota-board-update'),
                onPressed:
                    controller.busy ||
                        controller.checking ||
                        !controller.firmwareAvailable
                    ? null
                    : () => _confirmFirmware(controller.manifest!.firmware!),
                child: Text('ota_update'.tr),
              ),
            ),
            if (controller.phase == OtaPhase.needsPermission)
              FilledButton(
                onPressed: controller.openInstallPermission,
                child: Text('ota_permission'.tr),
              ),
            if (controller.errorKey != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  controller.errorKey!.trParams({
                    'code': '${controller.boardErrorCode ?? 0}',
                  }),
                  style: const TextStyle(
                    color: Color(0xffffc080),
                    fontSize: 16,
                  ),
                ),
              ),
            if (controller.noticeKey != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  controller.noticeKey!.tr,
                  style: const TextStyle(
                    color: Color(0xff83b5ff),
                    fontSize: 16,
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Text(
              controller.phaseKey.tr,
              style: const TextStyle(color: Colors.white60, fontSize: 15),
            ),
          ],
        ),
      ),
    ),
  );
}

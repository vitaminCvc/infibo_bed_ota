import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infibo_app/ota/ota_controller.dart';
import 'package:infibo_app/ota/ota_manifest.dart';
import 'package:infibo_app/ota/ota_update_style.dart';
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
    // The app-wide OTA overlay also listens to this controller. Start after
    // mounting so refresh notifications cannot rebuild ancestors mid-build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(controller.refresh());
    });
  }

  Future<void> _confirm(OtaFile release, {required bool firmware}) async {
    final accepted = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0x99000000),
      builder: (context) => UpdateConfirmationDialog(
        release: release,
        firmware: firmware,
        currentBoardVersion: controller.boardVersion,
      ),
    );
    if (accepted == true && mounted) {
      if (firmware) {
        await controller.updateFirmware();
      } else {
        await controller.updateApp();
      }
    }
  }

  Widget _header() => LayoutBuilder(
    builder: (context, constraints) {
      final check = ElevatedButton.icon(
        key: const ValueKey('ota-check'),
        onPressed: controller.busy || controller.checking
            ? null
            : controller.refresh,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff1266ff),
          disabledBackgroundColor: const Color(
            0xff1266ff,
          ).withValues(alpha: 0.4),
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white70,
          minimumSize: const Size(96, 40),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: const StadiumBorder(),
          shadowColor: const Color(0xff1266ff).withValues(alpha: 0.45),
          elevation: 6,
          textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontFamily: settingsFontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 20 / 14,
          ),
        ),
        icon: controller.checking
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.refresh, size: 18),
        label: Text('ota_check'.tr),
      );
      final heading = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('system_update'.tr, style: settingsPanelTitleStyle),
          const SizedBox(height: 8),
          Text(
            controller.checking
                ? 'ota_checking'.tr
                : controller.checkedAt == null
                ? 'ota_check_intro'.tr
                : 'ota_last_checked'.trParams({
                    'time': _checkedTime(controller.checkedAt!),
                  }),
            style: const TextStyle(
              color: Color(0xffb7b7bd),
              fontSize: 14,
              height: 20 / 14,
            ),
          ),
        ],
      );
      final compact =
          constraints.maxWidth < 360 ||
          MediaQuery.textScalerOf(context).scale(16) > 22;
      return compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [heading, const SizedBox(height: 16), check],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: heading),
                const SizedBox(width: 12),
                check,
              ],
            );
    },
  );

  String _checkedTime(DateTime value) {
    final local = value.toLocal();
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${local.year}-${pad(local.month)}-${pad(local.day)} ${pad(local.hour)}:${pad(local.minute)}';
  }

  Widget? _feedback() {
    if (controller.checking || controller.busy) return null;
    // phaseKey often repeats errorKey or noticeKey. Display one task result.
    final key =
        controller.errorKey ??
        controller.noticeKey ??
        (controller.phase != OtaPhase.idle &&
                !controller.checking &&
                !controller.busy
            ? controller.phaseKey
            : null);
    if (key == null) return null;
    final warning =
        controller.errorKey != null ||
        key == 'ota_install_not_completed' ||
        key == 'ota_board_reinstall_unverified';
    return Semantics(
      liveRegion: true,
      child: Container(
        key: const ValueKey('ota-result'),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: OtaUpdateStyle.inset,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: OtaUpdateStyle.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExcludeSemantics(
                  child: Icon(
                    warning
                        ? Icons.info_outline_rounded
                        : Icons.check_circle_outline_rounded,
                    color: warning
                        ? OtaUpdateStyle.warning
                        : OtaUpdateStyle.accent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    key.trParams({'code': '${controller.boardErrorCode ?? 0}'}),
                    style: OtaUpdateStyle.body.copyWith(
                      color: warning
                          ? OtaUpdateStyle.warning
                          : OtaUpdateStyle.foreground,
                    ),
                  ),
                ),
              ],
            ),
            if (controller.phase == OtaPhase.needsPermission) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: controller.openInstallPermission,
                child: Text('ota_permission'.tr),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: OtaUpdateStyle.theme(context),
    child: AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final app = controller.manifest?.app;
        final installed = controller.installed;
        final firmware = controller.manifest?.firmware;
        final board = controller.boardVersion;
        final ready =
            !controller.busy &&
            !controller.checking &&
            controller.phase != OtaPhase.needsPermission;
        final hasManifest = controller.manifest != null;
        final appStatus = controller.checking
            ? 'ota_status_checking'
            : app == null || installed == null
            ? 'ota_status_pending'
            : controller.appAvailable
            ? 'ota_status_available'
            : 'ota_status_current';
        final appHint = controller.checking
            ? 'ota_checking'
            : installed == null
            ? 'ota_unknown'
            : app == null
            ? (hasManifest ? 'ota_no_release' : 'ota_release_unavailable')
            : app.versionCode < installed.versionCode
            ? 'ota_app_higher_installed'
            : controller.appAvailable
            ? 'ota_available'
            : 'ota_app_target_installed';
        final boardAction = firmware != null && board != null
            ? firmware.versionRegister == board
                  ? 'ota_up_to_date_button'
                  : firmware.versionRegister < board
                  ? 'ota_board_downgrade'
                  : 'ota_update'
            : null;
        final boardStatus = controller.checking
            ? 'ota_status_checking'
            : board == null
            ? 'ota_status_connection'
            : firmware == null
            ? 'ota_status_pending'
            : firmware.versionRegister == board
            ? 'ota_status_current'
            : firmware.versionRegister < board
            ? 'ota_status_older'
            : 'ota_status_available';
        final boardHint = controller.checking
            ? 'ota_checking'
            : board == null
            ? 'ota_board_connection_hint'
            : firmware == null
            ? (hasManifest ? 'ota_no_release' : 'ota_release_unavailable')
            : firmware.versionRegister == board
            ? ''
            : firmware.versionRegister < board
            ? 'ota_board_lower_available'
            : 'ota_board_target_available';
        final feedback = _feedback();
        return SingleChildScrollView(
          child: DefaultTextStyle.merge(
            style: const TextStyle(
              fontFamily: settingsFontFamily,
              color: OtaUpdateStyle.foreground,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _header(),
                const SizedBox(height: 24),
                if (feedback != null) ...[feedback, const SizedBox(height: 20)],
                _ReleaseCard(
                  icon: Icons.apps_rounded,
                  title: 'ota_app'.tr,
                  status: appStatus.tr,
                  statusColor: controller.appAvailable
                      ? OtaUpdateStyle.success
                      : OtaUpdateStyle.secondary,
                  highlighted: controller.appAvailable,
                  current: installed?.version ?? 'ota_unknown'.tr,
                  published: app?.version,
                  hint:
                      appHint == 'ota_available' ||
                          appHint == 'ota_app_target_installed'
                      ? ''
                      : appHint.tr,
                  action: app != null && installed != null
                      ? FilledButton.icon(
                          key: const ValueKey('ota-app-update'),
                          onPressed: ready && controller.appAvailable
                              ? () => _confirm(app, firmware: false)
                              : null,
                          icon: const Icon(Icons.download_rounded, size: 20),
                          label: Text(
                            (controller.appAvailable
                                    ? 'ota_update'
                                    : 'ota_up_to_date_button')
                                .tr,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 20),
                _ReleaseCard(
                  icon: Icons.memory_outlined,
                  title: 'ota_board'.tr,
                  status: boardStatus.tr,
                  statusColor: boardStatus == 'ota_status_available'
                      ? OtaUpdateStyle.success
                      : OtaUpdateStyle.secondary,
                  highlighted:
                      firmware != null &&
                      board != null &&
                      firmware.versionRegister != board,
                  current: boardVersionText(board),
                  published: firmware?.version,
                  hint: boardHint == 'ota_board_target_available'
                      ? ''
                      : boardHint.tr,
                  action: boardAction == null
                      ? null
                      : FilledButton.icon(
                          key: const ValueKey('ota-board-update'),
                          onPressed: ready && firmware!.versionRegister != board
                              ? () => _confirm(firmware, firmware: true)
                              : null,
                          icon: const Icon(Icons.download_rounded, size: 20),
                          label: Text(boardAction.tr),
                        ),
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ExcludeSemantics(
                      child: Icon(
                        Icons.power_settings_new_rounded,
                        size: 18,
                        color: OtaUpdateStyle.secondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'ota_power_hint'.tr,
                        style: OtaUpdateStyle.caption,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    ),
  );
}

class _ReleaseCard extends StatelessWidget {
  const _ReleaseCard({
    required this.icon,
    required this.title,
    required this.status,
    required this.statusColor,
    required this.highlighted,
    required this.current,
    required this.published,
    required this.hint,
    this.action,
  });
  final String title, status, current, hint;
  final Color statusColor;
  final String? published;
  final IconData icon;
  final bool highlighted;
  final Widget? action;
  Widget _version(String label, String value, {bool target = false}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: OtaUpdateStyle.caption),
      const SizedBox(height: 6),
      Text(
        value,
        style: TextStyle(
          fontSize: 24,
          height: 1.3,
          fontWeight: FontWeight.w600,
          color: target && highlighted
              ? OtaUpdateStyle.accent
              : OtaUpdateStyle.foreground,
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: OtaUpdateStyle.cardDecoration,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ExcludeSemantics(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: OtaUpdateStyle.inset,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 24, color: OtaUpdateStyle.foreground),
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                height: 1.5,
                fontWeight: FontWeight.w600,
                color: OtaUpdateStyle.foreground,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ExcludeSemantics(
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusColor,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    status,
                    style: OtaUpdateStyle.caption.copyWith(color: statusColor),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(height: 1, color: OtaUpdateStyle.border),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final currentView = _version('ota_installed_label'.tr, current);
            final publishedView = _version(
              'ota_published_label'.tr,
              published ?? '—',
              target: true,
            );
            final stacked =
                constraints.maxWidth < 300 ||
                MediaQuery.textScalerOf(context).scale(16) > 22;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: stacked
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        currentView,
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(
                            height: 1,
                            color: OtaUpdateStyle.border,
                          ),
                        ),
                        publishedView,
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: currentView),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(left: 24),
                            decoration: const BoxDecoration(
                              border: Border(
                                left: BorderSide(color: OtaUpdateStyle.border),
                              ),
                            ),
                            child: publishedView,
                          ),
                        ),
                      ],
                    ),
            );
          },
        ),
        if (hint.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(hint, style: OtaUpdateStyle.body),
        ],
        if (action != null) ...[const SizedBox(height: 20), action!],
      ],
    ),
  );
}

/// Matches the home Wi-Fi dialog frame, with adaptive update content.
class UpdateConfirmationDialog extends StatelessWidget {
  const UpdateConfirmationDialog({
    super.key,
    required this.release,
    required this.firmware,
    required this.currentBoardVersion,
  });
  final OtaFile release;
  final bool firmware;
  final int? currentBoardVersion;

  @override
  Widget build(BuildContext context) => Theme(
    data: OtaUpdateStyle.theme(context),
    child: Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        key: const ValueKey('ota-confirmation-frame'),
        constraints: const BoxConstraints(maxWidth: 448, minHeight: 360),
        padding: EdgeInsets.all(
          MediaQuery.sizeOf(context).width < 400 ? 24 : 32,
        ),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/WifiBLE/bg.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: DefaultTextStyle(
          style: OtaUpdateStyle.body,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        (firmware ? 'ota_confirm_board' : 'ota_confirm_app').tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: settingsFontFamily,
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        firmware
                            ? '${boardVersionText(currentBoardVersion)} → ${release.version}'
                            : release.version,
                        textAlign: TextAlign.center,
                        style: OtaUpdateStyle.body.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 24),
                      const Divider(height: 1, color: Color(0x1affffff)),
                      const SizedBox(height: 20),
                      Text('ota_notes'.tr, style: OtaUpdateStyle.notesTitle),
                      const SizedBox(height: 8),
                      Text(
                        release.notesFor(Get.locale?.toString()).trim().isEmpty
                            ? 'ota_notes_empty'.tr
                            : release.notesFor(Get.locale?.toString()),
                        style: OtaUpdateStyle.body,
                      ),
                      const SizedBox(height: 20),
                      const Divider(height: 1, color: OtaUpdateStyle.border),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const ExcludeSemantics(
                            child: Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: Icon(
                                Icons.info_outline_rounded,
                                size: 16,
                                color: OtaUpdateStyle.secondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              (firmware ? 'ota_board_hint' : 'ota_confirm_hint')
                                  .tr,
                              style: OtaUpdateStyle.caption,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  final later = FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xff3c4045),
                      foregroundColor: OtaUpdateStyle.secondary,
                    ),
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('ota_later'.tr),
                  );
                  final confirm = FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text('ota_confirm'.tr),
                  );
                  final stacked =
                      constraints.maxWidth < 300 ||
                      MediaQuery.textScalerOf(context).scale(16) > 22;
                  return stacked
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            later,
                            const SizedBox(height: 12),
                            confirm,
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(child: later),
                            const SizedBox(width: 16),
                            Expanded(child: confirm),
                          ],
                        );
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

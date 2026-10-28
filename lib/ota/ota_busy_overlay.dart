import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ota_controller.dart';
import 'ota_update_style.dart';
import '../pages/settingpage/settings_panel_style.dart';

class OtaBusyOverlay extends StatefulWidget {
  const OtaBusyOverlay({super.key, required this.child, this.controller});
  final Widget child;
  final OtaController? controller;
  @override
  State<OtaBusyOverlay> createState() => _OtaBusyOverlayState();
}

class _OtaBusyOverlayState extends State<OtaBusyOverlay>
    with WidgetsBindingObserver {
  late final controller = widget.controller ?? OtaController.instance;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(controller.restore());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(controller.resume());
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) => Stack(
      children: [
        widget.child,
        if (controller.busy) ...[
          const Positioned.fill(
            child: ModalBarrier(dismissible: false, color: Color(0xc9000000)),
          ),
          Positioned.fill(
            child: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Theme(
                    data: OtaUpdateStyle.theme(context),
                    child: DefaultTextStyle(
                      style: const TextStyle(
                        fontFamily: settingsFontFamily,
                        decoration: TextDecoration.none,
                        color: OtaUpdateStyle.foreground,
                        fontSize: 16,
                      ),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 430),
                        padding: const EdgeInsets.all(24),
                        decoration: OtaUpdateStyle.dialogDecoration,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const ExcludeSemantics(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Icon(
                                    Icons.system_update_alt_rounded,
                                    color: OtaUpdateStyle.accent,
                                    size: 28,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Semantics(
                                liveRegion: true,
                                child: Text(
                                  controller.phaseKey.tr,
                                  style: const TextStyle(
                                    color: OtaUpdateStyle.foreground,
                                    fontSize: 22,
                                    height: 1.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              TickerMode(
                                enabled: !MediaQuery.disableAnimationsOf(
                                  context,
                                ),
                                child: LinearProgressIndicator(
                                  borderRadius: BorderRadius.circular(4),
                                  value:
                                      (controller.phase ==
                                              OtaPhase.downloading ||
                                          controller.phase ==
                                              OtaPhase.transferring)
                                      ? controller.progress.clamp(0, 1)
                                      : null,
                                  semanticsLabel: controller.phaseKey.tr,
                                ),
                              ),
                              if (controller.phase == OtaPhase.downloading ||
                                  controller.phase ==
                                      OtaPhase.transferring) ...[
                                const SizedBox(height: 12),
                                Text(
                                  '${(controller.progress.clamp(0, 1) * 100).round()}%',
                                  style: const TextStyle(
                                    color: OtaUpdateStyle.foreground,
                                    fontSize: 24,
                                    height: 1.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 20),
                              Text(
                                (controller.phase == OtaPhase.downloading
                                        ? 'ota_download_hint'
                                        : 'ota_power_hint')
                                    .tr,
                                style: OtaUpdateStyle.body,
                              ),
                              if (controller.canCancel) ...[
                                const SizedBox(height: 24),
                                OutlinedButton(
                                  key: const ValueKey('ota-progress-cancel'),
                                  onPressed: controller.cancel,
                                  child: Text(
                                    (controller.phase == OtaPhase.transferring
                                            ? 'ota_cancel_transfer'
                                            : controller.phase ==
                                                  OtaPhase.downloading
                                            ? 'ota_cancel'
                                            : 'ota_cancel_update')
                                        .tr,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

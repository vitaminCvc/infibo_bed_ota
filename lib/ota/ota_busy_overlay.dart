import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ota_controller.dart';

class OtaBusyOverlay extends StatefulWidget {
  const OtaBusyOverlay({super.key, required this.child});
  final Widget child;
  @override
  State<OtaBusyOverlay> createState() => _OtaBusyOverlayState();
}

class _OtaBusyOverlayState extends State<OtaBusyOverlay>
    with WidgetsBindingObserver {
  final controller = OtaController.instance;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(controller.metadata());
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
            child: Center(
              child: Container(
                width: 430,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: const Color(0xff252936),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      controller.phaseKey.tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 21),
                    ),
                    const SizedBox(height: 22),
                    LinearProgressIndicator(
                      value:
                          (controller.phase == OtaPhase.downloading ||
                              controller.phase == OtaPhase.transferring)
                          ? controller.progress
                          : null,
                    ),
                    if ((controller.phase == OtaPhase.downloading ||
                        controller.phase == OtaPhase.transferring)) ...[
                      const SizedBox(height: 12),
                      Text(
                        '${(controller.progress * 100).round()}%',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                        ),
                      ),
                    ],
                    if (controller.canCancel) ...[
                      const SizedBox(height: 18),
                      TextButton(
                        onPressed: controller.cancel,
                        child: Text('ota_cancel'.tr),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

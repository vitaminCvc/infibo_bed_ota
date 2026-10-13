import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:infibo_app/constants/color.dart';
import 'package:infibo_app/constants/layout.dart';

class AppLayoutScope extends InheritedWidget {
  const AppLayoutScope({super.key, required this.layout, required super.child});

  final AppLayoutMetrics layout;

  static AppLayoutMetrics of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<AppLayoutScope>()
            ?.layout ??
        AppLayout.ratio16x10;
  }

  @override
  bool updateShouldNotify(AppLayoutScope oldWidget) =>
      layout != oldWidget.layout;
}

class DesignCanvas extends StatelessWidget {
  const DesignCanvas({super.key, required this.child});

  final Widget child;

  static EdgeInsets _mapHostInsets({
    required Size hostSize,
    required EdgeInsets hostInsets,
    required Size designSize,
  }) {
    final double scale = math.min(
      hostSize.width / designSize.width,
      hostSize.height / designSize.height,
    );
    if (!scale.isFinite || scale <= 0) return EdgeInsets.zero;

    final double horizontalLetterbox =
        (hostSize.width - designSize.width * scale) / 2;
    final double verticalLetterbox =
        (hostSize.height - designSize.height * scale) / 2;

    double toDesignInset(double hostInset, double letterbox) {
      return math.max(0, (hostInset - letterbox) / scale);
    }

    return EdgeInsets.fromLTRB(
      toDesignInset(hostInsets.left, horizontalLetterbox),
      toDesignInset(hostInsets.top, verticalLetterbox),
      toDesignInset(hostInsets.right, horizontalLetterbox),
      toDesignInset(hostInsets.bottom, verticalLetterbox),
    );
  }

  static EdgeInsets _derivePadding({
    required EdgeInsets viewPadding,
    required EdgeInsets viewInsets,
  }) {
    return EdgeInsets.fromLTRB(
      math.max(viewPadding.left - viewInsets.left, 0),
      math.max(viewPadding.top - viewInsets.top, 0),
      math.max(viewPadding.right - viewInsets.right, 0),
      math.max(viewPadding.bottom - viewInsets.bottom, 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData hostMediaQuery = MediaQuery.of(context);

    return ColoredBox(
      color: AppTheme.primaryColor,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final Size hostSize = constraints.biggest;
          final AppLayoutMetrics layout = AppLayout.forHostSize(hostSize);
          final Size designSize = layout.designSize;
          final EdgeInsets designViewPadding = _mapHostInsets(
            hostSize: hostSize,
            hostInsets: hostMediaQuery.viewPadding,
            designSize: designSize,
          );
          final EdgeInsets designViewInsets = _mapHostInsets(
            hostSize: hostSize,
            hostInsets: hostMediaQuery.viewInsets,
            designSize: designSize,
          );
          final EdgeInsets designPadding = _derivePadding(
            viewPadding: designViewPadding,
            viewInsets: designViewInsets,
          );
          final double scale = math.min(
            hostSize.width / designSize.width,
            hostSize.height / designSize.height,
          );
          final double scaledDevicePixelRatio =
              hostMediaQuery.devicePixelRatio * scale;
          final double designDevicePixelRatio =
              scaledDevicePixelRatio.isFinite && scaledDevicePixelRatio > 0
              ? scaledDevicePixelRatio
              : hostMediaQuery.devicePixelRatio.isFinite &&
                    hostMediaQuery.devicePixelRatio > 0
              ? hostMediaQuery.devicePixelRatio
              : 1;

          final MediaQueryData designMediaQuery = hostMediaQuery.copyWith(
            size: designSize,
            devicePixelRatio: designDevicePixelRatio,
            padding: designPadding,
            viewPadding: designViewPadding,
            viewInsets: designViewInsets,
            systemGestureInsets: EdgeInsets.zero,
            displayFeatures: const [],
          );

          return SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.contain,
              alignment: Alignment.center,
              child: SizedBox.fromSize(
                size: designSize,
                child: MediaQuery(
                  data: designMediaQuery,
                  child: AppLayoutScope(layout: layout, child: child),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

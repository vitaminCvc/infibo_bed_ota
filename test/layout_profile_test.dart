// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:ui' show Size;

import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/constants/layout.dart';

void main() {
  group('AppLayout.forHostSize', () {
    test('detects 16:10 in portrait and landscape', () {
      expect(
        AppLayout.forHostSize(const Size(800, 1280)).profile,
        LayoutProfile.ratio16x10,
      );
      expect(
        AppLayout.forHostSize(const Size(1280, 800)).profile,
        LayoutProfile.ratio16x10,
      );
    });

    test('detects 16:9 in portrait and landscape', () {
      expect(
        AppLayout.forHostSize(const Size(1080, 1920)).profile,
        LayoutProfile.ratio16x9,
      );
      expect(
        AppLayout.forHostSize(const Size(1920, 1080)).profile,
        LayoutProfile.ratio16x9,
      );
    });

    test('uses an inclusive 16:9 aspect-ratio threshold', () {
      const epsilon = 0.000001;

      expect(
        AppLayout.forHostSize(
          const Size(AppLayout.ratio16x9Threshold - epsilon, 1),
        ).profile,
        LayoutProfile.ratio16x10,
      );
      expect(
        AppLayout.forHostSize(
          const Size(AppLayout.ratio16x9Threshold, 1),
        ).profile,
        LayoutProfile.ratio16x9,
      );
      expect(
        AppLayout.forHostSize(
          const Size(AppLayout.ratio16x9Threshold + epsilon, 1),
        ).profile,
        LayoutProfile.ratio16x9,
      );
    });

    test('falls back to 16:10 for square or invalid sizes', () {
      expect(
        AppLayout.forHostSize(const Size(1000, 1000)).profile,
        LayoutProfile.ratio16x10,
      );

      const invalidSizes = <Size>[
        Size.zero,
        Size(double.nan, 100),
        Size(100, double.nan),
        Size(double.infinity, 100),
        Size(100, double.infinity),
        Size(0, 100),
        Size(100, 0),
        Size(-1, 100),
        Size(100, -1),
      ];
      for (final size in invalidSizes) {
        expect(
          AppLayout.forHostSize(size).profile,
          LayoutProfile.ratio16x10,
          reason: '$size must use the safe fallback',
        );
      }
    });
  });

  group('AppLayoutMetrics', () {
    test('16:10 preserves legacy content coordinates', () {
      final metrics = AppLayout.ratio16x10;

      expect(metrics.designHeight, AppLayout.legacyViewportHeight);
      expect(metrics.addedHeight, 0);
      expect(metrics.contentTopOffset, 0);
      expect(metrics.standardContentHeight, 1160);
      expect(metrics.expandedContentHeight, 1088);
      expect(metrics.mainContentHeight, 1230);
      expect(metrics.spreadY(5, 10, 20), 10);
      expect(metrics.standardY(860), 860);
      expect(metrics.expandedY(860), 860);
      expect(metrics.mainY(1010), 1010);
      expect(metrics.viewportY(1010), 1010);
      expect(metrics.mainContentY(1010), 1010);
      expect(metrics.standardContentY(860), 860);
      expect(metrics.expandedContentY(860), 860);
      expect(metrics.viewportContentY(1010), 1010);
    });

    test('16:9 exposes exact dimensions and mapping formulas', () {
      final metrics = AppLayout.ratio16x9;
      const expectedDesignHeight = AppLayout.designWidth * 16 / 9;
      const expectedAddedHeight =
          expectedDesignHeight - AppLayout.legacyViewportHeight;
      const expectedStandardHeight = 1160 + expectedAddedHeight;
      const expectedExpandedHeight = 1088 + expectedAddedHeight;
      const expectedMainHeight = 1230 + expectedAddedHeight;

      expect(metrics.profile, LayoutProfile.ratio16x9);
      expect(metrics.is16x9, isTrue);
      expect(metrics.designHeight, expectedDesignHeight);
      expect(
        metrics.designSize,
        const Size(AppLayout.designWidth, expectedDesignHeight),
      );
      expect(metrics.addedHeight, expectedAddedHeight);
      expect(metrics.contentTopOffset, 40);
      expect(metrics.standardContentHeight, expectedStandardHeight);
      expect(metrics.expandedContentHeight, expectedExpandedHeight);
      expect(metrics.mainContentHeight, expectedMainHeight);

      expect(metrics.standardY(0), 0);
      expect(metrics.standardY(1160), expectedStandardHeight);
      expect(metrics.expandedY(0), 0);
      expect(metrics.expandedY(1088), expectedExpandedHeight);
      expect(metrics.mainY(0), 0);
      expect(metrics.mainY(1230), expectedMainHeight);
      expect(metrics.viewportY(0), 0);
      expect(metrics.viewportY(1280), expectedDesignHeight);
      expect(metrics.standardContentY(1160), expectedStandardHeight + 40);
      expect(metrics.expandedContentY(1088), expectedExpandedHeight + 40);
      expect(metrics.mainContentY(1230), expectedMainHeight + 40);
      expect(metrics.viewportContentY(1280), expectedDesignHeight + 40);
    });

    test('legacy static API safely delegates to 16:10 metrics', () {
      final metrics = AppLayout.ratio16x10;
      const legacyY = 700.0;

      expect(AppLayout.designHeight, metrics.designHeight);
      expect(AppLayout.addedHeight, metrics.addedHeight);
      expect(AppLayout.contentTopOffset, metrics.contentTopOffset);
      expect(AppLayout.standardContentHeight, metrics.standardContentHeight);
      expect(AppLayout.expandedContentHeight, metrics.expandedContentHeight);
      expect(AppLayout.mainContentHeight, metrics.mainContentHeight);
      expect(AppLayout.spreadY(5, 10, 20), metrics.spreadY(5, 10, 20));
      expect(AppLayout.standardY(legacyY), metrics.standardY(legacyY));
      expect(AppLayout.expandedY(legacyY), metrics.expandedY(legacyY));
      expect(AppLayout.mainY(legacyY), metrics.mainY(legacyY));
      expect(AppLayout.viewportY(legacyY), metrics.viewportY(legacyY));
      expect(
        AppLayout.standardContentY(legacyY),
        metrics.standardContentY(legacyY),
      );
      expect(
        AppLayout.expandedContentY(legacyY),
        metrics.expandedContentY(legacyY),
      );
      expect(AppLayout.mainContentY(legacyY), metrics.mainContentY(legacyY));
      expect(
        AppLayout.viewportContentY(legacyY),
        metrics.viewportContentY(legacyY),
      );
    });
  });
}

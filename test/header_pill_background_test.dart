import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:infibo_app/components/header_controls.dart';
import 'package:infibo_app/components/header_pill_background.dart';
import 'package:infibo_app/constants/assets.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.locale = const Locale('en', 'US');
  });

  tearDown(() => Get.reset());

  for (final source in [
    (
      variant: HeaderPillVariant.settings,
      asset: Assets.headerSettingsBackground,
      width: 90.0,
    ),
    (
      variant: HeaderPillVariant.user,
      asset: Assets.headerUserBackground,
      width: 108.0,
    ),
  ]) {
    testWidgets(
      'native ${source.variant.name} gradient matches the original SVG',
      (tester) async {
        final reference = await _render(
          tester,
          SizedBox(
            width: source.width,
            height: 48,
            child: SvgPicture.asset(source.asset, fit: BoxFit.fill),
          ),
        );
        final native = await _render(
          tester,
          SizedBox(
            width: source.width,
            height: 48,
            child: HeaderPillBackground(variant: source.variant),
          ),
        );
        var maxDifference = 0;
        var totalDifference = 0;
        for (var index = 0; index < reference.bytes.length; index++) {
          final difference = (reference.bytes[index] - native.bytes[index])
              .abs();
          if (difference > maxDifference) maxDifference = difference;
          totalDifference += difference;
        }
        expect(
          maxDifference,
          lessThanOrEqualTo(2),
          reason:
              'Mean channel difference: ${totalDifference / reference.bytes.length}',
        );
      },
    );
  }

  testWidgets('a longer settings label keeps the same circular corner', (
    tester,
  ) async {
    final backgrounds = <_Pixels>[];
    for (final label in ['Settings', 'A much longer settings label']) {
      Get.addTranslations({
        'en_US': {'settings': label},
      });
      backgrounds.add(
        await _render(tester, HeaderSettingsButton(key: ValueKey(label))),
      );
    }
    expect(backgrounds[1].width, greaterThan(backgrounds[0].width));
    expect(backgrounds[0].height, 48);
    expect(backgrounds[1].height, 48);
    // (8, 8) is inside a 24px circular corner at either button width.
    // Stretching the SVG instead moves this point outside the elongated cap.
    for (final pixels in backgrounds) {
      expect(pixels.redAt(8, 8), greaterThan(0));
      expect(pixels.redAt(pixels.width - 9, 8), greaterThan(0));
    }
  });

  testWidgets('widening preserves the SVG gradient across the straight middle', (
    tester,
  ) async {
    final reference = await _render(
      tester,
      SizedBox(
        width: 180,
        height: 48,
        child: SvgPicture.asset(
          Assets.headerSettingsBackground,
          fit: BoxFit.fill,
        ),
      ),
    );
    final native = await _render(
      tester,
      const SizedBox(
        width: 180,
        height: 48,
        child: HeaderPillBackground(variant: HeaderPillVariant.settings),
      ),
    );
    var maxDifference = 0;
    // The caps deliberately have a different shape; compare the common middle,
    // including its top and bottom gradient border.
    for (var y = 0; y < 48; y++) {
      for (var x = 50; x < 130; x++) {
        for (var channel = 0; channel < 4; channel++) {
          final index = (y * 180 + x) * 4 + channel;
          final difference = (reference.bytes[index] - native.bytes[index])
              .abs();
          if (difference > maxDifference) maxDifference = difference;
        }
      }
    }
    expect(maxDifference, lessThanOrEqualTo(2));
  });
}

Future<_Pixels> _render(WidgetTester tester, Widget child) async {
  final key = GlobalKey();
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Align(
          alignment: Alignment.topLeft,
          child: RepaintBoundary(
            key: key,
            child: ColoredBox(color: Colors.black, child: child),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    final result = _Pixels(
      image.width,
      image.height,
      Uint8List.fromList(bytes!.buffer.asUint8List()),
    );
    image.dispose();
    return result;
  }))!;
}

class _Pixels {
  const _Pixels(this.width, this.height, this.bytes);
  final int width;
  final int height;
  final Uint8List bytes;
  int redAt(int x, int y) => bytes[(y * width + x) * 4];
}

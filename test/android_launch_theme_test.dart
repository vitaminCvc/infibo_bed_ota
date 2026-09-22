import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android launch window uses the app dark background on every API', () {
    const String darkBackground = '#010106';
    const String backgroundResource = '@color/app_background';

    final String colors = File(
      'android/app/src/main/res/values/colors.xml',
    ).readAsStringSync();
    final String legacyLaunchBackground = File(
      'android/app/src/main/res/drawable/launch_background.xml',
    ).readAsStringSync();
    final String api21LaunchBackground = File(
      'android/app/src/main/res/drawable-v21/launch_background.xml',
    ).readAsStringSync();
    final String lightTheme = File(
      'android/app/src/main/res/values/styles.xml',
    ).readAsStringSync();
    final String darkTheme = File(
      'android/app/src/main/res/values-night/styles.xml',
    ).readAsStringSync();
    final String android12Theme = File(
      'android/app/src/main/res/values-v31/styles.xml',
    ).readAsStringSync();

    expect(colors, contains(darkBackground));
    expect(legacyLaunchBackground, contains(backgroundResource));
    expect(api21LaunchBackground, contains(backgroundResource));
    expect(lightTheme, contains(backgroundResource));
    expect(darkTheme, contains(backgroundResource));
    expect(android12Theme, contains('android:windowSplashScreenBackground'));
    expect(android12Theme, contains(backgroundResource));
  });
}

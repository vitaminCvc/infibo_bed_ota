import 'package:flutter/material.dart';
import '../pages/settingpage/settings_panel_style.dart';

/// Shared by update cards, confirmations and progress dialogs.
abstract final class OtaUpdateStyle {
  static const surface = Color(0xff2c2e34);
  static const inset = Color(0xff34363d);
  static const border = Color(0xff45474f);
  static const controlBorder = Color(0xff92949b);
  static const dialogBorder = Color(0xff858b98);
  static const foreground = Color(0xfff4f6fa);
  static const secondary = Color(0xffc1c3cb);
  static const primary = Color(0xff1464df);
  static const accent = Color(0xff92bfff);
  static const onAccent = Colors.white;
  static const warning = Color(0xffffcc91);
  static const success = Color(0xff61d79c);
  static const notesTitle = TextStyle(
    fontFamily: settingsFontFamily,
    color: foreground,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );
  static const cardDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xff303137), Color(0xff292b31)],
    ),
    borderRadius: BorderRadius.all(Radius.circular(20)),
    border: Border.fromBorderSide(BorderSide(color: Color(0xff3b3d45))),
  );
  static const dialogDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xff393c43), Color(0xff2e3037)],
    ),
    borderRadius: BorderRadius.all(Radius.circular(20)),
    border: Border.fromBorderSide(BorderSide(color: dialogBorder)),
    boxShadow: [
      BoxShadow(
        color: Color(0x66000000),
        blurRadius: 32,
        offset: Offset(0, 16),
      ),
    ],
  );
  static const body = TextStyle(
    fontFamily: settingsFontFamily,
    color: secondary,
    fontSize: 16,
    height: 1.5,
  );
  static const caption = TextStyle(
    fontFamily: settingsFontFamily,
    color: secondary,
    fontSize: 14,
    height: 1.5,
  );

  static ThemeData theme(BuildContext context) => Theme.of(context).copyWith(
    textTheme: Theme.of(context).textTheme.apply(
      fontFamily: settingsFontFamily,
      bodyColor: foreground,
      displayColor: foreground,
    ),
    colorScheme: const ColorScheme.dark(
      primary: primary,
      onPrimary: onAccent,
      surface: surface,
      onSurface: foreground,
      outline: border,
      error: warning,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: onAccent,
        disabledBackgroundColor: inset,
        disabledForegroundColor: secondary,
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: const TextStyle(
          fontFamily: settingsFontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        shape: const StadiumBorder(),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: foreground,
        disabledForegroundColor: secondary,
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        side: const BorderSide(color: controlBorder),
        textStyle: const TextStyle(
          fontFamily: settingsFontFamily,
          fontSize: 16,
        ),
        shape: const StadiumBorder(),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accent,
        minimumSize: const Size(48, 48),
        textStyle: const TextStyle(
          fontFamily: settingsFontFamily,
          fontSize: 16,
        ),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: accent,
      linearTrackColor: border,
      linearMinHeight: 6,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      elevation: 24,
      shadowColor: Color(0x99000000),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        side: BorderSide(color: dialogBorder),
      ),
      titleTextStyle: TextStyle(
        fontFamily: settingsFontFamily,
        color: foreground,
        fontSize: 22,
        height: 1.4,
      ),
      contentTextStyle: body,
    ),
  );
}

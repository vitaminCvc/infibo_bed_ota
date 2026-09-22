// 整个 Flutter App 的启动初始化代码：先初始化 Flutter → 配置品牌 → 加载用户登录状态 → 预加载数据 → 读取语言和音量设置 → 最后启动 App。

import 'dart:async' show unawaited;

import 'package:flutter/widgets.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:infibo_app/config/app_brand.dart';
import 'package:infibo_app/pages/customized/logic.dart';
import 'package:infibo_app/pages/start/audio_prompt_player.dart';
import 'package:infibo_app/routes/index.dart';
import 'package:infibo_app/stores/user_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

Locale resolveInitialLocale({
  String? languageCode,
  String? countryCode,
  required Locale fallback,
}) {
  if (languageCode == null || countryCode == null) {
    return fallback;
  }
  return Locale(languageCode, countryCode);
}

Future<void> bootstrapApp(AppBrandConfig brand) async {
  WidgetsFlutterBinding.ensureInitialized();
  AppBrand.configure(brand);

  final UserStore userStore = Get.put(UserStore());
  await userStore.loadUser();
  // Preloading intentionally runs in parallel with the remaining startup work.
  unawaited(CustomizedLogic.preload());

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  // 在页面显示及提示音播放前恢复用户保存的音量。
  await AudioPromptPlayer.instance.loadVolume();
  final String? languageCode = prefs.getString('app_language_code');
  final String? countryCode = prefs.getString('app_country_code');
  final Locale initialLocale = resolveInitialLocale(
    languageCode: languageCode,
    countryCode: countryCode,
    fallback: brand.defaultLocale,
  );

  runApp(
    getRootWidget(
      initialRoute: userStore.isLoggedIn ? '/main' : '/login',
      locale: initialLocale,
    ),
  );
}

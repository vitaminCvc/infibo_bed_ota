// 后端提示文案本地化工具。
//
// 后端目前可能返回中文 message。中文界面保留原提示；其他语言界面遇到
// 中文 message 时使用前端翻译表中的兜底文案，避免界面混入中文。
import 'package:get/get.dart';

final RegExp _chineseMessagePattern = RegExp(r'[\u3400-\u9fff]');

String localizedApiMessage(String message, {required String fallbackKey}) {
  final String text = message.trim();
  if (text.isEmpty) return fallbackKey.tr;

  final bool isChineseLocale = Get.locale?.languageCode == 'zh';
  if (!isChineseLocale && _chineseMessagePattern.hasMatch(text)) {
    return fallbackKey.tr;
  }
  return text;
}

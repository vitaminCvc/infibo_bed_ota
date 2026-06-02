// 时长文本工具函数。
//
// 统一处理倒计时和中文时长文本，避免页面重复拼接分钟与秒数。
import 'package:infibo_app/utils/date_time_utils.dart';

String formatMinutesAndSeconds(int seconds) {
  final int safeSeconds = seconds < 0 ? 0 : seconds;
  final int minutes = safeSeconds ~/ 60;
  final int restSeconds = safeSeconds % 60;
  return '${twoDigits(minutes)}:${twoDigits(restSeconds)}';
}

// 格式化中文分钟和秒数文本。
String formatChineseDuration(int seconds) {
  final int safeSeconds = seconds < 0 ? 0 : seconds;
  final int minutes = safeSeconds ~/ 60;
  final int restSeconds = safeSeconds % 60;
  return '$minutes分${twoDigits(restSeconds)}秒';
}

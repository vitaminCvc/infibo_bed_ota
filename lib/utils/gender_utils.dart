// 性别展示文本工具。
//
// 兼容后端返回的中文、英文和常见缩写，在 UI 渲染时转换为当前语言。
import 'package:get/get.dart';

String localizedGenderText(String? gender) {
  final String text = gender?.trim() ?? '';
  if (text.isEmpty) return '--';

  switch (text.toLowerCase()) {
    case '男':
    case 'male':
    case 'm':
      return 'male'.tr;
    case '女':
    case 'female':
    case 'f':
      return 'female'.tr;
    default:
      return text;
  }
}

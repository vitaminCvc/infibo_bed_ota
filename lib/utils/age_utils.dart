// 年龄文本工具函数。
//
// 统一处理年龄存储格式和不同语言下的展示格式。
String normalizeAgeText(String age) {
  final String text = age.trim();
  if (text.isEmpty || text.endsWith('岁')) return text;
  return '$text岁';
}

// 根据语言代码格式化年龄展示文本。
String formatAgeForLanguage(String age, String languageCode) {
  if (languageCode == 'zh') return age;

  final String digits = age.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return age;
  return '${digits}y';
}

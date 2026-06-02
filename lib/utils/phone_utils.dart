// 手机号相关工具函数。
//
// 统一维护手机号校验和脱敏规则，避免页面中重复编写正则表达式或截取逻辑。
final RegExp _mainlandChinaMobilePhonePattern = RegExp(r'^1[3-9]\d{9}$');

// 校验中国大陆手机号。
bool isValidMainlandChinaMobilePhone(String phone) {
  return _mainlandChinaMobilePhonePattern.hasMatch(phone.trim());
}

// 对手机号进行脱敏，只显示末尾指定数量的字符。
String maskPhoneNumber(String phone, {int visibleSuffixLength = 4}) {
  final String text = phone.trim();
  final int safeSuffixLength = visibleSuffixLength < 0
      ? 0
      : visibleSuffixLength;
  if (text.length <= safeSuffixLength) return text;
  return '****${text.substring(text.length - safeSuffixLength)}';
}

// 数值工具函数。
//
// 统一处理百分比边界和两位数展示格式。
int clampPercentage(num value) {
  return value.clamp(0, 100).toInt();
}

double clampPercentageDouble(num value) {
  return value.clamp(0, 100).toDouble();
}

// 将数值限制在指定范围，并按最少位数补零。
String formatPaddedInteger(
  num value, {
  int min = 0,
  int max = 100,
  int width = 2,
}) {
  final int normalizedValue = value.round().clamp(min, max).toInt();
  return normalizedValue.toString().padLeft(width, '0');
}

// 格式化百分比，0-99 补齐两位，100 保持三位。
String formatPaddedPercentage(num value) {
  return '${formatPaddedInteger(value)}%';
}

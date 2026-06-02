// 日期时间工具函数。
//
// 集中维护页头时钟、设置页和日志页面使用的日期时间格式及换算逻辑。
String twoDigits(int value) => value.toString().padLeft(2, '0');

// 格式化页头时钟时间。
String formatClockTime(DateTime value) {
  return '${twoDigits(value.hour)}:${twoDigits(value.minute)}';
}

// 格式化页头日期。
String formatClockDate(DateTime value) {
  return '${value.year}.${twoDigits(value.month)}.${twoDigits(value.day)}';
}

// 格式化带秒数的日志时间。
String formatClockTimeWithSeconds(DateTime value) {
  return '${formatClockTime(value)}:${twoDigits(value.second)}';
}

// 获取指定年月的天数。
int daysInMonth(int year, int month) {
  return DateTime(year, month + 1, 0).day;
}

// 将 24 小时制转换为 12 小时制。
int toHour12(int hour24) {
  final int normalizedHour = hour24 % 24;
  if (normalizedHour == 0) return 12;
  if (normalizedHour > 12) return normalizedHour - 12;
  return normalizedHour;
}

// 将 12 小时制和上午/下午标记转换为 24 小时制。
int toHour24({required int hour12, required bool isPm}) {
  final int normalizedHour = hour12.clamp(1, 12).toInt();
  if (!isPm) return normalizedHour == 12 ? 0 : normalizedHour;
  return normalizedHour == 12 ? 12 : normalizedHour + 12;
}

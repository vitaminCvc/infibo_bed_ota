// 启动理疗页逻辑。
class StartLogic {
  static const int totalSeconds = 30 * 60;
  static const int phaseSeconds = 5 * 60;
  static const int phaseCount = totalSeconds ~/ phaseSeconds;

  int elapsedSeconds = 0;
  bool isRunning = false;

  // 当前倒计时进度。
  double get progress => (elapsedSeconds / totalSeconds).clamp(0, 1).toDouble();

  // 当前剩余进度。开始时为 1，倒计时结束时为 0。
  double get remainingProgress => 1 - progress;

  // 当前 5 分钟阶段，从 0 开始。
  int get activePhaseIndex =>
      (elapsedSeconds ~/ phaseSeconds).clamp(0, phaseCount - 1);

  // 倒计时剩余时间文本。
  String get remainingTimeText {
    final int remaining = (totalSeconds - elapsedSeconds).clamp(
      0,
      totalSeconds,
    );
    final int minutes = remaining ~/ 60;
    final int seconds = remaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // 当前阶段工作的功能。
  List<String> activeDevices(String modeTitle) {
    final List<List<String>> phases =
        modePhases[modeTitle] ?? modePhases['深度放松']!;
    final int index = activePhaseIndex.clamp(0, phases.length - 1);
    return phases[index];
  }

  // 每秒推进倒计时。
  void tick() {
    if (!isRunning || elapsedSeconds >= totalSeconds) return;

    elapsedSeconds++;
    if (elapsedSeconds >= totalSeconds) {
      elapsedSeconds = totalSeconds;
      isRunning = false;
    }
  }

  // 暂停倒计时。
  void pause() {
    if (!isRunning) return;
    isRunning = false;
  }

  // 启动或继续倒计时。
  void play() {
    if (isRunning || elapsedSeconds >= totalSeconds) return;
    isRunning = true;
  }
}

// 十种理疗模式的 5 分钟阶段配置。
const Map<String, List<List<String>>> modePhases = {
  '深度放松': [
    ['red', 'vat'],
    ['pemf', 'vat'],
    ['hydrogen', 'vat'],
    ['red', 'pemf'],
    ['vat', 'expand'],
    ['red', 'hydrogen'],
  ],
  '压力释放': [
    ['pemf', 'vat'],
    ['vat', 'hydrogen'],
    ['red', 'vat'],
    ['pemf', 'expand'],
    ['hydrogen', 'expand'],
    ['vat'],
  ],
  '能量提升': [
    ['red', 'pemf'],
    ['pemf', 'hydrogen'],
    ['red', 'vat'],
    ['pemf', 'vat'],
    ['red', 'expand'],
    ['hydrogen', 'vat'],
  ],
  '免疫增强': [
    ['pemf', 'hydrogen'],
    ['red', 'hydrogen'],
    ['vat', 'hydrogen'],
    ['red', 'pemf'],
    ['hydrogen', 'expand'],
    ['red', 'vat'],
  ],
  '疼痛缓解': [
    ['pemf', 'red'],
    ['pemf', 'vat'],
    ['red', 'vat'],
    ['pemf', 'hydrogen'],
    ['red', 'expand'],
    ['vat'],
  ],
  '抗衰老': [
    ['red', 'hydrogen'],
    ['pemf', 'hydrogen'],
    ['red', 'vat'],
    ['hydrogen', 'expand'],
    ['red', 'pemf'],
    ['vat', 'hydrogen'],
  ],
  '睡眠改善': [
    ['pemf', 'vat'],
    ['vat'],
    ['red', 'vat'],
    ['pemf', 'hydrogen'],
    ['vat', 'expand'],
    ['red'],
  ],
  '全面养护': [
    ['red', 'pemf'],
    ['vat', 'hydrogen'],
    ['red', 'vat'],
    ['pemf', 'expand'],
    ['hydrogen', 'expand'],
    ['red', 'hydrogen'],
  ],
  '运动恢复': [
    ['pemf', 'red'],
    ['pemf', 'vat'],
    ['red', 'hydrogen'],
    ['vat', 'expand'],
    ['pemf', 'hydrogen'],
    ['red', 'vat'],
  ],
  '情绪疗愈': [
    ['vat'],
    ['pemf', 'vat'],
    ['red', 'vat'],
    ['hydrogen', 'vat'],
    ['expand', 'vat'],
    ['red', 'hydrogen'],
  ],
};

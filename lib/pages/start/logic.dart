// 启动理疗页的倒计时和阶段逻辑。
//
// 负责总时长、当前 5 分钟阶段、运行/暂停状态，以及解析自定义方案传入的节点配置。
import 'package:infibo_app/pages/customized/logic.dart';
import 'package:infibo_app/utils/duration_utils.dart';

// 启动理疗页逻辑。
class StartLogic {
  static const int phaseSeconds = 5 * 60;

  int totalSeconds = 30 * 60;
  int elapsedSeconds = 0;
  bool isRunning = false;
  bool isPaused = false;
  List<List<String>>? customizedPhases;
  List<RedLightPhaseSetting?>? customizedRedLightSettings;
  List<PemfPhaseSetting?>? customizedPemfSettings;
  List<HydrogenPhaseSetting?>? customizedHydrogenSettings;
  List<VatPhaseSetting?>? customizedVatSettings;
  VatPhaseSetting? _customizedVatModuleSetting;
  List<ChakraPhaseSetting?>? customizedChakraSettings;
  List<TerahertzPhaseSetting?>? customizedTerahertzSettings;
  List<HifemPhaseSetting?>? customizedHifemSettings;
  List<FragrancePhaseSetting?>? customizedFragranceSettings;

  int get phaseCount => totalSeconds ~/ phaseSeconds;
  bool get isCustomizedPlan => customizedPhases != null;
  bool get hasStarted => elapsedSeconds > 0 || isRunning || isPaused;
  bool get canStart => !hasStarted && elapsedSeconds < totalSeconds;
  bool get canPause => isRunning;
  bool get canResume => isPaused && elapsedSeconds < totalSeconds;
  bool get canStop => hasStarted && elapsedSeconds <= totalSeconds;

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
    return formatMinutesAndSeconds(remaining);
  }

  // 当前阶段工作的功能。
  List<String> activeDevices(String modeTitle) {
    final List<List<String>> phases =
        customizedPhases ?? modePhases[modeTitle] ?? modePhases['深度放松']!;
    final int index = activePhaseIndex.clamp(0, phases.length - 1);
    return phases[index];
  }

  RedLightPhaseSetting? get activeRedLightSetting {
    final List<RedLightPhaseSetting?>? settings = customizedRedLightSettings;
    if (settings == null || settings.isEmpty) return null;

    final int index = activePhaseIndex.clamp(0, settings.length - 1);
    return settings[index];
  }

  PemfPhaseSetting? get activePemfSetting {
    final List<PemfPhaseSetting?>? settings = customizedPemfSettings;
    if (settings == null || settings.isEmpty) return null;

    final int index = activePhaseIndex.clamp(0, settings.length - 1);
    return settings[index];
  }

  HydrogenPhaseSetting? get activeHydrogenSetting {
    final List<HydrogenPhaseSetting?>? settings = customizedHydrogenSettings;
    if (settings == null || settings.isEmpty) return null;

    final int index = activePhaseIndex.clamp(0, settings.length - 1);
    return settings[index];
  }

  VatPhaseSetting? get activeVatSetting {
    final List<VatPhaseSetting?>? settings = customizedVatSettings;
    if (settings == null || settings.isEmpty) return null;

    final int index = activePhaseIndex.clamp(0, settings.length - 1);
    final VatPhaseSetting? phaseSetting = settings[index];
    final VatPhaseSetting? moduleSetting = _customizedVatModuleSetting;
    if (phaseSetting == null || moduleSetting == null) return phaseSetting;
    return phaseSetting.withModuleSetting(moduleSetting);
  }

  ChakraPhaseSetting? get activeChakraSetting {
    final List<ChakraPhaseSetting?>? settings = customizedChakraSettings;
    if (settings == null || settings.isEmpty) return null;

    final int index = activePhaseIndex.clamp(0, settings.length - 1);
    return settings[index];
  }

  TerahertzPhaseSetting? get activeTerahertzSetting {
    final List<TerahertzPhaseSetting?>? settings = customizedTerahertzSettings;
    if (settings == null || settings.isEmpty) return null;

    final int index = activePhaseIndex.clamp(0, settings.length - 1);
    return settings[index];
  }

  HifemPhaseSetting? get activeHifemSetting {
    final List<HifemPhaseSetting?>? settings = customizedHifemSettings;
    if (settings == null || settings.isEmpty) return null;

    final int index = activePhaseIndex.clamp(0, settings.length - 1);
    return settings[index];
  }

  FragrancePhaseSetting? get activeFragranceSetting {
    final List<FragrancePhaseSetting?>? settings = customizedFragranceSettings;
    if (settings == null || settings.isEmpty) return null;

    final int index = activePhaseIndex.clamp(0, settings.length - 1);
    return settings[index];
  }

  Map<String, int> workSecondsByDevice(String modeTitle) {
    final List<List<String>> phases =
        customizedPhases ?? modePhases[modeTitle] ?? modePhases['深度放松']!;
    final Map<String, int> result = <String, int>{};

    for (final List<String> phase in phases) {
      for (final String device in phase.toSet()) {
        result[device] = (result[device] ?? 0) + phaseSeconds;
      }
    }

    return result;
  }

  Map<String, int> actualWorkSecondsByDevice(String modeTitle) {
    final List<List<String>> phases =
        customizedPhases ?? modePhases[modeTitle] ?? modePhases['深度放松']!;
    final Map<String, int> result = <String, int>{};
    int remainingElapsed = elapsedSeconds.clamp(0, totalSeconds).toInt();

    for (final List<String> phase in phases) {
      if (remainingElapsed <= 0) break;

      final int phaseWorkedSeconds = remainingElapsed >= phaseSeconds
          ? phaseSeconds
          : remainingElapsed;
      for (final String device in phase.toSet()) {
        result[device] = (result[device] ?? 0) + phaseWorkedSeconds;
      }
      remainingElapsed -= phaseWorkedSeconds;
    }

    return result;
  }

  static String formatDurationText(int seconds) {
    return formatChineseDuration(seconds);
  }

  static String deviceName(String id) {
    switch (id) {
      case 'red':
        return '红光';
      case 'pemf':
        return 'PEMF';
      case 'vat':
        return 'VAT';
      case 'hydrogen':
        return '分子氢';
      case 'expand':
        return '拓展功能';
      default:
        return id;
    }
  }

  // 根据页面参数配置自定义方案。
  void configure(Object? args) {
    if (args is! Map || args['customizedPlan'] is! CustomizedPlanData) return;

    final CustomizedPlanData plan =
        args['customizedPlan'] as CustomizedPlanData;
    final List<List<String>> phases = List.generate(12, (_) => <String>[]);
    final List<RedLightPhaseSetting?> redLightSettings = List.generate(
      12,
      (_) => null,
    );
    final List<PemfPhaseSetting?> pemfSettings = List.generate(12, (_) => null);
    final List<HydrogenPhaseSetting?> hydrogenSettings = List.generate(
      12,
      (_) => null,
    );
    final List<VatPhaseSetting?> vatSettings = List.generate(12, (_) => null);
    VatPhaseSetting? vatModuleSetting;
    final List<ChakraPhaseSetting?> chakraSettings = List.generate(
      12,
      (_) => null,
    );
    final List<TerahertzPhaseSetting?> terahertzSettings = List.generate(
      12,
      (_) => null,
    );
    final List<HifemPhaseSetting?> hifemSettings = List.generate(
      12,
      (_) => null,
    );
    final List<FragrancePhaseSetting?> fragranceSettings = List.generate(
      12,
      (_) => null,
    );
    int maxIndex = -1;

    for (final String text in plan.featureIds) {
      final List<String> parts = text.split(':');
      if (parts.length < 3) continue;

      final int? index = int.tryParse(parts[1]);
      if (index == null || index < 0 || index >= phases.length) continue;

      if (text.startsWith('phase:')) {
        phases[index] = parts[2]
            .split('|')
            .map(_startDeviceId)
            .where((id) => id.isNotEmpty)
            .toList();
        if (phases[index].isNotEmpty && index > maxIndex) maxIndex = index;
      } else if (text.startsWith('redlight:')) {
        redLightSettings[index] = RedLightPhaseSetting.parse(parts[2]);
        if (index > maxIndex) maxIndex = index;
      } else if (text.startsWith('pemf:')) {
        pemfSettings[index] = PemfPhaseSetting.parse(parts[2]);
        if (index > maxIndex) maxIndex = index;
      } else if (text.startsWith('hydrogen:')) {
        hydrogenSettings[index] = HydrogenPhaseSetting.parse(parts[2]);
        if (index > maxIndex) maxIndex = index;
      } else if (text.startsWith('vat:')) {
        final VatPhaseSetting setting = VatPhaseSetting.parse(parts[2]);
        vatSettings[index] = setting;
        vatModuleSetting = vatModuleSetting == null
            ? setting
            : vatModuleSetting.withMissingModuleValuesFrom(setting);
        if (index > maxIndex) maxIndex = index;
      } else if (text.startsWith('chakra:')) {
        chakraSettings[index] = ChakraPhaseSetting.parse(parts[2]);
        if (index > maxIndex) maxIndex = index;
      } else if (text.startsWith('terahertz:')) {
        terahertzSettings[index] = TerahertzPhaseSetting.parse(parts[2]);
        if (index > maxIndex) maxIndex = index;
      } else if (text.startsWith('hifem:')) {
        hifemSettings[index] = HifemPhaseSetting.parse(parts[2]);
        if (index > maxIndex) maxIndex = index;
      } else if (text.startsWith('fragrance:')) {
        fragranceSettings[index] = FragrancePhaseSetting.parse(parts[2]);
        if (index > maxIndex) maxIndex = index;
      }
    }

    if (maxIndex < 0) return;

    customizedPhases = phases.take(maxIndex + 1).toList();
    customizedRedLightSettings = redLightSettings.take(maxIndex + 1).toList();
    customizedPemfSettings = pemfSettings.take(maxIndex + 1).toList();
    customizedHydrogenSettings = hydrogenSettings.take(maxIndex + 1).toList();
    customizedVatSettings = vatSettings.take(maxIndex + 1).toList();
    _customizedVatModuleSetting = vatModuleSetting;
    customizedChakraSettings = chakraSettings.take(maxIndex + 1).toList();
    customizedTerahertzSettings = terahertzSettings.take(maxIndex + 1).toList();
    customizedHifemSettings = hifemSettings.take(maxIndex + 1).toList();
    customizedFragranceSettings = fragranceSettings.take(maxIndex + 1).toList();
    totalSeconds = (maxIndex + 1) * phaseSeconds;
    elapsedSeconds = 0;
    isRunning = false;
    isPaused = false;
  }

  // 每秒推进倒计时。
  void tick() {
    if (!isRunning || elapsedSeconds >= totalSeconds) return;

    elapsedSeconds++;
    if (elapsedSeconds >= totalSeconds) {
      elapsedSeconds = totalSeconds;
      isRunning = false;
      isPaused = false;
    }
  }

  // 暂停倒计时。
  void pause() {
    if (!isRunning) return;
    isRunning = false;
    isPaused = true;
  }

  // 启动或继续倒计时。
  void play() {
    if (isRunning || elapsedSeconds >= totalSeconds) return;
    isRunning = true;
    isPaused = false;
  }

  void stop() {
    isRunning = false;
    isPaused = false;
  }

  String _startDeviceId(String id) {
    if (id == 'redlight') return 'red';
    if (id == 'pemf') return 'pemf';
    if (id == 'vat') return 'vat';
    if (id == 'hydrogen') return 'hydrogen';
    if (id == 'expand') return 'expand';
    return '';
  }
}

enum RedLightWorkMode { continuous, pulse }

class RedLightPhaseSetting {
  const RedLightPhaseSetting({
    required this.strength660,
    required this.strength850,
    required this.mode,
  });

  final int strength660;
  final int strength850;
  final RedLightWorkMode mode;

  bool get hasOutput => strength660 > 0 || strength850 > 0;
  int get modbusMode => mode == RedLightWorkMode.continuous ? 0 : 1;

  factory RedLightPhaseSetting.parse(String text) {
    int strength660 = 0;
    int strength850 = 0;
    RedLightWorkMode mode = RedLightWorkMode.continuous;

    for (final String pair in text.split('|')) {
      final int separator = pair.indexOf('=');
      if (separator <= 0 || separator == pair.length - 1) continue;

      final String key = pair.substring(0, separator).trim();
      final String value = pair.substring(separator + 1).trim();

      switch (key) {
        case '660':
          strength660 = _percentValue(value);
          break;
        case '850':
          strength850 = _percentValue(value);
          break;
        case 'mode':
          mode = value == 'pulse'
              ? RedLightWorkMode.pulse
              : RedLightWorkMode.continuous;
          break;
      }
    }

    return RedLightPhaseSetting(
      strength660: strength660,
      strength850: strength850,
      mode: mode,
    );
  }

  static int _percentValue(String text) {
    final int? value = int.tryParse(text);
    if (value == null) return 0;
    return value.clamp(0, 100).toInt();
  }
}

class PemfPhaseSetting {
  const PemfPhaseSetting({
    required this.frequency,
    required this.intensity,
    required this.waveform,
  });

  final int frequency;
  final int intensity;
  final String waveform;

  int get waveformNumber {
    switch (waveform) {
      case 'sine':
        return 1;
      case 'halfSine':
        return 2;
      case 'trapezoid':
        return 3;
      case 'standardSine':
        return 4;
      case 'saw':
        return 5;
      case 'triangle':
        return 6;
      case 'pulse':
        return 7;
      case 'fastRise':
        return 8;
      case 'dualFrequency':
        return 9;
      case 'cubic':
        return 10;
      default:
        return 1;
    }
  }

  factory PemfPhaseSetting.parse(String text) {
    int frequency = 0;
    int intensity = 0;
    String waveform = '';

    for (final String pair in text.split('|')) {
      final int separator = pair.indexOf('=');
      if (separator <= 0 || separator == pair.length - 1) continue;

      final String key = pair.substring(0, separator).trim();
      final String value = pair.substring(separator + 1).trim();

      switch (key) {
        case 'frequency':
          frequency = _clampInt(value, 75);
          break;
        case 'intensity':
          intensity = _clampInt(value, 100);
          break;
        case 'wave':
          waveform = value;
          break;
      }
    }

    return PemfPhaseSetting(
      frequency: frequency,
      intensity: intensity,
      waveform: waveform,
    );
  }

  static int _clampInt(String text, int max) {
    final int? value = int.tryParse(text);
    if (value == null) return 0;
    return value.clamp(0, max).toInt();
  }
}

class HydrogenPhaseSetting {
  const HydrogenPhaseSetting({
    required this.concentration,
    required this.flowRate,
  });

  final int concentration;
  final int flowRate;

  factory HydrogenPhaseSetting.parse(String text) {
    int concentration = 0;
    int flowRate = 0;

    for (final String pair in text.split('|')) {
      final int separator = pair.indexOf('=');
      if (separator <= 0 || separator == pair.length - 1) continue;

      final String key = pair.substring(0, separator).trim();
      final String value = pair.substring(separator + 1).trim();
      final int? parsed = int.tryParse(value);
      if (parsed == null) continue;

      switch (key) {
        case 'concentration':
          concentration = parsed.clamp(0, 100);
          break;
        case 'flow':
          flowRate = parsed.clamp(0, 100);
          break;
      }
    }

    return HydrogenPhaseSetting(
      concentration: concentration,
      flowRate: flowRate,
    );
  }
}

class VatPhaseSetting {
  const VatPhaseSetting({
    required this.frequency,
    required this.intensity,
    this.songId,
    this.songName,
    this.seriesName,
  });

  final int frequency;
  final int intensity;
  final String? songId;
  final String? songName;
  final String? seriesName;

  VatPhaseSetting withModuleSetting(VatPhaseSetting setting) {
    return VatPhaseSetting(
      frequency: frequency,
      intensity: setting.intensity,
      songId: setting.songId,
      songName: setting.songName,
      seriesName: setting.seriesName,
    );
  }

  VatPhaseSetting withMissingModuleValuesFrom(VatPhaseSetting setting) {
    return VatPhaseSetting(
      frequency: frequency,
      intensity: intensity > 0 ? intensity : setting.intensity,
      songId: _nonEmpty(songId) ?? setting.songId,
      songName: _nonEmpty(songName) ?? setting.songName,
      seriesName: _nonEmpty(seriesName) ?? setting.seriesName,
    );
  }

  factory VatPhaseSetting.parse(String text) {
    int frequency = 0;
    int intensity = 0;
    String? songId;
    String? songName;
    String? seriesName;

    for (final String pair in text.split('|')) {
      final int separator = pair.indexOf('=');
      if (separator <= 0 || separator == pair.length - 1) continue;

      final String key = pair.substring(0, separator).trim();
      final String value = pair.substring(separator + 1).trim();

      switch (key) {
        case 'frequency':
          final int? parsed = int.tryParse(value);
          if (parsed != null) frequency = parsed.clamp(0, 100);
          break;
        case 'intensity':
          final int? parsed = int.tryParse(value);
          if (parsed != null) intensity = parsed.clamp(0, 100);
          break;
        case 'songId':
          songId = value;
          break;
        case 'songName':
          songName = Uri.decodeComponent(value);
          break;
        case 'seriesName':
          seriesName = Uri.decodeComponent(value);
          break;
      }
    }

    return VatPhaseSetting(
      frequency: frequency,
      intensity: intensity,
      songId: songId,
      songName: songName,
      seriesName: seriesName,
    );
  }
}

String? _nonEmpty(String? value) {
  return value == null || value.isEmpty ? null : value;
}

class ChakraPhaseSetting {
  const ChakraPhaseSetting({required this.strengths, required this.mode});

  final Map<String, int> strengths;
  final String mode;

  bool get hasStrengths => strengths.isNotEmpty;
  int get modbusMode => mode == 'independent' ? 1 : 0;

  factory ChakraPhaseSetting.parse(String text) {
    final Map<String, int> strengths = <String, int>{};
    String mode = 'rotation';

    for (final String pair in text.split('|')) {
      final int separator = pair.indexOf('=');
      if (separator <= 0 || separator == pair.length - 1) continue;

      final String key = pair.substring(0, separator).trim();
      final String value = pair.substring(separator + 1).trim();
      if (key == 'mode') {
        mode = value == 'independent' ? 'independent' : 'rotation';
        continue;
      }
      final int? parsed = int.tryParse(value);
      if (parsed == null) continue;
      strengths[key] = parsed.clamp(0, 100);
    }

    return ChakraPhaseSetting(strengths: strengths, mode: mode);
  }
}

class TerahertzPhaseSetting {
  const TerahertzPhaseSetting({
    required this.frequency,
    required this.power,
    required this.mode,
    required this.wave,
  });

  final int frequency;
  final int power;
  final String mode;
  final String wave;

  int get modbusMode {
    switch (mode) {
      case 'pulse':
        return 1;
      case 'custom':
        return 2;
      case 'continuous':
      default:
        return 0;
    }
  }

  int get modbusWave {
    switch (wave) {
      case 'square':
        return 1;
      case 'triangle':
        return 2;
      case 'sine':
      default:
        return 0;
    }
  }

  factory TerahertzPhaseSetting.parse(String text) {
    int frequency = 0;
    int power = 0;
    String mode = 'continuous';
    String wave = 'sine';

    for (final String pair in text.split('|')) {
      final int separator = pair.indexOf('=');
      if (separator <= 0 || separator == pair.length - 1) continue;

      final String key = pair.substring(0, separator).trim();
      final String value = pair.substring(separator + 1).trim();
      switch (key) {
        case 'frequency':
          frequency = _clampInt(value, 100);
          break;
        case 'power':
          power = _clampInt(value, 100);
          break;
        case 'mode':
          mode = value;
          break;
        case 'wave':
          wave = value;
          break;
      }
    }

    return TerahertzPhaseSetting(
      frequency: frequency,
      power: power,
      mode: mode,
      wave: wave,
    );
  }

  static int _clampInt(String text, int max) {
    final int? value = int.tryParse(text);
    if (value == null) return 0;
    return value.clamp(0, max).toInt();
  }
}

class HifemPhaseSetting {
  const HifemPhaseSetting({
    required this.foreheadRf,
    required this.foreheadHifes,
    required this.leftCheekRf,
    required this.leftCheekHifes,
    required this.rightCheekRf,
    required this.rightCheekHifes,
  });

  final int foreheadRf;
  final int foreheadHifes;
  final int leftCheekRf;
  final int leftCheekHifes;
  final int rightCheekRf;
  final int rightCheekHifes;

  bool get hasOutput =>
      foreheadRf > 0 ||
      foreheadHifes > 0 ||
      leftCheekRf > 0 ||
      leftCheekHifes > 0 ||
      rightCheekRf > 0 ||
      rightCheekHifes > 0;

  factory HifemPhaseSetting.parse(String text) {
    int foreheadLeftRf = 0;
    int foreheadLeftHifes = 0;
    int foreheadRightRf = 0;
    int foreheadRightHifes = 0;
    int cheekLeftRf = 0;
    int cheekLeftHifes = 0;
    int cheekRightRf = 0;
    int cheekRightHifes = 0;

    for (final String pair in text.split('|')) {
      final int separator = pair.indexOf('=');
      if (separator <= 0 || separator == pair.length - 1) continue;

      final String key = pair.substring(0, separator).trim();
      final String value = pair.substring(separator + 1).trim();
      switch (key) {
        case 'forehead.rf':
          final int v = _clampInt(value, 100);
          foreheadLeftRf = v;
          foreheadRightRf = v;
          break;
        case 'forehead.hifes':
          final int v = _clampInt(value, 100);
          foreheadLeftHifes = v;
          foreheadRightHifes = v;
          break;
        case 'forehead_left.rf':
          foreheadLeftRf = _clampInt(value, 100);
          break;
        case 'forehead_left.hifes':
          foreheadLeftHifes = _clampInt(value, 100);
          break;
        case 'forehead_right.rf':
          foreheadRightRf = _clampInt(value, 100);
          break;
        case 'forehead_right.hifes':
          foreheadRightHifes = _clampInt(value, 100);
          break;
        case 'cheek_left.rf':
          cheekLeftRf = _clampInt(value, 100);
          break;
        case 'cheek_left.hifes':
          cheekLeftHifes = _clampInt(value, 100);
          break;
        case 'cheek_right.rf':
          cheekRightRf = _clampInt(value, 100);
          break;
        case 'cheek_right.hifes':
          cheekRightHifes = _clampInt(value, 100);
          break;
      }
    }

    // 协议只有一个前额通道，而界面有左右前额区域。
    return HifemPhaseSetting(
      foreheadRf: foreheadLeftRf > foreheadRightRf
          ? foreheadLeftRf
          : foreheadRightRf,
      foreheadHifes: foreheadLeftHifes > foreheadRightHifes
          ? foreheadLeftHifes
          : foreheadRightHifes,
      leftCheekRf: cheekLeftRf,
      leftCheekHifes: cheekLeftHifes,
      rightCheekRf: cheekRightRf,
      rightCheekHifes: cheekRightHifes,
    );
  }

  static int _clampInt(String text, int max) {
    final int? value = int.tryParse(text);
    if (value == null) return 0;
    return value.clamp(0, max).toInt();
  }
}

class FragrancePhaseSetting {
  const FragrancePhaseSetting({required this.fragranceId});

  final String fragranceId;

  int get modbusType {
    switch (fragranceId) {
      case 'strong':
        return 1;
      case 'sleep':
        return 2;
      case 'flow':
        return 3;
      case 'meditation':
        return 4;
      case 'soft':
      default:
        return 0;
    }
  }

  factory FragrancePhaseSetting.parse(String text) {
    String fragranceId = 'soft';

    for (final String pair in text.split('|')) {
      final int separator = pair.indexOf('=');
      if (separator <= 0 || separator == pair.length - 1) continue;

      final String key = pair.substring(0, separator).trim();
      final String value = pair.substring(separator + 1).trim();
      if (key == 'type' && value.isNotEmpty) fragranceId = value;
    }

    return FragrancePhaseSetting(fragranceId: fragranceId);
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

import 'dart:async';
import 'dart:math' as math;
import 'package:infibo_app/api/modbus/hydrogen_modbus.dart';
import 'package:infibo_app/api/modbus/modbus_rtu_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 每个疗程创建一个实例，读取累计值后叠加总结页时长，写入新的累计总数。
/// 只保存已确认的累计基准；失败的本次时长不会留到下个疗程补记。
class HydrogenRuntimeRecorder {
  HydrogenRuntimeRecorder({required ModbusRtuService service})
    : _service = service;

  final ModbusRtuService _service;
  Future<void>? _recording;
  Future<void>? _resetting;
  static const _retryInterval = Duration(milliseconds: 200);
  static final _updatesByBoard = <String, Future<void>>{};

  String get _cacheKey =>
      'hydrogen_confirmed_minutes_v1:${_service.portName}:${_service.slaveId}';

  Future<void> recordSession(Map<String, int> moduleSeconds) =>
      _recording ??= _enqueue(moduleSeconds['hydrogen'] ?? 0);

  Future<void> _enqueue(int seconds) {
    if (seconds <= 0) return Future<void>.value();
    return _enqueueUpdate(() => _record(seconds));
  }

  /// 手动清零也与疗程累计串行执行，防止旧总数在清零之后写回。
  Future<void> resetCumulativeRuntime() async {
    final active = _resetting;
    if (active != null) return active;
    final reset = _enqueueUpdate(() async {
      final prefs = await SharedPreferences.getInstance();
      await _writeTotal(0);
      // 清零是明确的维护操作，必须替换本地基准，不能继续取旧值的最大值。
      await _saveConfirmed(prefs, 0);
    });
    _resetting = reset;
    try {
      await reset;
    } finally {
      if (identical(_resetting, reset)) _resetting = null;
    }
  }

  Future<void> _enqueueUpdate(Future<void> Function() action) {
    // 同一连接的读、加、写作为一个更新串行执行，避免重叠疗程覆盖累计值。
    final previous = _updatesByBoard[_cacheKey] ?? Future<void>.value();
    final update = previous.then((_) => action());
    // 失败也释放队列，下一次运行独立更新，不继承本次时长或错误。
    late final Future<void> finished;
    void release() {
      if (identical(_updatesByBoard[_cacheKey], finished)) {
        _updatesByBoard.remove(_cacheKey);
      }
    }

    finished = update.then<void>(
      (_) => release(),
      onError: (Object error, StackTrace stack) => release(),
    );
    _updatesByBoard[_cacheKey] = finished;
    return update;
  }

  Future<void> _record(int seconds) async {
    // 与总结报告的 runDurationMinutes 一致，不足一分钟按一分钟计。
    final minutes = (seconds / 60).ceil();
    RangeError.checkValueInInterval(minutes, 1, 0xFFFF, 'hydrogenMinutes');

    // 读取失败会直接退出，不能把未读到的值当成 0 写回。
    final boardMinutes = await _service.readHoldingRegister(
      HydrogenModbus.cumulativeRuntimeAddress,
    );
    RangeError.checkValueInInterval(boardMinutes, 0, 0xFFFF, 'boardMinutes');
    final prefs = await SharedPreferences.getInstance();
    final cachedMinutes = prefs.getInt(_cacheKey) ?? 0;
    RangeError.checkValueInInterval(cachedMinutes, 0, 0xFFFF, 'cachedMinutes');
    final confirmedMinutes = math.max(boardMinutes, cachedMinutes);

    // 主板本次读到的较大值也属于已确认的历史累计值，可以保留。
    if (confirmedMinutes > cachedMinutes) {
      await _saveConfirmed(prefs, confirmedMinutes);
    }
    final totalMinutes = confirmedMinutes + minutes;
    RangeError.checkValueInInterval(totalMinutes, 1, 0xFFFF, 'totalMinutes');
    await _writeTotal(totalMinutes);
    // 只在主板写入确认成功之后保存新总数，不缓存未确认的本次增量。
    await _saveConfirmed(prefs, totalMinutes);
  }

  Future<void> _writeTotal(int totalMinutes) async {
    for (var attempt = 0; ; attempt++) {
      try {
        await _service.writeSingleRegister(
          address: HydrogenModbus.cumulativeRuntimeAddress,
          value: totalMinutes,
        );
        return;
      } catch (error) {
        final timeout =
            error is TimeoutException ||
            (error is ModbusRtuException &&
                error.message.toLowerCase().contains('timeout'));
        if (attempt >= 1 || !timeout) rethrow;
        // 超时仅重试一次相同总数，不重新读取或再次加上本次时长。
        await Future<void>.delayed(_retryInterval);
      }
    }
  }

  Future<void> _saveConfirmed(SharedPreferences prefs, int minutes) async {
    if (!await prefs.setInt(_cacheKey, minutes)) {
      throw StateError('Could not save confirmed hydrogen runtime');
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:infibo_app/api/modbus/hydrogen_modbus.dart';

enum WaterQualityPhase {
  normal,
  waiting,
  treating,
  failed,
  success,
  unavailable,
}

enum WaterQualityReadError { tds, treatment }

/// 全局异常轮次独立于弹窗和页面生命周期。关闭只抑制当前访问的提醒。
class WaterQualityController extends ChangeNotifier {
  WaterQualityController({required this.readRegister});

  final Future<int> Function(int address) readRegister;
  WaterQualityPhase phase = WaterQualityPhase.normal;
  WaterQualityReadError? readError;
  bool visible = false;
  bool episodeActive = false;
  int? tds;
  String _page = '';
  int _visit = 0;
  int _episode = 0;
  int? _dismissedVisit;
  bool _tdsValid = false;
  bool _entryPending = false;
  bool _deferHomeRead = false;
  bool _refreshPending = false;
  bool _forceTdsPending = false;
  bool _disposed = false;
  Future<void>? _reading;

  bool get canUseHydrogen =>
      !_disposed && _tdsValid && tds != null && tds! < 10 && !episodeActive;
  bool get _eligible => _page == '/main' || _page == '/start';

  Future<void> enterPage(String page, {bool deferRead = false}) {
    if (_disposed) return Future.value();
    _page = page;
    _visit++;
    _entryPending = _eligible;
    _deferHomeRead = page == '/main' && deferRead;
    if (!_eligible || deferRead) return Future.value();
    return _refresh();
  }

  /// 首页由原来的 0012 → 0006 → 01E5 读取完成后触发，避免抢发首帧。
  Future<void> onHomeWaterPollComplete() {
    if (_disposed || _page != '/main') return Future.value();
    _deferHomeRead = false;
    return _refresh();
  }

  /// 首页正常检测由水位周期驱动；已有异常在总结页和关闭后仍跟踪 ED。
  Future<void> poll() {
    if (_disposed || (!episodeActive && _page != '/start')) {
      return Future.value();
    }
    return _refresh();
  }

  Future<bool> checkHydrogenBeforeCommand() async {
    if (_disposed) return false;
    await _refresh(forceTds: true);
    return canUseHydrogen;
  }

  void dismiss() {
    if (_disposed || !visible) return;
    visible = false;
    _dismissedVisit = _visit;
    notifyListeners();
  }

  Future<void> _refresh({bool forceTds = false}) {
    if (_disposed) return Future.value();
    _refreshPending = true;
    _forceTdsPending |= forceTds;
    final existing = _reading;
    if (existing != null) return existing;
    // 先存 Future 再执行，监听回调中的再次刷新也会合并到同一串行流程。
    final future = Future<void>.microtask(_readLoop);
    _reading = future;
    return future.whenComplete(() {
      if (identical(_reading, future)) _reading = null;
    });
  }

  Future<void> _readLoop() async {
    while (!_disposed && _refreshPending) {
      _refreshPending = false;
      final forceTds = _forceTdsPending;
      _forceTdsPending = false;
      final entry = _entryPending && !_deferHomeRead;
      if (entry) _entryPending = false;
      final visit = _visit;
      if (entry || forceTds || !episodeActive) {
        if ((!_eligible || _deferHomeRead) && !forceTds) continue;
        await _readTds(visit: visit, reopen: entry);
      }
      if (!_disposed && episodeActive) await _readTreatment();
    }
  }

  Future<void> _readTds({required int visit, required bool reopen}) async {
    try {
      final value = await readRegister(
        HydrogenModbus.waterQualityTestingAddress,
      );
      if (_disposed || visit != _visit) return;
      tds = value;
      _tdsValid = true;
      readError = null;
      if (value >= 10) {
        if (!episodeActive) {
          episodeActive = true;
          _episode++;
          _dismissedVisit = null;
          phase = WaterQualityPhase.waiting;
          visible = true;
        } else if (reopen && _dismissedVisit != visit) {
          _dismissedVisit = null;
          visible = true;
        }
      } else if (!episodeActive && phase == WaterQualityPhase.unavailable) {
        phase = WaterQualityPhase.normal;
        visible = false;
        _dismissedVisit = null;
      }
      notifyListeners();
    } catch (error) {
      if (_disposed || visit != _visit) return;
      _tdsValid = false;
      readError = WaterQualityReadError.tds;
      if (!episodeActive) {
        phase = WaterQualityPhase.unavailable;
        // 下位机可能尚未启动：读取失败静默重试，仅真实异常主动弹窗。
        visible = false;
      }
      notifyListeners();
    }
  }

  Future<void> _readTreatment() async {
    final episode = _episode;
    try {
      final status = await readRegister(
        HydrogenModbus.waterQualityTreatmentAddress,
      );
      if (_disposed || !episodeActive || episode != _episode) return;
      if (status < 0 || status > 2) {
        throw StateError('Unknown treatment status: $status');
      }
      readError = null;
      if (status == 1) {
        phase = WaterQualityPhase.treating;
      } else if (status == 2) {
        phase = WaterQualityPhase.failed;
      } else {
        if (_deferHomeRead) return;
        // 状态 0 是成功，但必须主动复测 EC；旧读数不能结束本轮异常。
        final value = await readRegister(
          HydrogenModbus.waterQualityTestingAddress,
        );
        if (_disposed || !episodeActive || episode != _episode) return;
        tds = value;
        _tdsValid = true;
        if (value < 10) {
          episodeActive = false;
          phase = WaterQualityPhase.success;
          _dismissedVisit = null;
          // 不改 visible：已关闭的成功静默，未关闭的继续显示确认界面。
        }
      }
      notifyListeners();
    } catch (error) {
      if (_disposed || !episodeActive || episode != _episode) return;
      readError = WaterQualityReadError.treatment;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

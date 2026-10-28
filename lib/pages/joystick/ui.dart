// 升降杆控制组件。
//
// 处理升降状态展示、按钮交互、设备命令发送和状态轮询。
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:infibo_app/api/modbus/modbus_rtu_service.dart';
import 'package:infibo_app/constants/assets.dart';
import 'package:infibo_app/routes/route_observer.dart';

enum JoystickAction {
  idle,
  lockedLeftTop,
  lockedLeftBottom,
  holdingRightTop,
  holdingRightBottom,
}

enum JoystickExternalCommand {
  lockLeftTop(JoystickAction.lockedLeftTop),
  lockLeftBottom(JoystickAction.lockedLeftBottom),
  reset(JoystickAction.idle),
  holdRightTop(JoystickAction.holdingRightTop),
  holdRightBottom(JoystickAction.holdingRightBottom);

  const JoystickExternalCommand(this.action);

  final JoystickAction action;

  // 0x0011 状态值与 0x0010 控制值一致；未知值不能当作停止。
  static JoystickExternalCommand? fromStatus(int status) => switch (status) {
    0 => reset,
    1 => holdRightTop,
    2 => holdRightBottom,
    3 => lockLeftTop,
    4 => lockLeftBottom,
    _ => null,
  };
}

class JoystickCommandBus {
  JoystickCommandBus._();

  static final JoystickCommandBus instance = JoystickCommandBus._();
  final StreamController<JoystickExternalCommand> _controller =
      StreamController<JoystickExternalCommand>.broadcast();
  JoystickExternalCommand _lastLiftCommand = JoystickExternalCommand.reset;
  int _commandRevision = 0;
  int _pendingDeviceWrites = 0;
  bool _waitingForStopFeedback = false;
  Future<void>? _deviceWriteTail;

  Stream<JoystickExternalCommand> get stream => _controller.stream;
  JoystickExternalCommand get lastLiftCommand => _lastLiftCommand;
  int get commandRevision => _commandRevision;
  bool get hasPendingDeviceWrite => _pendingDeviceWrites > 0;
  bool get waitingForStopFeedback => _waitingForStopFeedback;

  void noteLocalCommand(int value) {
    _commandRevision++;
    _waitingForStopFeedback = value == 0;
  }

  Future<void> runLiftWrite(Future<void> Function() write) async {
    final previous = _deviceWriteTail;
    final completion = Completer<void>();
    _deviceWriteTail = completion.future;
    _pendingDeviceWrites++;
    try {
      if (previous != null) await previous;
      await write();
    } finally {
      _pendingDeviceWrites--;
      if (identical(_deviceWriteTail, completion.future)) {
        _deviceWriteTail = null;
      }
      completion.complete();
    }
  }

  void lockLeftBottom() {
    _publish(JoystickExternalCommand.lockLeftBottom);
  }

  void lockLeftTop() {
    _publish(JoystickExternalCommand.lockLeftTop);
  }

  void reset() {
    _waitingForStopFeedback = false;
    _publish(JoystickExternalCommand.reset);
  }

  void syncStatus(int status) {
    if (status == 0) _waitingForStopFeedback = false;
    final command = JoystickExternalCommand.fromStatus(status);
    if (command != null && command != _lastLiftCommand) {
      _publish(command);
    }
  }

  void _publish(JoystickExternalCommand command) {
    _lastLiftCommand = command;
    _controller.add(command);
  }
}

class JoystickControl extends StatefulWidget {
  const JoystickControl({
    super.key,
    this.modbusService,
    this.beforeStatusRead,
    /*电流相关寄存器地址 */
    // this.onLiftCurrentChanged,
  });

  final ModbusRtuService? modbusService;

  /// 首页先完成氛围灯和系统状态读取，避免升降轮询抢占既有顺序。
  final Future<void> Function()? beforeStatusRead;
  /*电流相关寄存器地址 */
  /// 仅订阅时读取电流；null 表示本次读取失败。
  // final ValueChanged<int?>? onLiftCurrentChanged;

  @override
  State<JoystickControl> createState() => _JoystickControlState();
}

class _JoystickControlState extends State<JoystickControl> with RouteAware {
  static const double _joystickImageWidth = 187;
  static const double _joystickImageHeight = 187;
  static const double _leftTopOffsetX = 0;
  static const double _leftTopOffsetY = 0;
  static const double _rightTopOffsetX = 95;
  static const double _rightTopOffsetY = 0;
  static const double _leftBottomOffsetX = 0;
  static const double _leftBottomOffsetY = 93;
  static const double _rightBottomOffsetX = 95;
  static const double _rightBottomOffsetY = 93;

  final ValueNotifier<JoystickAction> _actionNotifier = ValueNotifier(
    JoystickAction.idle,
  );

  JoystickAction get _action => _actionNotifier.value;

  static const Duration _holdDebounceDuration = Duration(seconds: 1);
  static const int _liftStatusAddress = 0x0011;
  static const Duration _liftStatusPollInterval = Duration(milliseconds: 500);
  Timer? _rightTopDebounceTimer;
  Timer? _rightBottomDebounceTimer;
  Timer? _liftStatusPollTimer;
  StreamSubscription<JoystickExternalCommand>? _externalCommandSubscription;
  bool _rightTopCommandSent = false;
  bool _rightBottomCommandSent = false;
  bool _rightTopPressed = false;
  bool _rightBottomPressed = false;
  bool get _hasLocalPress => _rightTopPressed || _rightBottomPressed;
  bool _isReadingLiftStatus = false;
  int _liftPollGeneration = 0;
  ModalRoute<dynamic>? _route;

  ModbusRtuService get _service =>
      widget.modbusService ?? const ModbusRtuService();

  @override
  void initState() {
    super.initState();
    _externalCommandSubscription = JoystickCommandBus.instance.stream.listen((
      JoystickExternalCommand command,
    ) {
      _syncActionFromExternal(command);
    });
    _syncFromCurrentGlobalLiftState();
    _startLiftStatusPolling();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != _route) {
      appRouteObserver.unsubscribe(this);
      _route = route;
      if (route != null) appRouteObserver.subscribe(this, route);
    }
    precacheImage(const AssetImage(Assets.joystickDefault), context);
    precacheImage(const AssetImage(Assets.joystickLeftTop), context);
    precacheImage(const AssetImage(Assets.joystickLeftBottom), context);
    precacheImage(const AssetImage(Assets.joystickRightTop), context);
    precacheImage(const AssetImage(Assets.joystickRightBottom), context);
  }

  @override
  void dispose() {
    _rightTopDebounceTimer?.cancel();
    _rightBottomDebounceTimer?.cancel();
    _liftStatusPollTimer?.cancel();
    _externalCommandSubscription?.cancel();
    appRouteObserver.unsubscribe(this);
    _actionNotifier.dispose();
    super.dispose();
  }

  @override
  void didPush() => _startLiftStatusPolling();

  @override
  void didPopNext() => _startLiftStatusPolling();

  @override
  void didPushNext() => _stopLiftStatusPolling();

  @override
  void didPop() => _stopLiftStatusPolling();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _joystickImageWidth,
      height: _joystickImageHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Image.asset(Assets.joystickDefault),
          Positioned.fill(
            child: ValueListenableBuilder<JoystickAction>(
              valueListenable: _actionNotifier,
              builder: (context, action, child) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    if (action == JoystickAction.holdingRightTop)
                      Positioned(
                        left: _rightTopOffsetX,
                        top: _rightTopOffsetY,
                        child: Image.asset(Assets.joystickRightTop),
                      ),
                    if (action == JoystickAction.holdingRightBottom)
                      Positioned(
                        left: _rightBottomOffsetX,
                        top: _rightBottomOffsetY,
                        child: Image.asset(Assets.joystickRightBottom),
                      ),
                    if (action == JoystickAction.lockedLeftTop)
                      Positioned(
                        left: _leftTopOffsetX,
                        top: _leftTopOffsetY,
                        child: Image.asset(Assets.joystickLeftTop),
                      ),
                    if (action == JoystickAction.lockedLeftBottom)
                      Positioned(
                        left: _leftBottomOffsetX,
                        top: _leftBottomOffsetY,
                        child: Image.asset(Assets.joystickLeftBottom),
                      ),
                  ],
                );
              },
            ),
          ),
          // 左上区域 — 锁定类型
          Positioned(
            left: 0,
            top: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _onLeftTop,
              child: Container(
                width: 93,
                height: 93,
                color: Colors.transparent,
              ),
            ),
          ),
          // 左下区域 — 锁定类型
          Positioned(
            left: 0,
            top: 93,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _onLeftBottom,
              child: Container(
                width: 93,
                height: 94,
                color: Colors.transparent,
              ),
            ),
          ),
          // 右上区域 — 按住类型（扩展触摸区域）
          Positioned(
            left: 93,
            top: 0,
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (_) => _onRightTopDown(),
              onPointerUp: (_) => _onRightTopUp(),
              onPointerCancel: (_) => _onRightTopUp(),
              child: Container(
                width: 94,
                height: 93,
                color: Colors.transparent,
              ),
            ),
          ),
          // 右下区域 — 按住类型（扩展触摸区域）
          Positioned(
            left: 93,
            top: 93,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (_) => _onRightBottomDown(),
              onTapUp: (_) => _onRightBottomUp(),
              onTapCancel: _onRightBottomUp,
              child: Container(
                width: 94,
                height: 94,
                color: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 左上（锁定类型）──────────────────────────────────────────

  void _onLeftTop() {
    if (_action == JoystickAction.idle) {
      unawaited(_triggerLiftAction(JoystickAction.lockedLeftTop, 3));
      return;
    }
    if (_action == JoystickAction.lockedLeftTop) {
      _manualStopLiftAction();
    }
  }

  // ── 左下（锁定类型）──────────────────────────────────────────

  void _onLeftBottom() {
    if (_action == JoystickAction.idle) {
      unawaited(_triggerLiftAction(JoystickAction.lockedLeftBottom, 4));
      return;
    }
    if (_action == JoystickAction.lockedLeftBottom) {
      _manualStopLiftAction();
    }
  }

  Future<void> _triggerLiftAction(
    JoystickAction action,
    int commandValue,
  ) async {
    if (_action != JoystickAction.idle || _hasLocalPress) return;
    final generation = ++_liftPollGeneration;
    _actionNotifier.value = action;
    debugPrint('Joystick lift trigger TX 0x0010=$commandValue');
    final bool sent = await _sendCommand(0x0010, commandValue);
    if (!mounted || generation != _liftPollGeneration) return;
    if (!sent) {
      _actionNotifier.value = JoystickAction.idle;
      return;
    }
    if (action == JoystickAction.lockedLeftTop) {
      JoystickCommandBus.instance.lockLeftTop();
    } else if (action == JoystickAction.lockedLeftBottom) {
      JoystickCommandBus.instance.lockLeftBottom();
    }
  }

  void _startLiftStatusPolling() {
    _liftPollGeneration++;
    _liftStatusPollTimer?.cancel();
    _liftStatusPollTimer = Timer.periodic(_liftStatusPollInterval, (_) {
      _readLiftStatusOnce();
    });
  }

  void _syncActionFromExternal(JoystickExternalCommand command) {
    if (!mounted) return;
    _liftPollGeneration++;
    _actionNotifier.value = command.action;
  }

  void _manualStopLiftAction() {
    _liftPollGeneration++;
    _actionNotifier.value = JoystickAction.idle;
    JoystickCommandBus.instance.reset();
    debugPrint('Joystick manual stop TX 0x0010=0');
    unawaited(_sendCommand(0x0010, 0));
  }

  void _syncFromCurrentGlobalLiftState() {
    _syncActionFromExternal(JoystickCommandBus.instance.lastLiftCommand);
  }

  void _stopLiftStatusPolling() {
    _liftPollGeneration++;
    _liftStatusPollTimer?.cancel();
    _liftStatusPollTimer = null;
  }

  Future<void> _readLiftStatusOnce() async {
    final bus = JoystickCommandBus.instance;
    // 空闲时也要读取，才能发现由下位机或其他页面触发的动作。
    // 防抖期间先保留按压反馈，写命令时不使用之前的状态覆盖新操作。
    if (_isReadingLiftStatus ||
        bus.hasPendingDeviceWrite ||
        ModalRoute.of(context)?.isCurrent == false ||
        (_rightTopPressed && !_rightTopCommandSent) ||
        (_rightBottomPressed && !_rightBottomCommandSent)) {
      return;
    }

    _isReadingLiftStatus = true;
    final int generation = _liftPollGeneration;
    final int revision = bus.commandRevision;
    bool isCurrentRead() =>
        mounted &&
        generation == _liftPollGeneration &&
        revision == bus.commandRevision &&
        ModalRoute.of(context)?.isCurrent != false;
    int? confirmedStatus;
    try {
      await widget.beforeStatusRead?.call();
      if (!isCurrentRead()) return;
      final int status = await _service.readHoldingRegister(_liftStatusAddress);
      if (!isCurrentRead()) return;
      debugPrint('Joystick lift status RX 0x0011=$status');
      final command = JoystickExternalCommand.fromStatus(status);
      if (command == null) return;
      confirmedStatus = status;
      _actionNotifier.value = command.action;

      // 本地按压中的控制交给手势处理。停止命令发出后，旧的运动反馈
      // 不得重新写回运动指令；等收到停止状态后再恢复自动校正。
      if (_hasLocalPress || (bus.waitingForStopFeedback && status != 0)) return;
      final control = await _service.readHoldingRegister(0x0010);
      if (!isCurrentRead()) return;
      if (control != status) {
        debugPrint('Joystick reconcile TX 0x0010=$status (was $control)');
        await bus.runLiftWrite(() async {
          if (!isCurrentRead()) return;
          await _service.sendCommandQueue([
            ModbusWriteCommand(address: 0x0010, value: status),
          ]);
        });
      }

      /* 电流检测暂时停用。
      /// 读取升降杆的电流值
      if (widget.onLiftCurrentChanged != null &&
          ModalRoute.of(context)?.isCurrent != false) {
        try {
          /// 读取升降杆电流值，地址为0x0017
          /// 0x0017为16位无符号整数，当前值为0-65535
          final int current = await _service.readLiftCurrent();
          if (!mounted || generation != _liftPollGeneration) return;
          debugPrint('Lift current RX 0x0017=$current (raw)');
          widget.onLiftCurrentChanged?.call(current);
        } catch (error) {
          if (!mounted || generation != _liftPollGeneration) return;
          debugPrint('Lift current read failed: $error');
          widget.onLiftCurrentChanged?.call(null);
        }
      }
      */
    } catch (e) {
      debugPrint('Joystick lift status read failed: $e');
    } finally {
      if (confirmedStatus != null && isCurrentRead()) {
        bus.syncStatus(confirmedStatus);
      }
      _isReadingLiftStatus = false;
    }
  }

  // ── 右上（按住类型）──────────────────────────────────────────

  void _onRightTopDown() {
    if (_action != JoystickAction.idle || _hasLocalPress) return;
    _liftPollGeneration++;
    _rightTopPressed = true;
    debugPrint('Joystick rightTop down, wait 1s debounce');
    _actionNotifier.value = JoystickAction.holdingRightTop;
    _rightTopCommandSent = false;
    _rightTopDebounceTimer?.cancel();
    _rightTopDebounceTimer = Timer(_holdDebounceDuration, () {
      if (!mounted) return;
      if (!_rightTopPressed) return;
      _rightTopCommandSent = true;
      debugPrint('Joystick rightTop debounce passed TX 0x0010=1');
      // unawaited(_sendHoldCommand(1, JoystickAction.holdingRightTop));
      unawaited(_sendCommand(0x0010, 1));
    });
  }

  void _onRightTopUp() {
    // 状态反馈可能已改变图片，但只要本地发过移动命令，松手仍须停止。
    if (!_rightTopPressed) return;
    _rightTopPressed = false;
    _liftPollGeneration++;
    _rightTopDebounceTimer?.cancel();
    final bool sent = _rightTopCommandSent;
    _rightTopCommandSent = false;
    _actionNotifier.value = JoystickAction.idle;
    if (sent) {
      debugPrint('Joystick rightTop up/cancel TX 0x0010=0');
      _sendCommand(0x0010, 0);
    } else {
      debugPrint('Joystick rightTop released before 1s, skip TX');
    }
  }

  // ── 右下（按住类型）──────────────────────────────────────────

  void _onRightBottomDown() {
    if (_action != JoystickAction.idle || _hasLocalPress) return;
    _liftPollGeneration++;
    _rightBottomPressed = true;
    debugPrint('Joystick rightBottom down, wait 1s debounce');
    _actionNotifier.value = JoystickAction.holdingRightBottom;
    _rightBottomCommandSent = false;
    _rightBottomDebounceTimer?.cancel();
    _rightBottomDebounceTimer = Timer(_holdDebounceDuration, () {
      if (!mounted) return;
      if (!_rightBottomPressed) return;
      _rightBottomCommandSent = true;
      debugPrint('Joystick rightBottom debounce passed TX 0x0010=2');
      // unawaited(_sendHoldCommand(2, JoystickAction.holdingRightBottom));
      unawaited(_sendCommand(0x0010, 2));
    });
  }

  void _onRightBottomUp() {
    if (!_rightBottomPressed) return;
    _rightBottomPressed = false;
    _liftPollGeneration++;
    _rightBottomDebounceTimer?.cancel();
    final bool sent = _rightBottomCommandSent;
    _rightBottomCommandSent = false;
    _actionNotifier.value = JoystickAction.idle;
    if (sent) {
      debugPrint('Joystick rightBottom up/cancel TX 0x0010=0');
      _sendCommand(0x0010, 0);
    } else {
      debugPrint('Joystick rightBottom released before 1s, skip TX');
    }
  }

  // ── Modbus 命令分发 ──────────────────────────────────────────

  /* 电流检测暂时停用，手动升降只发送控制命令。
  Future<void> _sendHoldCommand(int value, JoystickAction action) async {
    final bool sent = await _sendCommand(0x0010, value);
    if (mounted &&
        sent &&
        _action == action &&
        widget.onLiftCurrentChanged != null) {
      _startLiftStatusPolling();
    }
  }

  */

  Future<bool> _sendCommand(int address, int value) async {
    final bus = JoystickCommandBus.instance;
    bus.noteLocalCommand(value);
    final revision = bus.commandRevision;
    var sent = false;
    try {
      await bus.runLiftWrite(() async {
        // 校正写完成前可能已经松手；取消排队中的旧移动，停止仍必须发送。
        if (value != 0 && revision != bus.commandRevision) return;
        await _service.sendCommandQueue([
          ModbusWriteCommand(address: address, value: value),
        ]);
        sent = true;
      });
      if (sent) debugPrint('Joystick command success');
      return sent;
    } catch (e) {
      debugPrint('Joystick command failed: $e');
      return false;
    }
  }
}

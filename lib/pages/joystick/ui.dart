import 'dart:async';
import 'package:flutter/material.dart';
import 'package:infibo_app/api/modbus_rtu_service.dart';
import 'package:infibo_app/constants/assets.dart';

enum JoystickAction {
  idle,
  lockedLeftTop,
  lockedLeftBottom,
  holdingRightTop,
  holdingRightBottom,
}

class JoystickControl extends StatefulWidget {
  const JoystickControl({super.key, this.modbusService});

  final ModbusRtuService? modbusService;

  @override
  State<JoystickControl> createState() => _JoystickControlState();
}

class _JoystickControlState extends State<JoystickControl> {
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

  bool _isCommanding = false;
  bool _pendingStop = false;
  static const Duration _holdDebounceDuration = Duration(seconds: 1);
  Timer? _rightTopDebounceTimer;
  Timer? _rightBottomDebounceTimer;
  bool _rightTopCommandSent = false;
  bool _rightBottomCommandSent = false;

  ModbusRtuService get _service =>
      widget.modbusService ?? const ModbusRtuService();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
    _actionNotifier.dispose();
    super.dispose();
  }

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
    switch (_action) {
      case JoystickAction.idle:
        debugPrint('Joystick leftTop lock TX 0x0010=3');
        _actionNotifier.value = JoystickAction.lockedLeftTop;
        _sendCommand(0x0010, 3);
      case JoystickAction.lockedLeftTop:
        debugPrint('Joystick leftTop unlock TX 0x0010=0');
        _actionNotifier.value = JoystickAction.idle;
        _sendCommand(0x0010, 0);
      default:
        break;
    }
  }

  // ── 左下（锁定类型）──────────────────────────────────────────

  void _onLeftBottom() {
    switch (_action) {
      case JoystickAction.idle:
        debugPrint('Joystick leftBottom lock TX 0x0010=4');
        _actionNotifier.value = JoystickAction.lockedLeftBottom;
        _sendCommand(0x0010, 4);
      case JoystickAction.lockedLeftBottom:
        debugPrint('Joystick leftBottom unlock TX 0x0010=0');
        _actionNotifier.value = JoystickAction.idle;
        _sendCommand(0x0010, 0);
      default:
        break;
    }
  }

  // ── 右上（按住类型）──────────────────────────────────────────

  void _onRightTopDown() {
    if (_action != JoystickAction.idle) return;
    debugPrint('Joystick rightTop down, wait 1s debounce');
    _actionNotifier.value = JoystickAction.holdingRightTop;
    _rightTopCommandSent = false;
    _rightTopDebounceTimer?.cancel();
    _rightTopDebounceTimer = Timer(_holdDebounceDuration, () {
      if (!mounted) return;
      if (_action != JoystickAction.holdingRightTop) return;
      _rightTopCommandSent = true;
      debugPrint('Joystick rightTop debounce passed TX 0x0010=1');
      _sendCommand(0x0010, 1);
    });
  }

  void _onRightTopUp() {
    if (_action != JoystickAction.holdingRightTop) return;
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
    if (_action != JoystickAction.idle) return;
    debugPrint('Joystick rightBottom down, wait 1s debounce');
    _actionNotifier.value = JoystickAction.holdingRightBottom;
    _rightBottomCommandSent = false;
    _rightBottomDebounceTimer?.cancel();
    _rightBottomDebounceTimer = Timer(_holdDebounceDuration, () {
      if (!mounted) return;
      if (_action != JoystickAction.holdingRightBottom) return;
      _rightBottomCommandSent = true;
      debugPrint('Joystick rightBottom debounce passed TX 0x0010=2');
      _sendCommand(0x0010, 2);
    });
  }

  void _onRightBottomUp() {
    if (_action != JoystickAction.holdingRightBottom) return;
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

  Future<void> _sendCommand(int address, int value) async {
    if (_isCommanding) {
      if (value == 0) {
        _pendingStop = true;
      }
      return;
    }
    _isCommanding = true;
    try {
      await _service.sendCommandQueue([
        ModbusWriteCommand(address: address, value: value),
      ]);
      debugPrint('Joystick command success');
    } catch (e) {
      debugPrint('Joystick command failed: $e');
    } finally {
      if (mounted) {
        _isCommanding = false;
        if (_pendingStop) {
          _pendingStop = false;
          _sendPendingStop();
        }
      }
    }
  }

  Future<void> _sendPendingStop() async {
    if (_isCommanding) return;
    _isCommanding = true;
    try {
      await _service.sendCommandQueue([
        const ModbusWriteCommand(address: 0x0010, value: 0),
      ]);
      debugPrint('Joystick pending stop success');
    } catch (e) {
      debugPrint('Joystick pending stop failed: $e');
    } finally {
      if (mounted) {
        _isCommanding = false;
      }
    }
  }
}

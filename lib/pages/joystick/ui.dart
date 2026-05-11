import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infibo_app/api/modbus_rtu_service.dart';
import 'package:infibo_app/constants/assets.dart';

enum _JoystickHoldState { none, leftTop, leftBottom }

enum _JoystickFlashState { none, rightTop, rightBottom }

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
  static const double _rightTopOffsetX = 93;
  static const double _rightTopOffsetY = 0;
  static const double _leftBottomOffsetX = 0;
  static const double _leftBottomOffsetY = 92;
  static const double _rightBottomOffsetX = 93;
  static const double _rightBottomOffsetY = 92;

  _JoystickHoldState _hold = _JoystickHoldState.none;
  _JoystickFlashState _flash = _JoystickFlashState.none;
  Timer? _flashTimer;
  bool _isCommanding = false;

  ModbusRtuService get _service =>
      widget.modbusService ?? const ModbusRtuService();

  @override
  void initState() {
    super.initState();
    _logJoystickImageSizes();
  }

  @override
  void dispose() {
    _flashTimer?.cancel();
    super.dispose();
  }

  Future<void> _logJoystickImageSizes() async {
    try {
      final List<String> assets = [
        Assets.joystickDefault,
        Assets.joystickLeftTop,
        Assets.joystickLeftBottom,
        Assets.joystickRightTop,
        Assets.joystickRightBottom,
      ];
      for (final String asset in assets) {
        final ByteData data = await rootBundle.load(asset);
        final ui.Image image = await decodeImageFromList(
          data.buffer.asUint8List(),
        );
        debugPrint(
          'Joystick asset $asset size: ${image.width}x${image.height}',
        );
      }
    } catch (e) {
      debugPrint('Joystick asset size log failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _joystickImageWidth,
      height: _joystickImageHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double w = constraints.maxWidth;
          final double h = constraints.maxHeight;
          final double zoneW = w / 3;
          final double zoneH = h / 3;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Image.asset(Assets.joystickDefault),
              if (_flash == _JoystickFlashState.rightTop)
                Positioned(
                  left: _rightTopOffsetX,
                  top: _rightTopOffsetY,
                  child: Image.asset(Assets.joystickRightTop),
                ),
              if (_flash == _JoystickFlashState.rightBottom)
                Positioned(
                  left: _rightBottomOffsetX,
                  top: _rightBottomOffsetY,
                  child: Image.asset(Assets.joystickRightBottom),
                ),
              if (_hold == _JoystickHoldState.leftTop)
                Positioned(
                  left: _leftTopOffsetX,
                  top: _leftTopOffsetY,
                  child: Image.asset(Assets.joystickLeftTop),
                ),
              if (_hold == _JoystickHoldState.leftBottom)
                Positioned(
                  left: _leftBottomOffsetX,
                  top: _leftBottomOffsetY,
                  child: Image.asset(Assets.joystickLeftBottom),
                ),
              // leftTop zone
              _HitRegion(
                left: 0,
                top: 0,
                width: zoneW,
                height: zoneH,
                onTapDown: (_) => _onLeftTop(),
              ),
              // rightTop zone
              _HitRegion(
                left: zoneW * 2,
                top: 0,
                width: zoneW,
                height: zoneH,
                onTapDown: (_) => _onRightTop(),
              ),
              // leftBottom zone
              _HitRegion(
                left: 0,
                top: zoneH * 2,
                width: zoneW,
                height: zoneH,
                onTapDown: (_) => _onLeftBottom(),
              ),
              // rightBottom zone
              _HitRegion(
                left: zoneW * 2,
                top: zoneH * 2,
                width: zoneW,
                height: zoneH,
                onTapDown: (_) => _onRightBottom(),
              ),
              // center zone
              _HitRegion(
                left: zoneW,
                top: zoneH,
                width: zoneW,
                height: zoneH,
                onTapDown: (_) => _onCenter(),
              ),
            ],
          );
        },
      ),
    );
  }

  void _onLeftTop() {
    debugPrint('Joystick leftTop pressed, TX address=0x0010 value=3');
    _flashTimer?.cancel();
    setState(() {
      _flash = _JoystickFlashState.none;
      _hold = _JoystickHoldState.leftTop;
    });
    _sendCommand(0x0010, 3);
  }

  void _onLeftBottom() {
    debugPrint('Joystick leftBottom pressed, TX address=0x0010 value=4');
    _flashTimer?.cancel();
    setState(() {
      _flash = _JoystickFlashState.none;
      _hold = _JoystickHoldState.leftBottom;
    });
    _sendCommand(0x0010, 4);
  }

  void _onRightTop() {
    debugPrint('Joystick rightTop pressed, TX address=0x0010 value=1');
    _startFlash(_JoystickFlashState.rightTop);
    _sendCommand(0x0010, 1);
  }

  void _onRightBottom() {
    debugPrint('Joystick rightBottom pressed, TX address=0x0010 value=2');
    _startFlash(_JoystickFlashState.rightBottom);
    _sendCommand(0x0010, 2);
  }

  void _onCenter() {
    debugPrint('Joystick center pressed, TX address=0x0010 value=0');
    _flashTimer?.cancel();
    setState(() {
      _hold = _JoystickHoldState.none;
      _flash = _JoystickFlashState.none;
    });
    _sendCommand(0x0010, 0);
  }

  void _startFlash(_JoystickFlashState state) {
    _flashTimer?.cancel();
    setState(() => _flash = state);
    _flashTimer = Timer(const Duration(milliseconds: 260), () {
      if (!mounted) return;
      setState(() => _flash = _JoystickFlashState.none);
    });
  }

  Future<void> _sendCommand(int address, int value) async {
    if (_isCommanding) return;
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
      }
    }
  }
}

class _HitRegion extends StatelessWidget {
  const _HitRegion({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.onTapDown,
  });

  final double left;
  final double top;
  final double width;
  final double height;
  final GestureTapDownCallback onTapDown;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: onTapDown,
        child: Container(
          width: width,
          height: height,
          color: Colors.transparent,
        ),
      ),
    );
  }
}

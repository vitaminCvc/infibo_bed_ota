//这个文件实现了一个串口通信服务，主要用于与硬件设备（如理疗仪器）进行数据交互。
// Android 原生串口桥接服务。
//
// Dart 侧通过 MethodChannel 调用 AndroidSerialPortBridge.kt 打开 /dev/ttyS0、
// 发送字节、关闭串口，并通过事件流接收下位机返回的数据。
// 正式业务和串口测试页都应从这里拿默认串口参数，避免不同地方写死不同节点。
import 'dart:async';
import 'serial_session_gate.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:infibo_app/utils/byte_utils.dart';

class AndroidSerialPortService {
  AndroidSerialPortService._() {
    _channel.setMethodCallHandler(_handleNativeCall);
  }

  final SerialSessionGate _gate = SerialSessionGate();
  Future<T?> _invoke<T>(String method, [Object? arguments]) =>
      _gate.run<T?>(null, () => _channel.invokeMethod<T>(method, arguments));
  Future<SerialLease> beginExclusiveSession() {
    _ensureAndroid();
    return _gate.acquire();
  }

  Future<Uint8List> transceiveExclusive({
    required SerialLease lease,
    required Uint8List bytes,
    required Duration timeout,
    String path = defaultPath,
    int baudRate = defaultBaudRate,
  }) async {
    _ensureAndroid();
    final response = await _gate.run<Object?>(
      lease,
      () => _channel.invokeMethod<Object>('transceiveBytes', {
        'path': path,
        'baudRate': baudRate,
        'timeoutMs': timeout.inMilliseconds,
        'bytes': bytes,
      }),
    );
    if (response is Uint8List) return response;
    return Uint8List.fromList(List<int>.from(response as List? ?? []));
  }

  static final AndroidSerialPortService instance = AndroidSerialPortService._();
  // 厂家确认安卓屏 RS232 对应这个节点。后续正式业务默认也用它。
  // static const String defaultPath = '/dev/ttyS0';
  static const String defaultPath = '/dev/ttyS2';
  static const int defaultBaudRate = 115200;
  static const int defaultDataBits = 8;
  static const int defaultStopBits = 1;
  static const String defaultParity = 'none';

  static const MethodChannel _channel = MethodChannel(
    'infibo_app/android_serial_port',
  );

  final StreamController<AndroidSerialPortEvent> _events =
      StreamController<AndroidSerialPortEvent>.broadcast();

  Stream<AndroidSerialPortEvent> get events => _events.stream;

  Future<void> openSerialPort({
    String path = defaultPath,
    int baudRate = defaultBaudRate,
  }) async {
    _ensureAndroid();
    await _invoke<bool>('openSerialPort', {'path': path, 'baudRate': baudRate});
  }

  Future<int> sendBytes(Uint8List bytes) async {
    _ensureAndroid();
    final int? count = await _invoke<int>('sendBytes', {'bytes': bytes});
    return count ?? 0;
  }

  Future<Uint8List> transceiveBytes({
    required Uint8List bytes,
    String path = defaultPath,
    int baudRate = defaultBaudRate,
    required Duration timeout,
  }) async {
    _ensureAndroid();
    final Object? response = await _invoke<Object>('transceiveBytes', {
      'path': path,
      'baudRate': baudRate,
      'timeoutMs': timeout.inMilliseconds,
      'bytes': bytes,
    });

    if (response is Uint8List) return response;
    return Uint8List.fromList(List<int>.from(response as List? ?? []));
  }

  Future<int> writeBytesOnce({
    required Uint8List bytes,
    String path = defaultPath,
    int baudRate = defaultBaudRate,
  }) async {
    _ensureAndroid();
    final int? count = await _invoke<int>('writeBytesOnce', {
      'path': path,
      'baudRate': baudRate,
      'bytes': bytes,
    });
    return count ?? 0;
  }

  Future<List<Uint8List>> writeModbusQueue({
    required List<Uint8List> frames,
    String path = defaultPath,
    int baudRate = defaultBaudRate,
    required Duration timeout,
    required Duration commandDelay,
    required int maxRetries,
  }) async {
    _ensureAndroid();
    final Object? response = await _invoke<Object>('writeModbusQueue', {
      'path': path,
      'baudRate': baudRate,
      'timeoutMs': timeout.inMilliseconds,
      'delayMs': commandDelay.inMilliseconds,
      'maxRetries': maxRetries,
      'frames': frames,
    });

    final List<dynamic> items = response is List ? response : const [];
    return [
      for (final dynamic item in items)
        item is Uint8List
            ? item
            : Uint8List.fromList(List<int>.from(item as List? ?? [])),
    ];
  }

  Future<int> writeModbusQueueNoResponse({
    required List<Uint8List> frames,
    String path = defaultPath,
    int baudRate = defaultBaudRate,
    required Duration commandDelay,
  }) async {
    _ensureAndroid();
    final int? count = await _invoke<int>('writeModbusQueueNoResponse', {
      'path': path,
      'baudRate': baudRate,
      'delayMs': commandDelay.inMilliseconds,
      'frames': frames,
    });
    return count ?? 0;
  }

  Future<void> closeSerialPort() async {
    _ensureAndroid();
    await _invoke<bool>('closeSerialPort');
  }

  Future<void> _handleNativeCall(MethodCall call) async {
    switch (call.method) {
      case 'onReceive':
        final Map<dynamic, dynamic> args =
            (call.arguments as Map?) ?? <dynamic, dynamic>{};
        final Object? rawBytes = args['bytes'];
        final Uint8List bytes = rawBytes is Uint8List
            ? rawBytes
            : Uint8List.fromList(List<int>.from(rawBytes as List? ?? []));

        _events.add(
          AndroidSerialPortEvent.rx(
            path: args['path'] as String?,
            bytes: bytes,
            hex: (args['hex'] as String?) ?? bytesToHex(bytes),
          ),
        );
        break;
      case 'onError':
        final Map<dynamic, dynamic> args =
            (call.arguments as Map?) ?? <dynamic, dynamic>{};
        _events.add(
          AndroidSerialPortEvent.error(
            (args['message'] as String?) ?? 'Unknown serial error',
          ),
        );
        break;
    }
  }

  void _ensureAndroid() {
    if (defaultTargetPlatform != TargetPlatform.android) {
      throw UnsupportedError('Android serial port test only supports Android.');
    }
  }
}

enum AndroidSerialPortEventType { rx, error }

class AndroidSerialPortEvent {
  const AndroidSerialPortEvent._({
    required this.type,
    this.path,
    this.bytes,
    this.hex,
    this.message,
  });

  factory AndroidSerialPortEvent.rx({
    required String? path,
    required Uint8List bytes,
    required String hex,
  }) {
    return AndroidSerialPortEvent._(
      type: AndroidSerialPortEventType.rx,
      path: path,
      bytes: bytes,
      hex: hex,
    );
  }

  factory AndroidSerialPortEvent.error(String message) {
    return AndroidSerialPortEvent._(
      type: AndroidSerialPortEventType.error,
      message: message,
    );
  }

  final AndroidSerialPortEventType type;
  final String? path;
  final Uint8List? bytes;
  final String? hex;
  final String? message;
}

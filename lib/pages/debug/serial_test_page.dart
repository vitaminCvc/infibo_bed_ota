// 隐藏串口调试页。
//
// 访问路由：/debug/serial-test。正式页面不显示入口。
// 这个页面用于现场排查 Android 屏 RS232 节点是否能通信，默认节点是 /dev/ttyS0，
// 串口参数固定为 115200、8N1、无校验。
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:infibo_app/services/android_serial_port_service.dart';
import 'package:infibo_app/utils/byte_utils.dart';
import 'package:infibo_app/utils/date_time_utils.dart';

class SerialTestPage extends StatefulWidget {
  const SerialTestPage({super.key});

  @override
  State<SerialTestPage> createState() => _SerialTestPageState();
}

class _SerialTestPageState extends State<SerialTestPage> {
  static const List<String> _serialPaths = [
    '/dev/ttyS0',
    '/dev/ttyS1',
    '/dev/ttyS2',
    '/dev/ttyS3',
    '/dev/ttyS4',
    '/dev/ttyS5',
  ];

  static final Uint8List _testCommand = Uint8List.fromList([
    0x10,
    0x06,
    0x00,
    0x00,
    0x00,
    0x01,
    0x4B,
    0x4B,
  ]);

  final AndroidSerialPortService _serialPort =
      AndroidSerialPortService.instance;
  final List<String> _logs = <String>[];
  final ScrollController _logScrollController = ScrollController();

  StreamSubscription<AndroidSerialPortEvent>? _eventSubscription;
  String _selectedPath = AndroidSerialPortService.defaultPath;
  bool _isOpening = false;
  bool _isSending = false;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    _eventSubscription = _serialPort.events.listen(_handleSerialEvent);
    _addLog('串口测试页已启动，默认节点 $_selectedPath');
    _addLog(
      '固定参数：${AndroidSerialPortService.defaultBaudRate}, '
      '${AndroidSerialPortService.defaultDataBits}N'
      '${AndroidSerialPortService.defaultStopBits}, '
      'parity ${AndroidSerialPortService.defaultParity}',
    );
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _logScrollController.dispose();
    if (defaultTargetPlatform == TargetPlatform.android) {
      unawaited(_serialPort.closeSerialPort());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF151821),
        foregroundColor: Colors.white,
        title: const Text('RS232 串口节点测试'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildConfigCard(),
              const SizedBox(height: 12),
              _buildButtons(),
              const SizedBox(height: 12),
              Expanded(child: _buildLogPanel()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfigCard() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF171A23),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2E3443)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '选择串口节点',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _selectedPath,
              dropdownColor: const Color(0xFF202532),
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color(0xFF10131A),
                border: OutlineInputBorder(),
              ),
              items: [
                for (final String path in _serialPaths)
                  DropdownMenuItem(value: path, child: Text(path)),
              ],
              onChanged: (String? value) {
                if (value == null) return;
                setState(() => _selectedPath = value);
                _addLog('已选择节点：$value');
              },
            ),
            const SizedBox(height: 12),
            const Text(
              'baudRate = 115200, dataBits = 8, stopBits = 1, parity = none',
              style: TextStyle(color: Color(0xFFB9BFCC), fontSize: 14),
            ),
            const SizedBox(height: 6),
            Text(
              '测试命令：${bytesToHex(_testCommand)}',
              style: const TextStyle(color: Color(0xFFB9BFCC), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _ActionButton(
          label: _isOpening ? '打开中...' : '打开串口',
          color: const Color(0xFF1F74E8),
          onPressed: _isOpening ? null : _openSerialPort,
        ),
        _ActionButton(
          label: _isSending ? '发送中...' : '发送测试命令',
          color: const Color(0xFF14A86B),
          onPressed: _isSending ? null : _sendTestCommand,
        ),
        _ActionButton(
          label: _isClosing ? '关闭中...' : '关闭串口',
          color: const Color(0xFF7B8496),
          onPressed: _isClosing ? null : _closeSerialPort,
        ),
        _ActionButton(
          label: '清空日志',
          color: const Color(0xFF3B4050),
          onPressed: _clearLogs,
        ),
      ],
    );
  }

  Widget _buildLogPanel() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2E3443)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView.builder(
          controller: _logScrollController,
          itemCount: _logs.length,
          itemBuilder: (context, index) {
            final String log = _logs[index];
            final Color color = log.contains('ERROR:')
                ? const Color(0xFFFF6B6B)
                : log.contains('RX:')
                ? const Color(0xFF58D68D)
                : log.contains('TX:')
                ? const Color(0xFF5DADE2)
                : const Color(0xFFD7DAE2);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Text(
                log,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontFamily: 'monospace',
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _openSerialPort() async {
    setState(() => _isOpening = true);

    try {
      await _serialPort.openSerialPort(path: _selectedPath);
      _addLog('打开串口成功：$_selectedPath');
    } catch (error) {
      _addLog('ERROR: 打开串口失败：$error');
    } finally {
      if (mounted) setState(() => _isOpening = false);
    }
  }

  Future<void> _sendTestCommand() async {
    setState(() => _isSending = true);

    try {
      _addLog('TX: ${bytesToHex(_testCommand)}');
      final int sentCount = await _serialPort.sendBytes(_testCommand);
      _addLog('发送完成：$sentCount bytes');
    } catch (error) {
      _addLog('ERROR: 发送失败：$error');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _closeSerialPort() async {
    setState(() => _isClosing = true);

    try {
      await _serialPort.closeSerialPort();
      _addLog('关闭串口成功');
    } catch (error) {
      _addLog('ERROR: 关闭串口失败：$error');
    } finally {
      if (mounted) setState(() => _isClosing = false);
    }
  }

  void _clearLogs() {
    setState(_logs.clear);
  }

  void _handleSerialEvent(AndroidSerialPortEvent event) {
    switch (event.type) {
      case AndroidSerialPortEventType.rx:
        _addLog('RX: ${event.hex}');
        break;
      case AndroidSerialPortEventType.error:
        _addLog('ERROR: ${event.message}');
        break;
    }
  }

  void _addLog(String message) {
    final DateTime now = DateTime.now();
    final String time = formatClockTimeWithSeconds(now);

    if (!mounted) {
      _logs.add('[$time] $message');
      return;
    }

    setState(() => _logs.add('[$time] $message'));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_logScrollController.hasClients) return;
      _logScrollController.animateTo(
        _logScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    });
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 156,
      height: 46,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: color.withValues(alpha: 0.42),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label),
      ),
    );
  }
}

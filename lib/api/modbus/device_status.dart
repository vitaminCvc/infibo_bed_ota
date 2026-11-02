/// 两个页面共用同一设备状态判定；未取得有效状态时显示离线。
enum DeviceStatus {
  offline('device_offline'),
  ready('device_ready'),
  fault('device_fault');

  const DeviceStatus(this.translationKey);
  final String translationKey;

  static DeviceStatus fromRegister(int value) {
    if (value < 0 || value > 0xFFFF) {
      throw StateError('Invalid device status register value: $value');
    }
    return value == 3 || value == 5 ? fault : ready;
  }
}

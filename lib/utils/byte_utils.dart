// 字节数据工具函数。
//
// 串口服务和调试页面共用这里的十六进制格式化规则。
String bytesToHex(Iterable<int> bytes, {String emptyText = ''}) {
  if (bytes.isEmpty) return emptyText;

  return bytes
      .map((int byte) => (byte & 0xFF).toRadixString(16).padLeft(2, '0'))
      .join(' ')
      .toUpperCase();
}

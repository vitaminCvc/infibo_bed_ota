import 'dart:io';
import 'dart:isolate';
import 'package:crypto/crypto.dart';

/// Sends only the path and expected metadata to the worker. File bytes are
/// streamed and hashed there, keeping CPU work off the UI isolate.
Future<bool> verifyOtaFile({
  required String path,
  required int size,
  required String expectedSha256,
}) => Isolate.run(
  () => _verifyFile(path, size, expectedSha256),
  debugName: 'infibo-ota-sha256',
);

Future<bool> _verifyFile(String path, int size, String expectedSha256) async {
  final file = File(path);
  if (!await file.exists() || await file.length() != size) {
    return false;
  }
  final digest = await sha256.bind(file.openRead()).first;
  return digest.toString() == expectedSha256.toLowerCase();
}

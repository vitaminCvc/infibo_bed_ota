import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/ota/ota_file_verifier.dart';

void main() {
  late Directory directory;
  late File file;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('infibo-ota-hash-');
    file = File('${directory.path}/update.apk');
  });
  tearDown(() async => directory.delete(recursive: true));
  test('verifies the standard SHA256 vector in the background', () async {
    await file.writeAsString('abc');
    expect(
      await verifyOtaFile(
        path: file.path,
        size: 3,
        expectedSha256:
            'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
      ),
      isTrue,
    );
  });
  test('streams a multichunk file and accepts uppercase hash', () async {
    final data = List<int>.generate(512 * 1024 + 19, (i) => i & 255);
    await file.writeAsBytes(data);
    expect(
      await verifyOtaFile(
        path: file.path,
        size: data.length,
        expectedSha256: sha256.convert(data).toString().toUpperCase(),
      ),
      isTrue,
    );
  });
  test('rejects corrupted bytes even when file length matches', () async {
    await file.writeAsString('abd');
    expect(
      await verifyOtaFile(
        path: file.path,
        size: 3,
        expectedSha256:
            'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
      ),
      isFalse,
    );
  });
  test('rejects missing and truncated files', () async {
    expect(
      await verifyOtaFile(path: file.path, size: 3, expectedSha256: 'a' * 64),
      isFalse,
    );
    await file.writeAsString('ab');
    expect(
      await verifyOtaFile(path: file.path, size: 3, expectedSha256: 'a' * 64),
      isFalse,
    );
  });
  test('rejects a directory without leaving a pending verification', () async {
    final asFile = File(directory.path);
    await expectLater(
      verifyOtaFile(path: asFile.path, size: 3, expectedSha256: 'a' * 64),
      completion(isFalse),
    );
  });
}

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/ota/android_update_gateway.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = AndroidUpdateGateway.channel;
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));
  test(
    'permission is read from Android each time and absent values fail closed',
    () async {
      bool? permission = false;
      final calls = <String>[];
      messenger.setMockMethodCallHandler(channel, (MethodCall call) async {
        calls.add(call.method);
        return permission;
      });
      final gateway = AndroidUpdateGateway();
      expect(await gateway.canInstallPackages(), isFalse);
      permission = true;
      expect(await gateway.canInstallPackages(), isTrue);
      permission = null;
      expect(await gateway.canInstallPackages(), isFalse);
      expect(calls, [
        'canInstallPackages',
        'canInstallPackages',
        'canInstallPackages',
      ]);
    },
  );
}

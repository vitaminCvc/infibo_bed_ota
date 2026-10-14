import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/services/serial_session_gate.dart';

void main() {
  test(
    'exclusive session drains existing requests and rejects normal traffic',
    () async {
      final gate = SerialSessionGate();
      final pending = Completer<int>();
      final first = gate.run<int>(null, () => pending.future);
      final acquiring = gate.acquire();
      await expectLater(gate.run<int>(null, () async => 2), throwsStateError);
      pending.complete(1);
      expect(await first, 1);
      final lease = await acquiring;
      expect(await gate.run<int>(lease, () async => 3), 3);
      await expectLater(gate.acquire(), throwsStateError);
      await lease.release();
      expect(await gate.run<int>(null, () async => 4), 4);
      await expectLater(gate.run<int>(lease, () async => 5), throwsStateError);
    },
  );
}

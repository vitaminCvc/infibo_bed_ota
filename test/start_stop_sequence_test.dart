import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/api/modbus/modbus_rtu_service.dart';

class RecordingStopService extends ModbusRtuService {
  RecordingStopService({this.failedRounds = const <int>{}})
    : super(commandDelay: const Duration(milliseconds: 20));

  final Set<int> failedRounds;
  final List<List<ModbusWriteCommand>> rounds = [];

  @override
  Future<void> sendCommandQueue(List<ModbusWriteCommand> commands) async {
    rounds.add(commands);
    if (failedRounds.contains(rounds.length)) {
      throw StateError('round ${rounds.length} failed');
    }
  }
}

void main() {
  List<String> writes(List<ModbusWriteCommand> commands) => [
    for (final command in commands) '${command.address}:${command.value}',
  ];

  test(
    'first round clears parameters; later rounds only stop active modules',
    () async {
      final service = RecordingStopService();

      await service.stopTherapyThreeRounds(stopRed: true, stopVat: true);

      expect(service.commandDelay, const Duration(milliseconds: 20));
      expect(service.rounds, hasLength(3));
      expect(writes(service.rounds.first), [
        '115:2',
        '104:0',
        '105:0',
        '109:0',
        '110:0',
        '100:0',
        '401:2',
        '386:0',
        '384:0',
        '4:2',
      ]);
      for (final round in service.rounds.skip(1)) {
        expect(writes(round), ['115:2', '401:2', '4:2']);
      }
    },
  );

  test(
    'a failed full round is retried in full before compact rounds',
    () async {
      final service = RecordingStopService(failedRounds: {1});

      await service.stopTherapyThreeRounds(stopRed: true);

      expect(service.rounds, hasLength(3));
      expect(writes(service.rounds[0]), writes(service.rounds[1]));
      expect(writes(service.rounds[2]), ['115:2', '4:2']);
    },
  );

  test('all failed full rounds report an error', () async {
    final service = RecordingStopService(failedRounds: {1, 2, 3});

    await expectLater(
      service.stopTherapyThreeRounds(stopRed: true),
      throwsStateError,
    );
    expect(service.rounds, hasLength(3));
    expect(writes(service.rounds[0]), writes(service.rounds[2]));
  });

  test('compact commands include each active stop and system stop last', () {
    final service = RecordingStopService();

    expect(
      writes(
        service.buildStopTherapyCompactCommands(
          stopRed: true,
          stopPemf: true,
          stopHydrogen: true,
          stopVat: true,
          stopChakra: true,
          stopTerahertz: true,
          stopHifem: true,
          stopFragrance: true,
        ),
      ),
      [
        '115:2',
        '209:2',
        '465:2',
        '401:2',
        '529:2',
        '593:2',
        '721:2',
        '657:2',
        '4:2',
      ],
    );
    expect(writes(service.buildStopTherapyCompactCommands()), ['4:2']);
  });
}

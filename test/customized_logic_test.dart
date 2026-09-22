import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:infibo_app/pages/customized/customizedPage/logic.dart';
import 'package:infibo_app/pages/customized/logic.dart';

void main() {
  test('loads custom plans with newest id first', () async {
    final FakeCustomizedPlanRepository repository =
        FakeCustomizedPlanRepository(
          initialPlans: [
            const CustomizedPlanData(
              id: 7,
              name: 'RED',
              featureIds: ['redlight'],
            ),
            const CustomizedPlanData(
              id: 12,
              name: 'qwertyu',
              featureIds: ['redlight'],
            ),
          ],
        );
    final CustomizedLogic logic = CustomizedLogic(repository: repository);

    await logic.init();

    expect(logic.plans.map((CustomizedPlanData plan) => plan.name), [
      'qwertyu',
      'RED',
    ]);
  });

  test('places newly added custom plan at the beginning of the list', () async {
    final FakeCustomizedPlanRepository repository =
        FakeCustomizedPlanRepository(
          initialPlans: [
            const CustomizedPlanData(
              id: 7,
              name: 'Plan A',
              featureIds: ['redlight'],
            ),
          ],
        );
    final CustomizedLogic logic = CustomizedLogic(repository: repository);
    await logic.init();

    await logic.addPlan(
      durationMinutes: 30,
      name: 'Plan B',
      featureIds: ['pemf'],
    );

    expect(logic.plans.map((CustomizedPlanData plan) => plan.name), [
      'Plan B',
      'Plan A',
    ]);
  });

  test('editing a plan updates it instead of adding a new plan', () async {
    final FakeCustomizedPlanRepository repository =
        FakeCustomizedPlanRepository(
          initialPlans: const [
            CustomizedPlanData(id: 7, name: 'Plan A', featureIds: ['redlight']),
          ],
        );
    final CustomizedEditLogic editLogic = CustomizedEditLogic(
      planLogic: CustomizedLogic(repository: repository),
    );

    await editLogic.savePlan(
      editingPlan: const CustomizedPlanData(
        id: 7,
        name: 'Plan A',
        featureIds: ['redlight'],
      ),
      name: 'Plan A',
      featureIds: const ['pemf'],
      durationMinutes: 30,
    );

    expect(repository.addCalls, 0);
    expect(repository.updateCalls, 1);
    expect(repository.lastUpdatedPlan?.id, 7);
    expect(repository.lastUpdatedPlan?.name, 'Plan A');
    expect(repository.lastUpdatedPlan?.featureIds, ['pemf']);
  });

  test('editing a plan may keep its current name', () async {
    final FakeCustomizedPlanRepository repository =
        FakeCustomizedPlanRepository(
          initialPlans: const [
            CustomizedPlanData(id: 7, name: 'Plan A', featureIds: ['redlight']),
          ],
        );
    final CustomizedEditLogic editLogic = CustomizedEditLogic(
      planLogic: CustomizedLogic(repository: repository),
    );

    await editLogic.savePlan(
      editingPlan: const CustomizedPlanData(
        id: 7,
        name: 'Plan A',
        featureIds: ['redlight'],
      ),
      name: '  Plan A  ',
      featureIds: const ['pemf'],
      durationMinutes: 30,
    );

    expect(repository.updateCalls, 1);
    expect(repository.lastUpdatedPlan?.name, 'Plan A');
  });

  test('editing a plan rejects another plan name', () async {
    final FakeCustomizedPlanRepository repository =
        FakeCustomizedPlanRepository(
          initialPlans: const [
            CustomizedPlanData(id: 7, name: 'Plan A', featureIds: ['redlight']),
            CustomizedPlanData(id: 8, name: 'Plan B', featureIds: ['pemf']),
          ],
        );
    final CustomizedEditLogic editLogic = CustomizedEditLogic(
      planLogic: CustomizedLogic(repository: repository),
    );

    await expectLater(
      editLogic.savePlan(
        editingPlan: const CustomizedPlanData(
          id: 7,
          name: 'Plan A',
          featureIds: ['redlight'],
        ),
        name: 'Plan B',
        featureIds: const ['pemf'],
        durationMinutes: 30,
      ),
      throwsA(isA<CustomizedPlanNameException>()),
    );

    expect(repository.addCalls, 0);
    expect(repository.updateCalls, 0);
  });

  test('adding a plan rejects every existing plan name', () async {
    final FakeCustomizedPlanRepository repository =
        FakeCustomizedPlanRepository(
          initialPlans: const [
            CustomizedPlanData(id: 7, name: 'Plan A', featureIds: ['redlight']),
          ],
        );
    final CustomizedEditLogic editLogic = CustomizedEditLogic(
      planLogic: CustomizedLogic(repository: repository),
    );

    await expectLater(
      editLogic.savePlan(
        editingPlan: null,
        name: 'Plan A',
        featureIds: const ['pemf'],
        durationMinutes: 30,
      ),
      throwsA(isA<CustomizedPlanNameException>()),
    );

    expect(repository.addCalls, 0);
    expect(repository.updateCalls, 0);
  });

  test('editing a plan without an id fails instead of adding it', () async {
    final FakeCustomizedPlanRepository repository =
        FakeCustomizedPlanRepository();
    final CustomizedEditLogic editLogic = CustomizedEditLogic(
      planLogic: CustomizedLogic(repository: repository),
    );

    await expectLater(
      editLogic.savePlan(
        editingPlan: const CustomizedPlanData(
          name: 'Plan A',
          featureIds: ['redlight'],
        ),
        name: 'Plan A',
        featureIds: const ['pemf'],
        durationMinutes: 30,
      ),
      throwsA(isA<CustomizedPlanNameException>()),
    );

    expect(repository.addCalls, 0);
    expect(repository.updateCalls, 0);
  });

  test(
    'renaming excludes the current plan but rejects other plan names',
    () async {
      final FakeCustomizedPlanRepository repository =
          FakeCustomizedPlanRepository(
            initialPlans: const [
              CustomizedPlanData(
                id: 7,
                name: 'Plan A',
                featureIds: ['redlight'],
              ),
              CustomizedPlanData(id: 8, name: 'Plan B', featureIds: ['pemf']),
            ],
          );
      final CustomizedLogic logic = CustomizedLogic(repository: repository);
      await logic.init();
      final int planAIndex = logic.plans.indexWhere(
        (CustomizedPlanData plan) => plan.id == 7,
      );

      await logic.renamePlan(planAIndex, '  Plan A  ');
      expect(repository.renameCalls, 1);
      expect(repository.lastRenamedName, 'Plan A');

      await expectLater(
        logic.renamePlan(planAIndex, 'Plan B'),
        throwsA(isA<CustomizedPlanNameException>()),
      );
      expect(repository.renameCalls, 1);
    },
  );

  test(
    'successful update does not fail when a later list refresh would fail',
    () async {
      final FakeCustomizedPlanRepository repository =
          FakeCustomizedPlanRepository(
            initialPlans: const [
              CustomizedPlanData(
                id: 7,
                name: 'Plan A',
                featureIds: ['redlight'],
              ),
            ],
          );
      final CustomizedLogic logic = CustomizedLogic(repository: repository);
      await logic.init();
      repository.failListRequests = true;

      await logic.updatePlan(
        plan: const CustomizedPlanData(
          id: 7,
          name: 'Plan A',
          featureIds: ['pemf'],
        ),
        durationMinutes: 30,
      );

      expect(repository.updateCalls, 1);
      expect(logic.plans.single.featureIds, ['pemf']);
    },
  );
}

class FakeCustomizedPlanRepository implements CustomizedPlanRepository {
  FakeCustomizedPlanRepository({
    List<CustomizedPlanData> initialPlans = const [],
  }) : _plans = List<CustomizedPlanData>.from(initialPlans);

  final List<CustomizedPlanData> _plans;
  int _nextId = 1;
  int addCalls = 0;
  int updateCalls = 0;
  int renameCalls = 0;
  bool failListRequests = false;
  CustomizedPlanData? lastUpdatedPlan;
  String? lastRenamedName;

  @override
  Future<List<CustomizedPlanData>> listPlans() async {
    if (failListRequests) throw StateError('list failed');
    return List<CustomizedPlanData>.from(_plans);
  }

  @override
  Future<CustomizedPlanData> addPlan({
    required int durationMinutes,
    required String name,
    required List<String> featureIds,
  }) async {
    addCalls += 1;
    final CustomizedPlanData saved = CustomizedPlanData(
      id: _nextId++,
      name: name,
      featureIds: featureIds,
    );
    _plans.add(saved);
    return saved;
  }

  @override
  Future<CustomizedPlanData> updatePlan({
    required CustomizedPlanData plan,
    required int durationMinutes,
  }) async {
    updateCalls += 1;
    lastUpdatedPlan = plan;
    final int index = _plans.indexWhere(
      (CustomizedPlanData item) => item.id == plan.id,
    );
    if (index >= 0) _plans[index] = plan;
    return plan;
  }

  @override
  Future<void> renamePlan({
    required int planId,
    required String planName,
  }) async {
    renameCalls += 1;
    lastRenamedName = planName;
  }

  @override
  Future<void> deletePlan(int planId) async {}

  @override
  Future<void> dispose() async {}
}

import 'package:drift/drift.dart';
import '../../domain/entities/goal.dart' as entity;
import '../../domain/entities/goal_progress_log.dart' as entity;
import '../../domain/repositories/goal_repository.dart';
import '../database/database.dart';

class GoalRepositoryImpl implements GoalRepository {
  final AppDatabase _db;

  GoalRepositoryImpl(this._db);

  @override
  Stream<List<entity.Goal>> watchAll() {
    return (_db.select(_db.goals)
          ..orderBy([
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ]))
        .watch()
        .map((rows) => rows.map(_mapToEntity).toList());
  }

  @override
  Future<entity.Goal?> getById(int id) async {
    final row = await (_db.select(_db.goals)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row != null ? _mapToEntity(row) : null;
  }

  @override
  Future<int> insert(entity.Goal goal) {
    return _db.into(_db.goals).insert(GoalsCompanion.insert(
          name: goal.name,
          notes: Value(goal.notes),
          progressType: Value(goal.progressType.index),
          totalSteps: Value(goal.totalSteps),
          completedSteps: Value(goal.completedSteps),
          deadline: Value(goal.deadline),
        ));
  }

  @override
  Future<bool> update(entity.Goal goal) {
    return _db.update(_db.goals).replace(GoalsCompanion(
          id: Value(goal.id!),
          name: Value(goal.name),
          notes: Value(goal.notes),
          progressType: Value(goal.progressType.index),
          totalSteps: Value(goal.totalSteps),
          completedSteps: Value(goal.completedSteps),
          deadline: Value(goal.deadline),
          updatedAt: Value(DateTime.now()),
        ));
  }

  @override
  Future<int> delete(int id) async {
    await (_db.delete(_db.goalProgressLogs)..where((t) => t.goalId.equals(id))).go();
    return (_db.delete(_db.goals)..where((t) => t.id.equals(id))).go();
  }

  @override
  Stream<List<entity.GoalProgressLog>> watchProgressLogs(int goalId) {
    return (_db.select(_db.goalProgressLogs)
          ..where((t) => t.goalId.equals(goalId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ]))
        .watch()
        .map((rows) => rows.map(_mapLogToEntity).toList());
  }

  @override
  Future<int> insertProgressLog(entity.GoalProgressLog log) {
    return _db.into(_db.goalProgressLogs).insert(GoalProgressLogsCompanion.insert(
          goalId: log.goalId,
          stepBefore: log.stepBefore,
          stepAfter: log.stepAfter,
          createdAt: Value(log.createdAt),
        ));
  }

  @override
  Future<void> updateProgress(int goalId, int newSteps) async {
    final goal = await getById(goalId);
    if (goal == null) return;
    if (goal.completedSteps == newSteps) return;

    await insertProgressLog(entity.GoalProgressLog(
      goalId: goalId,
      stepBefore: goal.completedSteps,
      stepAfter: newSteps,
      createdAt: DateTime.now(),
    ));

    await (_db.update(_db.goals)..where((t) => t.id.equals(goalId)))
        .write(GoalsCompanion(
          completedSteps: Value(newSteps),
          updatedAt: Value(DateTime.now()),
        ));
  }

  entity.Goal _mapToEntity(Goal row) {
    return entity.Goal(
      id: row.id,
      name: row.name,
      notes: row.notes,
      progressType: row.progressType < entity.GoalProgressType.values.length
          ? entity.GoalProgressType.values[row.progressType]
          : entity.GoalProgressType.percent,
      totalSteps: row.totalSteps,
      completedSteps: row.completedSteps,
      deadline: row.deadline,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  entity.GoalProgressLog _mapLogToEntity(GoalProgressLog row) {
    return entity.GoalProgressLog(
      id: row.id,
      goalId: row.goalId,
      stepBefore: row.stepBefore,
      stepAfter: row.stepAfter,
      createdAt: row.createdAt,
    );
  }
}

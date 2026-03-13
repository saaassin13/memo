import 'package:drift/drift.dart';
import '../../domain/entities/goal.dart' as entity;
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
          totalSteps: Value(goal.totalSteps),
          completedSteps: Value(goal.completedSteps),
          deadline: Value(goal.deadline),
          updatedAt: Value(DateTime.now()),
        ));
  }

  @override
  Future<int> delete(int id) {
    return (_db.delete(_db.goals)..where((t) => t.id.equals(id))).go();
  }

  entity.Goal _mapToEntity(Goal row) {
    return entity.Goal(
      id: row.id,
      name: row.name,
      totalSteps: row.totalSteps,
      completedSteps: row.completedSteps,
      deadline: row.deadline,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}

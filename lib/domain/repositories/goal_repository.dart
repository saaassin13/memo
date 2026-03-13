import '../entities/goal.dart';

abstract class GoalRepository {
  Stream<List<Goal>> watchAll();
  Future<Goal?> getById(int id);
  Future<int> insert(Goal goal);
  Future<bool> update(Goal goal);
  Future<int> delete(int id);
}

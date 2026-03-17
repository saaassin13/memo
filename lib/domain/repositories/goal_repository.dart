import '../entities/goal.dart';
import '../entities/goal_progress_log.dart';

abstract class GoalRepository {
  Stream<List<Goal>> watchAll();
  Future<Goal?> getById(int id);
  Future<int> insert(Goal goal);
  Future<bool> update(Goal goal);
  Future<int> delete(int id);

  // 进度记录
  Stream<List<GoalProgressLog>> watchProgressLogs(int goalId);
  Future<int> insertProgressLog(GoalProgressLog log);
  Future<void> updateProgress(int goalId, int newSteps);
}

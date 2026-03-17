import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/goal.dart';
import '../../domain/entities/goal_progress_log.dart';
import 'repository_providers.dart';

// 筛选状态
enum GoalFilter { all, inProgress, completed, overdue }

// 排序状态
enum GoalSort { deadlineAsc, deadlineDesc, createdAtDesc, progressDesc }

// 目标列表流
final goalsProvider = StreamProvider<List<Goal>>((ref) {
  final repository = ref.watch(goalRepositoryProvider);
  return repository.watchAll();
});

// 筛选 Provider
final goalFilterProvider = StateProvider<GoalFilter>((ref) => GoalFilter.all);

// 排序 Provider
final goalSortProvider = StateProvider<GoalSort>((ref) => GoalSort.deadlineAsc);

// 过滤排序后的目标列表
final filteredGoalsProvider = Provider<AsyncValue<List<Goal>>>((ref) {
  final goalsAsync = ref.watch(goalsProvider);
  final filter = ref.watch(goalFilterProvider);
  final sort = ref.watch(goalSortProvider);

  return goalsAsync.whenData((goals) {
    // 筛选
    List<Goal> filtered;
    switch (filter) {
      case GoalFilter.all:
        filtered = goals;
        break;
      case GoalFilter.inProgress:
        filtered = goals.where((g) => !g.isCompleted && !g.isOverdue).toList();
        break;
      case GoalFilter.completed:
        filtered = goals.where((g) => g.isCompleted).toList();
        break;
      case GoalFilter.overdue:
        filtered = goals.where((g) => g.isOverdue).toList();
        break;
    }

    // 排序
    switch (sort) {
      case GoalSort.deadlineAsc:
        filtered.sort((a, b) {
          if (a.deadline == null && b.deadline == null) return 0;
          if (a.deadline == null) return 1;
          if (b.deadline == null) return -1;
          return a.deadline!.compareTo(b.deadline!);
        });
        break;
      case GoalSort.deadlineDesc:
        filtered.sort((a, b) {
          if (a.deadline == null && b.deadline == null) return 0;
          if (a.deadline == null) return 1;
          if (b.deadline == null) return -1;
          return b.deadline!.compareTo(a.deadline!);
        });
        break;
      case GoalSort.createdAtDesc:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case GoalSort.progressDesc:
        filtered.sort((a, b) => b.progress.compareTo(a.progress));
        break;
    }

    return filtered;
  });
});

// 目标统计数据
class GoalStats {
  final int total;
  final int inProgress;
  final int completed;
  final int overdue;

  const GoalStats({
    required this.total,
    required this.inProgress,
    required this.completed,
    required this.overdue,
  });

  factory GoalStats.empty() => const GoalStats(total: 0, inProgress: 0, completed: 0, overdue: 0);
}

// 统计 Provider
final goalStatsProvider = Provider<AsyncValue<GoalStats>>((ref) {
  final goalsAsync = ref.watch(goalsProvider);
  return goalsAsync.whenData((goals) {
    return GoalStats(
      total: goals.length,
      inProgress: goals.where((g) => !g.isCompleted && !g.isOverdue).length,
      completed: goals.where((g) => g.isCompleted).length,
      overdue: goals.where((g) => g.isOverdue).length,
    );
  });
});

// 目标进度记录流
final goalProgressLogsProvider =
    StreamProvider.family<List<GoalProgressLog>, int>((ref, goalId) {
  final repository = ref.watch(goalRepositoryProvider);
  return repository.watchProgressLogs(goalId);
});

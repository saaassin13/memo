import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/anniversary.dart';
import 'repository_providers.dart';
import 'todo_providers.dart';
import 'diary_providers.dart';
import 'weight_providers.dart';
import 'memo_providers.dart';
import 'anniversary_providers.dart';

// 本周统计数据类
class WeeklyStats {
  final int todoCompleted;
  final int todoTotal;
  final int diaryCount;
  final double weightChange;
  final int exerciseCount;
  final double expenseTotal;

  const WeeklyStats({
    required this.todoCompleted,
    required this.todoTotal,
    required this.diaryCount,
    required this.weightChange,
    required this.exerciseCount,
    required this.expenseTotal,
  });

  factory WeeklyStats.empty() => const WeeklyStats(
        todoCompleted: 0,
        todoTotal: 0,
        diaryCount: 0,
        weightChange: 0,
        exerciseCount: 0,
        expenseTotal: 0,
      );
}

// 首次打开日期 key
const _firstOpenDateKey = 'first_open_date';

// 使用天数 Provider
final usageDaysProvider = FutureProvider<int>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final firstOpenStr = prefs.getString(_firstOpenDateKey);
  if (firstOpenStr == null) {
    // 首次使用，记录当前日期
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    await prefs.setString(_firstOpenDateKey, dateStr);
    return 1;
  }
  final parts = firstOpenStr.split('-');
  final firstOpen = DateTime(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return today.difference(firstOpen).inDays + 1;
});

// 本周起始日期（周一）
DateTime _weekStart() {
  final now = DateTime.now();
  final weekday = now.weekday;
  return DateTime(now.year, now.month, now.day).subtract(Duration(days: weekday - 1));
}

// 本周统计 Provider
final weeklyStatsProvider = Provider<AsyncValue<WeeklyStats>>((ref) {
  final todosAsync = ref.watch(todosProvider);
  final diariesAsync = ref.watch(diariesProvider);
  final weightsAsync = ref.watch(weightsProvider);

  return todosAsync.whenData((todos) {
    final weekStart = _weekStart();
    final now = DateTime.now();

    // 本周完成的待办
    final weeklyTodos = todos.where((t) =>
        t.isCompleted &&
        t.updatedAt.isAfter(weekStart) &&
        t.updatedAt.isBefore(now.add(const Duration(days: 1))));
    final todoCompleted = weeklyTodos.length;
    final todoTotal = todos.where((t) =>
        t.createdAt.isAfter(weekStart) &&
        t.createdAt.isBefore(now.add(const Duration(days: 1)))).length;

    // 本周日记数
    final diaries = diariesAsync.valueOrNull ?? [];
    final diaryCount = diaries.where((d) =>
        d.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
        d.date.isBefore(now.add(const Duration(days: 1)))).length;

    // 本周体重变化
    final weights = weightsAsync.valueOrNull ?? [];
    final weeklyWeights = weights
        .where((w) => w.date.isAfter(weekStart.subtract(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    double weightChange = 0;
    if (weeklyWeights.length >= 2) {
      weightChange = weeklyWeights.last.value - weeklyWeights.first.value;
    }

    // 本周运动次数
    final exerciseCount = weeklyWeights.where((w) => w.exercised).length;

    return WeeklyStats(
      todoCompleted: todoCompleted,
      todoTotal: todoTotal > 0 ? todoTotal : todoCompleted,
      diaryCount: diaryCount,
      weightChange: weightChange,
      exerciseCount: exerciseCount,
      expenseTotal: 0, // 记账功能暂未接入
    );
  });
});

// 备忘录总数
final memoCountProvider = Provider<int>((ref) {
  final memosAsync = ref.watch(memosProvider);
  return memosAsync.maybeWhen(
    data: (memos) => memos.length,
    orElse: () => 0,
  );
});

// 进行中的目标数
final activeGoalCountProvider = Provider<int>((ref) {
  // 目标功能暂未接入统计
  return 0;
});

// 本月支出
final monthlyExpenseProvider = Provider<double>((ref) {
  // 记账功能暂未接入统计
  return 0;
});

// 最近一次体重
final latestWeightProvider = Provider<AsyncValue<double?>>((ref) {
  final weightsAsync = ref.watch(weightsProvider);
  return weightsAsync.whenData((weights) {
    if (weights.isEmpty) return null;
    // weights 按日期倒序排列，第一个是最新的
    return weights.first.value;
  });
});

// 下一个纪念日
final nextAnniversaryProvider = Provider<AsyncValue<Anniversary?>>((ref) {
  final anniversariesAsync = ref.watch(anniversariesProvider);
  return anniversariesAsync.whenData((anniversaries) {
    if (anniversaries.isEmpty) return null;
    final upcoming = anniversaries.where((a) => a.daysUntil >= 0).toList()
      ..sort((a, b) => a.daysUntil.compareTo(b.daysUntil));
    if (upcoming.isEmpty) return null;
    return upcoming.first;
  });
});

// 待办完成率（本周）
final weeklyTodoCompletionRate = Provider<double>((ref) {
  final statsAsync = ref.watch(weeklyStatsProvider);
  return statsAsync.maybeWhen(
    data: (stats) {
      if (stats.todoTotal == 0) return 0;
      return stats.todoCompleted / stats.todoTotal;
    },
    orElse: () => 0,
  );
});

// 日记总数
final diaryCountProvider = Provider<int>((ref) {
  final diariesAsync = ref.watch(diariesProvider);
  return diariesAsync.maybeWhen(
    data: (diaries) => diaries.length,
    orElse: () => 0,
  );
});

// 纪念日总数
final anniversaryCountProvider = Provider<int>((ref) {
  final anniversariesAsync = ref.watch(anniversariesProvider);
  return anniversariesAsync.maybeWhen(
    data: (anniversaries) => anniversaries.length,
    orElse: () => 0,
  );
});

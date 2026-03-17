import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/weight.dart';
import 'repository_providers.dart';

// 统计时间范围
enum StatsPeriod { week, month, year }

// 时间范围选择
final weightStatsPeriodProvider = StateProvider<StatsPeriod>((ref) => StatsPeriod.week);

// 体重记录列表流
final weightsProvider = StreamProvider<List<Weight>>((ref) {
  final repository = ref.watch(weightRepositoryProvider);
  return repository.watchAll();
});

// 今日体重记录
final todayWeightProvider = Provider<AsyncValue<Weight?>>((ref) {
  final weightsAsync = ref.watch(weightsProvider);
  return weightsAsync.whenData((weights) {
    final today = DateTime.now();
    try {
      return weights.firstWhere((w) =>
        w.date.year == today.year &&
        w.date.month == today.month &&
        w.date.day == today.day
      );
    } catch (_) {
      return null;
    }
  });
});

// 按时间范围过滤的体重数据
final filteredWeightsProvider = Provider<AsyncValue<List<Weight>>>((ref) {
  final weightsAsync = ref.watch(weightsProvider);
  final period = ref.watch(weightStatsPeriodProvider);

  return weightsAsync.whenData((weights) {
    final now = DateTime.now();
    DateTime startDate;
    switch (period) {
      case StatsPeriod.week:
        startDate = now.subtract(const Duration(days: 7));
        break;
      case StatsPeriod.month:
        startDate = now.subtract(const Duration(days: 30));
        break;
      case StatsPeriod.year:
        startDate = now.subtract(const Duration(days: 365));
        break;
    }
    final filtered = weights.where((w) => w.date.isAfter(startDate)).toList();
    filtered.sort((a, b) => a.date.compareTo(b.date));
    return filtered;
  });
});

// 统计数据
final weightStatsProvider = Provider<AsyncValue<WeightStats>>((ref) {
  final filteredAsync = ref.watch(filteredWeightsProvider);
  return filteredAsync.whenData((weights) {
    if (weights.isEmpty) return WeightStats.empty();

    final values = weights.map((w) => w.value).toList();
    final avgWeight = values.reduce((a, b) => a + b) / values.length;
    final minWeight = values.reduce((a, b) => a < b ? a : b);
    final maxWeight = values.reduce((a, b) => a > b ? a : b);
    final exerciseCount = weights.where((w) => w.exercised).length;
    final weightChange = weights.last.value - weights.first.value;

    return WeightStats(
      avgWeight: avgWeight,
      minWeight: minWeight,
      maxWeight: maxWeight,
      exerciseCount: exerciseCount,
      weightChange: weightChange,
      days: weights.length,
    );
  });
});

// 运动类型定义
const exerciseTypes = ['跑步', '游泳', '健身', '瑜伽', '骑行', '其他'];

// 月份分组数据类
class MonthGroup {
  final DateTime month;
  final List<Weight> records;

  MonthGroup({required this.month, required this.records});

  double get avgWeight {
    if (records.isEmpty) return 0;
    return records.fold<double>(0, (sum, w) => sum + w.value) / records.length;
  }

  int get exerciseCount => records.where((w) => w.exercised).length;

  String get monthKey =>
      '${month.year}-${month.month.toString().padLeft(2, '0')}';
}

// 当前选中的年份（默认当前年）
final selectedYearProvider = StateProvider<int>((ref) => DateTime.now().year);

// 数据中可用的年份列表
final availableYearsProvider = Provider<AsyncValue<List<int>>>((ref) {
  final weightsAsync = ref.watch(weightsProvider);
  return weightsAsync.whenData((weights) {
    if (weights.isEmpty) return [DateTime.now().year];
    final years = weights.map((w) => w.date.year).toSet().toList();
    years.sort((a, b) => b.compareTo(a));
    return years;
  });
});

// 按月份分组的体重数据（按选中年份过滤）
final weightMonthGroupsProvider =
    Provider<AsyncValue<List<MonthGroup>>>((ref) {
  final weightsAsync = ref.watch(weightsProvider);
  final selectedYear = ref.watch(selectedYearProvider);
  final now = DateTime.now();
  final isCurrentYear = selectedYear == now.year;
  final endMonth = isCurrentYear ? now.month : 12;

  return weightsAsync.whenData((weights) {
    final filtered = weights.where((w) => w.date.year == selectedYear).toList();
    if (filtered.isEmpty) return [];

    filtered.sort((a, b) => b.date.compareTo(a.date));

    final Map<int, List<Weight>> grouped = {};
    for (final w in filtered) {
      grouped.putIfAbsent(w.date.month, () => []).add(w);
    }

    final groups = <MonthGroup>[];
    for (int m = endMonth; m >= 1; m--) {
      final records = grouped[m] ?? [];
      if (records.isNotEmpty) {
        groups.add(MonthGroup(
          month: DateTime(selectedYear, m),
          records: records,
        ));
      }
    }
    return groups;
  });
});

// 当前展开的月份集合
final expandedMonthsProvider =
    StateProvider<Set<String>>((ref) {
  final now = DateTime.now();
  return {'${now.year}-${now.month.toString().padLeft(2, '0')}'};
});

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

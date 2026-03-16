import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/diary.dart';
import 'repository_providers.dart';

// 当前月份
final diaryCurrentMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

// 选中日期
final diarySelectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// 日记列表流
final diariesProvider = StreamProvider<List<Diary>>((ref) {
  final repository = ref.watch(diaryRepositoryProvider);
  return repository.watchAll();
});

// 某月有日记的日期集合 (用于显示圆点)
final monthDiaryDatesProvider = Provider.family<Set<DateTime>, DateTime>((ref, month) {
  final diariesAsync = ref.watch(diariesProvider);
  return diariesAsync.whenData((diaries) {
    return diaries
        .where((d) => d.date.year == month.year && d.date.month == month.month)
        .map((d) => DateTime(d.date.year, d.date.month, d.date.day))
        .toSet();
  }).valueOrNull ?? {};
});

// 某月有日记的日期 -> 心情映射 (用于圆点颜色)
final monthDiaryMoodProvider = Provider.family<Map<DateTime, String>, DateTime>((ref, month) {
  final diariesAsync = ref.watch(diariesProvider);
  return diariesAsync.whenData((diaries) {
    final Map<DateTime, String> result = {};
    for (final diary in diaries) {
      if (diary.date.year == month.year && diary.date.month == month.month) {
        result[DateTime(diary.date.year, diary.date.month, diary.date.day)] = diary.mood;
      }
    }
    return result;
  }).valueOrNull ?? {};
});

// 某日的日记
final diaryByDateProvider = Provider.family<AsyncValue<Diary?>, DateTime>((ref, date) {
  final diariesAsync = ref.watch(diariesProvider);
  return diariesAsync.whenData((diaries) {
    try {
      return diaries.firstWhere((d) =>
        d.date.year == date.year &&
        d.date.month == date.month &&
        d.date.day == date.day
      );
    } catch (_) {
      return null;
    }
  });
});

// 标签定义
const diaryLabels = [
  {'name': '无', 'color': 0xFF6B7280, 'icon': ''},
  {'name': '生活', 'color': 0xFF10B981, 'icon': '🏠'},
  {'name': '工作', 'color': 0xFF4F46E5, 'icon': '💼'},
  {'name': '学习', 'color': 0xFFF59E0B, 'icon': '📚'},
  {'name': '旅行', 'color': 0xFF06B6D4, 'icon': '✈️'},
  {'name': '美食', 'color': 0xFFEF4444, 'icon': '🍜'},
  {'name': '运动', 'color': 0xFF8B5CF6, 'icon': '🏃'},
  {'name': '心情', 'color': 0xFFEC4899, 'icon': '💭'},
];

// 心情定义
const diaryMoods = [
  {'name': '开心', 'emoji': '😊', 'color': 0xFFF59E0B},
  {'name': '伤心', 'emoji': '😢', 'color': 0xFF3B82F6},
  {'name': '生气', 'emoji': '😡', 'color': 0xFFEF4444},
  {'name': '焦虑', 'emoji': '😰', 'color': 0xFFF97316},
  {'name': '平静', 'emoji': '😌', 'color': 0xFF10B981},
  {'name': '兴奋', 'emoji': '🥳', 'color': 0xFFEC4899},
  {'name': '疲惫', 'emoji': '😴', 'color': 0xFF6B7280},
  {'name': '思考', 'emoji': '🤔', 'color': 0xFF8B5CF6},
];

// 获取心情对应的圆点颜色
int getMoodDotColor(String mood) {
  for (final m in diaryMoods) {
    if (m['name'] == mood) return m['color'] as int;
  }
  return 0xFF11998E;
}

// 获取心情对应的 emoji
String getMoodEmoji(String mood) {
  for (final m in diaryMoods) {
    if (m['name'] == mood) return m['emoji'] as String;
  }
  return '';
}

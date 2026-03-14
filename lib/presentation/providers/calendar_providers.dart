import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/todo.dart';
import '../../domain/entities/memo.dart';
import '../../domain/entities/countdown.dart';
import '../../domain/entities/weight.dart';
import 'repository_providers.dart';
import 'memo_providers.dart';
import 'todo_providers.dart';
import 'other_providers.dart';

// 视图模式
enum CalendarViewMode { day, week, month }

// 日历事件类型
enum CalendarEventType { memo, todo, anniversary, goal, weight }

// 视图模式 Provider
final calendarViewModeProvider = StateProvider<CalendarViewMode>((ref) => CalendarViewMode.month);

// 选中日期 Provider
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// 当前显示的月份（用于月视图导航）
final currentMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

// 事件类型筛选
final eventTypeFilterProvider = StateProvider<Set<CalendarEventType>>((ref) => {
  CalendarEventType.memo,
  CalendarEventType.todo,
  CalendarEventType.anniversary,
  CalendarEventType.goal,
  CalendarEventType.weight,
});

// 待办事件 Provider - 按日期筛选
final todoEventsProvider = Provider.family<AsyncValue<List<Todo>>, DateTime>((ref, date) {
  final todosAsync = ref.watch(todosProvider);

  return todosAsync.whenData((todos) {
    return todos.where((t) {
      if (t.dueDate == null) return false;
      return isSameDay(t.dueDate!, date);
    }).toList()
      ..sort((a, b) {
        if (a.dueDate == null || b.dueDate == null) return 0;
        return a.dueDate!.compareTo(b.dueDate!);
      });
  });
});

// 备忘事件 Provider - 按日期筛选
final memoEventsProvider = Provider.family<AsyncValue<List<Memo>>, DateTime>((ref, date) {
  final memosAsync = ref.watch(memosProvider);

  return memosAsync.whenData((memos) {
    return memos.where((m) {
      if (m.remindTime == null) return false;
      return isSameDay(m.remindTime!, date);
    }).toList()
      ..sort((a, b) {
        if (a.remindTime == null || b.remindTime == null) return 0;
        return a.remindTime!.compareTo(b.remindTime!);
      });
  });
});

// 纪念日事件 Provider - 获取即将到来的纪念日
final countdownEventsProvider = Provider<AsyncValue<List<Countdown>>>((ref) {
  final countdownsAsync = ref.watch(countdownsProvider);

  return countdownsAsync.whenData((countdowns) {
    // 过滤出即将到来或已过的纪念日（30天内）
    final now = DateTime.now();
    return countdowns.where((c) {
      final daysUntil = c.targetDate.difference(now).inDays;
      return daysUntil >= -30 && daysUntil <= 30;
    }).toList()
      ..sort((a, b) => a.targetDate.compareTo(b.targetDate));
  });
});

// 体重记录 Provider - 按日期筛选
final weightEventsProvider = Provider.family<AsyncValue<Weight?>, DateTime>((ref, date) {
  final weightsAsync = ref.watch(weightsProvider);

  return weightsAsync.whenData((weights) {
    try {
      return weights.firstWhere((w) => isSameDay(w.date, date));
    } catch (_) {
      return null;
    }
  });
});

// 综合日历事件 Provider
class CalendarEvent {
  final String id;
  final CalendarEventType type;
  final DateTime date;
  final String title;
  final String? subtitle;
  final dynamic data; // 原始数据

  CalendarEvent({
    required this.id,
    required this.type,
    required this.date,
    required this.title,
    this.subtitle,
    this.data,
  });
}

// 获取某日综合事件
final dayEventsProvider = Provider.family<AsyncValue<List<CalendarEvent>>, DateTime>((ref, date) {
  final todoAsync = ref.watch(todoEventsProvider(date));
  final memoAsync = ref.watch(memoEventsProvider(date));
  final weightAsync = ref.watch(weightEventsProvider(date));
  final countdownsAsync = ref.watch(countdownEventsProvider);
  final filter = ref.watch(eventTypeFilterProvider);

  return todoAsync.when(
    data: (todos) => memoAsync.when(
      data: (memos) => weightAsync.when(
        data: (weight) => countdownsAsync.when(
          data: (countdowns) {
            final List<CalendarEvent> events = [];

            // 添加待办事件
            if (filter.contains(CalendarEventType.todo)) {
              for (final todo in todos) {
                events.add(CalendarEvent(
                  id: 'todo_${todo.id}',
                  type: CalendarEventType.todo,
                  date: todo.dueDate!,
                  title: todo.title,
                  subtitle: todo.category,
                  data: todo,
                ));
              }
            }

            // 添加备忘事件
            if (filter.contains(CalendarEventType.memo)) {
              for (final memo in memos) {
                events.add(CalendarEvent(
                  id: 'memo_${memo.id}',
                  type: CalendarEventType.memo,
                  date: memo.remindTime!,
                  title: memo.title,
                  subtitle: memo.category,
                  data: memo,
                ));
              }
            }

            // 添加体重记录
            if (filter.contains(CalendarEventType.weight) && weight != null) {
              events.add(CalendarEvent(
                id: 'weight_${weight.id}',
                type: CalendarEventType.weight,
                date: weight.date,
                title: '${weight.value} kg',
                subtitle: '体重记录',
                data: weight,
              ));
            }

            // 添加纪念日
            if (filter.contains(CalendarEventType.anniversary)) {
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              for (final countdown in countdowns) {
                final targetDay = DateTime(
                  date.year,
                  countdown.targetDate.month,
                  countdown.targetDate.day,
                );
                if (isSameDay(targetDay, date)) {
                  final daysUntil = countdown.targetDate.difference(today).inDays;
                  String subtitle;
                  if (daysUntil == 0) {
                    subtitle = '就是今天!';
                  } else if (daysUntil == 1) {
                    subtitle = '明天';
                  } else if (daysUntil == -1) {
                    subtitle = '昨天';
                  } else if (daysUntil > 0) {
                    subtitle = '还有 $daysUntil 天';
                  } else {
                    subtitle = '已过 ${-daysUntil} 天';
                  }
                  events.add(CalendarEvent(
                    id: 'countdown_${countdown.id}',
                    type: CalendarEventType.anniversary,
                    date: targetDay,
                    title: countdown.name,
                    subtitle: subtitle,
                    data: countdown,
                  ));
                }
              }
            }

            // 按日期排序
            events.sort((a, b) => a.date.compareTo(b.date));
            return AsyncValue.data(events);
          },
          loading: () => const AsyncValue.loading(),
          error: (e, st) => AsyncValue.error(e, st),
        ),
        loading: () => const AsyncValue.loading(),
        error: (e, st) => AsyncValue.error(e, st),
      ),
      loading: () => const AsyncValue.loading(),
      error: (e, st) => AsyncValue.error(e, st),
    ),
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

// 获取某月有事件的日期集合
final monthEventDatesProvider = Provider.family<Set<DateTime>, DateTime>((ref, month) {
  final todosAsync = ref.watch(todosProvider);
  final memosAsync = ref.watch(memosProvider);
  final countdownsAsync = ref.watch(countdownsProvider);
  final filter = ref.watch(eventTypeFilterProvider);

  final Set<DateTime> eventDates = {};

  // 从待办中获取有截止日期的日期
  final todos = todosAsync.valueOrNull ?? [];
  if (filter.contains(CalendarEventType.todo)) {
    for (final todo in todos) {
      if (todo.dueDate != null) {
        eventDates.add(DateTime(todo.dueDate!.year, todo.dueDate!.month, todo.dueDate!.day));
      }
    }
  }

  // 从备忘中获取有提醒时间的日期
  final memos = memosAsync.valueOrNull ?? [];
  if (filter.contains(CalendarEventType.memo)) {
    for (final memo in memos) {
      if (memo.remindTime != null) {
        eventDates.add(DateTime(memo.remindTime!.year, memo.remindTime!.month, memo.remindTime!.day));
      }
    }
  }

  // 从纪念日中获取日期
  final countdowns = countdownsAsync.valueOrNull ?? [];
  if (filter.contains(CalendarEventType.anniversary)) {
    for (final countdown in countdowns) {
      // 每年重复的纪念日
      eventDates.add(DateTime(month.year, countdown.targetDate.month, countdown.targetDate.day));
    }
  }

  return eventDates;
});

// 获取月份第一天是星期几 (0 = 周日)
int getFirstWeekdayOfMonth(DateTime date) {
  return DateTime(date.year, date.month, 1).weekday % 7;
}

// 获取月份总天数
int getDaysInMonth(DateTime date) {
  return DateTime(date.year, date.month + 1, 0).day;
}

// 判断两个日期是否是同一天
bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

// 判断是否是今天
bool isToday(DateTime date) {
  final now = DateTime.now();
  return isSameDay(date, now);
}

// 获取某月的日期列表
List<DateTime> getMonthDays(DateTime month) {
  final firstDay = DateTime(month.year, month.month, 1);
  final daysInMonth = getDaysInMonth(month);
  final firstWeekday = getFirstWeekdayOfMonth(month);

  final List<DateTime> days = [];

  // 上月末尾几天
  if (firstWeekday > 0) {
    final prevMonth = DateTime(month.year, month.month, 0);
    for (int i = firstWeekday - 1; i >= 0; i--) {
      days.add(DateTime(prevMonth.year, prevMonth.month, prevMonth.day - i));
    }
  }

  // 当月天数
  for (int i = 1; i <= daysInMonth; i++) {
    days.add(DateTime(month.year, month.month, i));
  }

  // 下月开头几天，补满6行
  final remaining = 42 - days.length;
  for (int i = 1; i <= remaining; i++) {
    days.add(DateTime(month.year, month.month + 1, i));
  }

  return days;
}

// 格式化月份标题
String formatMonthTitle(DateTime date) {
  return '${date.year}年${date.month}月';
}

// 格式化日期显示
String formatDateDisplay(DateTime date) {
  return '${date.month}月${date.day}日';
}

// 格式化周标题
String formatWeekTitle(DateTime startOfWeek) {
  final endOfWeek = startOfWeek.add(const Duration(days: 6));
  if (startOfWeek.month == endOfWeek.month) {
    return '${startOfWeek.month}月${startOfWeek.day}日 - ${endOfWeek.day}日';
  } else {
    return '${startOfWeek.month}月${startOfWeek.day}日 - ${endOfWeek.month}月${endOfWeek.day}日';
  }
}

// 获取某周的开始日期（周日）
DateTime getWeekStart(DateTime date) {
  final weekday = date.weekday % 7;
  return DateTime(date.year, date.month, date.day - weekday);
}

// 事件类型颜色
const Map<CalendarEventType, Color> eventTypeColors = {
  CalendarEventType.memo: Color(0xFF667EEA),
  CalendarEventType.todo: Color(0xFF11998E),
  CalendarEventType.anniversary: Color(0xFFF5576C),
  CalendarEventType.goal: Color(0xFFF59E0B),
  CalendarEventType.weight: Color(0xFF8B5CF6),
};

// 分类颜色
const Map<String, Color> categoryColors = {
  '工作': Color(0xFF4F46E5),
  '生活': Color(0xFF10B981),
  '学习': Color(0xFFF59E0B),
  '杂项': Color(0xFF6B7280),
};

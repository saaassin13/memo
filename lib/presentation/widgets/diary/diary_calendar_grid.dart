import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/diary_providers.dart';

class DiaryCalendarGrid extends ConsumerWidget {
  final DateTime currentMonth;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const DiaryCalendarGrid({
    super.key,
    required this.currentMonth,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diaryMoods = ref.watch(monthDiaryMoodProvider(currentMonth));
    final days = _getMonthDays(currentMonth);
    final firstWeekday = _getFirstWeekday(currentMonth);
    final weeks = ((days + firstWeekday) / 7).ceil();

    return Column(
      children: [
        // 周标题
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: ['日', '一', '二', '三', '四', '五', '六']
                .map((day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 8),
        // 日期网格
        ...List.generate(weeks, (weekIndex) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: List.generate(7, (dayIndex) {
                final dayNumber = weekIndex * 7 + dayIndex - firstWeekday + 1;
                if (dayNumber < 1 || dayNumber > days) {
                  return const Expanded(child: SizedBox(height: 48));
                }

                final date = DateTime(currentMonth.year, currentMonth.month, dayNumber);
                final dateKey = DateTime(date.year, date.month, date.day);
                final isSelected = date.year == selectedDate.year &&
                    date.month == selectedDate.month &&
                    date.day == selectedDate.day;
                final isToday = _isToday(date);
                final hasDiary = diaryMoods.containsKey(dateKey);
                final mood = diaryMoods[dateKey] ?? '';

                return Expanded(
                  child: GestureDetector(
                    onTap: () => onDateSelected(date),
                    child: Container(
                      height: 48,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: isToday
                            ? const Color(0xFF11998E)
                            : isSelected
                                ? const Color(0xFF11998E).withOpacity(0.15)
                                : null,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected && !isToday
                            ? Border.all(color: const Color(0xFF11998E), width: 1.5)
                            : null,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$dayNumber',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected || isToday
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isToday
                                      ? Colors.white
                                      : isSelected
                                          ? const Color(0xFF11998E)
                                          : Colors.black87,
                                ),
                              ),
                              if (hasDiary) ...[
                                const SizedBox(height: 2),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: isToday || isSelected
                                        ? Colors.white
                                        : Color(getMoodDotColor(mood)),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ] else
                                const SizedBox(height: 8),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ],
    );
  }

  int _getMonthDays(DateTime month) {
    return DateTime(month.year, month.month + 1, 0).day;
  }

  int _getFirstWeekday(DateTime month) {
    return DateTime(month.year, month.month, 1).weekday % 7;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}

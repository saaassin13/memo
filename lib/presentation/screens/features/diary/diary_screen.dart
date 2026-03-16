import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/diary_providers.dart';
import '../../../widgets/diary/diary_calendar_grid.dart';
import 'diary_edit_screen.dart';

class DiaryScreen extends ConsumerStatefulWidget {
  const DiaryScreen({super.key});

  @override
  ConsumerState<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends ConsumerState<DiaryScreen> {
  void _previousMonth() {
    final current = ref.read(diaryCurrentMonthProvider);
    ref.read(diaryCurrentMonthProvider.notifier).state =
        DateTime(current.year, current.month - 1);
  }

  void _nextMonth() {
    final current = ref.read(diaryCurrentMonthProvider);
    ref.read(diaryCurrentMonthProvider.notifier).state =
        DateTime(current.year, current.month + 1);
  }

  void _goToToday() {
    final now = DateTime.now();
    ref.read(diaryCurrentMonthProvider.notifier).state = now;
    ref.read(diarySelectedDateProvider.notifier).state = now;
  }

  void _onDateSelected(DateTime date) {
    ref.read(diarySelectedDateProvider.notifier).state = date;
  }

  void _addDiary() {
    final selected = ref.read(diarySelectedDateProvider);
    _navigateToEdit(selected, null);
  }

  void _editDiary(DateTime date, diary) {
    _navigateToEdit(date, diary);
  }

  void _navigateToEdit(DateTime date, diary) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => DiaryEditScreen(date: date, diary: diary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentMonth = ref.watch(diaryCurrentMonthProvider);
    final selectedDate = ref.watch(diarySelectedDateProvider);
    final diaryAsync = ref.watch(diaryByDateProvider(selectedDate));
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              context.go('/home');
            }
          },
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF11998E).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.book_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              '日记',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 24,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 月份导航
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _previousMonth,
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.chevron_left_rounded, color: Colors.grey.shade700),
                  ),
                ),
                Text(
                  '${currentMonth.year}年${currentMonth.month}月',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: _nextMonth,
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.chevron_right_rounded, color: Colors.grey.shade700),
                  ),
                ),
                TextButton(
                  onPressed: _goToToday,
                  child: const Text(
                    '今天',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF11998E),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 日历网格
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DiaryCalendarGrid(
              currentMonth: currentMonth,
              selectedDate: selectedDate,
              onDateSelected: _onDateSelected,
            ),
          ),
          const SizedBox(height: 16),
          // 选中日期的日记预览
          Expanded(
            child: _buildDiaryPreview(diaryAsync, selectedDate),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 定位今天按钮
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: FloatingActionButton(
              heroTag: 'diary_today',
              onPressed: _goToToday,
              backgroundColor: Colors.white,
              elevation: 0,
              mini: true,
              child: const Icon(Icons.my_location_rounded, color: Color(0xFF11998E)),
            ),
          ),
          const SizedBox(height: 12),
          // 新增按钮
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF11998E).withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: FloatingActionButton(
              heroTag: 'diary_add',
              onPressed: _addDiary,
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiaryPreview(AsyncValue diaryAsync, DateTime selectedDate) {
    return diaryAsync.when(
      data: (diary) {
        if (diary == null || diary.isEmpty) {
          return GestureDetector(
            onTap: _addDiary,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_note_rounded, size: 40, color: Colors.grey.shade300),
                  const SizedBox(height: 8),
                  Text(
                    '${selectedDate.month}月${selectedDate.day}日 还没有日记',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '点击添加日记',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        }

        final moodEmoji = getMoodEmoji(diary.mood);
        final labelColor = diary.mood.isNotEmpty ? Color(getMoodDotColor(diary.mood)) : const Color(0xFF11998E);

        return GestureDetector(
          onTap: () => _editDiary(selectedDate, diary),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标签和心情
                Row(
                  children: [
                    if (diary.label.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: labelColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          diary.label,
                          style: TextStyle(fontSize: 11, color: labelColor, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (diary.mood.isNotEmpty) ...[
                      Text(moodEmoji, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 4),
                      Text(
                        diary.mood,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      '${selectedDate.month}月${selectedDate.day}日',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
                if (diary.content.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    diary.content,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

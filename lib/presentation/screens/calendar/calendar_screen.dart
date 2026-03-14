import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/calendar_providers.dart';
import '../../providers/todo_providers.dart';
import '../../providers/repository_providers.dart';
import '../../../domain/entities/todo.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  @override
  Widget build(BuildContext context) {
    final viewMode = ref.watch(calendarViewModeProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final currentMonth = ref.watch(currentMonthProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          // 顶部区域
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
              bottom: 8,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // 标题栏
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF093FB).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.calendar_month_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      '日历',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    _ActionButton(
                      icon: Icons.filter_list_rounded,
                      onPressed: _showFilterMenu,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 模式切换
                _ViewModeSwitch(
                  currentMode: viewMode,
                  onModeChanged: (mode) {
                    ref.read(calendarViewModeProvider.notifier).state = mode;
                  },
                ),
              ],
            ),
          ),
          // 月份导航
          _MonthNavigator(
            currentMonth: currentMonth,
            onPrevious: () {
              ref.read(currentMonthProvider.notifier).state = DateTime(
                currentMonth.year,
                currentMonth.month - 1,
              );
            },
            onNext: () {
              ref.read(currentMonthProvider.notifier).state = DateTime(
                currentMonth.year,
                currentMonth.month + 1,
              );
            },
            onToday: () {
              final now = DateTime.now();
              ref.read(currentMonthProvider.notifier).state = now;
              ref.read(selectedDateProvider.notifier).state = now;
            },
          ),
          // 视图内容
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildView(viewMode, currentMonth, selectedDate),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildView(CalendarViewMode mode, DateTime currentMonth, DateTime selectedDate) {
    switch (mode) {
      case CalendarViewMode.day:
        return _DayView(
          key: const ValueKey('day'),
          date: selectedDate,
        );
      case CalendarViewMode.week:
        return _WeekView(
          key: const ValueKey('week'),
          currentMonth: currentMonth,
          selectedDate: selectedDate,
        );
      case CalendarViewMode.month:
      default:
        return _MonthView(
          key: const ValueKey('month'),
          currentMonth: currentMonth,
          selectedDate: selectedDate,
        );
    }
  }

  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: _showAddMenu,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  void _showFilterMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const _FilterSheet(),
    );
  }

  void _showAddMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 14),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  '新增',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _AddOption(
                icon: Icons.check_circle_rounded,
                color: const Color(0xFF11998E),
                title: '待办',
                subtitle: '添加新的待办事项',
                onTap: () {
                  Navigator.pop(context);
                  context.go('/todo');
                },
              ),
              _AddOption(
                icon: Icons.note_alt_rounded,
                color: const Color(0xFF667EEA),
                title: '备忘',
                subtitle: '记录新的备忘录',
                onTap: () {
                  Navigator.pop(context);
                  context.go('/memo/new');
                },
              ),
              _AddOption(
                icon: Icons.cake_rounded,
                color: const Color(0xFFF5576C),
                title: '纪念日',
                subtitle: '添加纪念日或生日',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: 跳转到纪念日编辑
                },
              ),
              _AddOption(
                icon: Icons.monitor_weight_rounded,
                color: const Color(0xFF8B5CF6),
                title: '体重',
                subtitle: '记录今日体重',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: 弹出体重记录
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// 视图模式切换
class _ViewModeSwitch extends StatelessWidget {
  final CalendarViewMode currentMode;
  final ValueChanged<CalendarViewMode> onModeChanged;

  const _ViewModeSwitch({
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _ModeButton(
            label: '日',
            isSelected: currentMode == CalendarViewMode.day,
            onTap: () => onModeChanged(CalendarViewMode.day),
          ),
          _ModeButton(
            label: '周',
            isSelected: currentMode == CalendarViewMode.week,
            onTap: () => onModeChanged(CalendarViewMode.week),
          ),
          _ModeButton(
            label: '月',
            isSelected: currentMode == CalendarViewMode.month,
            onTap: () => onModeChanged(CalendarViewMode.month),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  )
                : null,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF667EEA).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade600,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

// 月份导航
class _MonthNavigator extends StatelessWidget {
  final DateTime currentMonth;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;

  const _MonthNavigator({
    required this.currentMonth,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: onPrevious,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.chevron_left_rounded, color: Colors.grey.shade700),
            ),
          ),
          Expanded(
            child: Text(
              formatMonthTitle(currentMonth),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            onPressed: onNext,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.chevron_right_rounded, color: Colors.grey.shade700),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onToday,
            child: const Text(
              '今天',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF667EEA),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 月视图
class _MonthView extends ConsumerWidget {
  final DateTime currentMonth;
  final DateTime selectedDate;

  const _MonthView({
    super.key,
    required this.currentMonth,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = getMonthDays(currentMonth);
    final selected = ref.watch(selectedDateProvider);
    final eventDates = ref.watch(monthEventDatesProvider(currentMonth));
    final selectedDayEvents = ref.watch(dayEventsProvider(selected));

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
        // 日期网格 - 使用自定义布局让选中日期的事件显示在该日期下方
        Expanded(
          child: _buildCalendarGrid(context, ref, days, selected, eventDates),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid(BuildContext context, WidgetRef ref, List<DateTime> days, DateTime selected, Set<DateTime> eventDates) {
    // 将日期分成6行（每行7天）
    final rows = <List<DateTime>>[];
    for (var i = 0; i < days.length; i += 7) {
      final end = (i + 7 > days.length) ? days.length : i + 7;
      rows.add(days.sublist(i, end));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: rows.length,
      itemBuilder: (context, rowIndex) {
        final rowDays = rows[rowIndex];
        return Column(
          children: [
            // 日期行
            Row(
              children: rowDays.map((day) {
                final isCurrentMonth = day.month == currentMonth.month;
                final isSelected = isSameDay(day, selected);
                final isTodayDate = isToday(day);
                final dayKey = DateTime(day.year, day.month, day.day);
                final hasEvents = eventDates.contains(dayKey);

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      ref.read(selectedDateProvider.notifier).state = day;
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.all(2),
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: isTodayDate
                            ? const LinearGradient(
                                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : isSelected
                                ? LinearGradient(
                                    colors: [
                                      const Color(0xFF667EEA).withOpacity(0.15),
                                      const Color(0xFF764BA2).withOpacity(0.15),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected && !isTodayDate
                            ? Border.all(color: const Color(0xFF667EEA), width: 1.5)
                            : null,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            '${day.day}',
                            style: TextStyle(
                              color: isTodayDate
                                  ? Colors.white
                                  : isSelected
                                      ? const Color(0xFF667EEA)
                                      : isCurrentMonth
                                          ? Colors.black87
                                          : Colors.grey.shade400,
                              fontWeight: isSelected || isTodayDate
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                          // 有事件的日期用底部小圆点标识
                          if (hasEvents && isCurrentMonth)
                            Positioned(
                              bottom: 4,
                              child: Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: isTodayDate || isSelected
                                      ? Colors.white
                                      : const Color(0xFF11998E),
                                  shape: BoxShape.circle,
                                  boxShadow: isTodayDate || isSelected
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 2,
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            // 选中日期的事件列表（显示在该日期下方）
            if (rowDays.any((day) => isSameDay(day, selected)))
              _buildEventRowForSelectedDay(selected, eventDates),
          ],
        );
      },
    );
  }

  Widget _buildEventRowForSelectedDay(DateTime selected, Set<DateTime> eventDates) {
    final dayKey = DateTime(selected.year, selected.month, selected.day);
    if (!eventDates.contains(dayKey)) return const SizedBox.shrink();

    return Consumer(
      builder: (context, ref, _) {
        final events = ref.watch(dayEventsProvider(selected));
        return events.maybeWhen(
          data: (eventList) {
            if (eventList.isEmpty) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(bottom: 8, left: 2, right: 2),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    Colors.grey.shade50,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667EEA).withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题栏
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 12, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              '${selected.month}月${selected.day}日',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${eventList.length} 个事件',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // 事件列表
                  ...eventList.take(3).map((event) {
                    final color = eventTypeColors[event.type] ?? Colors.grey;
                    final icon = _getEventIcon(event.type);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          // 类型图标
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(icon, size: 16, color: color),
                          ),
                          const SizedBox(width: 10),
                          // 事件标题
                          Expanded(
                            child: Text(
                              event.title,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // 类型标签
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _getEventTypeName(event.type),
                              style: TextStyle(
                                fontSize: 10,
                                color: color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            );
          },
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }

  IconData _getEventIcon(CalendarEventType type) {
    switch (type) {
      case CalendarEventType.todo:
        return Icons.check_circle_rounded;
      case CalendarEventType.memo:
        return Icons.note_alt_rounded;
      case CalendarEventType.anniversary:
        return Icons.cake_rounded;
      case CalendarEventType.goal:
        return Icons.flag_rounded;
      case CalendarEventType.weight:
        return Icons.monitor_weight_rounded;
    }
  }

  String _getEventTypeName(CalendarEventType type) {
    switch (type) {
      case CalendarEventType.todo:
        return '待办';
      case CalendarEventType.memo:
        return '备忘';
      case CalendarEventType.anniversary:
        return '纪念日';
      case CalendarEventType.goal:
        return '目标';
      case CalendarEventType.weight:
        return '体重';
    }
  }
}

// 选中日期的事件列表
class _SelectedDayEvents extends StatelessWidget {
  final List<CalendarEvent> events;

  const _SelectedDayEvents({required this.events});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(12),
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.event_rounded,
                size: 16,
                color: const Color(0xFF667EEA),
              ),
              const SizedBox(width: 6),
              Text(
                '${events.length} 个事件',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF667EEA),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: events.length > 3 ? 3 : events.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final event = events[index];
                final color = eventTypeColors[event.type] ?? Colors.grey;
                return Row(
                  children: [
                    Container(
                      width: 4,
                      height: 16,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          if (events.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '还有 ${events.length - 3} 个事件...',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// 事件点组件
class _EventDot extends StatelessWidget {
  final CalendarEventType type;
  final DateTime date;
  final Set<DateTime> eventDates;

  const _EventDot({
    required this.type,
    required this.date,
    required this.eventDates,
  });

  @override
  Widget build(BuildContext context) {
    final dayKey = DateTime(date.year, date.month, date.day);

    // 检查这天是否有这个类型的事件
    // 这里简化处理，只要该日期有事件就显示
    final hasEvent = eventDates.contains(dayKey);

    if (!hasEvent) {
      return const SizedBox(width: 6, height: 6);
    }

    final color = eventTypeColors[type] ?? Colors.grey;

    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

// 周视图
class _WeekView extends ConsumerWidget {
  final DateTime currentMonth;
  final DateTime selectedDate;

  const _WeekView({
    super.key,
    required this.currentMonth,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekStart = getWeekStart(selectedDate);
    final days = List.generate(7, (i) => weekStart.add(Duration(days: i)));

    return Column(
      children: [
        // 周标题
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            formatWeekTitle(weekStart),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // 日期行
        Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: days.map((day) {
              final isSelected = isSameDay(day, selectedDate);
              final isTodayDate = isToday(day);

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    ref.read(selectedDateProvider.notifier).state = day;
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      gradient: isTodayDate
                          ? const LinearGradient(
                              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSelected && !isTodayDate
                          ? const Color(0xFF667EEA).withOpacity(0.1)
                          : null,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected && !isTodayDate
                          ? Border.all(color: const Color(0xFF667EEA), width: 1.5)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          ['日', '一', '二', '三', '四', '五', '六'][day.weekday % 7],
                          style: TextStyle(
                            color: isTodayDate
                                ? Colors.white.withOpacity(0.8)
                                : Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${day.day}',
                          style: TextStyle(
                            color: isTodayDate ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const Divider(height: 1),
        // 事件列表
        Expanded(
          child: _DayEvents(date: selectedDate),
        ),
      ],
    );
  }
}

// 日视图
class _DayView extends ConsumerWidget {
  final DateTime date;

  const _DayView({
    super.key,
    required this.date,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // 日期标题
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  formatDateDisplay(date),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _getWeekdayName(date.weekday),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        // 时间轴
        Expanded(
          child: _DayEvents(date: date),
        ),
      ],
    );
  }

  String _getWeekdayName(int weekday) {
    const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return weekdays[weekday - 1];
  }
}

// 某日事件列表
class _DayEvents extends ConsumerWidget {
  final DateTime date;

  const _DayEvents({required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(dayEventsProvider(date));

    return eventsAsync.when(
      data: (events) {
        if (events.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_available_rounded,
                  size: 48,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 12),
                Text(
                  '这一天没有安排',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return _CalendarEventCard(event: event);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('加载失败: $e')),
    );
  }
}

// 日历事件卡片
class _CalendarEventCard extends StatelessWidget {
  final CalendarEvent event;

  const _CalendarEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final color = eventTypeColors[event.type] ?? const Color(0xFF6B7280);

    IconData getEventIcon() {
      switch (event.type) {
        case CalendarEventType.todo:
          return Icons.check_circle_rounded;
        case CalendarEventType.memo:
          return Icons.note_alt_rounded;
        case CalendarEventType.anniversary:
          return Icons.cake_rounded;
        case CalendarEventType.goal:
          return Icons.flag_rounded;
        case CalendarEventType.weight:
          return Icons.monitor_weight_rounded;
      }
    }

    String getTypeName() {
      switch (event.type) {
        case CalendarEventType.todo:
          return '待办';
        case CalendarEventType.memo:
          return '备忘';
        case CalendarEventType.anniversary:
          return '纪念日';
        case CalendarEventType.goal:
          return '目标';
        case CalendarEventType.weight:
          return '体重';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // 根据事件类型跳转
            if (event.type == CalendarEventType.todo && event.data is Todo) {
              // 跳转到待办编辑
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 左侧图标
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    getEventIcon(),
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // 内容
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (event.subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          event.subtitle!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // 类型标签
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    getTypeName(),
                    style: TextStyle(
                      fontSize: 11,
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 事件卡片
class _EventCard extends StatelessWidget {
  final Todo todo;

  const _EventCard({required this.todo});

  @override
  Widget build(BuildContext context) {
    final categoryColors = {
      '工作': const Color(0xFF4F46E5),
      '生活': const Color(0xFF10B981),
      '学习': const Color(0xFFF59E0B),
      '杂项': const Color(0xFF6B7280),
    };
    final color = categoryColors[todo.category] ?? const Color(0xFF6B7280);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // TODO: 跳转到编辑
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 左侧色条
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                // 内容
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todo.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          decoration: todo.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: todo.isCompleted
                              ? Colors.grey
                              : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (todo.dueDate != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${todo.dueDate!.hour.toString().padLeft(2, '0')}:${todo.dueDate!.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // 分类标签
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    todo.category,
                    style: TextStyle(
                      fontSize: 11,
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 操作按钮
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}

// 筛选弹窗
class _FilterSheet extends ConsumerStatefulWidget {
  const _FilterSheet();

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  late Set<CalendarEventType> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set.from(ref.read(eventTypeFilterProvider));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 14),
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.filter_list_rounded, color: Color(0xFF667EEA)),
                  SizedBox(width: 10),
                  Text(
                    '筛选',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            _FilterOption(
              icon: Icons.note_alt_rounded,
              color: const Color(0xFF667EEA),
              title: '备忘',
              isSelected: _selected.contains(CalendarEventType.memo),
              onChanged: (selected) {
                setState(() {
                  if (selected) {
                    _selected.add(CalendarEventType.memo);
                  } else {
                    _selected.remove(CalendarEventType.memo);
                  }
                });
              },
            ),
            _FilterOption(
              icon: Icons.check_circle_rounded,
              color: const Color(0xFF11998E),
              title: '待办',
              isSelected: _selected.contains(CalendarEventType.todo),
              onChanged: (selected) {
                setState(() {
                  if (selected) {
                    _selected.add(CalendarEventType.todo);
                  } else {
                    _selected.remove(CalendarEventType.todo);
                  }
                });
              },
            ),
            _FilterOption(
              icon: Icons.cake_rounded,
              color: const Color(0xFFF5576C),
              title: '纪念日',
              isSelected: _selected.contains(CalendarEventType.anniversary),
              onChanged: (selected) {
                setState(() {
                  if (selected) {
                    _selected.add(CalendarEventType.anniversary);
                  } else {
                    _selected.remove(CalendarEventType.anniversary);
                  }
                });
              },
            ),
            _FilterOption(
              icon: Icons.flag_rounded,
              color: const Color(0xFFF59E0B),
              title: '目标',
              isSelected: _selected.contains(CalendarEventType.goal),
              onChanged: (selected) {
                setState(() {
                  if (selected) {
                    _selected.add(CalendarEventType.goal);
                  } else {
                    _selected.remove(CalendarEventType.goal);
                  }
                });
              },
            ),
            _FilterOption(
              icon: Icons.monitor_weight_rounded,
              color: const Color(0xFF8B5CF6),
              title: '体重',
              isSelected: _selected.contains(CalendarEventType.weight),
              onChanged: (selected) {
                setState(() {
                  if (selected) {
                    _selected.add(CalendarEventType.weight);
                  } else {
                    _selected.remove(CalendarEventType.weight);
                  }
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('取消'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          ref.read(eventTypeFilterProvider.notifier).state = _selected;
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '确定',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final bool isSelected;
  final ValueChanged<bool> onChanged;

  const _FilterOption({
    required this.icon,
    required this.color,
    required this.title,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: isSelected,
            onChanged: onChanged,
            activeColor: color,
          ),
        ],
      ),
    );
  }
}

// 新增选项
class _AddOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AddOption({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

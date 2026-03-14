import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// 自定义中文日期时间选择器
class DateTimePickerHelper {
  /// 显示日期时间选择器
  static Future<DateTime?> show(
    BuildContext context, {
    DateTime? initialDateTime,
    DateTime? minimumDate,
    DateTime? maximumDate,
  }) {
    return showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _DateTimePickerSheet(
        initialDateTime: initialDateTime ?? DateTime.now(),
        minimumDate: minimumDate,
        maximumDate: maximumDate,
      ),
    );
  }
}

class _DateTimePickerSheet extends StatefulWidget {
  final DateTime initialDateTime;
  final DateTime? minimumDate;
  final DateTime? maximumDate;

  const _DateTimePickerSheet({
    required this.initialDateTime,
    this.minimumDate,
    this.maximumDate,
  });

  @override
  State<_DateTimePickerSheet> createState() => _DateTimePickerSheetState();
}

class _DateTimePickerSheetState extends State<_DateTimePickerSheet> with SingleTickerProviderStateMixin {
  late DateTime _selectedDate;
  late int _selectedHour;
  late int _selectedMinute;
  late DateTime _currentMonth;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDateTime;
    _selectedHour = widget.initialDateTime.hour;
    _selectedMinute = widget.initialDateTime.minute;
    _currentMonth = DateTime(widget.initialDateTime.year, widget.initialDateTime.month);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  int _getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  int _getFirstWeekdayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1).weekday % 7;
  }

  bool _isDateSelectable(DateTime date) {
    if (widget.minimumDate != null && date.isBefore(widget.minimumDate!)) {
      return false;
    }
    if (widget.maximumDate != null && date.isAfter(widget.maximumDate!)) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.68,
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // 顶部拖动条和操作栏
            _buildHeader(),

            // 快捷选项
            _buildQuickOptions(),

            // 月份导航和日历
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildMonthNavigator(),
                    _buildWeekdayHeader(),
                    Expanded(child: _buildCalendarGrid()),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 时间选择器
            _buildTimePicker(),

            SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 8, 8),
      child: Column(
        children: [
          // 拖动条
          Container(
            width: 36,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          const SizedBox(height: 12),
          // 操作按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  '取消',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // 选中日期显示
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  '${_selectedDate.month}月${_selectedDate.day}日',
                  key: ValueKey('${_selectedDate.month}-${_selectedDate.day}'),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, DateTime(
                    _selectedDate.year,
                    _selectedDate.month,
                    _selectedDate.day,
                    _selectedHour,
                    _selectedMinute,
                  ));
                },
                child: const Text(
                  '确定',
                  style: TextStyle(
                    color: Color(0xFF6366F1),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _QuickOptionChip(
            label: '今天',
            icon: Icons.wb_sunny_rounded,
            color: const Color(0xFFF59E0B),
            onTap: () {
              final now = DateTime.now();
              setState(() {
                _selectedDate = now;
                _currentMonth = DateTime(now.year, now.month);
              });
            },
          ),
          const SizedBox(width: 8),
          _QuickOptionChip(
            label: '明天',
            icon: Icons.wb_twilight_rounded,
            color: const Color(0xFF6366F1),
            onTap: () {
              final tomorrow = DateTime.now().add(const Duration(days: 1));
              setState(() {
                _selectedDate = tomorrow;
                _currentMonth = DateTime(tomorrow.year, tomorrow.month);
              });
            },
          ),
          const SizedBox(width: 8),
          _QuickOptionChip(
            label: '周末',
            icon: Icons.weekend_rounded,
            color: const Color(0xFF10B981),
            onTap: () {
              final now = DateTime.now();
              final daysUntilWeekend = (7 - now.weekday) % 7;
              final weekend = now.add(Duration(days: daysUntilWeekend == 0 ? 7 : daysUntilWeekend));
              setState(() {
                _selectedDate = weekend;
                _currentMonth = DateTime(weekend.year, weekend.month);
              });
            },
          ),
          const SizedBox(width: 8),
          _QuickOptionChip(
            label: '下周',
            icon: Icons.calendar_view_week_rounded,
            color: const Color(0xFFEC4899),
            onTap: () {
              final nextWeek = DateTime.now().add(const Duration(days: 7));
              setState(() {
                _selectedDate = nextWeek;
                _currentMonth = DateTime(nextWeek.year, nextWeek.month);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMonthNavigator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavButton(
            icon: Icons.chevron_left_rounded,
            onTap: () {
              setState(() {
                _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
              });
            },
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              '${_currentMonth.year}年${_currentMonth.month}月',
              key: ValueKey('${_currentMonth.year}-${_currentMonth.month}'),
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          _NavButton(
            icon: Icons.chevron_right_rounded,
            onTap: () {
              setState(() {
                _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: ['日', '一', '二', '三', '四', '五', '六']
            .map((day) => Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: TextStyle(
                        color: day == '日' || day == '六'
                            ? const Color(0xFFEF4444)
                            : Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = _getDaysInMonth(_currentMonth);
    final firstWeekday = _getFirstWeekdayOfMonth(_currentMonth);
    final today = DateTime.now();

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: daysInMonth + firstWeekday,
      itemBuilder: (context, index) {
        if (index < firstWeekday) {
          return const SizedBox();
        }

        final day = index - firstWeekday + 1;
        final date = DateTime(_currentMonth.year, _currentMonth.month, day);
        final isToday = date.year == today.year &&
            date.month == today.month &&
            date.day == today.day;
        final isSelected = date.year == _selectedDate.year &&
            date.month == _selectedDate.month &&
            date.day == _selectedDate.day;
        final isSelectable = _isDateSelectable(date);

        return _CalendarDay(
          day: day,
          isToday: isToday,
          isSelected: isSelected,
          isSelectable: isSelectable,
          onTap: isSelectable
              ? () {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              : null,
        );
      },
    );
  }

  Widget _buildTimePicker() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 小时
          _WheelTimePicker(
            value: _selectedHour,
            maxValue: 23,
            label: '时',
            onChanged: (v) => setState(() => _selectedHour = v),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              ':',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade400,
              ),
            ),
          ),
          // 分钟
          _WheelTimePicker(
            value: _selectedMinute,
            maxValue: 59,
            label: '分',
            onChanged: (v) => setState(() => _selectedMinute = v),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: const Color(0xFF6366F1), size: 24),
        ),
      ),
    );
  }
}

class _QuickOptionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickOptionChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
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

class _CalendarDay extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool isSelected;
  final bool isSelectable;
  final VoidCallback? onTap;

  const _CalendarDay({
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.isSelectable,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          gradient: isToday
              ? const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected && !isToday
              ? const Color(0xFF6366F1).withOpacity(0.15)
              : null,
          borderRadius: BorderRadius.circular(14),
          border: isSelected && !isToday
              ? Border.all(color: const Color(0xFF6366F1), width: 2)
              : null,
          boxShadow: isToday
              ? [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              color: !isSelectable
                  ? Colors.grey.shade300
                  : isToday
                      ? Colors.white
                      : isSelected
                          ? const Color(0xFF6366F1)
                          : Colors.grey.shade700,
              fontWeight: isSelected || isToday ? FontWeight.w600 : FontWeight.w500,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}

class _WheelTimePicker extends StatelessWidget {
  final int value;
  final int maxValue;
  final String label;
  final ValueChanged<int> onChanged;

  const _WheelTimePicker({
    required this.value,
    required this.maxValue,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 110,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade50,
            Colors.white,
            Colors.grey.shade50,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // 增加按钮
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (value < maxValue) onChanged(value + 1);
                },
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Center(
                  child: Icon(
                    Icons.keyboard_arrow_up_rounded,
                    color: Colors.grey.shade500,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
          // 中间选中的值
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              value.toString().padLeft(2, '0'),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6366F1),
              ),
            ),
          ),
          // 减少按钮
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (value > 0) onChanged(value - 1);
                },
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                child: Center(
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey.shade500,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

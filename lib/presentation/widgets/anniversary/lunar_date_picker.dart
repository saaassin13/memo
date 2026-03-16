import 'package:flutter/material.dart';
import '../../../core/utils/lunar_calendar.dart';

class LunarDatePicker extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const LunarDatePicker({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  static Future<DateTime?> show(
    BuildContext context, {
    required DateTime initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    return showDialog<DateTime>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: LunarDatePicker(
          initialDate: initialDate,
          firstDate: firstDate ?? DateTime(1900),
          lastDate: lastDate ?? DateTime(2100),
        ),
      ),
    );
  }

  @override
  State<LunarDatePicker> createState() => _LunarDatePickerState();
}

class _LunarDatePickerState extends State<LunarDatePicker> {
  late int _year;
  late int _month;
  late int _day;
  late DateTime _displayMonth; // 当前显示的公历月份

  static const List<String> _months = ['正', '二', '三', '四', '五', '六', '七', '八', '九', '十', '冬', '腊'];
  static const List<String> _days = [
    '初一', '初二', '初三', '初四', '初五', '初六', '初七', '初八', '初九', '初十',
    '十一', '十二', '十三', '十四', '十五', '十六', '十七', '十八', '十九', '二十',
    '廿一', '廿二', '廿三', '廿四', '廿五', '廿六', '廿七', '廿八', '廿九', '三十'
  ];

  @override
  void initState() {
    super.initState();
    final lunar = LunarCalendar.solarToLunar(widget.initialDate);
    _year = lunar.year;
    _month = lunar.month;
    _day = lunar.day;
    _displayMonth = _getSolarDate();
  }

  DateTime _getSolarDate() {
    try {
      return LunarCalendar.lunarToSolar(_year, _month, _day);
    } catch (_) {
      return LunarCalendar.lunarToSolar(_year, _month, 1);
    }
  }

  int _getDaysInLunarMonth(int year, int month) {
    return LunarCalendar.solarToLunar(
      LunarCalendar.lunarToSolar(year, month, 15)
    ).day <= 15 ? 29 : 30;
    // 简单方式：用15号判断，15号之前是上半月
    // 更准确：直接从lunar_data取
  }

  void _previousMonth() {
    setState(() {
      if (_month == 1) {
        _year--;
        _month = 12;
      } else {
        _month--;
      }
      _day = 1;
      _displayMonth = _getSolarDate();
    });
  }

  void _nextMonth() {
    setState(() {
      if (_month == 12) {
        _year++;
        _month = 1;
      } else {
        _month++;
      }
      _day = 1;
      _displayMonth = _getSolarDate();
    });
  }

  // 获取农历某月天数
  int _getLunarMonthDays(int year, int month) {
    final firstDay = LunarCalendar.lunarToSolar(year, month, 1);
    final firstDayLunar = LunarCalendar.solarToLunar(firstDay);

    // 找下个月初一
    DateTime nextMonthFirst;
    if (month == 12) {
      nextMonthFirst = LunarCalendar.lunarToSolar(year + 1, 1, 1);
    } else {
      nextMonthFirst = LunarCalendar.lunarToSolar(year, month + 1, 1);
    }

    return nextMonthFirst.difference(firstDay).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = _getLunarMonthDays(_year, _month);
    // 计算初一是星期几
    final firstSolarDay = LunarCalendar.lunarToSolar(_year, _month, 1);
    final firstDayOfWeek = firstSolarDay.weekday % 7;
    final weeks = ((daysInMonth + firstDayOfWeek) / 7).ceil();

    return Container(
      width: 360,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 月份导航 - 显示农历月份
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: _previousMonth,
              ),
              Text(
                '农历${_months[_month - 1]}月',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: _nextMonth,
              ),
            ],
          ),
          // 显示公历对应年份
          Text(
            '${_displayMonth.year}年',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 12),
          // 星期标题
          Row(
            children: ['日', '一', '二', '三', '四', '五', '六']
                .map((day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          // 日期网格
          ...List.generate(weeks, (weekIndex) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: List.generate(7, (dayIndex) {
                  final dayNumber = weekIndex * 7 + dayIndex - firstDayOfWeek + 1;
                  if (dayNumber < 1 || dayNumber > daysInMonth) {
                    return const Expanded(child: SizedBox(height: 48));
                  }

                  final solarDate = LunarCalendar.lunarToSolar(_year, _month, dayNumber);
                  final isSelected = dayNumber == _day;
                  final now = DateTime.now();
                  final isToday = solarDate.year == now.year &&
                      solarDate.month == now.month &&
                      solarDate.day == now.day;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _day = dayNumber;
                        });
                      },
                      child: Container(
                        height: 48,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFF5576C)
                              : isToday
                                  ? const Color(0xFFF5576C).withOpacity(0.1)
                                  : null,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _days[dayNumber - 1],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                color: isSelected
                                    ? Colors.white
                                    : isToday
                                        ? const Color(0xFFF5576C)
                                        : Colors.black87,
                              ),
                            ),
                            Text(
                              '${solarDate.month}/${solarDate.day}',
                              style: TextStyle(
                                fontSize: 9,
                                color: isSelected
                                    ? Colors.white.withOpacity(0.8)
                                    : Colors.grey.shade500,
                              ),
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
          const SizedBox(height: 16),
          // 底部显示选中日期
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '农历${_months[_month - 1]}月${_days[_day - 1]}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 12),
                Text(
                  '(${_getSolarDate().month}月${_getSolarDate().day}日)',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {
                  final solarDate = LunarCalendar.lunarToSolar(_year, _month, _day);
                  Navigator.pop(context, solarDate);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFF5576C),
                ),
                child: const Text('确定'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

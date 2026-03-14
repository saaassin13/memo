import 'package:flutter/material.dart';

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

class _DateTimePickerSheetState extends State<_DateTimePickerSheet> {
  late DateTime _selectedDate;
  late int _selectedHour;
  late int _selectedMinute;
  late PageController _yearPageController;
  late PageController _monthPageController;
  late PageController _dayPageController;
  late PageController _hourPageController;
  late PageController _minutePageController;

  final int _startYear = 2020;
  final int _endYear = 2035;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDateTime;
    _selectedHour = widget.initialDateTime.hour;
    _selectedMinute = widget.initialDateTime.minute;

    _yearPageController = PageController(
      initialPage: widget.initialDateTime.year - _startYear,
    );
    _monthPageController = PageController(
      initialPage: widget.initialDateTime.month - 1,
    );
    _dayPageController = PageController(
      initialPage: widget.initialDateTime.day - 1,
    );
    _hourPageController = PageController(
      initialPage: _selectedHour,
    );
    _minutePageController = PageController(
      initialPage: _selectedMinute,
    );
  }

  @override
  void dispose() {
    _yearPageController.dispose();
    _monthPageController.dispose();
    _dayPageController.dispose();
    _hourPageController.dispose();
    _minutePageController.dispose();
    super.dispose();
  }

  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = _getDaysInMonth(_selectedDate.year, _selectedDate.month);

    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // 顶部拖动条和标题
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    '取消',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
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
                      color: Color(0xFF667EEA),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 标题
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  '选择日期和时间',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // 快捷选项
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                _QuickOption(
                  label: '今天',
                  onTap: () {
                    final now = DateTime.now();
                    setState(() {
                      _selectedDate = now;
                      _selectedHour = now.hour;
                      _selectedMinute = now.minute;
                    });
                    _yearPageController.jumpToPage(now.year - _startYear);
                    _monthPageController.jumpToPage(now.month - 1);
                    _dayPageController.jumpToPage(now.day - 1);
                    _hourPageController.jumpToPage(now.hour);
                    _minutePageController.jumpToPage(now.minute);
                  },
                ),
                const SizedBox(width: 8),
                _QuickOption(
                  label: '明天',
                  onTap: () {
                    final tomorrow = DateTime.now().add(const Duration(days: 1));
                    setState(() {
                      _selectedDate = tomorrow;
                      _selectedHour = 9;
                      _selectedMinute = 0;
                    });
                    _yearPageController.jumpToPage(tomorrow.year - _startYear);
                    _monthPageController.jumpToPage(tomorrow.month - 1);
                    _dayPageController.jumpToPage(tomorrow.day - 1);
                    _hourPageController.jumpToPage(9);
                    _minutePageController.jumpToPage(0);
                  },
                ),
                const SizedBox(width: 8),
                _QuickOption(
                  label: '一周后',
                  onTap: () {
                    final weekLater = DateTime.now().add(const Duration(days: 7));
                    setState(() {
                      _selectedDate = weekLater;
                      _selectedHour = 9;
                      _selectedMinute = 0;
                    });
                    _yearPageController.jumpToPage(weekLater.year - _startYear);
                    _monthPageController.jumpToPage(weekLater.month - 1);
                    _dayPageController.jumpToPage(weekLater.day - 1);
                    _hourPageController.jumpToPage(9);
                    _minutePageController.jumpToPage(0);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 日期选择器
          Expanded(
            child: Row(
              children: [
                // 年
                Expanded(
                  child: _PickerColumn(
                    controller: _yearPageController,
                    itemCount: _endYear - _startYear + 1,
                    labelBuilder: (index) => '${_startYear + index}年',
                    onChanged: (index) {
                      setState(() {
                        _selectedDate = DateTime(
                          _startYear + index,
                          _selectedDate.month,
                          _selectedDate.day,
                        );
                      });
                    },
                  ),
                ),
                // 月
                Expanded(
                  child: _PickerColumn(
                    controller: _monthPageController,
                    itemCount: 12,
                    labelBuilder: (index) => '${index + 1}月',
                    onChanged: (index) {
                      final newMonth = index + 1;
                      final maxDay = _getDaysInMonth(_selectedDate.year, newMonth);
                      final newDay = _selectedDate.day > maxDay ? maxDay : _selectedDate.day;
                      setState(() {
                        _selectedDate = DateTime(
                          _selectedDate.year,
                          newMonth,
                          newDay,
                        );
                      });
                    },
                  ),
                ),
                // 日
                Expanded(
                  child: _PickerColumn(
                    controller: _dayPageController,
                    itemCount: daysInMonth,
                    labelBuilder: (index) => '${index + 1}日',
                    onChanged: (index) {
                      setState(() {
                        _selectedDate = DateTime(
                          _selectedDate.year,
                          _selectedDate.month,
                          index + 1,
                        );
                      });
                    },
                  ),
                ),
                Container(
                  width: 1,
                  height: 120,
                  color: Colors.grey.shade200,
                ),
                // 时
                Expanded(
                  child: _PickerColumn(
                    controller: _hourPageController,
                    itemCount: 24,
                    labelBuilder: (index) => '${index.toString().padLeft(2, '0')}时',
                    onChanged: (index) {
                      setState(() => _selectedHour = index);
                    },
                  ),
                ),
                // 分
                Expanded(
                  child: _PickerColumn(
                    controller: _minutePageController,
                    itemCount: 60,
                    labelBuilder: (index) => '${index.toString().padLeft(2, '0')}分',
                    onChanged: (index) {
                      setState(() => _selectedMinute = index);
                    },
                  ),
                ),
              ],
            ),
          ),

          // 底部安全区
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}

class _QuickOption extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickOption({
    required this.label,
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
              color: const Color(0xFF667EEA).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF667EEA).withOpacity(0.2),
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF667EEA),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PickerColumn extends StatelessWidget {
  final PageController controller;
  final int itemCount;
  final String Function(int) labelBuilder;
  final ValueChanged<int> onChanged;

  const _PickerColumn({
    required this.controller,
    required this.itemCount,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollEndNotification>(
      onNotification: (notification) {
        final page = (notification.metrics.pixels / 50).round();
        if (page >= 0 && page < itemCount) {
          onChanged(page);
        }
        return true;
      },
      child: ListView.builder(
        controller: controller,
        physics: const BouncingScrollPhysics(),
        itemCount: itemCount,
        itemExtent: 50,
        itemBuilder: (context, index) {
          return Center(
            child: Text(
              labelBuilder(index),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        },
      ),
    );
  }
}

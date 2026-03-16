import '../../core/utils/lunar_calendar.dart';

class Anniversary {
  final int? id;
  final String title;
  final DateTime date; // 存储的是公历日期 (如果是农历，存储对应公历日期)
  final bool isLunar;
  final int reminderDays;
  final bool repeatYearly;
  final String relationship;
  final String? customRelation;
  final String? phoneNumber;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Anniversary({
    this.id,
    required this.title,
    required this.date,
    this.isLunar = false,
    this.reminderDays = 0,
    this.repeatYearly = true,
    this.relationship = '其他',
    this.customRelation,
    this.phoneNumber,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 获取下次纪念日日期
  DateTime get nextDate {
    if (!isLunar) {
      // 公历: 直接按年+月+日计算
      final now = DateTime.now();
      DateTime next = DateTime(now.year, date.month, date.day);
      if (next.isBefore(DateTime(now.year, now.month, now.day))) {
        next = DateTime(now.year + 1, date.month, date.day);
      }
      return next;
    } else {
      // 农历: 存储的 date 是对应公历日期，需要转换为农历再计算
      final lunarDate = LunarCalendar.solarToLunar(date);
      final now = DateTime.now();

      // 今年对应的农历公历日期
      try {
        DateTime next = LunarCalendar.lunarToSolar(
          now.year,
          lunarDate.month,
          lunarDate.day,
          isLeap: lunarDate.isLeap,
        );
        if (next.isBefore(DateTime(now.year, now.month, now.day))) {
          next = LunarCalendar.lunarToSolar(
            now.year + 1,
            lunarDate.month,
            lunarDate.day,
            isLeap: lunarDate.isLeap,
          );
        }
        return next;
      } catch (_) {
        // 出错时回退到公历计算
        DateTime next = DateTime(now.year, date.month, date.day);
        if (next.isBefore(DateTime(now.year, now.month, now.day))) {
          next = DateTime(now.year + 1, date.month, date.day);
        }
        return next;
      }
    }
  }

  /// 距离下次纪念日的天数
  int get daysUntil {
    final now = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final target = DateTime(nextDate.year, nextDate.month, nextDate.day);
    return target.difference(now).inDays;
  }

  bool get isToday => daysUntil == 0;

  /// 显示日期字符串
  String get displayDate {
    if (isLunar) {
      return LunarCalendar.formatLunarDate(LunarCalendar.solarToLunar(date));
    }
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}年$month月$day日';
  }

  /// 显示完整日期 (含对应日期)
  String get displayDateFull {
    if (isLunar) {
      final lunarStr = LunarCalendar.formatLunarDate(LunarCalendar.solarToLunar(date));
      final month = date.month.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');
      return '$lunarStr (${date.year}.$month.$day)';
    }
    final lunarStr = LunarCalendar.getLunarString(date);
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}年$month月$day日 ($lunarStr)';
  }

  String get daysUntilText {
    if (isToday) return '今天！';
    if (daysUntil < 0) return '已过';
    return '还有 $daysUntil 天';
  }

  Anniversary copyWith({
    int? id,
    String? title,
    DateTime? date,
    bool? isLunar,
    int? reminderDays,
    bool? repeatYearly,
    String? relationship,
    String? customRelation,
    String? phoneNumber,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Anniversary(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      isLunar: isLunar ?? this.isLunar,
      reminderDays: reminderDays ?? this.reminderDays,
      repeatYearly: repeatYearly ?? this.repeatYearly,
      relationship: relationship ?? this.relationship,
      customRelation: customRelation ?? this.customRelation,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

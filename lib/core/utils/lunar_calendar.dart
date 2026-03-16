/// 农历工具类
/// 支持公历与农历之间的转换
class LunarCalendar {
  // 农历数据 1900-2100
  // 每个数字的含义:
  // 1-4位: 闰月月份 (0表示没有闰月)
  // 5-16位: 每个月的大小月 (1=大月30天, 0=小月29天)
  // 17位: 闰月的大小 (1=大月30天, 0=小月29天)
  static const List<int> _lunarData = [
    0x04bd8, 0x04ae0, 0x0a570, 0x054d5, 0x0d260, 0x0d950, 0x16554, 0x056a0, 0x09ad0, 0x055d2,
    0x04ae0, 0x0a5b6, 0x0a4d0, 0x0d250, 0x1d255, 0x0b540, 0x0d6a0, 0x0ada2, 0x095b0, 0x14977,
    0x04970, 0x0a4b0, 0x0b4b5, 0x06a50, 0x06d40, 0x1ab54, 0x02b60, 0x09570, 0x052f2, 0x04970,
    0x06566, 0x0d4a0, 0x0ea50, 0x16a95, 0x05ad0, 0x02b60, 0x186e3, 0x092e0, 0x1c8d7, 0x0c950,
    0x0d4a0, 0x1d8a6, 0x0b550, 0x056a0, 0x1a5b4, 0x025d0, 0x092d0, 0x0d2b2, 0x0a950, 0x0b557,
    0x06ca0, 0x0b550, 0x15355, 0x04da0, 0x0a5d0, 0x14573, 0x052d0, 0x0a9a8, 0x0e950, 0x06aa0,
    0x0aea6, 0x0ab50, 0x04b60, 0x0aae4, 0x0a570, 0x05260, 0x0f263, 0x0d950, 0x05b57, 0x056a0,
    0x096d0, 0x04dd5, 0x04ad0, 0x0a4d0, 0x0d4d4, 0x0d250, 0x0d558, 0x0b540, 0x0b6a0, 0x195a6,
    0x095b0, 0x049b0, 0x0a974, 0x0a4b0, 0x0b27a, 0x06a50, 0x06d40, 0x0af46, 0x0ab60, 0x09570,
    0x04af5, 0x04970, 0x064b0, 0x074a3, 0x0ea50, 0x06b58, 0x05ac0, 0x0ab60, 0x096d5, 0x092e0,
    0x0c960, 0x0d954, 0x0d4a0, 0x0da50, 0x07552, 0x056a0, 0x0abb7, 0x025d0, 0x092d0, 0x0cab5,
    0x0a950, 0x0b4a0, 0x0baa4, 0x0ad50, 0x055d9, 0x04ba0, 0x0a5b0, 0x15176, 0x052b0, 0x0a930,
    0x07954, 0x06aa0, 0x0ad50, 0x05b52, 0x04b60, 0x0a6e6, 0x0a4e0, 0x0d260, 0x0ea65, 0x0d530,
    0x05aa0, 0x076a3, 0x096d0, 0x04afb, 0x04ad0, 0x0a4d0, 0x1d0b6, 0x0d250, 0x0d520, 0x0dd45,
    0x0b5a0, 0x056d0, 0x055b2, 0x049b0, 0x0a577, 0x0a4b0, 0x0aa50, 0x1b255, 0x06d20, 0x0ada0,
    0x14b63, 0x09370, 0x049f8, 0x04970, 0x064b0, 0x168a6, 0x0ea50, 0x06b20, 0x1a6c4, 0x0aae0,
    0x092e0, 0x0d2e3, 0x0c960, 0x0d557, 0x0d4a0, 0x0da50, 0x05d55, 0x056a0, 0x0a6d0, 0x055d4,
    0x052d0, 0x0a9b8, 0x0a950, 0x0b4a0, 0x0b6a6, 0x0ad50, 0x055a0, 0x0aba4, 0x0a5b0, 0x052b0,
    0x0b273, 0x06930, 0x07337, 0x06aa0, 0x0ad50, 0x14b55, 0x04b60, 0x0a570, 0x054e4, 0x0d160,
    0x0e968, 0x0d520, 0x0daa0, 0x16aa6, 0x056d0, 0x04ae0, 0x0a9d4, 0x0a2d0, 0x0d150, 0x0f252,
    0x0d520,
  ];

  // 天干
  static const List<String> _tianGan = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];

  // 地支
  static const List<String> _diZhi = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];

  // 生肖
  static const List<String> _shengXiao = ['鼠', '牛', '虎', '兔', '龙', '蛇', '马', '羊', '猴', '鸡', '狗', '猪'];

  // 农历月份
  static const List<String> _lunarMonths = ['正', '二', '三', '四', '五', '六', '七', '八', '九', '十', '冬', '腊'];

  // 农历日期
  static const List<String> _lunarDays = [
    '初一', '初二', '初三', '初四', '初五', '初六', '初七', '初八', '初九', '初十',
    '十一', '十二', '十三', '十四', '十五', '十六', '十七', '十八', '十九', '二十',
    '廿一', '廿二', '廿三', '廿四', '廿五', '廿六', '廿七', '廿八', '廿九', '三十'
  ];

  /// 获取某年农历的总天数
  static int _getLunarYearDays(int year) {
    int sum = 348;
    for (int i = 0x8000; i > 0x8; i >>= 1) {
      sum += (_lunarData[year - 1900] & i) != 0 ? 1 : 0;
    }
    return sum + _getLeapDays(year);
  }

  /// 获取某年闰月的天数
  static int _getLeapDays(int year) {
    if (_getLeapMonth(year) != 0) {
      return (_lunarData[year - 1900] & 0x10000) != 0 ? 30 : 29;
    }
    return 0;
  }

  /// 获取某年闰哪个月
  static int _getLeapMonth(int year) {
    return _lunarData[year - 1900] & 0xf;
  }

  /// 获取某年某月的天数
  static int _getLunarMonthDays(int year, int month) {
    return (_lunarData[year - 1900] & (0x10000 >> month)) != 0 ? 30 : 29;
  }

  /// 公历转农历
  static LunarDate solarToLunar(DateTime solarDate) {
    int year = solarDate.year;
    int month = solarDate.month;
    int day = solarDate.day;

    // 计算与1900年1月31日相差的天数
    DateTime baseDate = DateTime(1900, 1, 31);
    int offset = solarDate.difference(baseDate).inDays;

    int lunarYear = 1900;
    int lunarMonth = 1;
    int lunarDay = 1;
    bool isLeap = false;

    // 计算农历年
    int yearDays = 0;
    for (lunarYear = 1900; lunarYear < 2101 && offset > 0; lunarYear++) {
      yearDays = _getLunarYearDays(lunarYear);
      offset -= yearDays;
    }
    if (offset < 0) {
      offset += yearDays;
      lunarYear--;
    }

    // 计算农历月
    int leapMonth = _getLeapMonth(lunarYear);
    int monthDays = 0;
    for (lunarMonth = 1; lunarMonth < 13 && offset > 0; lunarMonth++) {
      // 闰月
      if (leapMonth > 0 && lunarMonth == (leapMonth + 1) && !isLeap) {
        --lunarMonth;
        isLeap = true;
        monthDays = _getLeapDays(lunarYear);
      } else {
        monthDays = _getLunarMonthDays(lunarYear, lunarMonth);
      }

      // 解除闰月
      if (isLeap && lunarMonth == (leapMonth + 1)) {
        isLeap = false;
      }

      offset -= monthDays;
    }

    if (offset == 0 && leapMonth > 0 && lunarMonth == leapMonth + 1) {
      if (isLeap) {
        isLeap = false;
      } else {
        isLeap = true;
        --lunarMonth;
      }
    }

    if (offset < 0) {
      offset += monthDays;
      --lunarMonth;
    }

    lunarDay = offset + 1;

    return LunarDate(
      year: lunarYear,
      month: lunarMonth,
      day: lunarDay,
      isLeap: isLeap,
    );
  }

  /// 农历转公历
  static DateTime lunarToSolar(int lunarYear, int lunarMonth, int lunarDay, {bool isLeap = false}) {
    // 从农历正月初一开始计算
    int days = 0;

    // 计算从1900年到指定农历年的天数
    for (int y = 1900; y < lunarYear; y++) {
      days += _getLunarYearDays(y);
    }

    // 计算该年从正月到指定月的天数
    int leapMonth = _getLeapMonth(lunarYear);
    for (int m = 1; m < lunarMonth; m++) {
      days += _getLunarMonthDays(lunarYear, m);
      if (m == leapMonth) {
        days += _getLeapDays(lunarYear);
      }
    }

    // 如果是闰月，加上该月前面那个月的天数
    if (isLeap && lunarMonth == leapMonth) {
      days += _getLunarMonthDays(lunarYear, lunarMonth);
    }

    // 加上日期
    days += lunarDay - 1;

    // 从1900年1月31日开始加上天数
    DateTime baseDate = DateTime(1900, 1, 31);
    return baseDate.add(Duration(days: days));
  }

  /// 格式化农历日期
  static String formatLunarDate(LunarDate lunarDate) {
    String result = '农历';
    result += _lunarMonths[lunarDate.month - 1];
    result += '月';
    result += _lunarDays[lunarDate.day - 1];
    if (lunarDate.isLeap) {
      result = '闰$result';
    }
    return result;
  }

  /// 获取公历日期对应的农历字符串
  static String getLunarString(DateTime solarDate) {
    final lunar = solarToLunar(solarDate);
    return formatLunarDate(lunar);
  }

  /// 获取公历日期的农历完整字符串 (含年份)
  static String getLunarStringWithYear(DateTime solarDate) {
    final lunar = solarToLunar(solarDate);
    String yearStr = '${_tianGan[(lunar.year - 4) % 10]}${_diZhi[(lunar.year - 4) % 12]}年';
    return '$yearStr${formatLunarDate(lunar)}';
  }
}

/// 农历日期
class LunarDate {
  final int year;
  final int month;
  final int day;
  final bool isLeap;

  const LunarDate({
    required this.year,
    required this.month,
    required this.day,
    this.isLeap = false,
  });

  @override
  String toString() => 'LunarDate($year, $month, $day, isLeap: $isLeap)';
}

class Weight {
  final int? id;
  final double value;
  final double? bodyFat;
  final bool exercised;
  final String exerciseType;
  final int exerciseDuration;
  final String notes;
  final DateTime date;
  final DateTime createdAt;

  const Weight({
    this.id,
    required this.value,
    this.bodyFat,
    this.exercised = false,
    this.exerciseType = '',
    this.exerciseDuration = 0,
    this.notes = '',
    required this.date,
    required this.createdAt,
  });

  /// 判断是否为空记录
  bool get isEmpty => value <= 0;

  /// 格式化体重显示
  String get displayValue => '${value.toStringAsFixed(1)} kg';

  /// 格式化体脂显示
  String get displayBodyFat => bodyFat != null ? '${bodyFat!.toStringAsFixed(1)} %' : '';

  /// 格式化运动时长
  String get displayDuration {
    if (exerciseDuration <= 0) return '';
    if (exerciseDuration < 60) return '$exerciseDuration 分钟';
    final hours = exerciseDuration ~/ 60;
    final mins = exerciseDuration % 60;
    return mins > 0 ? '${hours}小时${mins}分' : '${hours}小时';
  }

  Weight copyWith({
    int? id,
    double? value,
    double? bodyFat,
    bool? exercised,
    String? exerciseType,
    int? exerciseDuration,
    String? notes,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return Weight(
      id: id ?? this.id,
      value: value ?? this.value,
      bodyFat: bodyFat ?? this.bodyFat,
      exercised: exercised ?? this.exercised,
      exerciseType: exerciseType ?? this.exerciseType,
      exerciseDuration: exerciseDuration ?? this.exerciseDuration,
      notes: notes ?? this.notes,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// 统计数据类
class WeightStats {
  final double avgWeight;
  final double minWeight;
  final double maxWeight;
  final int exerciseCount;
  final double weightChange;
  final int days;

  const WeightStats({
    required this.avgWeight,
    required this.minWeight,
    required this.maxWeight,
    required this.exerciseCount,
    required this.weightChange,
    required this.days,
  });

  factory WeightStats.empty() => const WeightStats(
        avgWeight: 0,
        minWeight: 0,
        maxWeight: 0,
        exerciseCount: 0,
        weightChange: 0,
        days: 0,
      );

  bool get isEmpty => days == 0;

  /// 体重变化方向: true=下降, false=上升
  bool get isDecreasing => weightChange < 0;
}

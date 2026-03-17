// 进度类型
enum GoalProgressType {
  percent, // 百分比 (0-100%)
  count,   // 次数 (如: 读10本书)
  days,    // 天数 (如: 坚持30天)
}

extension GoalProgressTypeX on GoalProgressType {
  String get label {
    switch (this) {
      case GoalProgressType.percent:
        return '百分比';
      case GoalProgressType.count:
        return '次数';
      case GoalProgressType.days:
        return '天数';
    }
  }

  int get defaultTotal {
    switch (this) {
      case GoalProgressType.percent:
        return 100;
      case GoalProgressType.count:
        return 10;
      case GoalProgressType.days:
        return 30;
    }
  }

  String formatProgress(int completed, int total) {
    switch (this) {
      case GoalProgressType.percent:
        return '$completed%';
      case GoalProgressType.count:
        return '$completed/$total次';
      case GoalProgressType.days:
        return '$completed/$total天';
    }
  }
}

class Goal {
  final int? id;
  final String name;
  final String notes;
  final GoalProgressType progressType;
  final int totalSteps;
  final int completedSteps;
  final DateTime? deadline;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Goal({
    this.id,
    required this.name,
    this.notes = '',
    this.progressType = GoalProgressType.percent,
    this.totalSteps = 100,
    this.completedSteps = 0,
    this.deadline,
    required this.createdAt,
    required this.updatedAt,
  });

  // 进度百分比 (0.0 ~ 1.0)
  double get progress {
    if (totalSteps <= 0) return 0;
    return (completedSteps / totalSteps).clamp(0.0, 1.0);
  }

  // 进度百分比整数
  int get progressPercent => (progress * 100).round();

  // 格式化的进度文本
  String get progressText => progressType.formatProgress(completedSteps, totalSteps);

  // 是否已完成
  bool get isCompleted => completedSteps >= totalSteps;

  // 是否已逾期
  bool get isOverdue {
    if (deadline == null || isCompleted) return false;
    return DateTime.now().isAfter(deadline!);
  }

  // 剩余天数
  int? get daysRemaining {
    if (deadline == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadlineDay = DateTime(deadline!.year, deadline!.month, deadline!.day);
    return deadlineDay.difference(today).inDays;
  }

  // 状态文本
  String get statusText {
    if (isCompleted) return '已完成';
    if (isOverdue) return '已逾期${-daysRemaining!}天';
    if (daysRemaining == null) return '进行中';
    if (daysRemaining == 0) return '今天截止';
    if (daysRemaining! > 0) return '剩余${daysRemaining}天';
    return '已逾期${-daysRemaining!}天';
  }

  Goal copyWith({
    int? id,
    String? name,
    String? notes,
    GoalProgressType? progressType,
    int? totalSteps,
    int? completedSteps,
    DateTime? deadline,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Goal(
      id: id ?? this.id,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      progressType: progressType ?? this.progressType,
      totalSteps: totalSteps ?? this.totalSteps,
      completedSteps: completedSteps ?? this.completedSteps,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class GoalProgressLog {
  final int? id;
  final int goalId;
  final int stepBefore;
  final int stepAfter;
  final DateTime createdAt;

  const GoalProgressLog({
    this.id,
    required this.goalId,
    required this.stepBefore,
    required this.stepAfter,
    required this.createdAt,
  });

  // 变更步数
  int get stepChange => stepAfter - stepBefore;

  GoalProgressLog copyWith({
    int? id,
    int? goalId,
    int? stepBefore,
    int? stepAfter,
    DateTime? createdAt,
  }) {
    return GoalProgressLog(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      stepBefore: stepBefore ?? this.stepBefore,
      stepAfter: stepAfter ?? this.stepAfter,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

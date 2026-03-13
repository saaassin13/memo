class Goal {
  final int? id;
  final String name;
  final int totalSteps;
  final int completedSteps;
  final DateTime? deadline;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Goal({
    this.id,
    required this.name,
    this.totalSteps = 100,
    this.completedSteps = 0,
    this.deadline,
    required this.createdAt,
    required this.updatedAt,
  });

  Goal copyWith({
    int? id,
    String? name,
    int? totalSteps,
    int? completedSteps,
    DateTime? deadline,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Goal(
      id: id ?? this.id,
      name: name ?? this.name,
      totalSteps: totalSteps ?? this.totalSteps,
      completedSteps: completedSteps ?? this.completedSteps,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

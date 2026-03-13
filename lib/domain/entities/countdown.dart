class Countdown {
  final int? id;
  final String name;
  final DateTime targetDate;
  final String? category;
  final bool isRepeat;
  final DateTime createdAt;

  const Countdown({
    this.id,
    required this.name,
    required this.targetDate,
    this.category,
    this.isRepeat = false,
    required this.createdAt,
  });

  Countdown copyWith({
    int? id,
    String? name,
    DateTime? targetDate,
    String? category,
    bool? isRepeat,
    DateTime? createdAt,
  }) {
    return Countdown(
      id: id ?? this.id,
      name: name ?? this.name,
      targetDate: targetDate ?? this.targetDate,
      category: category ?? this.category,
      isRepeat: isRepeat ?? this.isRepeat,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

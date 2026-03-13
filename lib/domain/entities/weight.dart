class Weight {
  final int? id;
  final double value;
  final DateTime date;
  final DateTime createdAt;

  const Weight({
    this.id,
    required this.value,
    required this.date,
    required this.createdAt,
  });

  Weight copyWith({
    int? id,
    double? value,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return Weight(
      id: id ?? this.id,
      value: value ?? this.value,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

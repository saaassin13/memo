class Account {
  final int? id;
  final double amount;
  final String type;
  final String category;
  final String? note;
  final DateTime date;
  final DateTime createdAt;

  const Account({
    this.id,
    required this.amount,
    required this.type,
    required this.category,
    this.note,
    required this.date,
    required this.createdAt,
  });

  Account copyWith({
    int? id,
    double? amount,
    String? type,
    String? category,
    String? note,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return Account(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      note: note ?? this.note,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

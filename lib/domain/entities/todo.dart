class Todo {
  final int? id;
  final String title;
  final String? description;
  final String category;
  final bool isCompleted;
  final bool isPinned;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Todo({
    this.id,
    required this.title,
    this.description,
    this.category = '杂项',
    this.isCompleted = false,
    this.isPinned = false,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
  });

  Todo copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    bool? isCompleted,
    bool? isPinned,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      isPinned: isPinned ?? this.isPinned,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

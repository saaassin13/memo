class Memo {
  final int? id;
  final String title;
  final String content;
  final String? category;
  final bool isPinned;
  final DateTime? remindTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Memo({
    this.id,
    required this.title,
    required this.content,
    this.category,
    this.isPinned = false,
    this.remindTime,
    required this.createdAt,
    required this.updatedAt,
  });

  Memo copyWith({
    int? id,
    String? title,
    String? content,
    String? category,
    bool? isPinned,
    DateTime? remindTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Memo(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      isPinned: isPinned ?? this.isPinned,
      remindTime: remindTime ?? this.remindTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

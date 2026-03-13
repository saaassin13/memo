class Diary {
  final int? id;
  final DateTime date;
  final String? weather;
  final String content;
  final List<String> images;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Diary({
    this.id,
    required this.date,
    this.weather,
    required this.content,
    this.images = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  Diary copyWith({
    int? id,
    DateTime? date,
    String? weather,
    String? content,
    List<String>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Diary(
      id: id ?? this.id,
      date: date ?? this.date,
      weather: weather ?? this.weather,
      content: content ?? this.content,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

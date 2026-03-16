class Diary {
  final int? id;
  final DateTime date;
  final String? weather;
  final String content;
  final String label;
  final String mood;
  final List<String> images;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Diary({
    this.id,
    required this.date,
    this.weather,
    this.content = '',
    this.label = '',
    this.mood = '',
    this.images = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// 判断是否为空日记（无内容、标签、心情）
  bool get isEmpty => content.isEmpty && label.isEmpty && mood.isEmpty;

  /// 获取心情对应的颜色
  int get moodColor {
    switch (mood) {
      case '开心':
        return 0xFFF59E0B;
      case '伤心':
        return 0xFF3B82F6;
      case '生气':
        return 0xFFEF4444;
      case '焦虑':
        return 0xFFF97316;
      case '平静':
        return 0xFF10B981;
      case '兴奋':
        return 0xFFEC4899;
      case '疲惫':
        return 0xFF6B7280;
      case '思考':
        return 0xFF8B5CF6;
      default:
        return 0xFF11998E;
    }
  }

  Diary copyWith({
    int? id,
    DateTime? date,
    String? weather,
    String? content,
    String? label,
    String? mood,
    List<String>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Diary(
      id: id ?? this.id,
      date: date ?? this.date,
      weather: weather ?? this.weather,
      content: content ?? this.content,
      label: label ?? this.label,
      mood: mood ?? this.mood,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

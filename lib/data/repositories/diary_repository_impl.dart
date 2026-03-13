import 'dart:convert';
import 'package:drift/drift.dart';
import '../../domain/entities/diary.dart' as entity;
import '../../domain/repositories/diary_repository.dart';
import '../database/database.dart';

class DiaryRepositoryImpl implements DiaryRepository {
  final AppDatabase _db;

  DiaryRepositoryImpl(this._db);

  @override
  Stream<List<entity.Diary>> watchAll() {
    return (_db.select(_db.diaries)
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
          ]))
        .watch()
        .map((rows) => rows.map(_mapToEntity).toList());
  }

  @override
  Future<entity.Diary?> getById(int id) async {
    final row = await (_db.select(_db.diaries)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row != null ? _mapToEntity(row) : null;
  }

  @override
  Future<entity.Diary?> getByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final row = await (_db.select(_db.diaries)
          ..where((t) => t.date.isBetweenValues(startOfDay, endOfDay)))
        .getSingleOrNull();
    return row != null ? _mapToEntity(row) : null;
  }

  @override
  Future<int> insert(entity.Diary diary) {
    return _db.into(_db.diaries).insert(DiariesCompanion.insert(
          date: diary.date,
          weather: Value(diary.weather),
          content: diary.content,
          images: Value(jsonEncode(diary.images)),
        ));
  }

  @override
  Future<bool> update(entity.Diary diary) {
    return _db.update(_db.diaries).replace(DiariesCompanion(
          id: Value(diary.id!),
          date: Value(diary.date),
          weather: Value(diary.weather),
          content: Value(diary.content),
          images: Value(jsonEncode(diary.images)),
          updatedAt: Value(DateTime.now()),
        ));
  }

  @override
  Future<int> delete(int id) {
    return (_db.delete(_db.diaries)..where((t) => t.id.equals(id))).go();
  }

  entity.Diary _mapToEntity(Diary row) {
    List<String> images = [];
    if (row.images.isNotEmpty) {
      try {
        images = List<String>.from(jsonDecode(row.images));
      } catch (_) {}
    }
    return entity.Diary(
      id: row.id,
      date: row.date,
      weather: row.weather,
      content: row.content,
      images: images,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}

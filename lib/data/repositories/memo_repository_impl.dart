import 'dart:convert';
import 'package:drift/drift.dart';
import '../../domain/entities/memo.dart' as entity;
import '../../domain/repositories/memo_repository.dart';
import '../database/database.dart';

class MemoRepositoryImpl implements MemoRepository {
  final AppDatabase _db;

  MemoRepositoryImpl(this._db);

  @override
  Stream<List<entity.Memo>> watchAll() {
    return (_db.select(_db.memos)
          ..orderBy([
            (t) => OrderingTerm(expression: t.isPinned, mode: OrderingMode.desc),
            (t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc),
          ]))
        .watch()
        .map((rows) => rows.map(_mapToEntity).toList());
  }

  @override
  Future<entity.Memo?> getById(int id) async {
    final row = await (_db.select(_db.memos)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row != null ? _mapToEntity(row) : null;
  }

  @override
  Future<int> insert(entity.Memo memo) {
    return _db.into(_db.memos).insert(MemosCompanion.insert(
          title: memo.title,
          content: memo.content,
          category: Value(memo.category),
          isPinned: Value(memo.isPinned),
          remindTime: Value(memo.remindTime),
          images: Value(memo.images.isNotEmpty ? jsonEncode(memo.images) : null),
        ));
  }

  @override
  Future<bool> update(entity.Memo memo) {
    return _db.update(_db.memos).replace(MemosCompanion(
          id: Value(memo.id!),
          title: Value(memo.title),
          content: Value(memo.content),
          category: Value(memo.category),
          isPinned: Value(memo.isPinned),
          remindTime: Value(memo.remindTime),
          images: Value(memo.images.isNotEmpty ? jsonEncode(memo.images) : null),
          updatedAt: Value(DateTime.now()),
        ));
  }

  @override
  Future<int> delete(int id) {
    return (_db.delete(_db.memos)..where((t) => t.id.equals(id))).go();
  }

  entity.Memo _mapToEntity(Memo row) {
    List<String> images = [];
    final imagesStr = row.images;
    if (imagesStr != null && imagesStr.isNotEmpty) {
      try {
        images = List<String>.from(jsonDecode(imagesStr));
      } catch (_) {}
    }
    return entity.Memo(
      id: row.id,
      title: row.title,
      content: row.content,
      category: row.category,
      isPinned: row.isPinned,
      remindTime: row.remindTime,
      images: images,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}

import 'package:drift/drift.dart';
import '../../domain/entities/anniversary.dart' as entity;
import '../../domain/repositories/anniversary_repository.dart';
import '../database/database.dart';

class AnniversaryRepositoryImpl implements AnniversaryRepository {
  final AppDatabase _db;

  AnniversaryRepositoryImpl(this._db);

  @override
  Stream<List<entity.Anniversary>> watchAll() {
    return (_db.select(_db.anniversaries)
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.asc),
          ]))
        .watch()
        .map((rows) => rows.map(_mapToEntity).toList());
  }

  @override
  Future<entity.Anniversary?> getById(int id) async {
    final row = await (_db.select(_db.anniversaries)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row != null ? _mapToEntity(row) : null;
  }

  @override
  Future<int> insert(entity.Anniversary anniversary) {
    return _db.into(_db.anniversaries).insert(AnniversariesCompanion.insert(
          title: anniversary.title,
          date: anniversary.date,
          isLunar: Value(anniversary.isLunar),
          reminderDays: Value(anniversary.reminderDays),
          repeatYearly: Value(anniversary.repeatYearly),
          relationship: Value(anniversary.relationship),
          customRelation: Value(anniversary.customRelation),
          phoneNumber: Value(anniversary.phoneNumber),
          notes: Value(anniversary.notes),
        ));
  }

  @override
  Future<bool> update(entity.Anniversary anniversary) {
    return _db.update(_db.anniversaries).replace(AnniversariesCompanion(
          id: Value(anniversary.id!),
          title: Value(anniversary.title),
          date: Value(anniversary.date),
          isLunar: Value(anniversary.isLunar),
          reminderDays: Value(anniversary.reminderDays),
          repeatYearly: Value(anniversary.repeatYearly),
          relationship: Value(anniversary.relationship),
          customRelation: Value(anniversary.customRelation),
          phoneNumber: Value(anniversary.phoneNumber),
          notes: Value(anniversary.notes),
          updatedAt: Value(DateTime.now()),
        ));
  }

  @override
  Future<int> delete(int id) {
    return (_db.delete(_db.anniversaries)..where((t) => t.id.equals(id))).go();
  }

  entity.Anniversary _mapToEntity(Anniversary row) {
    return entity.Anniversary(
      id: row.id,
      title: row.title,
      date: row.date,
      isLunar: row.isLunar,
      reminderDays: row.reminderDays,
      repeatYearly: row.repeatYearly,
      relationship: row.relationship,
      customRelation: row.customRelation,
      phoneNumber: row.phoneNumber,
      notes: row.notes,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}

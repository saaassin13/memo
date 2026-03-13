import 'package:drift/drift.dart';
import '../../domain/entities/countdown.dart' as entity;
import '../../domain/repositories/countdown_repository.dart';
import '../database/database.dart';

class CountdownRepositoryImpl implements CountdownRepository {
  final AppDatabase _db;

  CountdownRepositoryImpl(this._db);

  @override
  Stream<List<entity.Countdown>> watchAll() {
    return (_db.select(_db.countdowns)
          ..orderBy([
            (t) => OrderingTerm(expression: t.targetDate, mode: OrderingMode.asc),
          ]))
        .watch()
        .map((rows) => rows.map(_mapToEntity).toList());
  }

  @override
  Future<entity.Countdown?> getById(int id) async {
    final row = await (_db.select(_db.countdowns)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row != null ? _mapToEntity(row) : null;
  }

  @override
  Future<int> insert(entity.Countdown countdown) {
    return _db.into(_db.countdowns).insert(CountdownsCompanion.insert(
          name: countdown.name,
          targetDate: countdown.targetDate,
          category: Value(countdown.category),
          isRepeat: Value(countdown.isRepeat),
        ));
  }

  @override
  Future<bool> update(entity.Countdown countdown) {
    return _db.update(_db.countdowns).replace(CountdownsCompanion(
          id: Value(countdown.id!),
          name: Value(countdown.name),
          targetDate: Value(countdown.targetDate),
          category: Value(countdown.category),
          isRepeat: Value(countdown.isRepeat),
        ));
  }

  @override
  Future<int> delete(int id) {
    return (_db.delete(_db.countdowns)..where((t) => t.id.equals(id))).go();
  }

  entity.Countdown _mapToEntity(Countdown row) {
    return entity.Countdown(
      id: row.id,
      name: row.name,
      targetDate: row.targetDate,
      category: row.category,
      isRepeat: row.isRepeat,
      createdAt: row.createdAt,
    );
  }
}

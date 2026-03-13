import 'package:drift/drift.dart';
import '../../domain/entities/weight.dart' as entity;
import '../../domain/repositories/weight_repository.dart';
import '../database/database.dart';

class WeightRepositoryImpl implements WeightRepository {
  final AppDatabase _db;

  WeightRepositoryImpl(this._db);

  @override
  Stream<List<entity.Weight>> watchAll() {
    return (_db.select(_db.weights)
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
          ]))
        .watch()
        .map((rows) => rows.map(_mapToEntity).toList());
  }

  @override
  Future<entity.Weight?> getById(int id) async {
    final row = await (_db.select(_db.weights)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row != null ? _mapToEntity(row) : null;
  }

  @override
  Future<int> insert(entity.Weight weight) {
    return _db.into(_db.weights).insert(WeightsCompanion.insert(
          value: weight.value,
          date: weight.date,
        ));
  }

  @override
  Future<bool> update(entity.Weight weight) {
    return _db.update(_db.weights).replace(WeightsCompanion(
          id: Value(weight.id!),
          value: Value(weight.value),
          date: Value(weight.date),
        ));
  }

  @override
  Future<int> delete(int id) {
    return (_db.delete(_db.weights)..where((t) => t.id.equals(id))).go();
  }

  entity.Weight _mapToEntity(Weight row) {
    return entity.Weight(
      id: row.id,
      value: row.value,
      date: row.date,
      createdAt: row.createdAt,
    );
  }
}

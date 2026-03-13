import 'package:drift/drift.dart';
import '../../domain/entities/account.dart' as entity;
import '../../domain/repositories/account_repository.dart';
import '../database/database.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AppDatabase _db;

  AccountRepositoryImpl(this._db);

  @override
  Stream<List<entity.Account>> watchAll() {
    return (_db.select(_db.accounts)
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
          ]))
        .watch()
        .map((rows) => rows.map(_mapToEntity).toList());
  }

  @override
  Future<entity.Account?> getById(int id) async {
    final row = await (_db.select(_db.accounts)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row != null ? _mapToEntity(row) : null;
  }

  @override
  Future<int> insert(entity.Account account) {
    return _db.into(_db.accounts).insert(AccountsCompanion.insert(
          amount: account.amount,
          type: account.type,
          category: account.category,
          note: Value(account.note),
          date: account.date,
        ));
  }

  @override
  Future<bool> update(entity.Account account) {
    return _db.update(_db.accounts).replace(AccountsCompanion(
          id: Value(account.id!),
          amount: Value(account.amount),
          type: Value(account.type),
          category: Value(account.category),
          note: Value(account.note),
          date: Value(account.date),
        ));
  }

  @override
  Future<int> delete(int id) {
    return (_db.delete(_db.accounts)..where((t) => t.id.equals(id))).go();
  }

  entity.Account _mapToEntity(Account row) {
    return entity.Account(
      id: row.id,
      amount: row.amount,
      type: row.type,
      category: row.category,
      note: row.note,
      date: row.date,
      createdAt: row.createdAt,
    );
  }
}

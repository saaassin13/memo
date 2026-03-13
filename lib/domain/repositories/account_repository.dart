import '../entities/account.dart';

abstract class AccountRepository {
  Stream<List<Account>> watchAll();
  Future<Account?> getById(int id);
  Future<int> insert(Account account);
  Future<bool> update(Account account);
  Future<int> delete(int id);
}

import '../entities/memo.dart';

abstract class MemoRepository {
  Stream<List<Memo>> watchAll();
  Future<Memo?> getById(int id);
  Future<int> insert(Memo memo);
  Future<bool> update(Memo memo);
  Future<int> delete(int id);
}

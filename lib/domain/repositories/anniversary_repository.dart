import '../entities/anniversary.dart';

abstract class AnniversaryRepository {
  Stream<List<Anniversary>> watchAll();
  Future<Anniversary?> getById(int id);
  Future<int> insert(Anniversary anniversary);
  Future<bool> update(Anniversary anniversary);
  Future<int> delete(int id);
}

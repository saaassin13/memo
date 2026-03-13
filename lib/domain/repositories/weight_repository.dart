import '../entities/weight.dart';

abstract class WeightRepository {
  Stream<List<Weight>> watchAll();
  Future<Weight?> getById(int id);
  Future<int> insert(Weight weight);
  Future<bool> update(Weight weight);
  Future<int> delete(int id);
}

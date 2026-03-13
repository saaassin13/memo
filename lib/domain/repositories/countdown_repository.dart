import '../entities/countdown.dart';

abstract class CountdownRepository {
  Stream<List<Countdown>> watchAll();
  Future<Countdown?> getById(int id);
  Future<int> insert(Countdown countdown);
  Future<bool> update(Countdown countdown);
  Future<int> delete(int id);
}

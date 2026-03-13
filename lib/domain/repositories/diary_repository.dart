import '../entities/diary.dart';

abstract class DiaryRepository {
  Stream<List<Diary>> watchAll();
  Future<Diary?> getById(int id);
  Future<Diary?> getByDate(DateTime date);
  Future<int> insert(Diary diary);
  Future<bool> update(Diary diary);
  Future<int> delete(int id);
}

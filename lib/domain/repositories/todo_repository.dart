import '../entities/todo.dart';

abstract class TodoRepository {
  Stream<List<Todo>> watchAll();
  Future<Todo?> getById(int id);
  Future<int> insert(Todo todo);
  Future<bool> update(Todo todo);
  Future<int> delete(int id);
  Future<bool> togglePin(int id, bool isPinned);
}

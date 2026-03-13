import 'package:drift/drift.dart';
import '../../domain/entities/todo.dart' as entity;
import '../../domain/repositories/todo_repository.dart';
import '../database/database.dart';

class TodoRepositoryImpl implements TodoRepository {
  final AppDatabase _db;

  TodoRepositoryImpl(this._db);

  @override
  Stream<List<entity.Todo>> watchAll() {
    return (_db.select(_db.todos)
          ..orderBy([
            (t) => OrderingTerm(expression: t.isCompleted, mode: OrderingMode.asc),
            (t) => OrderingTerm(expression: t.dueDate, mode: OrderingMode.asc),
          ]))
        .watch()
        .map((rows) => rows.map(_mapToEntity).toList());
  }

  @override
  Future<entity.Todo?> getById(int id) async {
    final row = await (_db.select(_db.todos)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row != null ? _mapToEntity(row) : null;
  }

  @override
  Future<int> insert(entity.Todo todo) {
    return _db.into(_db.todos).insert(TodosCompanion.insert(
          title: todo.title,
          description: Value(todo.description),
          category: Value(todo.category),
          isCompleted: Value(todo.isCompleted),
          dueDate: Value(todo.dueDate),
        ));
  }

  @override
  Future<bool> update(entity.Todo todo) {
    return _db.update(_db.todos).replace(TodosCompanion(
          id: Value(todo.id!),
          title: Value(todo.title),
          description: Value(todo.description),
          category: Value(todo.category),
          isCompleted: Value(todo.isCompleted),
          dueDate: Value(todo.dueDate),
          updatedAt: Value(DateTime.now()),
        ));
  }

  @override
  Future<int> delete(int id) {
    return (_db.delete(_db.todos)..where((t) => t.id.equals(id))).go();
  }

  entity.Todo _mapToEntity(Todo row) {
    return entity.Todo(
      id: row.id,
      title: row.title,
      description: row.description,
      category: row.category,
      isCompleted: row.isCompleted,
      dueDate: row.dueDate,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}

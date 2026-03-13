import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/todo.dart';
import 'repository_providers.dart';

// 分类列表
const todoCategories = ['全部', '工作', '生活', '学习', '杂项'];

// 筛选状态
enum TodoFilter { all, pending, completed }

// 排序方式
enum TodoSort { dueDate, createdAt, title }

// 当前选中的分类
final selectedTodoCategoryProvider = StateProvider<String>((ref) => '全部');

// 筛选状态
final todoFilterProvider = StateProvider<TodoFilter>((ref) => TodoFilter.all);

// 排序方式
final todoSortProvider = StateProvider<TodoSort>((ref) => TodoSort.dueDate);

// 全部 Todo 列表流
final todosProvider = StreamProvider<List<Todo>>((ref) {
  final repository = ref.watch(todoRepositoryProvider);
  return repository.watchAll();
});

// 过滤后的 Todo 列表
final filteredTodosProvider = Provider<AsyncValue<List<Todo>>>((ref) {
  final todosAsync = ref.watch(todosProvider);
  final category = ref.watch(selectedTodoCategoryProvider);
  final filter = ref.watch(todoFilterProvider);
  final sort = ref.watch(todoSortProvider);

  return todosAsync.whenData((todos) {
    // 分类过滤
    var filtered = category == '全部'
        ? todos
        : todos.where((t) => t.category == category).toList();

    // 状态过滤
    switch (filter) {
      case TodoFilter.pending:
        filtered = filtered.where((t) => !t.isCompleted).toList();
        break;
      case TodoFilter.completed:
        filtered = filtered.where((t) => t.isCompleted).toList();
        break;
      case TodoFilter.all:
        break;
    }

    // 排序
    switch (sort) {
      case TodoSort.dueDate:
        filtered.sort((a, b) {
          // 未设置截止时间的排后面
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
        break;
      case TodoSort.createdAt:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case TodoSort.title:
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
    }

    return filtered;
  });
});

// 待办列表（未完成）
final pendingTodosProvider = Provider<List<Todo>>((ref) {
  final todosAsync = ref.watch(todosProvider);
  return todosAsync.whenOrNull(
        data: (todos) => todos.where((t) => !t.isCompleted).toList(),
      ) ??
      const [];
});

// 已办列表（已完成）
final completedTodosProvider = Provider<List<Todo>>((ref) {
  final todosAsync = ref.watch(todosProvider);
  return todosAsync.whenOrNull(
        data: (todos) => todos.where((t) => t.isCompleted).toList(),
      ) ??
      const [];
});

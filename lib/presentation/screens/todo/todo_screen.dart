import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/todo_providers.dart';
import '../../providers/repository_providers.dart';
import '../../widgets/todo/todo_category_chips.dart';
import '../../widgets/todo/todo_list_tile.dart';
import '../../widgets/todo/completed_section.dart';
import '../../widgets/todo/empty_todo.dart';
import '../../widgets/todo/todo_edit_dialog.dart';
import '../../../domain/entities/todo.dart';

class TodoScreen extends ConsumerStatefulWidget {
  const TodoScreen({super.key});

  @override
  ConsumerState<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends ConsumerState<TodoScreen> {
  void _showFilterMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '筛选',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('全部'),
              trailing: ref.watch(todoFilterProvider) == TodoFilter.all
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                ref.read(todoFilterProvider.notifier).state = TodoFilter.all;
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.pending_actions),
              title: const Text('待处理'),
              trailing: ref.watch(todoFilterProvider) == TodoFilter.pending
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                ref.read(todoFilterProvider.notifier).state = TodoFilter.pending;
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text('已完成'),
              trailing: ref.watch(todoFilterProvider) == TodoFilter.completed
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                ref.read(todoFilterProvider.notifier).state =
                    TodoFilter.completed;
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSortMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '排序',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('截止时间'),
              trailing: ref.watch(todoSortProvider) == TodoSort.dueDate
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                ref.read(todoSortProvider.notifier).state = TodoSort.dueDate;
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('创建时间'),
              trailing: ref.watch(todoSortProvider) == TodoSort.createdAt
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                ref.read(todoSortProvider.notifier).state = TodoSort.createdAt;
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text('名称'),
              trailing: ref.watch(todoSortProvider) == TodoSort.title
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                ref.read(todoSortProvider.notifier).state = TodoSort.title;
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showOptions(BuildContext context, Todo todo) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('编辑'),
              onTap: () {
                Navigator.pop(context);
                _editTodo(todo);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red.shade400),
              title: Text('删除', style: TextStyle(color: Colors.red.shade400)),
              onTap: () {
                Navigator.pop(context);
                _deleteTodo(todo);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleComplete(Todo todo) async {
    final repository = ref.read(todoRepositoryProvider);
    final updated = todo.copyWith(
      isCompleted: !todo.isCompleted,
      updatedAt: DateTime.now(),
    );
    await repository.update(updated);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(updated.isCompleted ? '已完成' : '已取消完成'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _deleteTodo(Todo todo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除待办'),
        content: const Text('确定要删除这条待办吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('删除', style: TextStyle(color: Colors.red.shade400)),
          ),
        ],
      ),
    );

    if (confirmed == true && todo.id != null) {
      final repository = ref.read(todoRepositoryProvider);
      await repository.delete(todo.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已删除')),
        );
      }
    }
  }

  void _editTodo(Todo todo) {
    showTodoEditDialog(context, todo: todo);
  }

  void _addTodo() {
    final category = ref.read(selectedTodoCategoryProvider);
    if (category != null && category != '全部') {
      showTodoEditDialog(context);
    } else {
      showTodoEditDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final todosAsync = ref.watch(filteredTodosProvider);
    final completedTodos = ref.watch(completedTodosProvider);
    final filter = ref.watch(todoFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('待办'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterMenu,
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortMenu,
          ),
        ],
      ),
      body: Column(
        children: [
          const TodoCategoryChips(),
          Expanded(
            child: todosAsync.when(
              data: (todos) {
                // 分离待办和已办
                final pendingTodos =
                    todos.where((t) => !t.isCompleted).toList();
                final displayCompleted = filter == TodoFilter.completed
                    ? completedTodos
                    : <Todo>[];

                if (pendingTodos.isEmpty && displayCompleted.isEmpty) {
                  return EmptyTodo(onAdd: _addTodo);
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(todosProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: pendingTodos.length + (displayCompleted.isNotEmpty && filter == TodoFilter.all ? 1 : 0),
                    itemBuilder: (context, index) {
                      // 待办列表
                      if (index < pendingTodos.length) {
                        final todo = pendingTodos[index];
                        if (index == 0) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                                child: Text(
                                  '待办',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                              TodoListTile(
                                todo: todo,
                                onToggle: () => _toggleComplete(todo),
                                onTap: () => _editTodo(todo),
                                onLongPress: () => _showOptions(context, todo),
                              ),
                            ],
                          );
                        }
                        return TodoListTile(
                          todo: todo,
                          onToggle: () => _toggleComplete(todo),
                          onTap: () => _editTodo(todo),
                          onLongPress: () => _showOptions(context, todo),
                        );
                      }

                      // 已办列表
                      final completedIndex = index - pendingTodos.length;
                      if (completedIndex == 0 && displayCompleted.isNotEmpty && filter == TodoFilter.all) {
                        return CompletedSection(
                          completedTodos: displayCompleted,
                          onToggle: (todo) => _toggleComplete(todo),
                          onTap: (todo) => _editTodo(todo),
                          onDelete: (todo) => _deleteTodo(todo),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 48, color: Theme.of(context).colorScheme.error),
                    const SizedBox(height: 16),
                    Text('加载失败: $error'),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => ref.invalidate(todosProvider),
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667EEA).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _addTodo,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

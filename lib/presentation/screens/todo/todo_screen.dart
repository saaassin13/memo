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
    final currentFilter = ref.read(todoFilterProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 14),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(24),
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_list_rounded,
                      color: Color(0xFF667EEA),
                      size: 24,
                    ),
                    SizedBox(width: 10),
                    Text(
                      '筛选',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              _FilterOption(
                icon: Icons.list_alt_rounded,
                title: '全部',
                subtitle: '显示所有待办',
                isSelected: currentFilter == TodoFilter.all,
                onTap: () {
                  ref.read(todoFilterProvider.notifier).state = TodoFilter.all;
                  Navigator.pop(context);
                },
              ),
              _FilterOption(
                icon: Icons.pending_actions_rounded,
                title: '待处理',
                subtitle: '只显示未完成',
                isSelected: currentFilter == TodoFilter.pending,
                onTap: () {
                  ref.read(todoFilterProvider.notifier).state = TodoFilter.pending;
                  Navigator.pop(context);
                },
              ),
              _FilterOption(
                icon: Icons.check_circle_outline_rounded,
                title: '已完成',
                subtitle: '只显示已完成',
                isSelected: currentFilter == TodoFilter.completed,
                onTap: () {
                  ref.read(todoFilterProvider.notifier).state = TodoFilter.completed;
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showSortMenu() {
    final currentSort = ref.read(todoSortProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 14),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(24),
                child: Row(
                  children: [
                    Icon(
                      Icons.sort_rounded,
                      color: Color(0xFF667EEA),
                      size: 24,
                    ),
                    SizedBox(width: 10),
                    Text(
                      '排序',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              _FilterOption(
                icon: Icons.schedule_rounded,
                title: '截止时间',
                subtitle: '按截止时间排序',
                isSelected: currentSort == TodoSort.dueDate,
                onTap: () {
                  ref.read(todoSortProvider.notifier).state = TodoSort.dueDate;
                  Navigator.pop(context);
                },
              ),
              _FilterOption(
                icon: Icons.access_time_rounded,
                title: '创建时间',
                subtitle: '按创建时间排序',
                isSelected: currentSort == TodoSort.createdAt,
                onTap: () {
                  ref.read(todoSortProvider.notifier).state = TodoSort.createdAt;
                  Navigator.pop(context);
                },
              ),
              _FilterOption(
                icon: Icons.sort_by_alpha_rounded,
                title: '名称',
                subtitle: '按任务名称排序',
                isSelected: currentSort == TodoSort.title,
                onTap: () {
                  ref.read(todoSortProvider.notifier).state = TodoSort.title;
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context, Todo todo) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 14),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  todo.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      _editTodo(todo);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF667EEA).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF667EEA).withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF667EEA).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.edit_rounded,
                              color: Color(0xFF667EEA),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Text(
                              '编辑',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: Color(0xFF667EEA),
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Color(0xFF667EEA),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      _deleteTodo(todo);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.red.shade100,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.delete_rounded,
                              color: Colors.red.shade400,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              '删除',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: Colors.red.shade400,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.red.shade400,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
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
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _deleteTodo(Todo todo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
          SnackBar(
            content: const Text('已删除'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
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
      showTodoEditDialog(context, initialCategory: category);
    } else {
      showTodoEditDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final todosAsync = ref.watch(filteredTodosProvider);
    final completedTodos = ref.watch(completedTodosProvider);
    final filter = ref.watch(todoFilterProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF11998E).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              '待办事项',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 24,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        actions: [
          _ActionButton(
            icon: Icons.filter_list_rounded,
            onPressed: _showFilterMenu,
          ),
          _ActionButton(
            icon: Icons.sort_rounded,
            onPressed: _showSortMenu,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: colorScheme.surface,
            child: const TodoCategoryChips(),
          ),
          Expanded(
            child: todosAsync.when(
              data: (todos) {
                List<Todo> displayTodos;
                List<Todo> displayCompleted = [];

                switch (filter) {
                  case TodoFilter.pending:
                    displayTodos = todos.where((t) => !t.isCompleted).toList();
                    break;
                  case TodoFilter.completed:
                    displayTodos = [];
                    displayCompleted = todos.where((t) => t.isCompleted).toList();
                    break;
                  case TodoFilter.all:
                  default:
                    displayTodos = todos.where((t) => !t.isCompleted).toList();
                    displayCompleted = completedTodos;
                    break;
                }

                if (displayTodos.isEmpty && displayCompleted.isEmpty) {
                  return EmptyTodo(onAdd: _addTodo);
                }

                return Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(todosProvider);
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 16, bottom: 100),
                      itemCount: displayTodos.length + (displayCompleted.isNotEmpty ? 1 : 0) + displayCompleted.length,
                      itemBuilder: (context, index) {
                        if (index < displayTodos.length) {
                          final todo = displayTodos[index];
                          if (index == 0) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          '待办 ${displayTodos.length}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: TodoListTile(
                                    todo: todo,
                                    onToggle: () => _toggleComplete(todo),
                                    onTap: () => _editTodo(todo),
                                    onLongPress: () => _showOptions(context, todo),
                                  ),
                                ),
                              ],
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TodoListTile(
                              todo: todo,
                              onToggle: () => _toggleComplete(todo),
                              onTap: () => _editTodo(todo),
                              onLongPress: () => _showOptions(context, todo),
                            ),
                          );
                        }

                        final completedIndex = index - displayTodos.length;
                        if (completedIndex == 0 && displayCompleted.isNotEmpty) {
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
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: colorScheme.error),
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
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF11998E).withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _addTodo,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF667EEA).withOpacity(0.08)
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF667EEA).withOpacity(0.3)
                    : Colors.grey.shade100,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF667EEA).withOpacity(0.15)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? const Color(0xFF667EEA)
                        : Colors.grey.shade600,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: isSelected
                              ? const Color(0xFF667EEA)
                              : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isSelected
                      ? Container(
                          key: const ValueKey('check'),
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFF667EEA),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 14,
                          ),
                        )
                      : const SizedBox.shrink(key: ValueKey('empty')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

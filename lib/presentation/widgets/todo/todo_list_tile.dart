import 'package:flutter/material.dart';
import '../../../domain/entities/todo.dart';

class TodoListTile extends StatelessWidget {
  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const TodoListTile({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onTap,
    required this.onLongPress,
  });

  static const _categoryColors = {
    '工作': Color(0xFF4F46E5),
    '生活': Color(0xFF10B981),
    '学习': Color(0xFFF59E0B),
    '杂项': Color(0xFF6B7280),
  };

  Color get _categoryColor =>
      _categoryColors[todo.category] ?? _categoryColors['杂项']!;

  bool get _isOverdue {
    if (todo.dueDate == null || todo.isCompleted) return false;
    return todo.dueDate!.isBefore(DateTime.now());
  }

  bool get _isDueToday {
    if (todo.dueDate == null || todo.isCompleted) return false;
    final now = DateTime.now();
    return todo.dueDate!.year == now.year &&
        todo.dueDate!.month == now.month &&
        todo.dueDate!.day == now.day;
  }

  String _formatDueDate() {
    if (todo.dueDate == null) return '';
    return '${todo.dueDate!.year}-${todo.dueDate!.month.toString().padLeft(2, '0')}-${todo.dueDate!.day.toString().padLeft(2, '0')} ${todo.dueDate!.hour.toString().padLeft(2, '0')}:${todo.dueDate!.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('todo_${todo.id}'),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: Colors.blue.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onTap();
          return false;
        } else {
          return await _confirmDelete(context);
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          // 删除由父组件处理
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // 勾选框
                GestureDetector(
                  onTap: onToggle,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: todo.isCompleted
                          ? _categoryColor
                          : Colors.transparent,
                      border: Border.all(
                        color: todo.isCompleted
                            ? _categoryColor
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: todo.isCompleted
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                // 内容
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todo.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          decoration: todo.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: todo.isCompleted
                              ? Colors.grey
                              : Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (todo.dueDate != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '截止: ${_formatDueDate()}',
                          style: TextStyle(
                            fontSize: 12,
                            color: _isOverdue
                                ? Colors.red
                                : _isDueToday
                                    ? Colors.orange
                                    : Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // 分类标签
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _categoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    todo.category,
                    style: TextStyle(
                      fontSize: 12,
                      color: _categoryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
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
    return result ?? false;
  }
}

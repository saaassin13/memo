import 'package:flutter/material.dart';
import '../../../domain/entities/todo.dart';

class TodoListTile extends StatelessWidget {
  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback? onDelete;

  const TodoListTile({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onTap,
    required this.onLongPress,
    this.onDelete,
  });

  static const _categoryColors = {
    '工作': Color(0xFF4F46E5),
    '生活': Color(0xFF10B981),
    '学习': Color(0xFFF59E0B),
    '杂项': Color(0xFF6B7280),
  };

  static const _categoryIcons = {
    '工作': Icons.work_rounded,
    '生活': Icons.home_rounded,
    '学习': Icons.school_rounded,
    '杂项': Icons.more_horiz_rounded,
  };

  Color get _categoryColor =>
      _categoryColors[todo.category] ?? _categoryColors['杂项']!;

  IconData get _categoryIcon =>
      _categoryIcons[todo.category] ?? Icons.label_rounded;

  bool get _isOverdue {
    if (todo.dueDate == null || todo.isCompleted) return false;
    return todo.dueDate!.isBefore(DateTime.now());
  }

  int get _daysUntilDue {
    if (todo.dueDate == null) return 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(todo.dueDate!.year, todo.dueDate!.month, todo.dueDate!.day);
    return due.difference(today).inDays;
  }

  String _formatDueDate() {
    if (todo.dueDate == null) return '';

    final days = _daysUntilDue;

    if (todo.isCompleted) {
      return '${todo.dueDate!.month.toString().padLeft(2, '0')}-${todo.dueDate!.day.toString().padLeft(2, '0')} ${todo.dueDate!.hour.toString().padLeft(2, '0')}:${todo.dueDate!.minute.toString().padLeft(2, '0')}';
    }

    if (days < 0) {
      final overdueDays = -days;
      if (overdueDays == 1) {
        return '逾期 1 天';
      } else if (overdueDays <= 7) {
        return '逾期 $overdueDays 天';
      } else {
        return '逾期 7+ 天';
      }
    } else if (days == 0) {
      return '今天 ${todo.dueDate!.hour.toString().padLeft(2, '0')}:${todo.dueDate!.minute.toString().padLeft(2, '0')}';
    } else if (days == 1) {
      return '明天 ${todo.dueDate!.hour.toString().padLeft(2, '0')}:${todo.dueDate!.minute.toString().padLeft(2, '0')}';
    } else if (days <= 7) {
      return '$days 天后';
    } else {
      return '${todo.dueDate!.month.toString().padLeft(2, '0')}-${todo.dueDate!.day.toString().padLeft(2, '0')} ${todo.dueDate!.hour.toString().padLeft(2, '0')}:${todo.dueDate!.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key('todo_${todo.id}'),
        direction: DismissDirection.horizontal,
        background: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _categoryColor.withOpacity(0.8),
                _categoryColor,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            children: [
              Icon(Icons.edit_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text(
                '编辑',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        secondaryBackground: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '删除',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.delete_rounded, color: Colors.white),
            ],
          ),
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
          if (direction == DismissDirection.endToStart && onDelete != null) {
            onDelete!();
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              onLongPress: onLongPress,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // 勾选框
                    GestureDetector(
                      onTap: onToggle,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: todo.isCompleted
                              ? _categoryColor
                              : Colors.transparent,
                          border: Border.all(
                            color: todo.isCompleted
                                ? _categoryColor
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                          boxShadow: todo.isCompleted
                              ? [
                                  BoxShadow(
                                    color: _categoryColor.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: todo.isCompleted
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 14),
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
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  _isOverdue
                                      ? Icons.warning_rounded
                                      : _daysUntilDue <= 1
                                          ? Icons.schedule_rounded
                                          : Icons.calendar_today_rounded,
                                  size: 14,
                                  color: _isOverdue
                                      ? Colors.red
                                      : _daysUntilDue == 0
                                          ? Colors.orange
                                          : _daysUntilDue <= 3
                                              ? Colors.orange.shade400
                                              : Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDueDate(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _isOverdue
                                        ? Colors.red
                                        : _daysUntilDue == 0
                                            ? Colors.orange
                                            : _daysUntilDue <= 3
                                                ? Colors.orange.shade400
                                                : Colors.grey,
                                    fontWeight: _isOverdue || _daysUntilDue == 0
                                        ? FontWeight.w500
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 分类标签
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _categoryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _categoryColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _categoryIcon,
                            size: 12,
                            color: _categoryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            todo.category,
                            style: TextStyle(
                              fontSize: 11,
                              color: _categoryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
    return result ?? false;
  }
}

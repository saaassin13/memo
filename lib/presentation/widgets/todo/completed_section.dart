import 'package:flutter/material.dart';
import '../../../domain/entities/todo.dart';
import 'todo_list_tile.dart';

class CompletedSection extends StatefulWidget {
  final List<Todo> completedTodos;
  final Function(Todo) onToggle;
  final Function(Todo) onTap;
  final Function(Todo) onDelete;

  const CompletedSection({
    super.key,
    required this.completedTodos,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<CompletedSection> createState() => _CompletedSectionState();
}

class _CompletedSectionState extends State<CompletedSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.completedTodos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // 折叠标题
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  '已完成 (${widget.completedTodos.length})',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
        // 已完成列表
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            children: widget.completedTodos.map((todo) {
              return TodoListTile(
                todo: todo,
                onToggle: () => widget.onToggle(todo),
                onTap: () => widget.onTap(todo),
                onLongPress: () => _showOptions(context, todo),
                onDelete: () => widget.onDelete(todo),
              );
            }).toList(),
          ),
          crossFadeState:
              _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
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
                widget.onTap(todo);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red.shade400),
              title: Text('删除', style: TextStyle(color: Colors.red.shade400)),
              onTap: () {
                Navigator.pop(context);
                widget.onDelete(todo);
              },
            ),
          ],
        ),
      ),
    );
  }
}

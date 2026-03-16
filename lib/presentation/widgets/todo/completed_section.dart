import 'package:flutter/material.dart';
import '../../../domain/entities/todo.dart';
import 'todo_list_tile.dart';

class CompletedSection extends StatefulWidget {
  final List<Todo> completedTodos;
  final Function(Todo) onToggle;
  final Function(Todo) onTap;
  final Function(Todo) onDelete;
  final Function(Todo)? onPin;
  final Function(Todo)? onEdit;

  const CompletedSection({
    super.key,
    required this.completedTodos,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
    this.onPin,
    this.onEdit,
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
                onEdit: widget.onEdit != null ? () => widget.onEdit!(todo) : null,
                onDelete: () => widget.onDelete(todo),
                onPin: widget.onPin != null ? () => widget.onPin!(todo) : null,
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
}

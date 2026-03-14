import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/todo.dart';
import '../../providers/todo_providers.dart';
import '../../providers/repository_providers.dart';
import '../common/date_time_picker.dart';

class TodoEditDialog extends ConsumerStatefulWidget {
  final Todo? todo;
  final String? initialCategory;

  const TodoEditDialog({super.key, this.todo, this.initialCategory});

  @override
  ConsumerState<TodoEditDialog> createState() => _TodoEditDialogState();
}

class _TodoEditDialogState extends ConsumerState<TodoEditDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  String _category = '杂项';
  DateTime? _dueDate;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  bool get isEditing => widget.todo != null;

  static const _categories = ['工作', '生活', '学习', '杂项'];

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

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.todo?.description ?? '');
    _category = widget.todo?.category ?? widget.initialCategory ?? '杂项';
    _dueDate = widget.todo?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final result = await DateTimePickerHelper.show(
      context,
      initialDateTime: _dueDate,
      minimumDate: DateTime.now().subtract(const Duration(days: 365)),
      maximumDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (result != null && mounted) {
      setState(() {
        _dueDate = result;
      });
    }
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('请输入任务标题'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(todoRepositoryProvider);
      final now = DateTime.now();

      if (isEditing) {
        final updated = widget.todo!.copyWith(
          title: title,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          category: _category,
          dueDate: _dueDate,
          updatedAt: now,
        );
        await repository.update(updated);
      } else {
        final newTodo = Todo(
          title: title,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          category: _category,
          dueDate: _dueDate,
          createdAt: now,
          updatedAt: now,
        );
        await repository.insert(newTodo);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败: $e'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDueDate() {
    if (_dueDate == null) return '选择日期和时间';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(_dueDate!.year, _dueDate!.month, _dueDate!.day);
    final days = due.difference(today).inDays;

    if (days < 0) {
      final overdueDays = -days;
      return '逾期 ${overdueDays}天';
    } else if (days == 0) {
      return '今天 ${_dueDate!.hour.toString().padLeft(2, '0')}:${_dueDate!.minute.toString().padLeft(2, '0')}';
    } else if (days == 1) {
      return '明天 ${_dueDate!.hour.toString().padLeft(2, '0')}:${_dueDate!.minute.toString().padLeft(2, '0')}';
    } else if (days <= 7) {
      return '$days 天后';
    } else {
      return '${_dueDate!.month.toString().padLeft(2, '0')}-${_dueDate!.day.toString().padLeft(2, '0')} ${_dueDate!.hour.toString().padLeft(2, '0')}:${_dueDate!.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxHeight: 580),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题栏
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 20, 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF11998E).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      isEditing ? Icons.edit_rounded : Icons.add_task_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? '编辑待办' : '新建待办',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isEditing ? '修改任务信息' : '添加新的任务',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // 内容
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 任务标题
                    _SectionLabel(label: '任务标题'),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _titleController,
                      autofocus: true,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: '输入任务标题...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.normal,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFF667EEA),
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                        counterStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                        ),
                      ),
                      maxLength: 100,
                    ),
                    const SizedBox(height: 20),
                    // 截止时间
                    _SectionLabel(label: '截止时间'),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: _selectDueDate,
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: _dueDate != null
                              ? const Color(0xFF667EEA).withOpacity(0.06)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _dueDate != null
                                ? const Color(0xFF667EEA).withOpacity(0.3)
                                : Colors.grey.shade200,
                          ),
                          boxShadow: _dueDate != null
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF667EEA).withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _dueDate != null
                                    ? const Color(0xFF667EEA).withOpacity(0.12)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.calendar_today_rounded,
                                size: 18,
                                color: _dueDate != null
                                    ? const Color(0xFF667EEA)
                                    : Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  color: _dueDate != null
                                      ? Colors.black87
                                      : Colors.grey.shade500,
                                  fontSize: 15,
                                  fontWeight: _dueDate != null
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                                ),
                                child: Text(_formatDueDate()),
                              ),
                            ),
                            if (_dueDate != null)
                              GestureDetector(
                                onTap: () => setState(() => _dueDate = null),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    size: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              )
                            else
                              Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.grey.shade400,
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 分类
                    _SectionLabel(label: '分类'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _categories.map((cat) {
                        final isSelected = _category == cat;
                        final color = _categoryColors[cat]!;
                        final icon = _categoryIcons[cat]!;
                        return GestureDetector(
                          onTap: () => setState(() => _category = cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? color.withOpacity(0.12) : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? color : Colors.grey.shade200,
                                width: isSelected ? 1.5 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: color.withOpacity(0.15),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: Icon(
                                    isSelected ? Icons.check_circle : icon,
                                    key: ValueKey('$cat-$isSelected'),
                                    size: 16,
                                    color: isSelected ? color : Colors.grey.shade500,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  cat,
                                  style: TextStyle(
                                    color: isSelected ? color : Colors.grey.shade600,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    // 备注
                    _SectionLabel(label: '备注'),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _descriptionController,
                      textInputAction: TextInputAction.done,
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: '输入备注（可选）...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.normal,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFF667EEA),
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                        counterStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                        ),
                      ),
                      maxLines: 3,
                      maxLength: 500,
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            // 按钮
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: const Text('取消'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF11998E).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                '保存',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade600,
      ),
    );
  }
}

// 显示编辑弹窗的辅助函数
Future<bool?> showTodoEditDialog(BuildContext context, {Todo? todo, String? initialCategory}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => TodoEditDialog(todo: todo, initialCategory: initialCategory),
  );
}

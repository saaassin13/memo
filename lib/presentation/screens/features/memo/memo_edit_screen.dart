import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../providers/memo_edit_provider.dart';

class MemoEditScreen extends ConsumerStatefulWidget {
  final int? memoId;
  final String? initialCategory;

  const MemoEditScreen({super.key, this.memoId, this.initialCategory});

  @override
  ConsumerState<MemoEditScreen> createState() => _MemoEditScreenState();
}

class _MemoEditScreenState extends ConsumerState<MemoEditScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _titleFocus = FocusNode();
  final _contentFocus = FocusNode();
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.memoId != null) {
        ref.read(memoEditProvider.notifier).loadMemo(widget.memoId!);
      } else {
        ref.read(memoEditProvider.notifier).initNew();
        // 设置初始分类
        if (widget.initialCategory != null && widget.initialCategory!.isNotEmpty) {
          ref.read(memoEditProvider.notifier).setCategory(widget.initialCategory);
        }
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _titleFocus.dispose();
    _contentFocus.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('提示'),
        content: const Text('有未保存的更改，是否保存？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('不保存'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              final success = await ref.read(memoEditProvider.notifier).save();
              if (success && ctx.mounted) {
                Navigator.pop(ctx, true);
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Future<void> _save() async {
    ref.read(memoEditProvider.notifier).setTitle(_titleController.text);
    ref.read(memoEditProvider.notifier).setContent(_contentController.text);

    final success = await ref.read(memoEditProvider.notifier).save();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存成功')),
      );
      context.pop();
    } else if (mounted) {
      final error = ref.read(memoEditProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? '保存失败')),
      );
    }
  }

  void _showDeleteConfirm() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除备忘录'),
        content: const Text('确定要删除这条备忘录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref.read(memoEditProvider.notifier).delete();
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已删除')),
                );
                context.pop();
              }
            },
            child: Text('删除', style: TextStyle(color: Colors.red.shade400)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final editState = ref.watch(memoEditProvider);
    final isEditing = widget.memoId != null;

    // 同步控制器内容
    if (editState.title.isNotEmpty && _titleController.text.isEmpty) {
      _titleController.text = editState.title;
    }
    if (editState.content.isNotEmpty && _contentController.text.isEmpty) {
      _contentController.text = editState.content;
    }

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (_hasChanges) {
                final shouldPop = await _onWillPop();
                if (shouldPop && context.mounted) {
                  context.pop();
                }
              } else {
                context.pop();
              }
            },
          ),
          title: Text(isEditing ? '编辑备忘录' : '新建备忘录'),
          actions: [
            if (isEditing)
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                onPressed: _showDeleteConfirm,
              ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilledButton(
                onPressed: editState.isLoading ? null : _save,
                child: editState.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('保存'),
              ),
            ),
          ],
        ),
        body: editState.isLoading && isEditing
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 标题输入
                          TextField(
                            controller: _titleController,
                            focusNode: _titleFocus,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              hintText: '标题',
                              hintStyle: TextStyle(
                                color: colorScheme.outline,
                                fontWeight: FontWeight.normal,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            maxLength: 100,
                            textInputAction: TextInputAction.next,
                            onSubmitted: (_) {
                              _contentFocus.requestFocus();
                            },
                            onChanged: (_) => _onChanged(),
                          ),
                          const Divider(height: 1),
                          const SizedBox(height: 12),
                          // 内容输入
                          TextField(
                            controller: _contentController,
                            focusNode: _contentFocus,
                            style: const TextStyle(fontSize: 16, height: 1.6),
                            decoration: InputDecoration(
                              hintText: '开始记录...',
                              hintStyle: TextStyle(color: colorScheme.outline),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            maxLines: null,
                            minLines: 10,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            onChanged: (_) => _onChanged(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 底部工具栏
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      border: Border(
                        top: BorderSide(
                          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 分类选择
                            Row(
                              children: [
                                Icon(
                                  Icons.category_outlined,
                                  size: 18,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        _CategoryChip(
                                          label: '工作',
                                          color: const Color(0xFF4F46E5),
                                          isSelected: editState.category == '工作',
                                          onTap: () {
                                            ref.read(memoEditProvider.notifier).setCategory('工作');
                                            _onChanged();
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        _CategoryChip(
                                          label: '生活',
                                          color: const Color(0xFF10B981),
                                          isSelected: editState.category == '生活',
                                          onTap: () {
                                            ref.read(memoEditProvider.notifier).setCategory('生活');
                                            _onChanged();
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        _CategoryChip(
                                          label: '学习',
                                          color: const Color(0xFFF59E0B),
                                          isSelected: editState.category == '学习',
                                          onTap: () {
                                            ref.read(memoEditProvider.notifier).setCategory('学习');
                                            _onChanged();
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        _CategoryChip(
                                          label: '杂项',
                                          color: const Color(0xFF6B7280),
                                          isSelected: editState.category == '杂项',
                                          onTap: () {
                                            ref.read(memoEditProvider.notifier).setCategory('杂项');
                                            _onChanged();
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // 提醒和置顶
                            Row(
                              children: [
                                // 提醒时间
                                Expanded(
                                  child: _ActionButton(
                                    icon: Icons.alarm,
                                    label: editState.remindTime != null
                                        ? DateFormat('MM-dd HH:mm').format(editState.remindTime!)
                                        : '提醒',
                                    isActive: editState.remindTime != null,
                                    onTap: () => _selectRemindTime(editState.remindTime),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // 置顶
                                Expanded(
                                  child: _ActionButton(
                                    icon: Icons.push_pin,
                                    label: editState.isPinned ? '已置顶' : '置顶',
                                    isActive: editState.isPinned,
                                    onTap: () {
                                      ref.read(memoEditProvider.notifier).setPinned(!editState.isPinned);
                                      _onChanged();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _selectRemindTime(DateTime? current) async {
    final date = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(current ?? DateTime.now()),
      );
      if (time != null) {
        ref.read(memoEditProvider.notifier).setRemindTime(DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        ));
        _onChanged();
      }
    }
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isSelected ? color : Colors.grey.shade600,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeColor = const Color(0xFF667EEA);

    return Material(
      color: isActive ? activeColor.withValues(alpha: 0.1) : colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isActive ? activeColor : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: isActive ? activeColor : colorScheme.onSurfaceVariant,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

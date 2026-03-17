import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/goal.dart';
import '../../providers/repository_providers.dart';

class GoalEditDialog extends ConsumerStatefulWidget {
  final Goal? goal;

  const GoalEditDialog({super.key, this.goal});

  static Future<void> show(BuildContext context, {Goal? goal}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GoalEditDialog(goal: goal),
    );
  }

  @override
  ConsumerState<GoalEditDialog> createState() => _GoalEditDialogState();
}

class _GoalEditDialogState extends ConsumerState<GoalEditDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _notesController;
  late final TextEditingController _stepsController;
  late GoalProgressType _progressType;
  DateTime? _deadline;
  bool _isLoading = false;

  bool get isEditing => widget.goal != null;

  // 百分比类型不允许修改目标值
  bool get _isTargetEditable => _progressType != GoalProgressType.percent;
  // 天数类型自动计算截止日期
  bool get _showDeadlinePicker => _progressType != GoalProgressType.days;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.goal?.name ?? '');
    _notesController = TextEditingController(text: widget.goal?.notes ?? '');
    _progressType = widget.goal?.progressType ?? GoalProgressType.percent;
    _stepsController = TextEditingController(
      text: (widget.goal?.totalSteps ?? _progressType.defaultTotal).toString(),
    );
    _deadline = widget.goal?.deadline;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    _stepsController.dispose();
    super.dispose();
  }

  void _onProgressTypeChanged(GoalProgressType type) {
    setState(() {
      _progressType = type;
      if (!isEditing) {
        if (type == GoalProgressType.percent) {
          _stepsController.text = '100';
        } else {
          _stepsController.text = type.defaultTotal.toString();
        }
        // 天数类型自动计算截止日期，清除手动选择
        if (type == GoalProgressType.days) {
          _deadline = null;
        }
      }
    });
  }

  // 获取截止日期：天数类型自动计算，其他类型使用手动选择
  DateTime? _getDeadline() {
    if (_progressType == GoalProgressType.days) {
      final days = int.tryParse(_stepsController.text) ?? _progressType.defaultTotal;
      return DateTime.now().add(Duration(days: days));
    }
    return _deadline;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 14),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                isEditing ? '编辑目标' : '新建目标',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 目标名称
                  _buildLabel('目标名称'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: '输入目标名称...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 进度类型选择
                  _buildLabel('进度类型'),
                  const SizedBox(height: 8),
                  Row(
                    children: GoalProgressType.values.map((type) {
                      final isSelected = _progressType == type;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => _onProgressTypeChanged(type),
                          child: Container(
                            margin: EdgeInsets.only(
                              right: type != GoalProgressType.values.last ? 8 : 0,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey.shade200,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              type.label,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                color: isSelected ? Colors.white : Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  // 目标值（百分比类型固定100，不可编辑）
                  if (_isTargetEditable) ...[
                    _buildLabel(_getTargetLabel()),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _stepsController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        hintText: _getHintText(),
                        suffixText: _getSuffixText(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ] else ...[
                    // 百分比类型显示固定值
                    _buildLabel('目标百分比'),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Text(
                        '100%',
                        style: TextStyle(fontSize: 15, color: Colors.black54, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  // 截止日期（天数类型自动计算，不显示选择器）
                  if (_showDeadlinePicker) ...[
                    _buildLabel('截止日期 (可选)'),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickDeadline,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_rounded, size: 18, color: Colors.grey.shade600),
                            const SizedBox(width: 10),
                            Text(
                              _deadline != null
                                  ? '${_deadline!.year}年${_deadline!.month}月${_deadline!.day}日'
                                  : '选择截止日期',
                              style: TextStyle(
                                fontSize: 14,
                                color: _deadline != null ? Colors.black87 : Colors.grey.shade400,
                              ),
                            ),
                            const Spacer(),
                            if (_deadline != null)
                              GestureDetector(
                                onTap: () => setState(() => _deadline = null),
                                child: Icon(Icons.close_rounded, size: 18, color: Colors.grey.shade400),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ] else if (_progressType == GoalProgressType.days) ...[
                    // 天数类型显示自动计算的截止日期
                    _buildLabel('截止日期 (自动计算)'),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F0FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFF8B5CF6)),
                          const SizedBox(width: 10),
                          Text(
                            _formatDate(_getDeadline()),
                            style: const TextStyle(fontSize: 14, color: Color(0xFF8B5CF6), fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  // 备注输入
                  _buildLabel('备注 (可选)'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    maxLength: 200,
                    decoration: InputDecoration(
                      hintText: '输入备注信息...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // 操作按钮
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('取消'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: FilledButton(
                            onPressed: _isLoading ? null : _save,
                            style: FilledButton.styleFrom(
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
                                : Text(
                                    isEditing ? '保存' : '创建目标',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
    );
  }

  String _getTargetLabel() {
    switch (_progressType) {
      case GoalProgressType.percent:
        return '目标百分比';
      case GoalProgressType.count:
        return '目标次数';
      case GoalProgressType.days:
        return '目标天数';
    }
  }

  String _getHintText() {
    switch (_progressType) {
      case GoalProgressType.percent:
        return '100';
      case GoalProgressType.count:
        return '10';
      case GoalProgressType.days:
        return '30';
    }
  }

  String _getSuffixText() {
    switch (_progressType) {
      case GoalProgressType.percent:
        return '%';
      case GoalProgressType.count:
        return '次';
      case GoalProgressType.days:
        return '天';
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '未设置';
    return '${date.year}年${date.month}月${date.day}日';
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _deadline = picked);
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入目标名称')),
      );
      return;
    }

    int totalSteps;
    if (_progressType == GoalProgressType.percent) {
      totalSteps = 100;
    } else {
      totalSteps = int.tryParse(_stepsController.text) ?? _progressType.defaultTotal;
      if (totalSteps <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_getTargetLabel()}必须大于0')),
        );
        return;
      }
    }

    final deadline = _getDeadline();
    final notes = _notesController.text.trim();

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(goalRepositoryProvider);
      final now = DateTime.now();

      if (isEditing) {
        final updated = widget.goal!.copyWith(
          name: name,
          notes: notes,
          progressType: _progressType,
          totalSteps: totalSteps,
          deadline: deadline,
          updatedAt: now,
        );
        await repository.update(updated);
      } else {
        await repository.insert(Goal(
          name: name,
          notes: notes,
          progressType: _progressType,
          totalSteps: totalSteps,
          deadline: deadline,
          createdAt: now,
          updatedAt: now,
        ));
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEditing ? '已更新' : '已创建')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/weight_providers.dart';
import '../../../providers/repository_providers.dart';
import '../../../../domain/entities/weight.dart';

class WeightEditScreen extends ConsumerStatefulWidget {
  final DateTime? date;
  final Weight? weight;

  const WeightEditScreen({super.key, this.date, this.weight});

  bool get isEditing => weight != null;

  @override
  ConsumerState<WeightEditScreen> createState() => _WeightEditScreenState();
}

class _WeightEditScreenState extends ConsumerState<WeightEditScreen> {
  final _weightController = TextEditingController();
  final _bodyFatController = TextEditingController();
  final _durationController = TextEditingController();
  final _notesController = TextEditingController();
  late DateTime _selectedDate;
  bool _exercised = false;
  String _exerciseType = '';

  static const _primaryPurple = Color(0xFF8B5CF6);
  static const _lightPurple = Color(0xFFF3F0FF);
  static const _softPurple = Color(0xFFE9E0FF);
  static const _successGreen = Color(0xFF34D399);
  static const _dangerRed = Color(0xFFF87171);
  static const _creamBg = Color(0xFFFAFAFA);

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.date ?? DateTime.now();
    if (widget.isEditing) {
      final w = widget.weight!;
      _weightController.text = w.value.toString();
      if (w.bodyFat != null) _bodyFatController.text = w.bodyFat!.toString();
      _exercised = w.exercised;
      _exerciseType = w.exerciseType;
      if (w.exerciseDuration > 0) _durationController.text = w.exerciseDuration.toString();
      if (w.notes.isNotEmpty) _notesController.text = w.notes;
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _bodyFatController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      locale: const Locale('zh', 'CN'),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    final weightStr = _weightController.text.trim();
    if (weightStr.isEmpty) {
      _showSnackBar('请输入体重');
      return;
    }

    final weightValue = double.tryParse(weightStr);
    if (weightValue == null || weightValue <= 0 || weightValue > 500) {
      _showSnackBar('请输入有效的体重');
      return;
    }

    final bodyFatStr = _bodyFatController.text.trim();
    final bodyFat = bodyFatStr.isNotEmpty ? double.tryParse(bodyFatStr) : null;
    final durationStr = _durationController.text.trim();
    final duration = durationStr.isNotEmpty ? (int.tryParse(durationStr) ?? 0) : 0;

    final repository = ref.read(weightRepositoryProvider);
    final now = DateTime.now();
    final selectedDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    Weight? targetWeight = widget.weight;

    if (!widget.isEditing) {
      final existing = await repository.getByDate(selectedDate);
      if (existing != null) {
        targetWeight = existing;
      }
    }

    final weight = Weight(
      id: targetWeight?.id,
      value: weightValue,
      bodyFat: bodyFat,
      exercised: _exercised,
      exerciseType: _exercised ? _exerciseType : '',
      exerciseDuration: duration,
      notes: _notesController.text.trim(),
      date: selectedDate,
      createdAt: targetWeight?.createdAt ?? now,
    );

    if (targetWeight != null) {
      await repository.update(weight);
    } else {
      await repository.insert(weight);
    }

    if (mounted) {
      Navigator.pop(context);
      _showSnackBar(targetWeight != null ? '已更新' : '已保存');
    }
  }

  Future<void> _delete() async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.delete_outline_rounded, size: 40, color: _dangerRed),
            const SizedBox(height: 12),
            const Text('删除记录', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('确定要删除这条体重记录吗？',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _PillButton(
                    label: '取消',
                    onTap: () => Navigator.pop(context, false),
                    filled: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PillButton(
                    label: '删除',
                    onTap: () => Navigator.pop(context, true),
                    filled: true,
                    color: _dangerRed,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;

    final repository = ref.read(weightRepositoryProvider);
    await repository.delete(widget.weight!.id!);

    if (mounted) {
      Navigator.pop(context);
      _showSnackBar('已删除');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.grey.shade800,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _creamBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isEditing ? '编辑记录' : '记录体重',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _PillButton(
              label: '保存',
              onTap: _save,
              filled: true,
              color: _primaryPurple,
              compact: true,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 日期选择 - 药丸样式
            _SectionCard(
              icon: Icons.calendar_today_rounded,
              title: '日期',
              child: GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: _lightPurple,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.edit_calendar_rounded, size: 18, color: _primaryPurple),
                      const SizedBox(width: 8),
                      Text(
                        '${_selectedDate.year}年${_selectedDate.month}月${_selectedDate.day}日',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: _primaryPurple,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 体重 + 体脂 - 合并卡片
            _SectionCard(
              icon: Icons.monitor_weight_rounded,
              title: '身体数据',
              child: Column(
                children: [
                  _NumberInput(
                    controller: _weightController,
                    label: '体重',
                    unit: 'kg',
                    hint: '65.5',
                    isRequired: true,
                    decimal: true,
                  ),
                  const SizedBox(height: 12),
                  _NumberInput(
                    controller: _bodyFatController,
                    label: '体脂率',
                    unit: '%',
                    hint: '18.5',
                    isRequired: false,
                    decimal: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 运动 - 卡片
            _SectionCard(
              icon: Icons.fitness_center_rounded,
              title: '运动',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 开关
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _exercised ? '今日已运动' : '今日未运动',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: _exercised ? FontWeight.w600 : FontWeight.normal,
                            color: _exercised ? _successGreen : Colors.grey.shade600,
                          ),
                        ),
                      ),
                      Transform.scale(
                        scale: 0.85,
                        child: Switch(
                          value: _exercised,
                          onChanged: (v) => setState(() => _exercised = v),
                          activeColor: _successGreen,
                          activeTrackColor: _successGreen.withOpacity(0.3),
                          inactiveThumbColor: Colors.grey.shade300,
                          inactiveTrackColor: Colors.grey.shade200,
                        ),
                      ),
                    ],
                  ),
                  if (_exercised) ...[
                    const SizedBox(height: 4),
                    Text('运动类型', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: exerciseTypes.map((type) {
                        final isSelected = _exerciseType == type;
                        return GestureDetector(
                          onTap: () => setState(() => _exerciseType = type),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? _primaryPurple : Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isSelected ? _primaryPurple : Colors.grey.shade200,
                                width: 1.5,
                              ),
                              boxShadow: isSelected
                                  ? [BoxShadow(color: _primaryPurple.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 2))]
                                  : null,
                            ),
                            child: Text(
                              type,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                color: isSelected ? Colors.white : Colors.grey.shade700,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    _NumberInput(
                      controller: _durationController,
                      label: '运动时长',
                      unit: '分钟',
                      hint: '30',
                      isRequired: false,
                      decimal: false,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 备注 - 卡片
            _SectionCard(
              icon: Icons.edit_note_rounded,
              title: '备注',
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  controller: _notesController,
                  maxLines: 3,
                  maxLength: 200,
                  style: const TextStyle(fontSize: 15, height: 1.5),
                  decoration: InputDecoration(
                    hintText: '今天感觉怎么样...',
                    hintStyle: TextStyle(color: Colors.grey.shade300),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    counterStyle: TextStyle(color: Colors.grey.shade300, fontSize: 11),
                  ),
                ),
              ),
            ),

            // 删除按钮
            if (widget.isEditing) ...[
              const SizedBox(height: 24),
              Center(
                child: TextButton.icon(
                  onPressed: _delete,
                  icon: Icon(Icons.delete_outline_rounded, size: 18, color: _dangerRed.withOpacity(0.8)),
                  label: Text('删除记录',
                      style: TextStyle(color: _dangerRed.withOpacity(0.8), fontSize: 14)),
                ),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// 带图标的分组卡片
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard({required this.icon, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F0FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: const Color(0xFF8B5CF6)),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// 简洁数字输入
class _NumberInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String unit;
  final String hint;
  final bool isRequired;
  final bool decimal;

  const _NumberInput({
    required this.controller,
    required this.label,
    required this.unit,
    required this.hint,
    required this.isRequired,
    required this.decimal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Text(
            label + (isRequired ? ' *' : ''),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 90,
            child: TextField(
              controller: controller,
              keyboardType: decimal
                  ? const TextInputType.numberWithOptions(decimal: true)
                  : TextInputType.number,
              inputFormatters: decimal
                  ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}'))]
                  : [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w300,
                letterSpacing: -0.5,
                color: Color(0xFF8B5CF6),
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w300, color: Colors.grey.shade300),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(unit,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// 药丸形按钮
class _PillButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool filled;
  final Color color;
  final bool compact;

  const _PillButton({
    required this.label,
    required this.onTap,
    this.filled = false,
    this.color = const Color(0xFF8B5CF6),
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 16 : 24,
          vertical: compact ? 8 : 14,
        ),
        decoration: BoxDecoration(
          color: filled ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          border: filled ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: compact ? 14 : 15,
            fontWeight: FontWeight.w600,
            color: filled ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}

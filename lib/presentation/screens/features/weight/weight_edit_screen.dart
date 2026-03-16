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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('请输入体重'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final weightValue = double.tryParse(weightStr);
    if (weightValue == null || weightValue <= 0 || weightValue > 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('请输入有效的体重'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
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

    // 非编辑模式下，检查同日期是否已有记录
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(targetWeight != null ? '已更新' : '已保存'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条体重记录吗？'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final repository = ref.read(weightRepositoryProvider);
    await repository.delete(widget.weight!.id!);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('已删除'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
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
          TextButton(
            onPressed: _save,
            child: const Text(
              '保存',
              style: TextStyle(
                color: Color(0xFF8B5CF6),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 日期选择
            _SectionLabel(label: '日期'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 20, color: Color(0xFF8B5CF6)),
                    const SizedBox(width: 12),
                    Text(
                      '${_selectedDate.year}年${_selectedDate.month}月${_selectedDate.day}日',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 体重输入
            _SectionLabel(label: '体重 (kg) *'),
            const SizedBox(height: 8),
            TextField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
              ],
              decoration: InputDecoration(
                hintText: '输入体重',
                suffixText: 'kg',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 体脂率
            _SectionLabel(label: '体脂率 (%)'),
            const SizedBox(height: 8),
            TextField(
              controller: _bodyFatController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
              ],
              decoration: InputDecoration(
                hintText: '输入体脂率 (选填)',
                suffixText: '%',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 是否运动
            _SectionLabel(label: '今日运动'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => setState(() => _exercised = !_exercised),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: _exercised ? const Color(0xFF10B981).withOpacity(0.1) : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _exercised ? const Color(0xFF10B981) : Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _exercised ? Icons.check_circle_rounded : Icons.circle_outlined,
                      size: 20,
                      color: _exercised ? const Color(0xFF10B981) : Colors.grey.shade400,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _exercised ? '已运动' : '未运动',
                      style: TextStyle(
                        fontSize: 15,
                        color: _exercised ? const Color(0xFF10B981) : Colors.grey.shade600,
                        fontWeight: _exercised ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_exercised) ...[
              const SizedBox(height: 20),

              // 运动类型
              _SectionLabel(label: '运动类型'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: exerciseTypes.map((type) {
                  final isSelected = _exerciseType == type;
                  return GestureDetector(
                    onTap: () => setState(() => _exerciseType = type),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF8B5CF6).withOpacity(0.15) : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey.shade200,
                        ),
                      ),
                      child: Text(
                        type,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // 运动时长
              _SectionLabel(label: '运动时长 (分钟)'),
              const SizedBox(height: 8),
              TextField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: '输入运动时长',
                  suffixText: '分钟',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),

            // 备注
            _SectionLabel(label: '备注'),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: '添加备注 (选填)',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
                ),
              ),
            ),
            if (widget.isEditing) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _delete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('删除记录'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
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

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
    );
  }
}

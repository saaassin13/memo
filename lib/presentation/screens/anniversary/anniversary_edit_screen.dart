import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/repository_providers.dart';
import '../../../domain/entities/anniversary.dart';
import '../../../core/utils/lunar_calendar.dart';
import '../../widgets/anniversary/lunar_date_picker.dart';

class AnniversaryEditScreen extends ConsumerStatefulWidget {
  final Anniversary? anniversary;

  const AnniversaryEditScreen({super.key, this.anniversary});

  bool get isEditing => anniversary != null;

  @override
  ConsumerState<AnniversaryEditScreen> createState() => _AnniversaryEditScreenState();
}

class _AnniversaryEditScreenState extends ConsumerState<AnniversaryEditScreen> {
  final _titleController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  final _customRelationController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isLunar = false;
  int _reminderDays = 0;
  bool _repeatYearly = true;
  String _relationship = '其他';

  static const _relationships = ['亲人', '爱人', '朋友', '同事', '小孩', '其他'];

  static const _relationshipColors = {
    '亲人': Color(0xFF4F46E5),
    '爱人': Color(0xFFEC4899),
    '朋友': Color(0xFF10B981),
    '同事': Color(0xFF6B7280),
    '小孩': Color(0xFFF59E0B),
    '其他': Color(0xFF8B5CF6),
  };

  static const _reminderOptions = {
    0: '当天',
    1: '提前1天',
    2: '提前2天',
    3: '提前3天',
    7: '提前1周',
    14: '提前2周',
    30: '提前1个月',
  };

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      final a = widget.anniversary!;
      _titleController.text = a.title;
      _selectedDate = a.date;
      _isLunar = a.isLunar;
      _reminderDays = a.reminderDays;
      _repeatYearly = a.repeatYearly;
      _relationship = a.relationship;
      if (a.customRelation != null) {
        _customRelationController.text = a.customRelation!;
      }
      if (a.phoneNumber != null) {
        _phoneController.text = a.phoneNumber!;
      }
      if (a.notes != null) {
        _notesController.text = a.notes!;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    _customRelationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked;
    if (_isLunar) {
      // 选择农历：显示农历日历
      picked = await LunarDatePicker.show(
        context,
        initialDate: _selectedDate,
      );
    } else {
      // 选择公历：显示公历日历
      picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(1900),
        lastDate: DateTime(2100),
        locale: const Locale('zh', 'CN'),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFFF5576C),
              ),
            ),
            child: child!,
          );
        },
      );
    }
    if (picked != null) {
      setState(() {
        _selectedDate = picked!;
      });
    }
  }

  void _showReminderPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '提醒时间',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ..._reminderOptions.entries.map((entry) {
                  return ListTile(
                    title: Text(entry.value),
                    trailing: _reminderDays == entry.key
                        ? const Icon(Icons.check_rounded, color: Color(0xFFF5576C))
                        : null,
                    onTap: () {
                      setState(() {
                        _reminderDays = entry.key;
                      });
                      Navigator.pop(context);
                    },
                  );
                }),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('请输入纪念日名称'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final repository = ref.read(anniversaryRepositoryProvider);
    final now = DateTime.now();

    final anniversary = Anniversary(
      id: widget.isEditing ? widget.anniversary!.id : null,
      title: _titleController.text.trim(),
      date: _selectedDate,
      isLunar: _isLunar,
      reminderDays: _reminderDays,
      repeatYearly: _repeatYearly,
      relationship: _relationship,
      customRelation: _relationship == '其他' && _customRelationController.text.isNotEmpty
          ? _customRelationController.text.trim()
          : null,
      phoneNumber: _phoneController.text.isNotEmpty ? _phoneController.text.trim() : null,
      notes: _notesController.text.isNotEmpty ? _notesController.text.trim() : null,
      createdAt: widget.isEditing ? widget.anniversary!.createdAt : now,
      updatedAt: now,
    );

    if (widget.isEditing) {
      await repository.update(anniversary);
    } else {
      await repository.insert(anniversary);
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEditing ? '已更新' : '已添加'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  String get _formattedDate {
    final month = _selectedDate.month.toString().padLeft(2, '0');
    final day = _selectedDate.day.toString().padLeft(2, '0');
    return '${_selectedDate.year}年$month月$day日';
  }

  String get _lunarDateStr {
    return LunarCalendar.getLunarString(_selectedDate);
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
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isEditing ? '编辑纪念日' : '新增纪念日',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              '保存',
              style: TextStyle(
                color: Color(0xFFF5576C),
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
            // 标题输入
            _SectionLabel(label: '名称'),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: '请输入纪念日名称',
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
                  borderSide: const BorderSide(color: Color(0xFFF5576C)),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 日期选择
            _SectionLabel(label: '日期'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 20, color: Color(0xFFF5576C)),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formattedDate,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _lunarDateStr,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildCalendarTypeButton('公历', false),
                const SizedBox(width: 12),
                _buildCalendarTypeButton('农历', true),
              ],
            ),
            const SizedBox(height: 24),

            // 提醒时间
            _SectionLabel(label: '提醒'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _showReminderPicker,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.notifications_rounded, size: 20, color: Color(0xFFF5576C)),
                    const SizedBox(width: 12),
                    Text(
                      _reminderOptions[_reminderDays] ?? '当天',
                      style: const TextStyle(fontSize: 15),
                    ),
                    const Spacer(),
                    Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 重复
            _SectionLabel(label: '重复'),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildRepeatOption('每年重复', true),
                const SizedBox(width: 12),
                _buildRepeatOption('不重复', false),
              ],
            ),
            const SizedBox(height: 24),

            // 关系
            _SectionLabel(label: '关系'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _relationships.map((rel) {
                final isSelected = _relationship == rel;
                final color = _relationshipColors[rel]!;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _relationship = rel;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? color.withOpacity(0.15) : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? color : Colors.grey.shade200,
                      ),
                    ),
                    child: Text(
                      rel,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? color : Colors.grey.shade700,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            if (_relationship == '其他') ...[
              const SizedBox(height: 12),
              TextField(
                controller: _customRelationController,
                decoration: InputDecoration(
                  hintText: '输入自定义关系名称',
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
                    borderSide: const BorderSide(color: Color(0xFFF5576C)),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),

            // 手机号
            _SectionLabel(label: '手机号（选填）'),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              decoration: InputDecoration(
                hintText: '输入手机号',
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
                  borderSide: const BorderSide(color: Color(0xFFF5576C)),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 备注
            _SectionLabel(label: '备忘（选填）'),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: '添加备注信息',
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
                  borderSide: const BorderSide(color: Color(0xFFF5576C)),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildRepeatOption(String label, bool value) {
    final isSelected = _repeatYearly == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _repeatYearly = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF5576C).withOpacity(0.15) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFFF5576C) : Colors.grey.shade200,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? const Color(0xFFF5576C) : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarTypeButton(String label, bool isLunarType) {
    final isSelected = isLunarType == _isLunar;
    return GestureDetector(
      onTap: () {
        setState(() {
          _isLunar = isLunarType;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF5576C).withOpacity(0.15) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFFF5576C) : Colors.grey.shade200,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(right: 6),
                child: Icon(Icons.check_rounded, size: 16, color: Color(0xFFF5576C)),
              ),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? const Color(0xFFF5576C) : Colors.grey.shade700,
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
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/diary_providers.dart';
import '../../../providers/repository_providers.dart';
import '../../../../domain/entities/diary.dart';

class DiaryEditScreen extends ConsumerStatefulWidget {
  final DateTime date;
  final Diary? diary;

  const DiaryEditScreen({
    super.key,
    required this.date,
    this.diary,
  });

  @override
  ConsumerState<DiaryEditScreen> createState() => _DiaryEditScreenState();
}

class _DiaryEditScreenState extends ConsumerState<DiaryEditScreen> {
  final _contentController = TextEditingController();
  String _label = '';
  String _mood = '';
  Timer? _saveTimer;
  bool _isSaving = false;
  bool _hasSaved = false;
  int? _diaryId;
  late DateTime _createdAt;

  static const List<String> _weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  @override
  void initState() {
    super.initState();
    if (widget.diary != null) {
      final d = widget.diary!;
      _contentController.text = d.content;
      _label = d.label;
      _mood = d.mood;
      _diaryId = d.id;
      _createdAt = d.createdAt;
    } else {
      _createdAt = DateTime.now();
    }
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _contentController.dispose();
    super.dispose();
  }

  void _onContentChanged(String content) {
    _scheduleSave();
  }

  void _scheduleSave() {
    _saveTimer?.cancel();
    setState(() {
      _isSaving = true;
      _hasSaved = false;
    });
    _saveTimer = Timer(const Duration(milliseconds: 1500), () {
      _save();
    });
  }

  Future<void> _save() async {
    final content = _contentController.text;
    // 如果没有任何内容，不保存
    if (content.isEmpty && _label.isEmpty && _mood.isEmpty) {
      setState(() {
        _isSaving = false;
      });
      return;
    }

    final repository = ref.read(diaryRepositoryProvider);
    final now = DateTime.now();

    try {
      final diary = Diary(
        id: _diaryId,
        date: DateTime(widget.date.year, widget.date.month, widget.date.day),
        content: content,
        label: _label,
        mood: _mood,
        createdAt: _createdAt,
        updatedAt: now,
      );

      if (_diaryId == null) {
        final id = await repository.insert(diary);
        _diaryId = id;
      } else {
        await repository.update(diary);
      }

      if (mounted) {
        setState(() {
          _isSaving = false;
          _hasSaved = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showLabelSelector() {
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
              const Text(
                '选择标签',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: diaryLabels.map((label) {
                  final name = label['name'] as String;
                  final color = label['color'] as int;
                  final icon = label['icon'] as String;
                  final isSelected = _label == name || (name == '无' && _label.isEmpty);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _label = name == '无' ? '' : name;
                      });
                      Navigator.pop(context);
                      _scheduleSave();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? Color(color).withOpacity(0.15) : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? Color(color) : Colors.grey.shade200,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (icon.isNotEmpty) ...[
                            Text(icon, style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              color: isSelected ? Color(color) : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showMoodSelector() {
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
              const Text(
                '选择心情',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: diaryMoods.map((mood) {
                  final name = mood['name'] as String;
                  final emoji = mood['emoji'] as String;
                  final color = mood['color'] as int;
                  final isSelected = _mood == name;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _mood = name;
                      });
                      Navigator.pop(context);
                      _scheduleSave();
                    },
                    child: Container(
                      width: 80,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? Color(color).withOpacity(0.15) : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? Color(color) : Colors.grey.shade200,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(emoji, style: const TextStyle(fontSize: 28)),
                          const SizedBox(height: 4),
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              color: isSelected ? Color(color) : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _getFormattedDate() {
    final month = widget.date.month;
    final day = widget.date.day;
    final weekday = _weekdays[widget.date.weekday - 1];
    return '$month月$day日 $weekday';
  }

  Widget _buildSaveStatus() {
    if (_isSaving) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '保存中...',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
        ],
      );
    }
    if (_hasSaved) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, size: 14, color: Colors.green.shade400),
          const SizedBox(width: 4),
          Text(
            '已保存',
            style: TextStyle(fontSize: 12, color: Colors.green.shade400),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
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
          _getFormattedDate(),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          _buildSaveStatus(),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // 标签和心情栏
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // 标签选择
                GestureDetector(
                  onTap: _showLabelSelector,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.label_rounded, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Text(
                          _label.isEmpty ? '标签' : _label,
                          style: TextStyle(
                            fontSize: 13,
                            color: _label.isEmpty ? Colors.grey.shade500 : const Color(0xFF11998E),
                            fontWeight: _label.isNotEmpty ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_drop_down_rounded, size: 18, color: Colors.grey.shade400),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 心情选择
                GestureDetector(
                  onTap: _showMoodSelector,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_mood.isNotEmpty) ...[
                          Text(getMoodEmoji(_mood), style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 4),
                        ] else
                          Icon(Icons.mood_rounded, size: 16, color: Colors.grey.shade600),
                        Text(
                          _mood.isEmpty ? '心情' : _mood,
                          style: TextStyle(
                            fontSize: 13,
                            color: _mood.isEmpty ? Colors.grey.shade500 : const Color(0xFF11998E),
                            fontWeight: _mood.isNotEmpty ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_drop_down_rounded, size: 18, color: Colors.grey.shade400),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // 正文输入
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _contentController,
                onChanged: _onContentChanged,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: '记录今天的心情...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

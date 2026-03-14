import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/todo_providers.dart';

class TodoCategoryChips extends ConsumerWidget {
  const TodoCategoryChips({super.key});

  static const _categoryColors = {
    '全部': Color(0xFF667EEA),
    '工作': Color(0xFF4F46E5),
    '生活': Color(0xFF10B981),
    '学习': Color(0xFFF59E0B),
    '杂项': Color(0xFF6B7280),
  };

  static const _categoryIcons = {
    '全部': Icons.dashboard_rounded,
    '工作': Icons.work_rounded,
    '生活': Icons.home_rounded,
    '学习': Icons.school_rounded,
    '杂项': Icons.more_horiz_rounded,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedTodoCategoryProvider);

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: todoCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = todoCategories[index];
          final isSelected = selectedCategory == category;
          final color = _categoryColors[category] ?? _categoryColors['杂项']!;
          final icon = _categoryIcons[category] ?? Icons.label_rounded;

          return GestureDetector(
            onTap: () =>
                ref.read(selectedTodoCategoryProvider.notifier).state = category,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [color, color.withOpacity(0.85)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
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
                      isSelected ? Icons.check_rounded : icon,
                      key: ValueKey(isSelected),
                      size: 16,
                      color: isSelected ? Colors.white : Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 13,
                    ),
                    child: Text(category),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/memo.dart';

class MemoCard extends StatelessWidget {
  final Memo memo;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const MemoCard({
    super.key,
    required this.memo,
    required this.onTap,
    this.onLongPress,
  });

  static const _categoryColors = {
    '工作': Color(0xFF4F46E5),
    '生活': Color(0xFF10B981),
    '学习': Color(0xFFF59E0B),
    '杂项': Color(0xFF6B7280),
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('MM-dd HH:mm');

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: memo.isPinned
              ? Border(
                  left: BorderSide(
                    color: const Color(0xFFFFB800),
                    width: 4,
                  ),
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题行
            Row(
              children: [
                if (memo.isPinned) ...[
                  Icon(
                    Icons.push_pin,
                    size: 14,
                    color: const Color(0xFFFFB800),
                  ),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: Text(
                    memo.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 摘要和图片
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 摘要
                  Expanded(
                    child: Text(
                      memo.content,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // 图片缩略图
                  if (memo.images.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 36,
                      child: Row(
                        children: [
                          // 显示第一张图片
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.file(
                              File(memo.images.first),
                              width: 36,
                              height: 36,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 36,
                                height: 36,
                                color: colorScheme.surfaceContainerHighest,
                                child: Icon(
                                  Icons.image,
                                  size: 16,
                                  color: colorScheme.outline,
                                ),
                              ),
                            ),
                          ),
                          if (memo.images.length > 1) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '+${memo.images.length}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            // 日期和分类
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '创建: ${dateFormat.format(memo.createdAt)}',
                        style: TextStyle(
                          fontSize: 10,
                          color: colorScheme.outline,
                        ),
                      ),
                      if (memo.remindTime != null)
                        Text(
                          '提醒: ${dateFormat.format(memo.remindTime!)}',
                          style: TextStyle(
                            fontSize: 10,
                            color: colorScheme.primary,
                          ),
                        ),
                    ],
                  ),
                ),
                if (memo.category != null) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _categoryColors[memo.category]?.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      memo.category!,
                      style: TextStyle(
                        fontSize: 10,
                        color: _categoryColors[memo.category] ?? Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

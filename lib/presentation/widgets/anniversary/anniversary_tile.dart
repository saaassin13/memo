import 'package:flutter/material.dart';
import '../../../domain/entities/anniversary.dart';

class AnniversaryTile extends StatelessWidget {
  final Anniversary anniversary;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const AnniversaryTile({
    super.key,
    required this.anniversary,
    this.onTap,
    this.onDelete,
  });

  static const _relationshipColors = {
    '亲人': Color(0xFF4F46E5),
    '爱人': Color(0xFFEC4899),
    '朋友': Color(0xFF10B981),
    '同事': Color(0xFF6B7280),
    '小孩': Color(0xFFF59E0B),
    '其他': Color(0xFF8B5CF6),
  };

  Color get _relationshipColor =>
      _relationshipColors[anniversary.relationship] ?? _relationshipColors['其他']!;

  Color get _daysColor {
    if (anniversary.isToday) return const Color(0xFFF5576C);
    if (anniversary.daysUntil <= 3) return const Color(0xFFF59E0B);
    return const Color(0xFF6B7280);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onLongPress: () => _showOptionsMenu(context),
        child: _buildContent(),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
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
            ListTile(
              leading: const Icon(Icons.edit_rounded, color: Colors.blue),
              title: const Text('编辑'),
              onTap: () {
                Navigator.pop(context);
                onTap?.call();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_rounded, color: Colors.red),
              title: const Text('删除', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                onDelete?.call();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 倒数天数
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _daysColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        anniversary.isToday ? '!' : anniversary.daysUntil.toString(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: _daysColor,
                        ),
                      ),
                      Text(
                        anniversary.isToday ? '今天' : '天后',
                        style: TextStyle(
                          fontSize: 10,
                          color: _daysColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                // 名称和日期
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        anniversary.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        anniversary.displayDateFull,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // 关系标签
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _relationshipColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _relationshipColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    anniversary.customRelation ?? anniversary.relationship,
                    style: TextStyle(
                      fontSize: 11,
                      color: _relationshipColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

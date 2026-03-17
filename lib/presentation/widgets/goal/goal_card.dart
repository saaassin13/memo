import 'package:flutter/material.dart';
import '../../../domain/entities/goal.dart';
import 'progress_ring.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback? onTap;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback? onComplete;

  const GoalCard({
    super.key,
    required this.goal,
    this.onTap,
    this.onIncrement,
    this.onDecrement,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = goal.isCompleted;
    final isLate = goal.isOverdue;

    Color statusColor;
    if (isDone) {
      statusColor = const Color(0xFF10B981);
    } else if (isLate) {
      statusColor = const Color(0xFFEF4444);
    } else {
      statusColor = const Color(0xFF8B5CF6);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: isDone ? Border.all(color: statusColor.withOpacity(0.3), width: 1.5) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 进度环
            ProgressRing(
              progress: goal.progress,
              size: 52,
              strokeWidth: 5,
              color: statusColor,
              child: Text(
                '${goal.progressPercent}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // 目标信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDone ? Colors.grey.shade500 : Colors.black87,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        isLate ? Icons.warning_rounded : Icons.schedule_rounded,
                        size: 12,
                        color: isLate ? const Color(0xFFEF4444) : Colors.grey.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        goal.statusText,
                        style: TextStyle(
                          fontSize: 12,
                          color: isLate ? const Color(0xFFEF4444) : Colors.grey.shade500,
                        ),
                      ),
                      if (goal.deadline != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(goal.deadline!),
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 进度条
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: goal.progress,
                      minHeight: 6,
                      backgroundColor: statusColor.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation(statusColor),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    goal.progressText,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // 快捷操作
            if (!isDone)
              Column(
                children: [
                  _SmallButton(
                    icon: Icons.add_rounded,
                    onTap: onIncrement,
                  ),
                  const SizedBox(height: 6),
                  _SmallButton(
                    icon: Icons.check_rounded,
                    color: const Color(0xFF10B981),
                    onTap: onComplete,
                  ),
                  const SizedBox(height: 6),
                  _SmallButton(
                    icon: Icons.remove_rounded,
                    onTap: onDecrement,
                  ),
                ],
              )
            else
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}月${date.day}日';
  }
}

class _SmallButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  const _SmallButton({
    required this.icon,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final btnColor = color ?? Colors.grey.shade600;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: btnColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: btnColor),
      ),
    );
  }
}

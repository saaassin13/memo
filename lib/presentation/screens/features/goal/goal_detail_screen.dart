import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/goal_providers.dart';
import '../../../providers/repository_providers.dart';
import '../../../../domain/entities/goal.dart';
import '../../../widgets/goal/progress_ring.dart';
import '../../../widgets/goal/goal_edit_dialog.dart';

class GoalDetailScreen extends ConsumerWidget {
  final int goalId;

  const GoalDetailScreen({super.key, required this.goalId});

  static const _primaryPurple = Color(0xFF8B5CF6);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsProvider);
    final logsAsync = ref.watch(goalProgressLogsProvider(goalId));

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('目标详情', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        actions: [
          goalsAsync.when(
            data: (goals) {
              final goal = goals.firstWhere((g) => g.id == goalId, orElse: () => goals.first);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_rounded),
                    onPressed: () => GoalEditDialog.show(context, goal: goal),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded),
                    onPressed: () => _deleteGoal(context, ref, goal),
                  ),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: goalsAsync.when(
        data: (goals) {
          final goal = goals.firstWhere(
            (g) => g.id == goalId,
            orElse: () => goals.first,
          );
          return _buildContent(context, ref, goal, logsAsync);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败: $e')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, Goal goal, AsyncValue<List<dynamic>> logsAsync) {
    final isDone = goal.isCompleted;
    final isLate = goal.isOverdue;

    Color statusColor;
    if (isDone) {
      statusColor = const Color(0xFF10B981);
    } else if (isLate) {
      statusColor = const Color(0xFFEF4444);
    } else {
      statusColor = _primaryPurple;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 进度环
          ProgressRing(
            progress: goal.progress,
            size: 160,
            strokeWidth: 12,
            color: statusColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  goal.progressType == GoalProgressType.percent
                      ? '${goal.progressPercent}%'
                      : goal.progressText,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
                Text(
                  goal.progressType == GoalProgressType.percent
                      ? '${goal.completedSteps}/${goal.totalSteps}'
                      : goal.progressType.label,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // 目标名称
          Text(
            goal.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // 状态信息
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isLate ? Icons.warning_rounded : Icons.schedule_rounded,
                size: 14,
                color: isLate ? const Color(0xFFEF4444) : Colors.grey.shade400,
              ),
              const SizedBox(width: 6),
              Text(
                goal.statusText,
                style: TextStyle(
                  fontSize: 14,
                  color: isLate ? const Color(0xFFEF4444) : Colors.grey.shade500,
                ),
              ),
              if (goal.deadline != null) ...[
                const SizedBox(width: 12),
                Text(
                  '截止: ${goal.deadline!.year}-${goal.deadline!.month.toString().padLeft(2, '0')}-${goal.deadline!.day.toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                ),
              ],
            ],
          ),
          const SizedBox(height: 28),
          // 进度调整
          if (!isDone) ...[
            _buildProgressAdjuster(context, ref, goal, statusColor),
            const SizedBox(height: 28),
          ],
          // 进度记录
          _buildProgressLogs(logsAsync),
        ],
      ),
    );
  }

  Widget _buildProgressAdjuster(BuildContext context, WidgetRef ref, Goal goal, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '进度调整',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          // 进度条
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: goal.progress,
              minHeight: 12,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 16),
          // 调整按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _AdjustButton(
                label: '-10',
                onTap: () => _adjustProgress(ref, goal, -10),
              ),
              const SizedBox(width: 8),
              _AdjustButton(
                label: '-1',
                onTap: () => _adjustProgress(ref, goal, -1),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => _showStepInputDialog(context, ref, goal),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${goal.completedSteps}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              _AdjustButton(
                label: '+1',
                onTap: () => _adjustProgress(ref, goal, 1),
              ),
              const SizedBox(width: 8),
              _AdjustButton(
                label: '+10',
                onTap: () => _adjustProgress(ref, goal, 10),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 标记完成按钮
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _completeGoal(ref, goal),
              icon: const Icon(Icons.check_circle_rounded, size: 20),
              label: const Text('标记完成', style: TextStyle(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressLogs(AsyncValue<List<dynamic>> logsAsync) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '进度记录',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          logsAsync.when(
            data: (logs) {
              if (logs.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      '暂无记录',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                    ),
                  ),
                );
              }
              return Column(
                children: logs.map((log) {
                  final change = log.stepChange;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: change >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _formatDateTime(log.createdAt),
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          ),
                        ),
                        Text(
                          '${log.stepBefore} → ${log.stepAfter}',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: (change >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            change >= 0 ? '+$change' : '$change',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: change >= 0 ? const Color(0xFF059669) : const Color(0xFFDC2626),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.month}月${dt.day}日 ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  void _adjustProgress(WidgetRef ref, Goal goal, int delta) {
    if (goal.id == null) return;
    final newSteps = (goal.completedSteps + delta).clamp(0, goal.totalSteps);
    ref.read(goalRepositoryProvider).updateProgress(goal.id!, newSteps);
  }

  void _completeGoal(WidgetRef ref, Goal goal) {
    if (goal.id == null) return;
    ref.read(goalRepositoryProvider).updateProgress(goal.id!, goal.totalSteps);
  }

  void _showStepInputDialog(BuildContext context, WidgetRef ref, Goal goal) {
    final controller = TextEditingController(text: goal.completedSteps.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('输入进度'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: '输入当前进度值',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value >= 0 && value <= goal.totalSteps) {
                _adjustProgress(ref, goal, value - goal.completedSteps);
                Navigator.pop(ctx);
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _deleteGoal(BuildContext context, WidgetRef ref, Goal goal) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除目标'),
        content: Text('确定要删除"${goal.name}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              if (goal.id != null) {
                await ref.read(goalRepositoryProvider).delete(goal.id!);
              }
              if (context.mounted) {
                Navigator.pop(ctx);
                Navigator.pop(context);
              }
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _AdjustButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AdjustButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}

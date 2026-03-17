import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/goal_providers.dart';
import '../../../providers/repository_providers.dart';
import '../../../../domain/entities/goal.dart';
import '../../../widgets/goal/goal_card.dart';
import '../../../widgets/goal/goal_edit_dialog.dart';
import 'goal_detail_screen.dart';

class GoalScreen extends ConsumerWidget {
  const GoalScreen({super.key});

  static const _primaryPurple = Color(0xFF8B5CF6);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(goalStatsProvider);
    final goalsAsync = ref.watch(filteredGoalsProvider);
    final filter = ref.watch(goalFilterProvider);
    final sort = ref.watch(goalSortProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              context.go('/home');
            }
          },
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFEAB308)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.flag_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            const Text('目标', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24, color: Colors.black87)),
          ],
        ),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              context.go('/home');
            }
          }
        },
        child: Column(
          children: [
            // 统计概览卡片
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: statsAsync.when(
                data: (stats) => _buildStatsCard(context, stats),
                loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
            // 筛选栏
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  _FilterChip(
                    label: '全部',
                    isSelected: filter == GoalFilter.all,
                    onTap: () => ref.read(goalFilterProvider.notifier).state = GoalFilter.all,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: '进行中',
                    isSelected: filter == GoalFilter.inProgress,
                    onTap: () => ref.read(goalFilterProvider.notifier).state = GoalFilter.inProgress,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: '已完成',
                    isSelected: filter == GoalFilter.completed,
                    onTap: () => ref.read(goalFilterProvider.notifier).state = GoalFilter.completed,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: '已逾期',
                    isSelected: filter == GoalFilter.overdue,
                    onTap: () => ref.read(goalFilterProvider.notifier).state = GoalFilter.overdue,
                  ),
                  const Spacer(),
                  // 排序按钮
                  PopupMenuButton<GoalSort>(
                    initialValue: sort,
                    onSelected: (value) => ref.read(goalSortProvider.notifier).state = value,
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: GoalSort.deadlineAsc,
                        child: Text('截止日期近优先'),
                      ),
                      const PopupMenuItem(
                        value: GoalSort.deadlineDesc,
                        child: Text('截止日期远优先'),
                      ),
                      const PopupMenuItem(
                        value: GoalSort.createdAtDesc,
                        child: Text('创建时间新优先'),
                      ),
                      const PopupMenuItem(
                        value: GoalSort.progressDesc,
                        child: Text('进度高优先'),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.sort_rounded, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            _sortLabel(sort),
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 目标列表
            Expanded(
              child: goalsAsync.when(
                data: (goals) {
                  if (goals.isEmpty) {
                    return _buildEmptyState(context);
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(goalsProvider);
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                      itemCount: goals.length,
                      itemBuilder: (context, index) {
                        final goal = goals[index];
                        return GoalCard(
                          goal: goal,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => GoalDetailScreen(goalId: goal.id!)),
                            );
                          },
                          onIncrement: () => _adjustProgress(ref, goal, 1),
                          onDecrement: () => _adjustProgress(ref, goal, -1),
                          onComplete: () => _completeGoal(ref, goal),
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('加载失败: $e')),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF59E0B), Color(0xFFEAB308)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF59E0B).withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => GoalEditDialog.show(context),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, GoalStats stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          _StatItem(label: '总数', value: '${stats.total}', color: Colors.black87),
          _buildDivider(),
          _StatItem(label: '进行中', value: '${stats.inProgress}', color: const Color(0xFF8B5CF6)),
          _buildDivider(),
          _StatItem(label: '已完成', value: '${stats.completed}', color: const Color(0xFF10B981)),
          _buildDivider(),
          _StatItem(label: '已逾期', value: '${stats.overdue}', color: const Color(0xFFEF4444)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: Colors.grey.shade200,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.flag_outlined, size: 36, color: Color(0xFFF59E0B)),
          ),
          const SizedBox(height: 20),
          Text('还没有目标',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text('设定目标，一步步实现',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => GoalEditDialog.show(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFEAB308)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '+ 创建第一个目标',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _sortLabel(GoalSort sort) {
    switch (sort) {
      case GoalSort.deadlineAsc:
        return '截止近';
      case GoalSort.deadlineDesc:
        return '截止远';
      case GoalSort.createdAtDesc:
        return '最新';
      case GoalSort.progressDesc:
        return '进度高';
    }
  }

  Future<void> _adjustProgress(WidgetRef ref, Goal goal, int delta) async {
    if (goal.id == null) return;
    final newSteps = (goal.completedSteps + delta).clamp(0, goal.totalSteps);
    final repository = ref.read(goalRepositoryProvider);
    await repository.updateProgress(goal.id!, newSteps);
  }

  Future<void> _completeGoal(WidgetRef ref, Goal goal) async {
    if (goal.id == null) return;
    final repository = ref.read(goalRepositoryProvider);
    await repository.updateProgress(goal.id!, goal.totalSteps);
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF59E0B) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}

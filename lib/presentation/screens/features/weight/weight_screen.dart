import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/weight_providers.dart';
import '../../../providers/repository_providers.dart';
import 'weight_edit_screen.dart';
import 'weight_stats_screen.dart';
import '../../../../domain/entities/weight.dart';

class WeightScreen extends ConsumerWidget {
  const WeightScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayAsync = ref.watch(todayWeightProvider);
    final weightsAsync = ref.watch(weightsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
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
                  colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
                begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.monitor_weight_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            const Text('体重', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24, color: Colors.black87)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const WeightStatsScreen()));
            },
          ),
          const SizedBox(width: 8),
        ],
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
            // 今日概览卡片
            Padding(
              padding: const EdgeInsets.all(16),
              child: todayAsync.when(
                data: (today) => _buildTodayCard(context, today),
                loading: () => const SizedBox(height: 180, child: Center(child: CircularProgressIndicator())),
                error: (_, __) => _buildTodayCard(context, null),
              ),
            ),
            // 历史记录标题
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text('历史记录', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const WeightStatsScreen()));
                    },
                    child: const Text('查看统计', style: TextStyle(color: Color(0xFF8B5CF6))),
                  ),
                ],
              ),
            ),
            // 历史列表
            Expanded(
              child: weightsAsync.when(
                data: (weights) {
                  if (weights.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.monitor_weight_outlined, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text('暂无记录', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                          const SizedBox(height: 8),
                          Text('点击右下角按钮添加今日数据', style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: weights.length,
                    itemBuilder: (context, index) {
                      final w = weights[index];
                      final prev = index < weights.length - 1 ? weights[index + 1] : null;
                      return _buildHistoryItem(context, ref, w, prev);
                    },
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
            colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B5CF6).withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const WeightEditScreen()));
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildTodayCard(BuildContext context, Weight? today) {
    final now = DateTime.now();
    final weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final weekday = weekdays[now.weekday - 1];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '${now.month}月${now.day}日 $weekday',
            style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14),
          ),
          const SizedBox(height: 16),
          if (today != null) ...[
            Text(
              '${today.value.toStringAsFixed(1)} kg',
              style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (today.bodyFat != null) ...[
                  Text('体脂 ${today.bodyFat!.toStringAsFixed(1)}%',
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                  const SizedBox(width: 16),
                ],
                Icon(
                  today.exercised ? Icons.check_circle_rounded : Icons.cancel_outlined,
                  size: 16,
                  color: Colors.white.withOpacity(0.8),
                ),
                const SizedBox(width: 4),
                Text(today.exercised ? '已运动' : '未运动',
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
              ],
            ),
            if (today.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(today.notes,
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ] else ...[
            Text('-- kg', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 36, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('今日未记录', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, WidgetRef ref, Weight w, Weight? prev) {
    double? diff;
    if (prev != null) {
      diff = w.value - prev.value;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => WeightEditScreen(weight: w, date: w.date)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${w.date.month}月${w.date.day}日',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87)),
                const SizedBox(height: 2),
                Text(
                  '${w.value.toStringAsFixed(1)} kg${w.bodyFat != null ? '  体脂 ${w.bodyFat!.toStringAsFixed(1)}%' : ''}',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
              ],
            ),
            const Spacer(),
            if (diff != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (diff <= 0 ? Colors.green : Colors.red).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${diff >= 0 ? '+' : ''}${diff.toStringAsFixed(1)}kg',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: diff <= 0 ? Colors.green.shade600 : Colors.red.shade400,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            Icon(
              w.exercised ? Icons.directions_run_rounded : Icons.horizontal_rule_rounded,
              size: 20,
              color: w.exercised ? const Color(0xFF10B981) : Colors.grey.shade300,
            ),
          ],
        ),
      ),
    );
  }
}

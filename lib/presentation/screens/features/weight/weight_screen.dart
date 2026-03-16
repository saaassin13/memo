import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/weight_providers.dart';
import 'weight_edit_screen.dart';
import 'weight_stats_screen.dart';
import '../../../../domain/entities/weight.dart';

class WeightScreen extends ConsumerWidget {
  const WeightScreen({super.key});

  static const _primaryPurple = Color(0xFF8B5CF6);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayAsync = ref.watch(todayWeightProvider);
    final weightsAsync = ref.watch(weightsProvider);
    final colorScheme = Theme.of(context).colorScheme;

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
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: todayAsync.when(
                data: (today) => _buildTodayCard(context, today),
                loading: () => const SizedBox(height: 180, child: Center(child: CircularProgressIndicator())),
                error: (_, __) => _buildTodayCard(context, null),
              ),
            ),
            // 历史记录标题
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  const Text('历史记录', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const WeightStatsScreen()));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F0FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.show_chart_rounded, size: 14, color: _primaryPurple),
                          SizedBox(width: 4),
                          Text('统计', style: TextStyle(color: _primaryPurple, fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 历史列表
            Expanded(
              child: weightsAsync.when(
                data: (weights) {
                  if (weights.isEmpty) {
                    return _buildEmptyState(context);
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: weights.length,
                    itemBuilder: (context, index) {
                      final w = weights[index];
                      final prev = index < weights.length - 1 ? weights[index + 1] : null;
                      return _buildHistoryItem(context, ref, w, prev, index);
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F0FF),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.monitor_weight_outlined, size: 36, color: _primaryPurple),
          ),
          const SizedBox(height: 20),
          Text('暂无记录',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text('点击右下角 + 按钮开始记录',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildTodayCard(BuildContext context, Weight? today) {
    final now = DateTime.now();
    final weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final weekday = weekdays[now.weekday - 1];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 装饰圆点
          Positioned(
            top: -10,
            right: -10,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -15,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Column(
            children: [
              Text(
                '${now.month}月${now.day}日 $weekday',
                style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14),
              ),
              const SizedBox(height: 16),
              if (today != null) ...[
                Text(
                  '${today.value.toStringAsFixed(1)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w300,
                    letterSpacing: -2,
                    height: 1,
                  ),
                ),
                Text('kg',
                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (today.bodyFat != null) ...[
                      _TodayBadge(
                        icon: Icons.water_drop_outlined,
                        label: '${today.bodyFat!.toStringAsFixed(1)}%',
                      ),
                      const SizedBox(width: 12),
                    ],
                    _TodayBadge(
                      icon: today.exercised ? Icons.directions_run_rounded : Icons.airline_seat_individual_suite_rounded,
                      label: today.exercised ? '已运动' : '未运动',
                      active: today.exercised,
                    ),
                  ],
                ),
                if (today.notes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(today.notes,
                        style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ] else ...[
                Text('—',
                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 48, fontWeight: FontWeight.w300)),
                Text('kg',
                    style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14)),
                const SizedBox(height: 12),
                Text('今日未记录', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, WidgetRef ref, Weight w, Weight? prev, int index) {
    double? diff;
    if (prev != null) {
      diff = w.value - prev.value;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => WeightEditScreen(weight: w, date: w.date)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.025), blurRadius: 10, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            // 日期彩色条
            Container(
              width: 4,
              height: 36,
              decoration: BoxDecoration(
                color: _getDayColor(w.date.weekday),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${w.date.month}月${w.date.day}日',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
                const SizedBox(height: 3),
                Text(
                  '${w.value.toStringAsFixed(1)} kg${w.bodyFat != null ? ' · ${w.bodyFat!.toStringAsFixed(1)}%' : ''}',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const Spacer(),
            if (diff != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: (diff <= 0 ? const Color(0xFF34D399) : const Color(0xFFF87171)).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${diff >= 0 ? '+' : ''}${diff.toStringAsFixed(1)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: diff <= 0 ? const Color(0xFF059669) : const Color(0xFFDC2626),
                  ),
                ),
              ),
            const SizedBox(width: 10),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: w.exercised ? const Color(0xFF34D399).withOpacity(0.12) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                w.exercised ? Icons.directions_run_rounded : Icons.horizontal_rule_rounded,
                size: 16,
                color: w.exercised ? const Color(0xFF059669) : Colors.grey.shade300,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDayColor(int weekday) {
    const colors = [
      Color(0xFF8B5CF6), // 周一 紫
      Color(0xFF3B82F6), // 周二 蓝
      Color(0xFF10B981), // 周三 绿
      Color(0xFFF59E0B), // 周四 琥珀
      Color(0xFFEF4444), // 周五 红
      Color(0xFFEC4899), // 周六 粉
      Color(0xFF6366F1), // 周日 靛蓝
    ];
    return colors[weekday - 1];
  }
}

class _TodayBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _TodayBadge({required this.icon, required this.label, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white.withOpacity(0.9)),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/weight_providers.dart';
import '../../../../domain/entities/weight.dart';

class WeightStatsScreen extends ConsumerWidget {
  const WeightStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(weightStatsPeriodProvider);
    final filteredAsync = ref.watch(filteredWeightsProvider);
    final statsAsync = ref.watch(weightStatsProvider);
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
        title: const Text('统计分析', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 时间范围选择
            Row(
              children: StatsPeriod.values.map((p) {
                final isSelected = period == p;
                final label = p == StatsPeriod.week ? '周' : p == StatsPeriod.month ? '月' : '年';
                return Expanded(
                  child: GestureDetector(
                    onTap: () => ref.read(weightStatsPeriodProvider.notifier).state = p,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // 体重趋势图
            _buildSectionTitle('体重趋势'),
            const SizedBox(height: 12),
            filteredAsync.when(
              data: (weights) => _buildTrendChart(weights, '体重', (w) => w.value, 'kg'),
              loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            // 关键指标
            _buildSectionTitle('关键指标'),
            const SizedBox(height: 12),
            statsAsync.when(
              data: (stats) => _buildStatsCards(stats),
              loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87));
  }

  Widget _buildTrendChart(List<Weight> weights, String label, double Function(Weight) getValue, String unit) {
    if (weights.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Center(child: Text('暂无数据', style: TextStyle(color: Colors.grey.shade400))),
      );
    }

    final values = weights.map(getValue).toList();
    final minVal = values.reduce((a, b) => a < b ? a : b);
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final range = maxVal - minVal;
    final padding = range > 0 ? range * 0.2 : 1.0;

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          const SizedBox(height: 12),
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: _TrendLinePainter(
                values: values,
                minVal: minVal - padding,
                maxVal: maxVal + padding,
                color: const Color(0xFF8B5CF6),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDate(weights.first.date), style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
              Text(_formatDate(weights.last.date), style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(WeightStats stats) {
    if (stats.isEmpty) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Center(child: Text('暂无数据', style: TextStyle(color: Colors.grey.shade400))),
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.8,
      children: [
        _buildStatCard('平均体重', '${stats.avgWeight.toStringAsFixed(1)} kg', '近${stats.days}天', const Color(0xFF8B5CF6)),
        _buildStatCard('最低体重', '${stats.minWeight.toStringAsFixed(1)} kg', '', const Color(0xFF10B981)),
        _buildStatCard('运动次数', '${stats.exerciseCount} 次', '近${stats.days}天', const Color(0xFFF59E0B)),
        _buildStatCard(
          '体重变化',
          '${stats.weightChange >= 0 ? '+' : ''}${stats.weightChange.toStringAsFixed(1)} kg',
          '近${stats.days}天',
          stats.weightChange <= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.month}/${date.day}';
}

class _TrendLinePainter extends CustomPainter {
  final List<double> values;
  final double minVal;
  final double maxVal;
  final Color color;

  _TrendLinePainter({required this.values, required this.minVal, required this.maxVal, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final range = maxVal - minVal;

    for (int i = 0; i < values.length; i++) {
      final x = i / (values.length - 1) * size.width;
      final y = range > 0 ? size.height - ((values[i] - minVal) / range * size.height) : size.height / 2;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      canvas.drawCircle(Offset(x, y), 5, dotPaint);
      canvas.drawCircle(Offset(x, y), 5, dotBorderPaint);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrendLinePainter old) => true;
}

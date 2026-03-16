import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/weight_providers.dart';
import '../../../../domain/entities/weight.dart';

class WeightStatsScreen extends ConsumerWidget {
  const WeightStatsScreen({super.key});

  static const _primaryPurple = Color(0xFF8B5CF6);
  static const _lightPurple = Color(0xFFF3F0FF);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(weightStatsPeriodProvider);
    final filteredAsync = ref.watch(filteredWeightsProvider);
    final statsAsync = ref.watch(weightStatsProvider);

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
        title: const Text('统计分析', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 时间范围 - 胶囊式分段控件
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                children: StatsPeriod.values.map((p) {
                  final isSelected = period == p;
                  final label = p == StatsPeriod.week ? '周' : p == StatsPeriod.month ? '月' : '年';
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => ref.read(weightStatsPeriodProvider.notifier).state = p,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: isSelected
                              ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? _primaryPurple : Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // 体重趋势图
            _buildSectionHeader('体重趋势', Icons.show_chart_rounded),
            const SizedBox(height: 12),
            filteredAsync.when(
              data: (weights) => _buildTrendChart(weights),
              loading: () => const SizedBox(height: 220, child: Center(child: CircularProgressIndicator())),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            // 关键指标
            _buildSectionHeader('关键指标', Icons.insights_rounded),
            const SizedBox(height: 12),
            statsAsync.when(
              data: (stats) => _buildStatsCards(stats),
              loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _lightPurple,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: _primaryPurple),
        ),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
      ],
    );
  }

  Widget _buildTrendChart(List<Weight> weights) {
    if (weights.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.show_chart_rounded, size: 36, color: Colors.grey.shade300),
              const SizedBox(height: 8),
              Text('暂无数据', style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
            ],
          ),
        ),
      );
    }

    final values = weights.map((w) => w.value).toList();
    final minVal = values.reduce((a, b) => a < b ? a : b);
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final range = maxVal - minVal;
    final padding = range > 0 ? range * 0.25 : 1.0;

    return Container(
      height: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('体重',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
              Text('${minVal.toStringAsFixed(1)} ~ ${maxVal.toStringAsFixed(1)} kg',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: _TrendLinePainter(
                values: values,
                minVal: minVal - padding,
                maxVal: maxVal + padding,
                color: _primaryPurple,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDate(weights.first.date), style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
              Text(_formatDate(weights.last.date), style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(WeightStats stats) {
    if (stats.isEmpty) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.insights_rounded, size: 36, color: Colors.grey.shade300),
              const SizedBox(height: 8),
              Text('暂无数据', style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
            ],
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _StatCard(
          icon: Icons.speed_rounded,
          title: '平均体重',
          value: '${stats.avgWeight.toStringAsFixed(1)}',
          unit: 'kg',
          subtitle: '近${stats.days}天',
          color: _primaryPurple,
        ),
        _StatCard(
          icon: Icons.arrow_downward_rounded,
          title: '最低体重',
          value: '${stats.minWeight.toStringAsFixed(1)}',
          unit: 'kg',
          subtitle: '',
          color: const Color(0xFF34D399),
        ),
        _StatCard(
          icon: Icons.fitness_center_rounded,
          title: '运动次数',
          value: '${stats.exerciseCount}',
          unit: '次',
          subtitle: '近${stats.days}天',
          color: const Color(0xFFFBBF24),
        ),
        _StatCard(
          icon: stats.weightChange <= 0 ? Icons.trending_down_rounded : Icons.trending_up_rounded,
          title: '体重变化',
          value: '${stats.weightChange >= 0 ? '+' : ''}${stats.weightChange.toStringAsFixed(1)}',
          unit: 'kg',
          subtitle: '近${stats.days}天',
          color: stats.weightChange <= 0 ? const Color(0xFF34D399) : const Color(0xFFF87171),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) => '${date.month}/${date.day}';
}

// 统计卡片组件
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String unit;
  final String subtitle;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.025), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 14, color: color),
              ),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: color, letterSpacing: -1, height: 1)),
              const SizedBox(width: 3),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(unit,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ],
      ),
    );
  }
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

    final range = maxVal - minVal;
    if (range <= 0) return;

    // 渐变填充
    final fillPath = Path();
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.2), color.withOpacity(0.02)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    fillPath.moveTo(0, size.height);
    for (int i = 0; i < values.length; i++) {
      final x = i / (values.length - 1) * size.width;
      final y = size.height - ((values[i] - minVal) / range * size.height);
      if (i == 0) {
        fillPath.lineTo(x, y);
      } else {
        fillPath.lineTo(x, y);
      }
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);

    // 折线
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    for (int i = 0; i < values.length; i++) {
      final x = i / (values.length - 1) * size.width;
      final y = size.height - ((values[i] - minVal) / range * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, linePaint);

    // 数据点
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final dotBorderPaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < values.length; i++) {
      final x = i / (values.length - 1) * size.width;
      final y = size.height - ((values[i] - minVal) / range * size.height);
      canvas.drawCircle(Offset(x, y), 5, dotPaint);
      canvas.drawCircle(Offset(x, y), 5, dotBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TrendLinePainter old) => true;
}

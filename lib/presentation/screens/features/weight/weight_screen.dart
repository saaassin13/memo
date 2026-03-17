import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
    final monthGroupsAsync = ref.watch(weightMonthGroupsProvider);
    final selectedYear = ref.watch(selectedYearProvider);
    final availableYearsAsync = ref.watch(availableYearsProvider);

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
                error: (_, _) => _buildTodayCard(context, null),
              ),
            ),
            // 历史记录标题 + 年份选择
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  const Text('历史记录', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 12),
                  // 年份选择器
                  availableYearsAsync.when(
                    data: (years) => _YearSelector(
                      years: years,
                      selectedYear: selectedYear,
                      onChanged: (year) {
                        ref.read(selectedYearProvider.notifier).state = year;
                      },
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
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
            // 分组列表
            Expanded(
              child: monthGroupsAsync.when(
                data: (groups) {
                  if (groups.isEmpty) {
                    return _buildEmptyState(context);
                  }
                  return _GroupedWeightList(groups: groups);
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
}

// 年份选择器
class _YearSelector extends StatelessWidget {
  final List<int> years;
  final int selectedYear;
  final ValueChanged<int> onChanged;

  const _YearSelector({
    required this.years,
    required this.selectedYear,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showYearPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F0FF),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${selectedYear}年',
              style: const TextStyle(
                color: Color(0xFF8B5CF6),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF8B5CF6)),
          ],
        ),
      ),
    );
  }

  void _showYearPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('选择年份', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
              ...years.map((year) {
                final isSelected = year == selectedYear;
                return ListTile(
                  title: Text(
                    '${year}年',
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? const Color(0xFF8B5CF6) : Colors.black87,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_rounded, color: Color(0xFF8B5CF6))
                      : null,
                  onTap: () {
                    onChanged(year);
                    Navigator.pop(ctx);
                  },
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

// 分组列表组件
class _GroupedWeightList extends ConsumerStatefulWidget {
  final List<MonthGroup> groups;

  const _GroupedWeightList({required this.groups});

  @override
  ConsumerState<_GroupedWeightList> createState() => _GroupedWeightListState();
}

class _GroupedWeightListState extends ConsumerState<_GroupedWeightList> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _monthKeys = {};
  String? _currentMonthKey;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final keys = _monthKeys.entries.toList();
    String? newCurrentMonth;
    for (var i = keys.length - 1; i >= 0; i--) {
      final key = keys[i].value;
      final ctx = key.currentContext;
      if (ctx != null) {
        final box = ctx.findRenderObject() as RenderBox?;
        if (box != null) {
          final pos = box.localToGlobal(Offset.zero);
          if (pos.dy < 200) {
            newCurrentMonth = keys[i].key;
            break;
          }
        }
      }
    }
    if (newCurrentMonth != null && newCurrentMonth != _currentMonthKey) {
      setState(() => _currentMonthKey = newCurrentMonth);
    }
  }

  void _scrollToMonth(String monthKey) {
    final key = _monthKeys[monthKey];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final expandedMonths = ref.watch(expandedMonthsProvider);

    return Stack(
      children: [
        ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.only(left: 20, right: 48, bottom: 20),
          itemCount: widget.groups.length,
          itemBuilder: (context, index) {
            final group = widget.groups[index];
            final monthKey = group.monthKey;
            _monthKeys.putIfAbsent(monthKey, () => GlobalKey());

            return Container(
              key: _monthKeys[monthKey],
              margin: const EdgeInsets.only(bottom: 8),
              child: _MonthGroupTile(
                group: group,
                isExpanded: expandedMonths.contains(monthKey),
                onToggle: () {
                  final notifier = ref.read(expandedMonthsProvider.notifier);
                  final current = Set<String>.from(notifier.state);
                  if (current.contains(monthKey)) {
                    current.remove(monthKey);
                  } else {
                    current.add(monthKey);
                  }
                  notifier.state = current;
                },
              ),
            );
          },
        ),
        // 右侧月份快速导航
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          width: 36,
          child: _MonthQuickNav(
            groups: widget.groups,
            currentMonthKey: _currentMonthKey,
            onTap: _scrollToMonth,
          ),
        ),
      ],
    );
  }
}

// 月份分组卡片
class _MonthGroupTile extends StatelessWidget {
  final MonthGroup group;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _MonthGroupTile({
    required this.group,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final monthStr = '${group.month.month}月';

    return Column(
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                AnimatedRotation(
                  turns: isExpanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: isExpanded ? const Color(0xFF8B5CF6) : Colors.grey.shade400,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  monthStr,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${group.records.length}条',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                const Spacer(),
                Text(
                  '${group.avgWeight.toStringAsFixed(1)}kg',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF34D399).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '运动${group.exerciseCount}天',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF059669), fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              children: List.generate(group.records.length, (index) {
                final w = group.records[index];
                final prev = index < group.records.length - 1 ? group.records[index + 1] : null;
                return _buildRecordItem(context, w, prev);
              }),
            ),
          ),
          crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }

  Widget _buildRecordItem(BuildContext context, Weight w, Weight? prev) {
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
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 1)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 32,
              decoration: BoxDecoration(
                color: _getDayColor(w.date.weekday),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${w.date.month}月${w.date.day}日',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 2),
                Text(
                  '${w.value.toStringAsFixed(1)} kg${w.bodyFat != null ? ' · ${w.bodyFat!.toStringAsFixed(1)}%' : ''}',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const Spacer(),
            if (diff != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (diff <= 0 ? const Color(0xFF34D399) : const Color(0xFFF87171)).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${diff >= 0 ? '+' : ''}${diff.toStringAsFixed(1)}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: diff <= 0 ? const Color(0xFF059669) : const Color(0xFFDC2626),
                  ),
                ),
              ),
            const SizedBox(width: 8),
            Icon(
              w.exercised ? Icons.directions_run_rounded : null,
              size: 14,
              color: const Color(0xFF059669),
            ),
          ],
        ),
      ),
    );
  }

  static Color _getDayColor(int weekday) {
    const colors = [
      Color(0xFF8B5CF6),
      Color(0xFF3B82F6),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFFEF4444),
      Color(0xFFEC4899),
      Color(0xFF6366F1),
    ];
    return colors[weekday - 1];
  }
}

// 右侧月份快速导航
class _MonthQuickNav extends StatelessWidget {
  final List<MonthGroup> groups;
  final String? currentMonthKey;
  final ValueChanged<String> onTap;

  const _MonthQuickNav({
    required this.groups,
    required this.currentMonthKey,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFAFAFA).withOpacity(0),
            const Color(0xFFFAFAFA).withOpacity(0.9),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
          final monthKey = group.monthKey;
          final isActive = currentMonthKey == monthKey;
          final label = '${group.month.month}月';

          return GestureDetector(
            onTap: () => onTap(monthKey),
            child: Container(
              height: 28,
              margin: const EdgeInsets.symmetric(vertical: 1),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF8B5CF6) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? Colors.white : Colors.grey.shade500,
                ),
              ),
            ),
          );
        },
      ),
    );
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../providers/profile_providers.dart';
import '../../providers/weight_providers.dart';
import '../../providers/goal_providers.dart';
import '../../providers/repository_providers.dart';
import 'settings_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const _primaryPurple = Color(0xFF8B5CF6);
  static const _lightPurple = Color(0xFFF3F0FF);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usageDaysAsync = ref.watch(usageDaysProvider);
    final weeklyStatsAsync = ref.watch(weeklyStatsProvider);
    final latestWeightAsync = ref.watch(latestWeightProvider);
    final nextAnniversaryAsync = ref.watch(nextAnniversaryProvider);
    final memoCount = ref.watch(memoCountProvider);
    final diaryCount = ref.watch(diaryCountProvider);
    final anniversaryCount = ref.watch(anniversaryCountProvider);
    final goalStatsAsync = ref.watch(goalStatsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // 顶部标题
              const Text('我的',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.black87)),
              const SizedBox(height: 20),

              // 用户卡片
              _buildUserCard(context, usageDaysAsync),
              const SizedBox(height: 20),

              // 本周概览
              _buildSectionHeader('本周数据', Icons.calendar_view_week_rounded),
              const SizedBox(height: 12),
              weeklyStatsAsync.when(
                data: (stats) => _buildWeeklyOverview(stats),
                loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
                error: (_, __) => _buildWeeklyOverview(WeeklyStats.empty()),
              ),
              const SizedBox(height: 20),

              // 数据统计入口
              _buildSectionHeader('数据统计', Icons.bar_chart_rounded),
              const SizedBox(height: 12),
              _buildStatsList(context, ref, latestWeightAsync, nextAnniversaryAsync, memoCount, diaryCount, anniversaryCount, goalStatsAsync),
              const SizedBox(height: 20),

              // 数据管理
              _buildSectionHeader('数据管理', Icons.storage_rounded),
              const SizedBox(height: 12),
              _buildDataManagement(context, ref),
              const SizedBox(height: 20),

              // 设置
              _buildSectionHeader('设置', Icons.settings_rounded),
              const SizedBox(height: 12),
              _buildSettings(context),
              const SizedBox(height: 20),

              // 关于
              _buildSectionHeader('关于', Icons.info_outline_rounded),
              const SizedBox(height: 12),
              _buildAbout(context),
              const SizedBox(height: 32),
            ],
          ),
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

  Widget _buildUserCard(BuildContext context, AsyncValue<int> usageDaysAsync) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = '早上好';
    } else if (hour < 18) {
      greeting = '下午好';
    } else {
      greeting = '晚上好';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                usageDaysAsync.when(
                  data: (days) => Text('已使用第 $days 天',
                      style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13)),
                  loading: () => Text('加载中...',
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyOverview(WeeklyStats stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _WeeklyStatItem(
              icon: Icons.check_circle_outline_rounded,
              iconColor: const Color(0xFF10B981),
              label: '待办完成',
              value: '${stats.todoCompleted}',
              unit: '项',
            ),
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade100),
          Expanded(
            child: _WeeklyStatItem(
              icon: Icons.book_outlined,
              iconColor: const Color(0xFF6366F1),
              label: '日记',
              value: '${stats.diaryCount}',
              unit: '篇',
            ),
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade100),
          Expanded(
            child: _WeeklyStatItem(
              icon: Icons.directions_run_rounded,
              iconColor: const Color(0xFF10B981),
              label: '运动',
              value: '${stats.exerciseCount}',
              unit: '天',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsList(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<double?> latestWeightAsync,
    AsyncValue<dynamic> nextAnniversaryAsync,
    int memoCount,
    int diaryCount,
    int anniversaryCount,
    AsyncValue<GoalStats> goalStatsAsync,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          _StatsListItem(
            icon: Icons.note_alt_outlined,
            iconBg: const Color(0xFFFEF3C7),
            iconColor: const Color(0xFFF59E0B),
            title: '备忘录',
            subtitle: '共 $memoCount 条',
            onTap: () => context.push('/memo'),
          ),
          _divider(),
          _StatsListItem(
            icon: Icons.book_outlined,
            iconBg: const Color(0xFFEDE9FE),
            iconColor: const Color(0xFF6366F1),
            title: '日记',
            subtitle: '共 $diaryCount 篇',
            onTap: () => context.push('/diary'),
          ),
          _divider(),
          _StatsListItem(
            icon: Icons.monitor_weight_outlined,
            iconBg: const Color(0xFFF3F0FF),
            iconColor: _primaryPurple,
            title: '体重',
            subtitle: latestWeightAsync.maybeWhen(
              data: (w) => w != null ? '最近 ${w.toStringAsFixed(1)} kg' : '暂无记录',
              orElse: () => '暂无记录',
            ),
            onTap: () => context.push('/weight'),
          ),
          _divider(),
          _StatsListItem(
            icon: Icons.cake_outlined,
            iconBg: const Color(0xFFD1FAE5),
            iconColor: const Color(0xFF10B981),
            title: '纪念日',
            subtitle: nextAnniversaryAsync.maybeWhen(
              data: (a) => a != null ? '下次 ${a.daysUntil} 天后' : '共 $anniversaryCount 个',
              orElse: () => '暂无纪念日',
            ),
            onTap: () => context.push('/anniversary'),
          ),
          _divider(),
          _StatsListItem(
            icon: Icons.flag_outlined,
            iconBg: const Color(0xFFFEE2E2),
            iconColor: const Color(0xFFEF4444),
            title: '目标',
            subtitle: goalStatsAsync.maybeWhen(
              data: (stats) => '进行中 ${stats.inProgress} 个',
              orElse: () => '查看全部',
            ),
            onTap: () => context.push('/goal'),
          ),
        ],
      ),
    );
  }

  Widget _buildDataManagement(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          _SettingsListItem(
            icon: Icons.upload_rounded,
            iconBg: const Color(0xFFDBEAFE),
            iconColor: const Color(0xFF3B82F6),
            title: '数据导出',
            subtitle: '备份所有数据',
            onTap: () => _showExportDialog(context, ref),
          ),
          _divider(),
          _SettingsListItem(
            icon: Icons.download_rounded,
            iconBg: const Color(0xFFD1FAE5),
            iconColor: const Color(0xFF10B981),
            title: '数据导入',
            subtitle: '从备份恢复数据',
            onTap: () => _showImportDialog(context, ref),
          ),
          _divider(),
          _SettingsListItem(
            icon: Icons.cleaning_services_rounded,
            iconBg: const Color(0xFFFEF3C7),
            iconColor: const Color(0xFFF59E0B),
            title: '清除缓存',
            subtitle: '清理临时数据',
            onTap: () => _showClearCacheDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSettings(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          _SettingsListItem(
            icon: Icons.settings_rounded,
            iconBg: const Color(0xFFF3F0FF),
            iconColor: _primaryPurple,
            title: '设置',
            subtitle: '主题、字体、数据等',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAbout(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          _SettingsListItem(
            icon: Icons.info_outline_rounded,
            iconBg: const Color(0xFFF3F4F6),
            iconColor: const Color(0xFF6B7280),
            title: '版本',
            subtitle: 'v1.0.0',
            onTap: null,
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(height: 1, indent: 56, color: Colors.grey.shade100);
  }

  void _showExportDialog(BuildContext context, WidgetRef ref) {
    bool isExporting = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Icon(Icons.upload_rounded, size: 40, color: _primaryPurple),
              const SizedBox(height: 12),
              const Text('数据导出', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(
                '将所有数据导出为备份文件\n包含备忘录、待办、日记、纪念日、目标、体重等',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: _PillButton(
                  label: isExporting ? '导出中...' : '开始导出',
                  onTap: isExporting
                      ? () {}
                      : () async {
                          setState(() => isExporting = true);
                          try {
                            final service = ref.read(dataBackupServiceProvider);
                            final filePath = await service.exportData();
                            Navigator.pop(ctx);
                            if (context.mounted) {
                              _showExportSuccessDialog(context, filePath);
                            }
                          } catch (e) {
                            setState(() => isExporting = false);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('导出失败: $e')),
                              );
                            }
                          }
                        },
                  filled: true,
                  color: _primaryPurple,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _showExportSuccessDialog(BuildContext context, String filePath) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.check_circle_rounded, size: 40, color: Color(0xFF10B981)),
            const SizedBox(height: 12),
            const Text('导出成功', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('备份文件已保存到:\n$filePath',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: _PillButton(
                label: '确定',
                onTap: () => Navigator.pop(ctx),
                filled: true,
                color: _primaryPurple,
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showImportDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.download_rounded, size: 40, color: Color(0xFF10B981)),
            const SizedBox(height: 12),
            const Text('数据导入', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              '从备份文件恢复数据\n导入将追加数据，不会覆盖现有记录',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _PillButton(
                    label: '取消',
                    onTap: () => Navigator.pop(ctx),
                    filled: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PillButton(
                    label: '选择文件',
                    onTap: () async {
                      Navigator.pop(ctx);
                      await _pickAndImportFile(context, ref);
                    },
                    filled: true,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndImportFile(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) return;

      final filePath = result.files.first.path;
      if (filePath == null) return;

      // 确认导入
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('确认导入'),
          content: const Text('导入将追加数据到现有记录中，确定继续吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('确定', style: TextStyle(color: Color(0xFF10B981))),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // 显示加载
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );
      }

      final service = ref.read(dataBackupServiceProvider);
      final importResult = await service.importData(filePath);

      if (context.mounted) {
        Navigator.pop(context); // 关闭加载
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入成功！共 ${importResult.totalRecords} 条记录')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // 确保关闭加载
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入失败: $e')),
        );
      }
    }
  }

  void _showClearCacheDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.cleaning_services_rounded, size: 40, color: Color(0xFFF59E0B)),
            const SizedBox(height: 12),
            const Text('清除缓存', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('清除临时缓存数据，不会删除您的记录',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _PillButton(
                    label: '取消',
                    onTap: () => Navigator.pop(context),
                    filled: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PillButton(
                    label: '清除',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('缓存已清除'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          backgroundColor: Colors.grey.shade800,
                        ),
                      );
                    },
                    filled: true,
                    color: const Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyStatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String unit;

  const _WeeklyStatItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(value,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: iconColor, letterSpacing: -0.5, height: 1)),
            const SizedBox(width: 2),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(unit, style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
      ],
    );
  }
}

class _StatsListItem extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _StatsListItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87)),
            ),
            Text(subtitle,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }
}

class _SettingsListItem extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _SettingsListItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool filled;
  final Color color;

  const _PillButton({
    required this.label,
    required this.onTap,
    this.filled = false,
    this.color = const Color(0xFF8B5CF6),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: filled ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          border: filled ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: filled ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}

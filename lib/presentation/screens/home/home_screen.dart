import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/memo_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final memosAsync = ref.watch(memosProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF667EEA).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.emoji_emotions_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '你好',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              '今天记录点什么？',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.15,
                ),
                delegate: SliverChildListDelegate([
                  _FeatureCard(
                    icon: Icons.note_alt_rounded,
                    title: '备忘录',
                    subtitle: memosAsync.when(
                      data: (memos) => '${memos.length} 条记录',
                      loading: () => '加载中...',
                      error: (_, __) => '加载失败',
                    ),
                    gradient: const [Color(0xFF667EEA), Color(0xFF764BA2)],
                    onTap: () => context.go('/memo'),
                    onLongPress: () => context.push('/memo/edit?category=工作'),
                  ),
                  _FeatureCard(
                    icon: Icons.book_rounded,
                    title: '日记',
                    subtitle: '每日记录',
                    gradient: const [Color(0xFF11998E), Color(0xFF38EF7D)],
                    onTap: () => context.go('/diary'),
                  ),
                  _FeatureCard(
                    icon: Icons.favorite_rounded,
                    title: '纪念日',
                    subtitle: '重要日子',
                    gradient: const [Color(0xFFF093FB), Color(0xFFF5576C)],
                    onTap: () => context.go('/countdown'),
                  ),
                  _FeatureCard(
                    icon: Icons.account_balance_wallet_rounded,
                    title: '记账',
                    subtitle: '收支明细',
                    gradient: const [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                    onTap: () => context.go('/account'),
                  ),
                  _FeatureCard(
                    icon: Icons.flag_rounded,
                    title: '目标',
                    subtitle: '进度追踪',
                    gradient: const [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
                    onTap: () => context.go('/goal'),
                  ),
                  _FeatureCard(
                    icon: Icons.monitor_weight_rounded,
                    title: '体重',
                    subtitle: '健康记录',
                    gradient: const [Color(0xFFA8EB12), Color(0xFF36D1DC)],
                    onTap: () => context.go('/weight'),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: gradient[0].withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

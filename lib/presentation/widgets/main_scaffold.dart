import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: '首页',
                  isSelected: navigationShell.currentIndex == 0,
                  onTap: () => _onTap(0),
                  gradient: const [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
                _NavItem(
                  icon: Icons.check_circle_rounded,
                  label: '待办',
                  isSelected: navigationShell.currentIndex == 1,
                  onTap: () => _onTap(1),
                  gradient: const [Color(0xFF11998E), Color(0xFF38EF7D)],
                ),
                _NavItem(
                  icon: Icons.calendar_month_rounded,
                  label: '日历',
                  isSelected: navigationShell.currentIndex == 2,
                  onTap: () => _onTap(2),
                  gradient: const [Color(0xFFF093FB), Color(0xFFF5576C)],
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: '我的',
                  isSelected: navigationShell.currentIndex == 3,
                  onTap: () => _onTap(3),
                  gradient: const [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTap(int index) {
    // 只有在不同 tab 时才切换，避免重新加载
    if (index != navigationShell.currentIndex) {
      navigationShell.goBranch(
        index,
        initialLocation: true,
      );
    }
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final List<Color> gradient;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: gradient.map((c) => c.withOpacity(0.15)).toList(),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                borderRadius: BorderRadius.circular(14),
              ),
              child: isSelected
                  ? Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: gradient[0].withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 22,
                      ),
                    )
                  : Icon(
                      icon,
                      color: colorScheme.onSurfaceVariant,
                      size: 22,
                    ),
            ),
            const SizedBox(height: 6),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? gradient[0] : colorScheme.onSurfaceVariant,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

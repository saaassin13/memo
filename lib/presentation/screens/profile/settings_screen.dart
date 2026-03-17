import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 设置相关的 Provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString('theme_mode') ?? 'system';
    switch (value) {
      case 'light':
        state = ThemeMode.light;
        break;
      case 'dark':
        state = ThemeMode.dark;
        break;
      default:
        state = ThemeMode.system;
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    switch (mode) {
      case ThemeMode.light:
        await prefs.setString('theme_mode', 'light');
        break;
      case ThemeMode.dark:
        await prefs.setString('theme_mode', 'dark');
        break;
      default:
        await prefs.setString('theme_mode', 'system');
    }
  }
}

final fontSizeProvider = StateNotifierProvider<FontSizeNotifier, double>((ref) {
  return FontSizeNotifier();
});

class FontSizeNotifier extends StateNotifier<double> {
  FontSizeNotifier() : super(1.0) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getDouble('font_scale') ?? 1.0;
  }

  Future<void> setScale(double scale) async {
    state = scale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('font_scale', scale);
  }
}

final weightUnitKgProvider = StateNotifierProvider<WeightUnitNotifier, bool>((ref) {
  return WeightUnitNotifier();
});

class WeightUnitNotifier extends StateNotifier<bool> {
  WeightUnitNotifier() : super(true) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('weight_unit_kg') ?? true;
  }

  Future<void> setUnit(bool isKg) async {
    state = isKg;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('weight_unit_kg', isKg);
  }
}

final backupReminderProvider = StateNotifierProvider<BackupReminderNotifier, bool>((ref) {
  return BackupReminderNotifier();
});

class BackupReminderNotifier extends StateNotifier<bool> {
  BackupReminderNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('backup_reminder') ?? false;
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('backup_reminder', enabled);
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _primaryPurple = Color(0xFF8B5CF6);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final fontSizeScale = ref.watch(fontSizeProvider);
    final weightUnitKg = ref.watch(weightUnitKgProvider);
    final backupReminder = ref.watch(backupReminderProvider);

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
        title: const Text('设置', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 外观设置
            _buildSectionHeader('外观'),
            const SizedBox(height: 12),
            _buildSettingCard([
              _ThemeModeSelector(
                current: themeMode,
                onChanged: (mode) => ref.read(themeModeProvider.notifier).setMode(mode),
              ),
              const SizedBox(height: 4),
              _buildDivider(),
              _FontSizeSelector(
                scale: fontSizeScale,
                onChanged: (scale) => ref.read(fontSizeProvider.notifier).setScale(scale),
              ),
            ]),
            const SizedBox(height: 20),

            // 数据设置
            _buildSectionHeader('数据'),
            const SizedBox(height: 12),
            _buildSettingCard([
              _SwitchItem(
                icon: Icons.monitor_weight_outlined,
                iconColor: _primaryPurple,
                title: '体重单位',
                subtitle: weightUnitKg ? '公斤 (kg)' : '斤',
                value: !weightUnitKg,
                onChanged: (v) => ref.read(weightUnitKgProvider.notifier).setUnit(!v),
              ),
            ]),
            const SizedBox(height: 20),

            // 提醒设置
            _buildSectionHeader('提醒'),
            const SizedBox(height: 12),
            _buildSettingCard([
              _SwitchItem(
                icon: Icons.backup_outlined,
                iconColor: const Color(0xFF3B82F6),
                title: '备份提醒',
                subtitle: '每周提醒备份数据',
                value: backupReminder,
                onChanged: (v) => ref.read(backupReminderProvider.notifier).setEnabled(v),
              ),
            ]),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: _primaryPurple,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
      ],
    );
  }

  Widget _buildSettingCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.grey.shade100);
  }
}

class _ThemeModeSelector extends StatelessWidget {
  final ThemeMode current;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeModeSelector({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.palette_outlined, size: 20, color: Color(0xFF8B5CF6)),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('主题模式', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                SizedBox(height: 2),
                Text('选择你喜欢的主题', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ThemeOption(
                  icon: Icons.brightness_auto_rounded,
                  label: '跟随',
                  isSelected: current == ThemeMode.system,
                  onTap: () => onChanged(ThemeMode.system),
                ),
                _ThemeOption(
                  icon: Icons.light_mode_rounded,
                  label: '浅色',
                  isSelected: current == ThemeMode.light,
                  onTap: () => onChanged(ThemeMode.light),
                ),
                _ThemeOption(
                  icon: Icons.dark_mode_rounded,
                  label: '深色',
                  isSelected: current == ThemeMode.dark,
                  onTap: () => onChanged(ThemeMode.dark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: const Offset(0, 1))]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey.shade500),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FontSizeSelector extends StatelessWidget {
  final double scale;
  final ValueChanged<double> onChanged;

  const _FontSizeSelector({required this.scale, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    String label;
    if (scale <= 0.85) {
      label = '小';
    } else if (scale <= 1.0) {
      label = '标准';
    } else if (scale <= 1.15) {
      label = '大';
    } else {
      label = '特大';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.text_fields_rounded, size: 20, color: Color(0xFF8B5CF6)),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('字体大小', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                SizedBox(height: 2),
                Text('调整应用内文字大小', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          SizedBox(
            width: 120,
            child: Row(
              children: [
                const Text('A', style: TextStyle(fontSize: 12, color: Colors.grey)),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                      activeTrackColor: const Color(0xFF8B5CF6),
                      inactiveTrackColor: Colors.grey.shade200,
                      thumbColor: const Color(0xFF8B5CF6),
                    ),
                    child: Slider(
                      value: scale,
                      min: 0.8,
                      max: 1.3,
                      divisions: 5,
                      onChanged: onChanged,
                    ),
                  ),
                ),
                const Text('A', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F0FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(label,
                style: const TextStyle(fontSize: 11, color: Color(0xFF8B5CF6), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _SwitchItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF8B5CF6),
              activeTrackColor: const Color(0xFF8B5CF6).withOpacity(0.3),
              inactiveThumbColor: Colors.grey.shade300,
              inactiveTrackColor: Colors.grey.shade200,
            ),
          ),
        ],
      ),
    );
  }
}

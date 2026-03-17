# Step 18: "我的"页面开发进度

## 开发进度

### Phase 1: 状态管理 ✅

- [x] 创建 profile_providers.dart
- [x] 实现 usageDaysProvider (使用天数，从 SharedPreferences 读取)
- [x] 实现 weeklyStatsProvider (本周待办完成/日记/体重变化/运动次数)
- [x] 实现 memoCountProvider (备忘录总数)
- [x] 实现 diaryCountProvider (日记总数)
- [x] 实现 latestWeightProvider (最近一次体重)
- [x] 实现 nextAnniversaryProvider (下一个纪念日)
- [x] 定义 WeeklyStats 数据类

**文件清单:**

| 文件 | 操作 | 说明 |
|------|------|------|
| `lib/presentation/providers/profile_providers.dart` | 已创建 | "我的"页面数据统计 Provider |

**依赖新增:**
- `shared_preferences: ^2.3.3` - 本地设置和使用天数存储

---

### Phase 2: 主页面 ✅

- [x] 重写 ProfileScreen
- [x] 实现顶部用户卡片 (头像 + 动态问候语 + 使用天数)
- [x] 实现本周数据概览 (待办完成数/日记篇数/体重变化)
- [x] 实现数据统计入口列表 (备忘录/日记/体重/纪念日/目标)
- [x] 实现数据管理区域 (导出/导入/清除缓存)
- [x] 实现设置入口
- [x] 实现关于区域 (版本号)
- [x] 实现底部弹出式对话框 (导出/导入/清除缓存)

**文件清单:**

| 文件 | 操作 | 说明 |
|------|------|------|
| `lib/presentation/screens/profile/profile_screen.dart` | 已重写 | "我的"页面主体 |

**页面结构:**

```
我的页面
├── 顶部标题
├── 用户卡片 (紫色渐变，头像 + 问候 + 使用天数)
├── 本周数据 (三列：待办完成 / 日记 / 体重变化)
├── 数据统计入口 (点击跳转各功能)
│   ├── 备忘录 (计数)
│   ├── 日记 (计数)
│   ├── 体重 (最近值)
│   ├── 纪念日 (下次倒计时)
│   └── 目标
├── 数据管理
│   ├── 数据导出 (开发中占位)
│   ├── 数据导入 (开发中占位)
│   └── 清除缓存
├── 设置 (跳转设置页)
└── 关于 (版本号)
```

---

### Phase 3: 设置页面 ✅

- [x] 创建 SettingsScreen
- [x] 实现主题模式切换 (跟随系统/浅色/深色)
- [x] 实现字体大小滑块 (小/标准/大/特大)
- [x] 实现体重单位切换 (kg/斤)
- [x] 实现备份提醒开关
- [x] 所有设置持久化到 SharedPreferences
- [x] 创建对应 StateNotifier Provider

**文件清单:**

| 文件 | 操作 | 说明 |
|------|------|------|
| `lib/presentation/screens/profile/settings_screen.dart` | 已创建 | 设置页面 |

**设置项列表:**

| 设置项 | 类型 | SharedPreferences Key | 默认值 |
|--------|------|----------------------|--------|
| 主题模式 | 三选一 SegmentedButton | `theme_mode` | `system` |
| 字体大小 | Slider | `font_scale` | `1.0` |
| 体重单位 | Switch | `weight_unit_kg` | `true` (kg) |
| 备份提醒 | Switch | `backup_reminder` | `false` |

**新增 Provider:**

| Provider | 类型 | 说明 |
|----------|------|------|
| `themeModeProvider` | `StateNotifierProvider<ThemeModeNotifier, ThemeMode>` | 主题模式 |
| `fontSizeProvider` | `StateNotifierProvider<FontSizeNotifier, double>` | 字体缩放比例 |
| `weightUnitKgProvider` | `StateNotifierProvider<WeightUnitNotifier, bool>` | 体重单位 |
| `backupReminderProvider` | `StateNotifierProvider<BackupReminderNotifier, bool>` | 备份提醒 |

---

### Phase 4: 数据导出/导入 ✅

- [x] 创建 DataBackupService (JSON 序列化所有表)
- [x] 实现 exportData() 导出为 JSON 文件
- [x] 实现 importData() 从 JSON 文件导入
- [x] 导出后通过 share_plus 分享文件
- [x] 导入通过 file_picker 选择文件
- [x] 导入确认对话框
- [x] 导入/导出 loading 状态

**文件清单:**

| 文件 | 操作 | 说明 |
|------|------|------|
| `lib/data/services/data_backup_service.dart` | 已创建 | 数据备份服务 |

**导出的数据表:**
- memos (备忘录)
- todos (待办)
- diaries (日记)
- anniversaries (纪念日)
- goals (目标)
- goalProgressLogs (目标进度记录)
- weights (体重记录)
- countdowns (倒计时)
- accounts (记账)

**依赖新增:**
- `share_plus: ^10.0.0` - 文件分享
- `file_picker: ^8.0.0` - 文件选择

---

## 已创建文件列表

| 文件 | 说明 | 状态 |
|------|------|------|
| `lib/presentation/providers/profile_providers.dart` | "我的"页面数据统计 | ✅ |
| `lib/presentation/screens/profile/profile_screen.dart` | "我的"页面主体 | ✅ 已重写 |
| `lib/presentation/screens/profile/settings_screen.dart` | 设置页面 | ✅ |
| `lib/data/services/data_backup_service.dart` | 数据备份服务 | ✅ |
| `notes/step18-profile-dev.md` | 本开发文档 | ✅ |

## 已修改文件列表

| 文件 | 修改内容 | 状态 |
|------|------|------|
| `pubspec.yaml` | 新增 `shared_preferences`、`share_plus`、`file_picker` 依赖 | ✅ |
| `lib/presentation/providers/repository_providers.dart` | 新增 dataBackupServiceProvider | ✅ |

---

## SharedPreferences Keys 汇总

| Key | 类型 | 用途 |
|-----|------|------|
| `first_open_date` | String | 首次打开日期，格式 `YYYY-MM-DD` |
| `theme_mode` | String | 主题模式: `system`/`light`/`dark` |
| `font_scale` | double | 字体缩放比例 (0.8~1.3) |
| `weight_unit_kg` | bool | 体重单位: true=kg, false=斤 |
| `backup_reminder` | bool | 备份提醒开关 |

---

## UI 设计风格

保持与体重页面一致的 "温暖有机 / Premium Journal" 风格：
- 浅紫色为主色调 (`#8B5CF6`)
- 圆角卡片 (20px)
- 柔和阴影
- 药丸形按钮
- 底部弹出式对话框替代 AlertDialog

---

## 待完善项

1. **数据导出/导入** - 需要实现 JSON 序列化和文件操作
2. **头像更换** - 点击头像从相册选择/拍照（image_picker 已有依赖）
3. **存储用量展示** - 显示数据库文件大小
4. **主题模式生效** - 需要在 MaterialApp 中接入 themeModeProvider
5. **字体大小生效** - 需要在 MaterialApp 中接入 fontSizeProvider
6. **目标功能统计** - 接入 GoalRepository 数据
7. **记账功能统计** - 接入 AccountRepository 数据

---
*文档创建日期: 2026年3月16日*
*最后更新: 2026年3月16日*

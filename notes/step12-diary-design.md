# 日记功能设计 (Step 12)

## 功能概述

日记功能以月历形式展示，用户可以在任意日期写日记。支持标签分类、心情记录，自动保存。

---

## 一、日记展示列表（月历视图）

### 页面布局

```
日记页面 (DiaryScreen)
├── 顶部导航栏
│   ├── 日历图标 + "日记" 标题
│   └── 筛选/搜索按钮
├── 月份导航
│   ├── 左箭头 (上一月)
│   ├── 2026年3月 (当前月份标题)
│   ├── 右箭头 (下一月)
│   └── 今天按钮 (快速回到当天)
├── 周标题行
│   └── 日 一 二 三 四 五 六
├── 日期网格 (6行×7列)
│   └── 每天显示:
│       ├── 日期数字
│       └── ● (有日记时显示彩色圆点)
└── 浮动按钮区域
    ├── 定位今天按钮 (圆形, 日历+箭头图标)
    └── + 新增按钮 (圆形, 粉色渐变)
```

### 月历视图设计

```
┌─────────────────────────────────────────┐
│ ◀      2026年3月                      ▶ │
├─────────────────────────────────────────┤
│  日    一    二    三    四    五    六  │
│       1     2     3     4     5     6   │
│    [●]   [●]                        [●] │
│   7     8     9    10    11    12   13   │
│  [●]        [●]                        │
│  ...                                    │
├─────────────────────────────────────────┤
│                                 [📍][+] │
└─────────────────────────────────────────┘
```

- 有日记的日期: 日期数字下方显示彩色圆点 (●)
- 当天: 日期数字高亮 (渐变背景 + 白色文字)
- 选中日期: 蓝色边框
- 非当月日期: 灰色显示
- 圆点颜色: 可根据心情或标签变化

### 交互逻辑

| 操作 | 响应 |
|------|------|
| 点击日期 | 选中该日期，高亮显示 |
| 点击+按钮 | 进入选中日期的日记编辑页 |
| 点击定位按钮 | 跳转到今天，选中今天 |
| 左右箭头 | 切换上/下月 |
| 点击有圆点的日期 | 可预览摘要或直接进入编辑 |

---

## 二、日记编辑页面

### 页面布局

```
日记编辑页面 (DiaryEditScreen)
├── 顶部导航栏
│   ├── 返回箭头
│   ├── 日期显示 (3月16日 周一)
│   └── 自动保存提示 (绿色小字 "已保存")
├── 标签栏
│   ├── 当前标签 (彩色圆角标签)
│   └── 点击展开标签选择器
├── 心情栏
│   ├── 心情表情 (大图标/emoji)
│   └── 点击展开心情选择器
├── 正文输入区
│   └── 多行文本输入 (占满剩余空间)
└── 底部工具栏 (可选)
    └── 图片/附件按钮
```

### 编辑页详细设计

```
┌─────────────────────────────────────┐
│ [←]   3月16日 周一       已保存 ✓  │
├─────────────────────────────────────┤
│ 标签: [🏷️ 生活 ▼]    心情: [😊 ▼] │
├─────────────────────────────────────┤
│                                     │
│  今天天气很好，出门散步了...         │
│                                     │
│  上午去了公园，看到了很多花...       │
│                                     │
│  下午在家看了一本书...               │
│                                     │
│                                     │
│                                     │
│                                     │
└─────────────────────────────────────┘
```

---

## 三、标签选择器

### 标签设计

点击标签栏弹出底部选择器：

```
┌─────────────────────────────────────┐
│  ───                                │
│  选择标签                            │
│  [无] [生活] [工作] [学习] [旅行]    │
│  [美食] [运动] [心情] [其他]         │
│  [+ 自定义]                         │
└─────────────────────────────────────┘
```

**预设标签:**
| 标签 | 颜色 | 图标 |
|------|------|------|
| 无 | 灰色 | 无 |
| 生活 | 绿色 #10B981 | 🏠 |
| 工作 | 蓝色 #4F46E5 | 💼 |
| 学习 | 橙色 #F59E0B | 📚 |
| 旅行 | 青色 #06B6D4 | ✈️ |
| 美食 | 红色 #EF4444 | 🍜 |
| 运动 | 紫色 #8B5CF6 | 🏃 |
| 心情 | 粉色 #EC4899 | 💭 |
| 自定义 | 用户定义 | 用户定义 |

---

## 四、心情选择器

### 心情设计

点击心情栏弹出底部选择器：

```
┌─────────────────────────────────────┐
│  ───                                │
│  选择心情                            │
│                                     │
│  😊 开心  😢 伤心  😡 生气  😰 焦虑  │
│  😌 平静  🥳 兴奋  😴 疲惫  🤔 思考  │
│                                     │
│  [+ 自定义心情]                     │
└─────────────────────────────────────┘
```

**预设心情:**

| 心情 | Emoji | 颜色 |
|------|-------|------|
| 开心 | 😊 | 黄色 #F59E0B |
| 伤心 | 😢 | 蓝色 #3B82F6 |
| 生气 | 😡 | 红色 #EF4444 |
| 焦虑 | 😰 | 橙色 #F97316 |
| 平静 | 😌 | 绿色 #10B981 |
| 兴奋 | 🥳 | 粉色 #EC4899 |
| 疲惫 | 😴 | 灰色 #6B7280 |
| 思考 | 🤔 | 紫色 #8B5CF6 |
| 自定义 | 用户输入 | 默认灰色 |

---

## 五、自动保存机制

### 保存策略

- **触发时机**: 用户停止输入 1.5 秒后自动保存
- **状态显示**: 顶部右侧显示保存状态
  - "保存中..." (灰色)
  - "已保存 ✓" (绿色)
  - "保存失败" (红色，可点击重试)
- **离线支持**: 本地数据库存储，无需网络

### 实现方案

```dart
Timer? _saveTimer;

void _onContentChanged(String content) {
  _saveTimer?.cancel();
  _saveTimer = Timer(const Duration(milliseconds: 1500), () {
    _save();
  });
}
```

---

## 六、数据库设计

### 字段扩展

在现有 `Diaries` 表基础上新增字段:

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INTEGER | 主键 |
| date | DATETIME | 日期 (唯一) |
| weather | TEXT | 天气 (可选，保留) |
| content | TEXT | 正文内容 |
| label | TEXT | 标签 (新增) |
| mood | TEXT | 心情 (新增，存储 emoji 或文字) |
| images | TEXT | 图片列表 JSON (保留) |
| createdAt | DATETIME | 创建时间 |
| updatedAt | DATETIME | 更新时间 |

### 数据库迁移

- schemaVersion: 4 → 5
- 添加 `label` 字段
- 添加 `mood` 字段

---

## 七、状态管理

### Providers

```dart
// 当前月份
final diaryCurrentMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

// 选中日期
final diarySelectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// 日记列表流
final diariesProvider = StreamProvider<List<Diary>>((ref) {
  final repository = ref.watch(diaryRepositoryProvider);
  return repository.watchAll();
});

// 某月有日记的日期集合 (用于显示圆点)
final monthDiaryDatesProvider = Provider.family<Set<DateTime>, DateTime>((ref, month) {
  final diariesAsync = ref.watch(diaryProviders);
  return diariesAsync.whenData((diaries) {
    return diaries
        .where((d) => d.date.year == month.year && d.date.month == month.month)
        .map((d) => DateTime(d.date.year, d.date.month, d.date.day))
        .toSet();
  }).valueOrNull ?? {};
});

// 某日的日记
final diaryByDateProvider = Provider.family<AsyncValue<Diary?>, DateTime>((ref, date) {
  final diariesAsync = ref.watch(diaryProviders);
  return diariesAsync.whenData((diaries) {
    try {
      return diaries.firstWhere((d) =>
        d.date.year == date.year &&
        d.date.month == date.month &&
        d.date.day == date.day
      );
    } catch (_) {
      return null;
    }
  });
});
```

---

## 八、视觉设计

### 配色方案

- 主色调: 绿色渐变 `#11998E → #38EF7D`
- 当天日期: 绿色渐变背景 + 白色文字
- 选中日期: 绿色边框
- 有日记日期: 圆点颜色根据心情变化
- 标签颜色: 各标签预设颜色

### 圆角与阴影

- 卡片圆角: 16px
- 按钮圆角: 16px
- 标签圆角: 14px
- 阴影: 0 2-10px rgba(0,0,0,0.04)

### 心情对应圆点颜色

| 心情 | 圆点颜色 |
|------|----------|
| 开心 | 黄色 #F59E0B |
| 伤心 | 蓝色 #3B82F6 |
| 生气 | 红色 #EF4444 |
| 焦虑 | 橙色 #F97316 |
| 平静 | 绿色 #10B981 |
| 兴奋 | 粉色 #EC4899 |
| 疲惫 | 灰色 #6B7280 |
| 思考 | 紫色 #8B5CF6 |
| 无心情 | 绿色 #11998E |

---

## 九、文件清单

| 文件 | 说明 | 操作 |
|------|------|------|
| `lib/domain/entities/diary.dart` | 日记实体 | 修改 (新增 label, mood 字段) |
| `lib/data/database/tables/diaries.dart` | 数据库表 | 修改 (新增 label, mood 列) |
| `lib/data/database/database.dart` | 数据库 | 修改 (升级到 v5) |
| `lib/presentation/screens/features/diary/diary_screen.dart` | 日记月历页面 | 重写 |
| `lib/presentation/screens/features/diary/diary_edit_screen.dart` | 日记编辑页面 | 新增 |
| `lib/presentation/widgets/diary/mood_selector.dart` | 心情选择器 | 新增 |
| `lib/presentation/widgets/diary/label_selector.dart` | 标签选择器 | 新增 |
| `lib/presentation/widgets/diary/diary_calendar_grid.dart` | 日记日历网格 | 新增 |
| `lib/presentation/providers/diary_providers.dart` | 日记状态管理 | 新增 |
| `notes/step12-diary-design.md` | 本设计文档 | 新增 |

---

## 十、开发步骤

### Step 12.1: 数据层
- [ ] 扩展 Diary 实体 (label, mood)
- [ ] 更新数据库表 (新增列)
- [ ] 升级数据库版本 (v4 → v5)

### Step 12.2: 状态管理
- [ ] 创建 diary_providers.dart
- [ ] 实现 diariesProvider
- [ ] 实现 monthDiaryDatesProvider
- [ ] 实现 diaryByDateProvider

### Step 12.3: 月历页面
- [ ] 创建日记日历网格组件
- [ ] 实现月份导航
- [ ] 实现日期点击选中
- [ ] 实现有日记日期的圆点显示
- [ ] 实现悬浮按钮 (定位今天 + 新增)

### Step 12.4: 编辑页面
- [ ] 创建 DiaryEditScreen
- [ ] 实现日期显示
- [ ] 实现自动保存
- [ ] 实现标签选择器
- [ ] 实现心情选择器
- [ ] 实现正文输入

### Step 12.5: 集成测试
- [ ] 新增日记
- [ ] 编辑日记
- [ ] 自动保存
- [ ] 圆点显示
- [ ] 日期切换

---

## 十一、交互流程

```
用户打开日记页面
    │
    ▼
显示当月日历 (有圆点标记)
    │
    ├─ 点击日期 → 选中 (高亮)
    │
    ├─ 点击+按钮 → 进入编辑页面 (该日期)
    │       │
    │       ├─ 输入标题/正文 → 1.5秒后自动保存
    │       ├─ 选择标签 → 立即保存
    │       ├─ 选择心情 → 立即保存 + 更新圆点颜色
    │       └─ 点击返回 → 返回日历页面
    │
    ├─ 点击定位按钮 → 跳转到今天
    │
    └─ 左右箭头 → 切换月份
```

---

*文档创建日期: 2026年3月16日*

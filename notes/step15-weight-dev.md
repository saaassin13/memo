# 体重功能开发 (Step 15)

## 开发进度

### Phase 1: 数据层 ✅

- [x] 扩展 Weight 实体 (新增 bodyFat, exercised, exerciseType, exerciseDuration, notes + WeightStats 类)
- [x] 更新数据库表 (新增 5 个列)
- [x] 升级数据库版本 (v5 → v6)
- [x] 更新仓储实现 (insert/update/_mapToEntity 支持新字段)

**文件清单:**

| 文件 | 操作 | 说明 |
|------|------|------|
| `lib/domain/entities/weight.dart` | ✅ 已修改 | 新增字段 + WeightStats 统计类 |
| `lib/data/database/tables/weights.dart` | ✅ 已修改 | 新增 bodyFat, exercised, exerciseType, exerciseDuration, notes |
| `lib/data/database/database.dart` | ✅ 已修改 | schemaVersion 5→6, 添加迁移逻辑 |
| `lib/data/repositories/weight_repository_impl.dart` | ✅ 已修改 | 支持新字段的 CRUD |

---

### Phase 2: 状态管理 ✅

- [x] 创建 weight_providers.dart
- [x] 实现 weightStatsPeriodProvider (时间范围选择)
- [x] 实现 weightsProvider (体重记录流)
- [x] 实现 todayWeightProvider (今日记录)
- [x] 实现 filteredWeightsProvider (按时间范围过滤)
- [x] 实现 weightStatsProvider (统计数据计算)
- [x] 定义 exerciseTypes (运动类型常量)

**文件清单:**

| 文件 | 操作 | 说明 |
|------|------|------|
| `lib/presentation/providers/weight_providers.dart` | ✅ 已创建 | 体重状态管理 (5个Provider + 常量) |

---

### Phase 3: 主页面 ✅

- [x] 重写 WeightScreen
- [x] 实现今日概览卡片 (体重/体脂/运动状态/备注)
- [x] 实现历史记录列表 (体重差值 + 运动标记)
- [x] 实现 FAB 添加按钮 (紫色渐变)
- [x] 实现滑动返回手势
- [x] 实现统计分析入口 (AppBar 图标 + 列表标题)

**文件清单:**

| 文件 | 操作 | 说明 |
|------|------|------|
| `lib/presentation/screens/features/weight/weight_screen.dart` | ✅ 已重写 | 体重主页面 |

---

### Phase 4: 编辑页面 ✅

- [x] 创建 WeightEditScreen
- [x] 实现日期选择
- [x] 实现体重输入 (必填，验证范围)
- [x] 实现体脂率输入 (选填)
- [x] 实现运动开关
- [x] 实现运动类型选择 (6个选项)
- [x] 实现运动时长输入
- [x] 实现备注输入
- [x] 实现保存逻辑 (新建/编辑)

**文件清单:**

| 文件 | 操作 | 说明 |
|------|------|------|
| `lib/presentation/screens/features/weight/weight_edit_screen.dart` | ✅ 已创建 | 体重编辑页面 |

---

### Phase 5: 统计页面 ✅

- [x] 创建 WeightStatsScreen
- [x] 实现时间范围切换 (周/月/年)
- [x] 实现体重趋势图 (自定义 Canvas 绘制折线图)
- [x] 实现关键指标卡片 (平均体重/最低体重/运动次数/体重变化)

**文件清单:**

| 文件 | 操作 | 说明 |
|------|------|------|
| `lib/presentation/screens/features/weight/weight_stats_screen.dart` | ✅ 已创建 | 统计分析页面 |

---

## 已创建文件列表

| 文件 | 说明 | 状态 |
|------|------|------|
| `lib/presentation/providers/weight_providers.dart` | 体重状态管理 | ✅ |
| `lib/presentation/screens/features/weight/weight_edit_screen.dart` | 编辑页面 | ✅ |
| `lib/presentation/screens/features/weight/weight_stats_screen.dart` | 统计分析页面 | ✅ |

## 已修改文件列表

| 文件 | 修改内容 | 状态 |
|------|------|------|
| `lib/domain/entities/weight.dart` | 新增字段 + WeightStats 类 | ✅ |
| `lib/data/database/tables/weights.dart` | 新增 5 个列 | ✅ |
| `lib/data/database/database.dart` | schemaVersion 5→6 | ✅ |
| `lib/data/repositories/weight_repository_impl.dart` | 支持新字段 CRUD | ✅ |
| `lib/presentation/screens/features/weight/weight_screen.dart` | 重写主页面 | ✅ |

---

## 功能说明

### 主页面
- 今日概览卡片：紫色渐变，显示体重(大字体)/体脂率/运动状态/备注
- 历史记录列表：体重+体脂+与前一天差值(红绿)+运动标记
- 点击记录进入编辑，右上角📊进入统计

### 编辑页面
- 日期选择 (默认今天)
- 体重输入 (必填，验证 0-500kg)
- 体脂率输入 (选填)
- 运动开关 (展开显示运动类型+时长)
- 运动类型：跑步/游泳/健身/瑜伽/骑行/其他
- 备注输入

### 统计页面
- 时间范围：周/月/年 切换
- 体重趋势图：自定义 Canvas 折线图，带数据点
- 关键指标卡片：平均体重、最低体重、运动次数、体重变化

---

## 路由集成

体重页面已有路由 `/weight`，通过首页的"体重"卡片点击进入。

---

## 日历页面调整 (2026-03-17)

1. **移除体重展示** - 日历中不再显示体重事件类型，日历专注于待办、备忘、纪念日、目标
2. **事件列表改为横向滚动** - 月视图下选中日期的事件改为横向卡片列表（固定高度120px），避免遮挡月历网格

---

## Phase 6: 历史记录列表优化 (待开发)

### 问题分析

当前历史记录使用简单的 `ListView.builder` 平铺展示所有记录，当记录数量较多时存在以下问题：
- 难以快速定位到特定月份
- 缺少时间维度的视觉分隔
- 长列表滚动体验差

### 优化方案：月份分组 + 快速导航

#### 页面布局

```
┌─────────────────────────────────────┐
│ [←]  体重                      [📊] │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │      今日概览卡片               │ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│ 历史记录                    [统计]  │
├─────────────────────────────────────┤
│ ▼ 2026年3月                (12条)  │  ← 可折叠月份标题
│ ┌─────────────────────────────────┐ │
│ │ 3月16日  65.5kg  18.5%  ✅运动  │ │
│ │ 3月15日  65.8kg  18.8%  ❌      │ │
│ │ ...                            │ │
│ └─────────────────────────────────┘ │
│ ▼ 2026年2月                (15条)  │  ← 可折叠月份标题
│ ┌─────────────────────────────────┐ │
│ │ 2月28日  66.0kg  19.0%  ✅运动  │ │
│ │ 2月27日  66.2kg  19.1%  ❌      │ │
│ │ ...                            │ │
│ └─────────────────────────────────┘ │
│ ▶ 2026年1月                 (8条)  │  ← 已折叠
│ ▶ 2025年12月               (20条)  │
└─────────────────────────────────────┘
```

#### 核心功能

**1. 月份分组 (MonthGroup)**

```dart
class MonthGroup {
  final DateTime month;           // 2026-03-01
  final List<Weight> records;     // 该月所有记录
  final double avgWeight;         // 月平均体重
  final int exerciseCount;        // 运动天数

  MonthGroup({required this.month, required this.records});
}
```

**2. 月份分组标题 (MonthHeader)**

```
┌─────────────────────────────────────────┐
│ ▼ 2026年3月           65.8kg  运动8天   │  ← 展开状态
├─────────────────────────────────────────┤
│                                         │
│ ▶ 2026年2月           66.2kg  运动10天  │  ← 折叠状态
└─────────────────────────────────────────┘
```

- 显示月份、平均体重、运动天数
- 点击折叠/展开该月记录
- 默认展开当月，折叠其他月份
- 展开时带动画过渡

**3. 快速月份导航 (MonthQuickNav)**

在列表右侧显示月份索引，支持快速跳转：

```
                        ┌─────┐
                        │ 3月 │
                        ├─────┤
                        │ 2月 │
                        ├─────┤
                        │ 1月 │
                        ├─────┤
                        │ 12月│
                        ├─────┤
                        │ 11月│
                        └─────┘
```

- 右侧固定月份索引条
- 点击对应月份快速滚动到该分组
- 当前可见月份高亮显示
- 月份较多时支持滑动选择

**4. 滚动时吸顶效果 (StickyHeader)**

滚动时当前月份分组标题吸顶显示，直到下一个分组顶上来。

#### 数据处理

```dart
// 按月份分组 Provider
final weightMonthGroupsProvider = Provider<AsyncValue<List<MonthGroup>>>((ref) {
  final weightsAsync = ref.watch(weightsProvider);
  return weightsAsync.whenData((weights) {
    if (weights.isEmpty) return [];

    final Map<String, List<Weight>> grouped = {};
    for (final w in weights) {
      final key = '${w.date.year}-${w.date.month.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(key, () => []).add(w);
    }

    return grouped.entries.map((entry) {
      return MonthGroup(
        month: DateTime.parse('${entry.key}-01'),
        records: entry.value,
      );
    }).toList()
      ..sort((a, b) => b.month.compareTo(a.month)); // 月份倒序
  });
});
```

#### 交互细节

| 操作 | 效果 |
|------|------|
| 点击月份标题 | 折叠/展开该月记录 (带动画) |
| 点击月份索引 | 平滑滚动到对应分组 |
| 点击记录 | 进入编辑页面 (现有逻辑) |
| 上滑加载 | 记录全部加载，无需分页 |
| 下拉刷新 | 刷新数据 (现有逻辑) |

#### 折叠状态管理

```dart
// 当前展开的月份集合 (默认展开当月)
final expandedMonthsProvider = StateProvider<Set<String>>((ref) {
  final now = DateTime.now();
  return {'${now.year}-${now.month.toString().padLeft(2, '0')}'};
});
```

#### 视觉设计

| 元素 | 样式 |
|------|------|
| 月份标题背景 | 浅灰 `#F5F5F5`，圆角 12px |
| 展开图标 | `▼` 紫色 `#8B5CF6` |
| 折叠图标 | `▶` 灰色 `#9CA3AF` |
| 月份索引条 | 右侧固定，半透明背景 |
| 月份索引项 | 选中时紫色底色白色文字 |
| 分割线 | 浅灰虚线 `#E5E7EB` |

#### 记录数阈值优化

```dart
// 记录数超过阈值时自动启用月份分组
const kMonthGroupThreshold = 14; // 超过14条(约2周)启用分组

// Provider 中自动判断
final shouldGroupByMonthProvider = Provider<bool>((ref) {
  final weightsAsync = ref.watch(weightsProvider);
  final count = weightsAsync.valueOrNull?.length ?? 0;
  return count > kMonthGroupThreshold;
});
```

- 记录较少时保持现有平铺展示
- 记录超过阈值自动切换为月份分组
- 避免少量记录时分组标题占用过多空间

---

## 待办清单

### Phase 6: 历史记录列表优化
- [x] 创建 MonthGroup 数据类
- [x] 实现 weightMonthGroupsProvider (按年份+月份分组)
- [x] 实现 selectedYearProvider (年份选择)
- [x] 实现 availableYearsProvider (可用年份列表)
- [x] 实现 MonthHeader 组件 (可折叠月份标题 + 月度统计)
- [x] 实现 expandedMonthsProvider (折叠状态管理)
- [x] 实现 MonthQuickNav 组件 (右侧月份快速导航)
- [x] 重写历史列表 (分组展示 + 年份选择器)
- [x] 实现折叠展开动画
- [x] 实现月份索引点击跳转

---

*文档创建日期: 2026年3月16日*
*最后更新: 2026年3月17日*

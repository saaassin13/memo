# 体重功能设计 (Step 14)

## 功能概述

体重健康管理功能，记录每日体重、体脂、运动情况等数据，支持趋势图展示和多维度统计分析。

---

## 一、体重主页

### 页面布局

```
体重页面 (WeightScreen)
├── 顶部导航栏
│   ├── 返回箭头 (或滑动返回)
│   ├── "体重" 标题
│   └── 📊 统计分析按钮
├── 今日概览卡片
│   ├── 日期显示 (3月16日 周一)
│   ├── 体重数值 (大字体, 如 65.5 kg)
│   ├── 体脂率 (如 18.5%)
│   ├── 今日运动状态 (✅已运动 / ❌未运动)
│   └── 备注摘要
├── 历史记录列表
│   └── 按日期倒序排列
│       ├── 日期
│       ├── 体重 + 体脂
│       └── 运动标记
└── 浮动按钮: + 添加今日数据
```

### 主页详细设计

```
┌─────────────────────────────────────┐
│ [←]  体重                      [📊] │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │      3月16日 周一               │ │
│ │                                 │ │
│ │      65.5 kg                    │ │
│ │      体脂 18.5%                  │ │
│ │                                 │ │
│ │  ✅ 已运动    备注: 今天状态不错  │ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│ 历史记录                             │
│ ┌─────────────────────────────────┐ │
│ │ 3月15日  65.8kg  18.8%  ✅运动  │ │
│ │ 3月14日  66.0kg  19.0%  ❌      │ │
│ │ 3月13日  66.2kg  19.1%  ✅运动  │ │
│ │ ...                            │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
                              [+ 添加]
```

### 今日概览卡片

| 元素 | 显示 | 说明 |
|------|------|------|
| 日期 | 3月16日 周一 | 今日日期 |
| 体重 | 65.5 kg | 大字体加粗 |
| 体脂 | 18.5% | 次要信息 |
| 运动 | ✅ 已运动 / ❌ 未运动 | 图标 + 文字 |
| 备注 | 今天状态不错 | 灰色小字，最多1行 |

### 历史记录列表

每条记录显示：
```
┌─────────────────────────────────────────┐
│ 3月15日 (周六)                 ↓0.3kg  │
│ 65.8 kg  体脂 18.8%          ✅ 运动   │
└─────────────────────────────────────────┘
```

- 日期 + 星期
- 体重数值 + 体脂率
- 与前一天的差值 (↓0.3kg 绿色 / ↑0.3kg 红色)
- 运动状态图标

---

## 二、添加/编辑体重记录

### 页面布局

```
添加体重记录 (WeightEditScreen)
├── 顶部导航栏
│   ├── 返回箭头
│   ├── 标题: "记录体重"
│   └── 保存按钮
├── 日期选择
│   └── 默认今天，可修改
├── 体重输入 (必填)
│   └── 数字输入 + 单位 kg
├── 体脂率输入 (选填)
│   └── 数字输入 + 单位 %
├── 今日是否运动
│   └── 开关按钮 (是/否)
├── 运动类型 (运动时显示)
│   └── 跑步/游泳/健身/瑜伽/其他
├── 运动时长 (选填)
│   └── 数字输入 + 分钟
├── 备注 (选填)
│   └── 多行文本输入
└── 删除按钮 (仅编辑模式)
```

### 字段设计

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| 日期 | 日期选择器 | 是 | 默认今天 |
| 体重 | 数字输入 | 是 | 单位 kg，精确到0.1 |
| 体脂率 | 数字输入 | 否 | 单位 %，精确到0.1 |
| 是否运动 | 开关 | 否 | 默认否 |
| 运动类型 | 单选 | 否 | 跑步/游泳/健身/瑜伽/其他 |
| 运动时长 | 数字输入 | 否 | 单位 分钟 |
| 备注 | 文本输入 | 否 | 最多 200 字符 |

---

## 三、统计分析页面

### 页面布局

```
统计分析页面 (WeightStatsScreen)
├── 顶部导航栏
│   ├── 返回箭头
│   └── "统计分析" 标题
├── 时间范围选择
│   └── [周] [月] [年] 切换按钮
├── 体重趋势图
│   └── 折线图 (X轴日期, Y轴体重)
├── 体脂趋势图
│   └── 折线图 (X轴日期, Y轴体脂%)
├── 关键指标卡片组
│   ├── 平均体重
│   ├── 最低/最高体重
│   ├── 运动次数
│   └── 体重变化
└── 数据汇总
```

### 时间范围选择

```
┌─────────────────────────────────────┐
│    [周]     月     年              │
└─────────────────────────────────────┘
```

- 默认选中"周"
- 切换时图表和统计数据实时更新
- "周": 最近7天
- "月": 最近30天
- "年": 最近365天

### 体重趋势图

```
┌─────────────────────────────────────┐
│ 体重趋势 (近7天)                     │
│                                 67  │
│    ●----●        ●                  │
│  66        ●----●    ●----●      66 │
│  ●                                  │
│  65                               65│
│  ───────────────────────────────────│
│  3/10  3/11  3/12  3/13  3/14  ...  │
└─────────────────────────────────────┘
```

- 折线图，数据点为圆形
- Y轴自动缩放适配数据范围
- X轴显示日期
- 空心点表示无数据的日期
- 点击数据点显示详细信息

### 体脂趋势图

与体重趋势图相同布局，显示体脂率变化。

### 关键指标卡片

```
┌──────────┬──────────┬──────────┬──────────┐
│ 平均体重  │ 最低体重  │ 运动次数  │ 体重变化  │
│  66.2kg  │  65.5kg  │   5次    │  ↓0.7kg │
│  近7天   │  3/14    │  近7天   │  近7天   │
└──────────┴──────────┴──────────┴──────────┘
```

| 指标 | 说明 | 计算方式 |
|------|------|----------|
| 平均体重 | 该周期内平均值 | sum/count |
| 最低体重 | 该周期内最小值 + 日期 | min() |
| 运动次数 | 该周期内运动天数 | count(exercised) |
| 体重变化 | 该周期首尾差值 | last - first (带颜色) |

---

## 四、数据库设计

### 字段扩展

现有 `Weights` 表需要新增字段:

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INTEGER | 主键 |
| value | REAL | 体重 (kg) |
| bodyFat | REAL | 体脂率 % (新增) |
| exercised | BOOLEAN | 是否运动 (新增) |
| exerciseType | TEXT | 运动类型 (新增) |
| exerciseDuration | INTEGER | 运动时长-分钟 (新增) |
| notes | TEXT | 备注 (新增) |
| date | DATETIME | 日期 |
| createdAt | DATETIME | 创建时间 |

### 数据库迁移

- schemaVersion: 5 → 6
- 添加 bodyFat, exercised, exerciseType, exerciseDuration, notes 字段

---

## 五、状态管理

### Providers

```dart
// 当前选中的统计时间范围
enum StatsPeriod { week, month, year }
final weightStatsPeriodProvider = StateProvider<StatsPeriod>((ref) => StatsPeriod.week);

// 体重记录列表流
final weightsProvider = StreamProvider<List<Weight>>((ref) {
  final repository = ref.watch(weightRepositoryProvider);
  return repository.watchAll();
});

// 今日体重记录
final todayWeightProvider = Provider<AsyncValue<Weight?>>((ref) {
  final weightsAsync = ref.watch(weightsProvider);
  return weightsAsync.whenData((weights) {
    final today = DateTime.now();
    try {
      return weights.firstWhere((w) =>
        w.date.year == today.year &&
        w.date.month == today.month &&
        w.date.day == today.day
      );
    } catch (_) {
      return null;
    }
  });
});

// 按时间范围过滤的体重数据
final filteredWeightsProvider = Provider<AsyncValue<List<Weight>>>((ref) {
  final weightsAsync = ref.watch(weightsProvider);
  final period = ref.watch(weightStatsPeriodProvider);

  return weightsAsync.whenData((weights) {
    final now = DateTime.now();
    DateTime startDate;
    switch (period) {
      case StatsPeriod.week:
        startDate = now.subtract(const Duration(days: 7));
        break;
      case StatsPeriod.month:
        startDate = now.subtract(const Duration(days: 30));
        break;
      case StatsPeriod.year:
        startDate = now.subtract(const Duration(days: 365));
        break;
    }
    return weights
        .where((w) => w.date.isAfter(startDate))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  });
});

// 统计数据
final weightStatsProvider = Provider<AsyncValue<WeightStats>>((ref) {
  final filteredAsync = ref.watch(filteredWeightsProvider);
  return filteredAsync.whenData((weights) {
    if (weights.isEmpty) return WeightStats.empty();

    final values = weights.map((w) => w.value).toList();
    final avgWeight = values.reduce((a, b) => a + b) / values.length;
    final minWeight = values.reduce((a, b) => a < b ? a : b);
    final maxWeight = values.reduce((a, b) => a > b ? a : b);
    final exerciseCount = weights.where((w) => w.exercised).length;
    final weightChange = weights.last.value - weights.first.value;

    return WeightStats(
      avgWeight: avgWeight,
      minWeight: minWeight,
      maxWeight: maxWeight,
      exerciseCount: exerciseCount,
      weightChange: weightChange,
      days: weights.length,
    );
  });
});
```

### WeightStats 数据类

```dart
class WeightStats {
  final double avgWeight;
  final double minWeight;
  final double maxWeight;
  final int exerciseCount;
  final double weightChange;
  final int days;

  WeightStats({ ... });
  factory WeightStats.empty() => WeightStats(avgWeight: 0, ...);
}
```

---

## 六、视觉设计

### 配色方案

- 主色: 紫色渐变 `#8B5CF6 → #A855F7`
- 体重上升: 红色 `#EF4444`
- 体重下降: 绿色 `#10B981`
- 体脂: 橙色 `#F59E0B`
- 运动: 绿色 `#10B981`
- 无运动: 灰色 `#9CA3AF`

### 图表样式

- 折线颜色: 紫色 `#8B5CF6`
- 数据点: 白色圆圈 + 紫色边框
- 填充区域: 紫色渐变 (半透明)
- 网格线: 浅灰色虚线

### 圆角与阴影

- 卡片圆角: 16px
- 按钮圆角: 14px
- 图表圆角: 12px
- 阴影: 0 2px 10px rgba(0,0,0,0.04)

---

## 七、文件清单

| 文件 | 说明 | 操作 |
|------|------|------|
| `lib/domain/entities/weight.dart` | 体重实体 | 修改 (扩展字段) |
| `lib/data/database/tables/weights.dart` | 数据库表 | 修改 (新增列) |
| `lib/data/database/database.dart` | 数据库 | 修改 (升级到 v6) |
| `lib/domain/repositories/weight_repository.dart` | 仓储接口 | 查看/修改 |
| `lib/data/repositories/weight_repository_impl.dart` | 仓储实现 | 修改 |
| `lib/presentation/screens/features/weight/weight_screen.dart` | 体重主页 | 重写 |
| `lib/presentation/screens/features/weight/weight_edit_screen.dart` | 编辑页面 | 新增 |
| `lib/presentation/screens/features/weight/weight_stats_screen.dart` | 统计页面 | 新增 |
| `lib/presentation/widgets/weight/weight_trend_chart.dart` | 趋势图组件 | 新增 |
| `lib/presentation/widgets/weight/stats_card.dart` | 统计卡片 | 新增 |
| `lib/presentation/providers/weight_providers.dart` | 状态管理 | 新增 |
| `notes/step14-weight-design.md` | 本设计文档 | 新增 |

---

## 八、开发步骤

### Step 14.1: 数据层
- [ ] 扩展 Weight 实体 (bodyFat, exercised, exerciseType, exerciseDuration, notes)
- [ ] 更新数据库表 (新增列)
- [ ] 升级数据库版本 (v5 → v6)
- [ ] 更新仓储实现

### Step 14.2: 状态管理
- [ ] 创建 weight_providers.dart
- [ ] 实现 weightsProvider
- [ ] 实现 todayWeightProvider
- [ ] 实现 filteredWeightsProvider
- [ ] 实现 weightStatsProvider

### Step 14.3: 主页面
- [ ] 重写 WeightScreen
- [ ] 实现今日概览卡片
- [ ] 实现历史记录列表
- [ ] 实现 FAB 添加按钮
- [ ] 实现滑动返回

### Step 14.4: 编辑页面
- [ ] 创建 WeightEditScreen
- [ ] 实现体重输入
- [ ] 实现体脂率输入
- [ ] 实现运动开关 + 类型 + 时长
- [ ] 实现备注输入
- [ ] 实现保存逻辑

### Step 14.5: 统计页面
- [ ] 创建 WeightStatsScreen
- [ ] 实现时间范围切换
- [ ] 实现体重趋势图
- [ ] 实现体脂趋势图
- [ ] 实现关键指标卡片

---

## 九、交互流程

```
用户打开体重页面
    │
    ▼
显示今日概览 + 历史记录列表
    │
    ├─ 点击+按钮 → 进入添加页面
    │       │
    │       ├─ 输入体重/体脂/运动信息
    │       ├─ 点击保存 → 返回主页
    │       └─ 点击取消 → 返回主页
    │
    ├─ 点击历史记录 → 进入编辑页面
    │
    ├─ 点击📊按钮 → 进入统计页面
    │       │
    │       ├─ 切换周/月/年 → 更新图表
    │       ├─ 查看趋势图
    │       └─ 查看关键指标
    │
    └─ 左滑 → 返回上一页/主页
```

---

*文档创建日期: 2026年3月16日*

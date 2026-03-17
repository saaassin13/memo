# 目标功能完善 (Step 19)

## 现有数据模型

```dart
class Goal {
  final int? id;
  final String name;           // 目标名称
  final int totalSteps;        // 总步数 (默认100)
  final int completedSteps;    // 已完成步数
  final DateTime? deadline;    // 截止日期
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

---

## 一、页面结构

```
目标页面 (GoalScreen)
├── 顶部导航栏
│   ├── 返回箭头
│   ├── "目标" 标题 + 渐变图标
│   ├── 搜索按钮
│   └── 筛选按钮 (全部/进行中/已完成/已逾期)
├── 统计概览卡片
│   ├── 目标总数
│   ├── 进行中
│   ├── 已完成
│   └── 已逾期
├── 目标列表
│   └── 目标卡片 (按状态分组或按截止日期排序)
│       ├── 进度环 / 进度条
│       ├── 目标名称
│       ├── 截止日期 + 剩余天数
│       ├── 进度百分比
│       └── 快捷操作 (+1/-1 步)
└── 浮动按钮: + 新建目标
```

---

## 二、目标卡片设计

### 卡片布局

```
┌─────────────────────────────────────────┐
│  ┌────┐                                │
│  │75% │  学习 Flutter                  │
│  │ ◉  │  截止: 2026-04-30 · 剩余44天   │
│  └────┘  ████████████████░░░░ 75/100   │
│         [−]  [标记完成]  [+]           │
└─────────────────────────────────────────┘
```

### 卡片元素

| 元素 | 说明 |
|------|------|
| 进度环 | 圆形进度指示器，显示百分比 |
| 目标名称 | 大字加粗，最多2行 |
| 截止日期 | 灰色小字，显示绝对日期 + 剩余天数 |
| 进度条 | 细长条，带渐变填充 |
| 快捷按钮 | 减少/标记完成/增加 步数 |

### 状态标识

| 状态 | 视觉表现 |
|------|---------|
| 进行中 | 进度环紫色渐变，正常显示 |
| 已完成 | 进度环绿色，卡片带绿色边角标记 ✓ |
| 已逾期 | 进度环红色，显示"已逾期X天" |
| 未开始 | 进度环灰色，显示"未开始" |

### 颜色方案

| 状态 | 主色 | 进度条 |
|------|------|--------|
| 进行中 | `#8B5CF6` 紫色 | 紫色渐变 |
| 已完成 | `#10B981` 绿色 | 绿色 |
| 已逾期 | `#EF4444` 红色 | 红色渐变 |
| 未开始 | `#9CA3AF` 灰色 | 灰色 |

---

## 三、新建/编辑目标弹窗

### 布局

```
┌─────────────────────────────────────┐
│           新建目标                   │
├─────────────────────────────────────┤
│  目标名称                            │
│  ┌─────────────────────────────────┐ │
│  │ 学习 Flutter                    │ │
│  └─────────────────────────────────┘ │
│                                     │
│  目标进度类型                        │
│  ○ 百分比 (0-100%)                  │
│  ○ 次数 (如: 读10本书)              │
│  ○ 天数 (如: 坚持30天)              │
│                                     │
│  总步数                              │
│  ┌─────────────────────────────────┐ │
│  │ 100                            │ │
│  └─────────────────────────────────┘ │
│                                     │
│  截止日期 (可选)                     │
│  ┌─────────────────────────────────┐ │
│  │ 2026年4月30日    📅             │ │
│  └─────────────────────────────────┘ │
│                                     │
│  备注 (可选)                         │
│  ┌─────────────────────────────────┐ │
│  │ 每天学习一点点...               │ │
│  └─────────────────────────────────┘ │
│                                     │
│     [取消]         [创建目标]        │
└─────────────────────────────────────┘
```

### 字段说明

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| 目标名称 | 文本输入 | 是 | 最多50字符 |
| 进度类型 | 单选 | 是 | 百分比/次数/天数 |
| 总步数 | 数字输入 | 是 | 最小1，最大9999 |
| 截止日期 | 日期选择 | 否 | 默认无限制 |
| 备注 | 文本输入 | 否 | 最多200字符 |

---

## 四、进度追踪

### 交互方式

**方式1: 卡片快捷按钮**
- 点击 `[+]` 增加1步
- 点击 `[−]` 减少1步
- 点击 `[标记完成]` 直接设为100%

**方式2: 点击进入详情页**
- 点击卡片进入目标详情
- 详情页可手动输入精确进度值

### 进度详情页

```
┌─────────────────────────────────────┐
│ [←]  目标详情                   [⋯] │
├─────────────────────────────────────┤
│                                     │
│         ┌─────────┐                 │
│         │   75%   │  进度环          │
│         │  75/100 │                  │
│         └─────────┘                 │
│                                     │
│   学习 Flutter                       │
│   截止: 2026-04-30 · 剩余44天       │
│                                     │
│  ┌─────────────────────────────────┐ │
│  │ 进度调整                        │ │
│  │                                 │ │
│  │    [−10] [−1]  [75]  [+1] [+10]│ │
│  │                                 │ │
│  │  ════════════════════░░░░░░░░░  │ │
│  │  0                  75      100 │ │
│  └─────────────────────────────────┘ │
│                                     │
│  进度记录                            │
│  ┌─────────────────────────────────┐ │
│  │ 3月17日  75/100 (+3)    ✅      │ │
│  │ 3月16日  72/100 (+5)    ✅      │ │
│  │ 3月15日  67/100 (+2)    ✅      │ │
│  │ ...                            │ │
│  └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

### 进度记录 (ProgressLog)

需要新增进度记录表，记录每次进度变更：

```dart
class GoalProgressLog {
  final int? id;
  final int goalId;          // 关联目标
  final int stepBefore;      // 变更前步数
  final int stepAfter;       // 变更后步数
  final DateTime createdAt;  // 记录时间
}
```

---

## 五、筛选与排序

### 筛选选项

| 筛选 | 说明 |
|------|------|
| 全部 | 显示所有目标 |
| 进行中 | 未完成且未逾期 |
| 已完成 | completedSteps >= totalSteps |
| 已逾期 | 有截止日期且已过期且未完成 |

### 排序选项

| 排序 | 说明 |
|------|------|
| 截止日期近优先 | 按 deadline 升序，无截止日期排最后 |
| 截止日期远优先 | 按 deadline 降序 |
| 创建时间新优先 | 按 createdAt 降序 |
| 进度高优先 | 按完成百分比降序 |

---

## 六、空状态

```
┌─────────────────────────────────────┐
│                                     │
│           ┌─────────┐               │
│           │   🎯    │               │
│           └─────────┘               │
│                                     │
│         还没有目标                   │
│      设定目标，一步步实现            │
│                                     │
│       [ + 创建第一个目标 ]           │
│                                     │
└─────────────────────────────────────┘
```

---

## 七、目标完成动画

当 `completedSteps >= totalSteps` 时：
- 播放完成动画 (进度环填充动画 + 庆祝图标)
- 显示 SnackBar "恭喜完成目标! 🎉"
- 卡片变为绿色已完成状态

---

## 八、数据库设计

### 新增表: goal_progress_logs

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INTEGER | 主键 |
| goalId | INTEGER | 外键关联 goals.id |
| stepBefore | INTEGER | 变更前步数 |
| stepAfter | INTEGER | 变更后步数 |
| createdAt | DATETIME | 记录时间 |

### 数据库迁移

- schemaVersion: 6 → 7
- 新增 goal_progress_logs 表

---

## 九、状态管理 (Providers)

```dart
// 目标列表流
final goalsProvider = StreamProvider<List<Goal>>((ref) { ... });

// 筛选状态
enum GoalFilter { all, inProgress, completed, overdue }
final goalFilterProvider = StateProvider<GoalFilter>((ref) => GoalFilter.all);

// 排序状态
enum GoalSort { deadlineAsc, deadlineDesc, createdAtDesc, progressDesc }
final goalSortProvider = StateProvider<GoalSort>((ref) => GoalSort.deadlineAsc);

// 过滤排序后的目标列表
final filteredGoalsProvider = Provider<AsyncValue<List<Goal>>>((ref) { ... });

// 目标统计
final goalStatsProvider = Provider<AsyncValue<GoalStats>>((ref) { ... });

// 目标进度记录流
final goalProgressLogsProvider = StreamProvider.family<List<GoalProgressLog>, int>((ref, goalId) { ... });
```

---

## 十、文件清单

| 文件 | 说明 | 操作 |
|------|------|------|
| `lib/domain/entities/goal.dart` | 目标实体 | 修改 (扩展方法) |
| `lib/domain/entities/goal_progress_log.dart` | 进度记录实体 | 新增 |
| `lib/data/database/tables/goals.dart` | 目标表 | 查看 |
| `lib/data/database/tables/goal_progress_logs.dart` | 进度记录表 | 新增 |
| `lib/data/database/database.dart` | 数据库 | 修改 (v7迁移) |
| `lib/domain/repositories/goal_repository.dart` | 仓储接口 | 修改 |
| `lib/data/repositories/goal_repository_impl.dart` | 仓储实现 | 修改 |
| `lib/presentation/screens/features/goal/goal_screen.dart` | 目标主页 | 重写 |
| `lib/presentation/screens/features/goal/goal_detail_screen.dart` | 目标详情页 | 新增 |
| `lib/presentation/widgets/goal/goal_card.dart` | 目标卡片组件 | 新增 |
| `lib/presentation/widgets/goal/goal_edit_dialog.dart` | 新建/编辑弹窗 | 新增 |
| `lib/presentation/widgets/goal/progress_ring.dart` | 进度环组件 | 新增 |
| `lib/presentation/providers/goal_providers.dart` | 状态管理 | 新增 |
| `notes/step19-goal-design.md` | 本设计文档 | 新增 |

---

*文档创建日期: 2026年3月17日*

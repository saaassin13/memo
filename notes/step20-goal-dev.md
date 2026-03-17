# 目标功能开发 (Step 20)

## 开发进度

### Step 20.1: 数据层 ✅

- [x] 扩展 Goal 实体 (计算属性: progress, progressPercent, isCompleted, isOverdue, daysRemaining, statusText)
- [x] 创建 GoalProgressLog 实体
- [x] 新增 goal_progress_logs 表
- [x] 升级数据库版本 (v6 → v7)
- [x] 更新仓储接口 (新增 watchProgressLogs, insertProgressLog, updateProgress)
- [x] 更新仓储实现 (支持进度记录 CRUD)
- [x] 运行 build_runner 重新生成代码

**文件清单:**

| 文件 | 操作 | 说明 |
|------|------|------|
| `lib/domain/entities/goal.dart` | ✅ 已修改 | 新增计算属性 |
| `lib/domain/entities/goal_progress_log.dart` | ✅ 已创建 | 进度记录实体 |
| `lib/data/database/tables/goal_progress_logs.dart` | ✅ 已创建 | 进度记录表 |
| `lib/data/database/database.dart` | ✅ 已修改 | schemaVersion 6→7 |
| `lib/domain/repositories/goal_repository.dart` | ✅ 已修改 | 新增进度记录接口 |
| `lib/data/repositories/goal_repository_impl.dart` | ✅ 已修改 | 支持进度记录 CRUD |

---

### Step 20.2: 状态管理 ✅

- [x] 创建 goal_providers.dart
- [x] 实现 goalsProvider (目标列表流)
- [x] 实现 goalFilterProvider (筛选: 全部/进行中/已完成/已逾期)
- [x] 实现 goalSortProvider (排序: 截止日期/创建时间/进度)
- [x] 实现 filteredGoalsProvider (过滤排序后的列表)
- [x] 实现 goalStatsProvider (统计: 总数/进行中/已完成/已逾期)
- [x] 实现 goalProgressLogsProvider (进度记录流)

**文件清单:**

| 文件 | 操作 | 说明 |
|------|------|------|
| `lib/presentation/providers/goal_providers.dart` | ✅ 已创建 | 目标状态管理 |

---

### Step 20.3: 组件开发 ✅

- [x] 创建 ProgressRing 进度环组件 (自定义 Canvas 绘制)
- [x] 创建 GoalCard 目标卡片组件 (进度环/名称/日期/进度条/快捷按钮)
- [x] 创建 GoalEditDialog 新建/编辑弹窗

**文件清单:**

| 文件 | 操作 | 说明 |
|------|------|------|
| `lib/presentation/widgets/goal/progress_ring.dart` | ✅ 已创建 | 进度环组件 |
| `lib/presentation/widgets/goal/goal_card.dart` | ✅ 已创建 | 目标卡片组件 |
| `lib/presentation/widgets/goal/goal_edit_dialog.dart` | ✅ 已创建 | 新建/编辑弹窗 |

---

### Step 20.4: 主页面 ✅

- [x] 重写 GoalScreen
- [x] 实现统计概览卡片 (总数/进行中/已完成/已逾期)
- [x] 实现筛选栏 (全部/进行中/已完成/已逾期)
- [x] 实现排序菜单 (截止日期/创建时间/进度)
- [x] 实现目标列表 (带空状态)
- [x] 实现卡片快捷操作 (+1/-1/标记完成)
- [x] 实现下拉刷新

**文件清单:**

| 文件 | 操作 | 说明 |
|------|------|------|
| `lib/presentation/screens/features/goal/goal_screen.dart` | ✅ 已重写 | 目标主页面 |

---

### Step 20.5: 详情页 ✅

- [x] 创建 GoalDetailScreen
- [x] 实现大进度环展示
- [x] 实现进度调整控件 (±1/±10/手动输入)
- [x] 实现进度记录列表
- [x] 实现标记完成按钮
- [x] 实现删除功能

**文件清单:**

| 文件 | 操作 | 说明 |
|------|------|------|
| `lib/presentation/screens/features/goal/goal_detail_screen.dart` | ✅ 已创建 | 目标详情页 |

---

## 已创建文件列表

| 文件 | 说明 | 状态 |
|------|------|------|
| `lib/domain/entities/goal_progress_log.dart` | 进度记录实体 | ✅ |
| `lib/data/database/tables/goal_progress_logs.dart` | 进度记录表 | ✅ |
| `lib/presentation/providers/goal_providers.dart` | 目标状态管理 | ✅ |
| `lib/presentation/widgets/goal/progress_ring.dart` | 进度环组件 | ✅ |
| `lib/presentation/widgets/goal/goal_card.dart` | 目标卡片组件 | ✅ |
| `lib/presentation/widgets/goal/goal_edit_dialog.dart` | 新建/编辑弹窗 | ✅ |
| `lib/presentation/screens/features/goal/goal_detail_screen.dart` | 目标详情页 | ✅ |

## 已修改文件列表

| 文件 | 修改内容 | 状态 |
|------|------|------|
| `lib/domain/entities/goal.dart` | 新增计算属性 | ✅ |
| `lib/data/database/database.dart` | schemaVersion 6→7, 新增 goalProgressLogs 表 | ✅ |
| `lib/domain/repositories/goal_repository.dart` | 新增进度记录接口 | ✅ |
| `lib/data/repositories/goal_repository_impl.dart` | 支持进度记录 CRUD | ✅ |
| `lib/presentation/screens/features/goal/goal_screen.dart` | 重写主页面 | ✅ |

---

## 功能说明

### 主页面
- 统计概览：总数/进行中/已完成/已逾期 四宫格
- 筛选：全部/进行中/已完成/已逾期 筛选芯片
- 排序：截止日期近优先/远优先、创建时间新优先、进度高优先
- 目标卡片：进度环、名称、截止日期、进度条、快捷操作按钮
- 空状态：引导创建第一个目标

### 详情页
- 大进度环：160px，显示百分比和步数
- 进度调整：-10/-1/+1/+10 按钮，点击数字手动输入
- 标记完成：一键设为100%
- 进度记录：显示每次变更的时间和步数变化
- 删除功能：确认后删除目标及关联记录

### 编辑弹窗
- 目标名称输入
- 总步数设置（默认100）
- 截止日期选择（可选）
- 新建/编辑两种模式

---

*文档创建日期: 2026年3月17日*

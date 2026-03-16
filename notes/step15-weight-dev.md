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

*文档创建日期: 2026年3月16日*
*最后更新: 2026年3月16日*

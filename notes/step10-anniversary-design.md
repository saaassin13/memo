# 纪念日功能设计 (Step 10)

## 功能概述

纪念日功能用于记录和提醒重要的日期（生日、结婚纪念日、节日等），支持公历/农历切换、倒数天数显示、重复提醒等功能。

---

## 一、纪念日展示列表

### 页面布局

```
纪念日页面 (AnniversaryScreen)
├── 顶部导航栏
│   ├── 标题: "纪念日"
│   └── 搜索按钮 (点击展开搜索框)
├── 搜索框 (展开时显示，支持按名称搜索)
├── 纪念日列表 (按倒计时排序，最近的在前)
│   └── 纪念日卡片 (AnniversaryTile)
│       ├── 左侧: 倒数天数
│       ├── 中间: 名称 + 日期
│       └── 右侧: 关系标签
├── 空状态提示
└── 浮动按钮: 新增纪念日
```

### 列表展示内容

| 字段 | 说明 | 示例 |
|------|------|------|
| 纪念日名称 | 用户自定义标题 | "妈妈生日"、"结婚纪念日" |
| 纪念日时间 | 公历/农历 + 日期 | "2026年5月15日" 或 "农历八月初八" |
| 倒数天数 | 距离下次日期的天数 | "还有 23 天"、"今天！" |
| 关系标签 | 分类标签 | 亲人、爱人、朋友等 |

### 纪念日卡片设计

```
┌─────────────────────────────────────────────┐
│ ┌──────┐                                    │
│ │  23  │  妈妈生日                    [亲人] │
│ │ 天后  │  2026年5月15日 · 农历三月初八      │
│ └──────┘  每年重复 · 提前1天提醒             │
└─────────────────────────────────────────────┘
```

- 倒数区域: 左侧大数字 + "天后"/"今天！"/"已过"
- 名称: 粗体大字
- 日期: 公历 + 农历并排显示
- 关系标签: 彩色圆角标签
- 重复/提醒: 灰色小字

---

## 二、新增/编辑纪念日页面

### 页面布局

```
新增纪念日 (AnniversaryEditScreen)
├── 顶部导航栏
│   ├── 返回按钮
│   ├── 标题: "新增纪念日" / "编辑纪念日"
│   └── 保存按钮
└── 表单区域
    ├── 标题输入框
    ├── 日期选择器 (公历/农历切换)
    ├── 提醒时间选择
    ├── 重复方式选择
    ├── 关系选择
    ├── 手机号输入 (可选)
    ├── 备忘输入 (可选)
    └── 删除按钮 (仅编辑模式)
```

### 字段设计

#### 1. 标题
- 类型: 文本输入框
- 占位符: "请输入纪念日名称"
- 验证: 必填，最多 30 个字符

#### 2. 日期
- 类型: 日期选择器 + 公历/农历切换
- 设计:
  ```
  ┌─────────────────────────────────────┐
  │  日期                        [公历▼]│
  │  ┌───────────────────────────────┐  │
  │  │  2026 年  5 月  15 日         │  │
  │  └───────────────────────────────┘  │
  │  农历对应: 三月初八                 │
  └─────────────────────────────────────┘
  ```
- 切换开关: 公历 ↔ 农历
- 选择农历时显示对应公历日期，反之亦然

#### 3. 提醒时间
- 类型: 下拉选择 / 弹窗选择
- 选项:
  - 当天 (09:00)
  - 提前 1 天
  - 提前 2 天
  - 提前 3 天
  - 提前 1 周
  - 提前 2 周
  - 提前 1 个月
  - 自定义 (选择具体天数)
- 支持多选（可同时设置多个提醒时间）

#### 4. 重复
- 类型: 单选
- 选项:
  - 每年重复 (默认选中)
  - 不重复 (一次性)
- 说明: "每年重复的纪念日会自动计算下一次日期"

#### 5. 关系
- 类型: 标签选择 (单选)
- 选项:
  - 亲人 (蓝色)
  - 爱人 (粉色)
  - 朋友 (绿色)
  - 同事 (灰色)
  - 小孩 (橙色)
  - 自定义 (紫色，选择后可输入自定义名称)
- 设计: 横向标签按钮组

#### 6. 手机号 (可选)
- 类型: 电话号码输入框
- 说明: "可选，用于发送提醒短信"
- 验证: 手机号格式校验 (11位数字)

#### 7. 备忘 (可选)
- 类型: 多行文本输入框
- 说明: "添加备注信息"
- 最多 200 个字符

---

## 三、数据库设计

### 纪念日表 (Anniversaries)

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INTEGER | 主键 |
| title | TEXT | 纪念日名称 |
| date | TEXT | 日期 (ISO格式) |
| isLunar | BOOLEAN | 是否农历 |
| reminderDays | INTEGER | 提前几天提醒 (0=当天, 1=提前1天...) |
| repeatYearly | BOOLEAN | 每年重复 |
| relationship | TEXT | 关系分类 |
| customRelation | TEXT | 自定义关系名称 |
| phoneNumber | TEXT | 手机号 (可选) |
| notes | TEXT | 备注 |
| createdAt | DATETIME | 创建时间 |
| updatedAt | DATETIME | 更新时间 |

---

## 四、Provider 设计

```dart
// 搜索关键词
final anniversarySearchProvider = StateProvider<String>((ref) => '');

// 纪念日列表 (按倒计时排序，支持搜索)
final anniversariesProvider = StreamProvider<List<Anniversary>>
final filteredAnniversariesProvider = Provider<List<Anniversary>>
  - 按搜索关键词过滤名称
  - 按下次日期排序 (最近的在前)

// 即将到来的纪念日 (未来30天)
final upcomingAnniversariesProvider = Provider<List<Anniversary>>

// 日历视图中的纪念日标记
final anniversaryEventsProvider = Provider.family<List<Anniversary>, DateTime>
```

---

## 五、视觉设计

### 配色方案
- 主色: 粉色 #F5576C → #FF6B8A (纪念日主题色)
- 关系标签色:
  - 亲人: 蓝色 #4F46E5
  - 爱人: 粉色 #EC4899
  - 朋友: 绿色 #10B981
  - 同事: 灰色 #6B7280
  - 小孩: 橙色 #F59E0B
  - 自定义: 紫色 #8B5CF6

### 圆角与阴影
- 卡片圆角: 16px
- 标签圆角: 14px
- 输入框圆角: 12px
- 阴影: 0 2px 10px rgba(0,0,0,0.04)

---

## 六、文件清单

| 文件 | 说明 |
|------|------|
| `lib/domain/entities/anniversary.dart` | 纪念日实体 |
| `lib/data/database/tables/anniversaries.dart` | 数据库表定义 |
| `lib/data/repositories/anniversary_repository_impl.dart` | 仓储实现 |
| `lib/domain/repositories/anniversary_repository.dart` | 仓储接口 |
| `lib/presentation/screens/anniversary/anniversary_screen.dart` | 列表页面 |
| `lib/presentation/screens/anniversary/anniversary_edit_screen.dart` | 编辑页面 |
| `lib/presentation/widgets/anniversary/anniversary_tile.dart` | 列表项组件 |
| `lib/presentation/widgets/anniversary/date_picker_field.dart` | 日期选择器 |
| `lib/presentation/providers/anniversary_providers.dart` | 状态管理 |
| `notes/step10-anniversary-design.md` | 本设计文档 |

---

## 七、与日历页面的集成

- 日历页面标记纪念日日期 (粉色圆点)
- 点击日期显示纪念日详情
- 从日历页面可直接新增纪念日
- 纪念日 Provider 复用于日历页面的 `anniversaryEventsProvider`

---

## 八、农历功能

### 需求
- 支持公历与农历之间的转换
- 选择农历日期时，自动显示对应的公历日期
- 农历重复纪念日需每年自动计算对应的公历日期

### 实现方案
- 引入农历转换库 (如 `lunar_calendar`)
- 数据库存储统一使用公历日期
- `isLunar` 字段标记原始选择
- 每年计算下一次纪念日时进行农历转换

---

*文档创建日期: 2026年3月16日*

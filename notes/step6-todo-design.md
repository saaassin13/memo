# Todo 页面设计 (Step 6)

## 概述

Todo 页面是底部导航的第二个 Tab，用于任务管理。包含待办列表、已办列表、分类筛选、新增/编辑功能。

---

## 页面结构

```
┌─────────────────────────────────────┐
│           Todo 页面                  │
├─────────────────────────────────────┤
│  AppBar: 标题 + 筛选/排序图标         │
├─────────────────────────────────────┤
│  分类标签栏 (横向滚动)                │
│  [全部] [工作] [生活] [学习] [杂项] [+]│
├─────────────────────────────────────┤
│  待办列表                            │
│  ┌─────────────────────────────┐    │
│  │ ☐ 任务标题              标签 │    │
│  │   截止时间: 2024-01-15       │    │
│  └─────────────────────────────┘    │
│  ┌─────────────────────────────┐    │
│  │ ☐ 任务标题              标签 │    │
│  │   截止时间: 2024-01-16       │    │
│  └─────────────────────────────┘    │
├─────────────────────────────────────┤
│  已办列表 (可折叠)                    │
│  ▼ 已完成 (3)                       │
│  ┌─────────────────────────────┐    │
│  │ ☑ 任务标题              标签 │    │
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
                          [+ 新增按钮]
```

---

## 模块设计

### 1. 顶部导航 (AppBar)

| 元素 | 功能 |
|------|------|
| 标题 | 显示「Todo」或「待办」 |
| 筛选按钮 | 弹出筛选菜单（按状态/按时间） |
| 排序按钮 | 弹出排序菜单（按截止时间/按创建时间） |

**筛选选项：**
- 全部
- 待处理
- 已完成

**排序选项：**
- 截止时间（默认：近到远）
- 创建时间（近到远）
- 名称（A-Z）

### 2. 分类标签栏

与备忘录页面共用 `CategoryChips` 组件，分类选项：
- 全部
- 工作
- 生活
- 学习
- 杂项
- + (新增分类)

### 3. 待办列表

**列表项结构：**
```
┌────────────────────────────────────────┐
│ [勾选框]  任务标题              [分类标签]│
│          截止时间: YYYY-MM-DD HH:mm    │
└────────────────────────────────────────┘
```

**交互：**
- 点击勾选框：切换完成状态
- 点击任务项：打开编辑弹窗
- 长按任务项：显示操作菜单（编辑/删除）
- 左滑：删除
- 右滑：编辑

**状态样式：**
- 未过期：正常显示
- 已过期：红色文字提示
- 今日到期：橙色文字提示

### 4. 已办列表

- 默认折叠，显示已完成数量
- 点击展开显示所有已完成任务
- 已完成任务显示删除线样式

### 5. 新增/编辑弹窗

**触发方式：** 点击右下角 FAB 按钮

**弹窗结构：**
```
┌─────────────────────────────────────┐
│  新建待办                    [X]    │
├─────────────────────────────────────┤
│  任务标题                            │
│  ┌─────────────────────────────┐    │
│  │ 输入任务标题...              │    │
│  └─────────────────────────────┘    │
│                                     │
│  截止时间                            │
│  ┌─────────────────────────────┐    │
│  │ 选择日期和时间          [📅] │    │
│  └─────────────────────────────┘    │
│                                     │
│  分类                                │
│  [工作] [生活] [学习] [杂项]          │
│                                     │
│  备注                                │
│  ┌─────────────────────────────┐    │
│  │ 输入备注（可选）...           │    │
│  └─────────────────────────────┘    │
│                                     │
│  [取消]              [保存]          │
└─────────────────────────────────────┘
```

**字段说明：**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| 任务标题 | 文本输入 | 是 | 最长 100 字符 |
| 截止时间 | 日期时间选择器 | 否 | 可选择日期和时间 |
| 分类 | 单选 Chips | 否 | 默认「杂项」 |
| 备注 | 多行文本 | 否 | 最长 500 字符 |

---

## 数据模型

### Todo 实体

```dart
class Todo {
  final int? id;           // 主键
  final String title;      // 任务标题
  final String? description; // 备注
  final String category;   // 分类
  final bool isCompleted;  // 是否完成
  final DateTime? dueDate; // 截止时间
  final DateTime createdAt; // 创建时间
  final DateTime updatedAt; // 更新时间
}
```

### 数据库表

```dart
class Todos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get category => text().withDefault(const Constant('杂项'))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
```

---

## 组件设计

### 组件列表

| 组件 | 文件 | 说明 |
|------|------|------|
| TodoScreen | `screens/todo/todo_screen.dart` | 主页面 |
| TodoListTile | `widgets/todo/todo_list_tile.dart` | 任务列表项 |
| TodoEditDialog | `widgets/todo/todo_edit_dialog.dart` | 新建/编辑弹窗 |
| CompletedSection | `widgets/todo/completed_section.dart` | 已完成区域 |
| CategoryChips | `widgets/memo/category_chips.dart` | 分类标签栏（复用） |

### TodoListTile 设计

```
┌─────────────────────────────────────────────────────┐
│  Checkbox    标题文本                        Chip   │
│              副标题（截止时间）                          │
└─────────────────────────────────────────────────────┘
```

**属性：**
- `todo`: Todo 对象
- `onToggle`: 勾选回调
- `onTap`: 点击回调
- `onLongPress`: 长按回调

**样式：**
- 未完成：正常文字
- 已完成：删除线 + 灰色文字
- 已过期：红色截止时间
- 今日到期：橙色截止时间

### TodoEditDialog 设计

**新建模式：**
- 标题：「新建待办」
- 保存按钮：创建新记录

**编辑模式：**
- 标题：「编辑待办」
- 保存按钮：更新记录

---

## 状态管理

### Providers

| Provider | 说明 |
|----------|------|
| `todosProvider` | 全部 Todo 列表流 |
| `filteredTodosProvider` | 过滤后的 Todo 列表 |
| `todoCategoryProvider` | 当前选中的分类 |
| `todoFilterProvider` | 筛选状态（全部/待处理/已完成） |
| `todoSortProvider` | 排序方式 |

### 过滤逻辑

```
filteredTodos = todos
  .where(分类匹配)
  .where(筛选状态匹配)
  .sorted(排序方式)
```

---

## 路由配置

```
/todo              -> TodoScreen (底部导航)
/todo/edit         -> 弹窗模式（新建）
/todo/edit?id=1    -> 弹窗模式（编辑）
```

---

## 文件结构

```
lib/presentation/
├── providers/
│   ├── todo_providers.dart      # 新增
│   └── repository_providers.dart # 更新（添加 todoRepositoryProvider）
├── screens/
│   └── todo/
│       └── todo_screen.dart     # 更新
└── widgets/
    └── todo/
        ├── todo_list_tile.dart  # 新增
        ├── todo_edit_dialog.dart # 新增
        └── completed_section.dart # 新增
```

---

## 开发步骤

### Step 6.1: 创建 Providers
- [ ] 创建 todo_providers.dart
- [ ] 添加 todoRepositoryProvider
- [ ] 添加 todosProvider
- [ ] 添加 filteredTodosProvider
- [ ] 添加分类/筛选/排序状态

### Step 6.2: 实现列表页面
- [ ] 更新 TodoScreen 布局
- [ ] 实现分类标签栏
- [ ] 实现待办列表
- [ ] 实现已办列表（可折叠）
- [ ] 实现 FAB 按钮
- [ ] 实现空状态

### Step 6.3: 实现新建/编辑
- [ ] 创建 TodoEditDialog
- [ ] 实现标题输入
- [ ] 实现截止时间选择
- [ ] 实现分类选择
- [ ] 实现备注输入
- [ ] 实现保存/取消逻辑

### Step 6.4: 实现交互逻辑
- [ ] 勾选切换完成状态
- [ ] 删除待办
- [ ] 编辑待办
- [ ] 分类筛选
- [ ] 状态筛选
- [ ] 排序功能

---

## 交互细节

### 勾选完成
1. 用户点击勾选框
2. 更新 isCompleted 状态
3. 待办列表移除该任务
4. 已办列表添加该任务
5. 显示 SnackBar 提示

### 删除待办
1. 左滑任务项 或 长按选择删除
2. 弹出确认对话框
3. 确认后删除
4. 显示 SnackBar 提示

### 编辑待办
1. 点击任务项 或 右滑
2. 弹出编辑弹窗
3. 修改内容
4. 保存更新

---

## 样式规范

### 颜色
- 主色调：与 App 主题一致
- 分类标签：工作(蓝)、生活(绿)、学习(橙)、杂项(灰)
- 过期提醒：红色
- 今日提醒：橙色

### 间距
- 列表项内边距：16px
- 列表项间距：8px
- 卡片圆角：12px

### 动画
- 列表项滑动：300ms ease-out
- 勾选状态切换：200ms
- 折叠展开：300ms ease-in-out

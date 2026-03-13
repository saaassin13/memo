# Todo 功能开发进度 (Step 7)

## 开发步骤

### Step 7.1: 创建 Providers 和状态管理
- [x] 创建 todo_providers.dart (列表数据流)
- [x] 添加 todoRepositoryProvider (已存在)
- [x] 创建分类/筛选/排序状态 Providers

### Step 7.2: 实现列表页面
- [x] 更新 TodoScreen 布局
- [x] 实现分类标签栏组件 (TodoCategoryChips)
- [x] 实现待办列表
- [x] 实现已办列表（可折叠）
- [x] 实现 FAB 按钮
- [x] 实现空状态组件

### Step 7.3: 实现新建/编辑
- [x] 创建 TodoEditDialog 组件
- [x] 实现标题输入
- [x] 实现截止时间选择
- [x] 实现分类选择
- [x] 实现备注输入
- [x] 实现保存/取消逻辑

### Step 7.4: 实现交互逻辑
- [x] 勾选切换完成状态
- [x] 删除待办
- [x] 编辑待办
- [x] 分类筛选
- [x] 状态筛选
- [x] 排序功能

---

## 详细文件列表

### 7.1 Providers

| 文件 | 说明 | 状态 |
|------|------|------|
| `providers/todo_providers.dart` | Todo 列表 Provider | ✅ |
| `providers/repository_providers.dart` | 已存在 todoRepositoryProvider | ✅ |

### 7.2 列表页面组件

| 文件 | 说明 | 状态 |
|------|------|------|
| `screens/todo/todo_screen.dart` | Todo 列表页 | ✅ |
| `widgets/todo/todo_category_chips.dart` | 分类标签栏 | ✅ |
| `widgets/todo/todo_list_tile.dart` | 任务列表项 | ✅ |
| `widgets/todo/completed_section.dart` | 已完成区域 | ✅ |
| `widgets/todo/empty_todo.dart` | 空状态组件 | ✅ |

### 7.3 编辑弹窗组件

| 文件 | 说明 | 状态 |
|------|------|------|
| `widgets/todo/todo_edit_dialog.dart` | 新建/编辑弹窗 | ✅ |

---

## 交互功能

| 功能 | 说明 | 状态 |
|------|------|------|
| 分类筛选 | 按分类筛选待办 | ✅ |
| 状态筛选 | 全部/待处理/已完成 | ✅ |
| 排序 | 按截止时间/创建时间/名称 | ✅ |
| 新增 | 创建新待办 | ✅ |
| 编辑 | 修改待办 | ✅ |
| 删除 | 删除待办 | ✅ |
| 完成标记 | 勾选切换完成状态 | ✅ |
| 滑动操作 | 左滑删除/右滑编辑 | ✅ |
| 下拉刷新 | 刷新列表 | ✅ |

---

## 当前进度

### 已完成
- [x] 项目基础框架搭建
- [x] 数据库表定义
- [x] Repository 接口和实现
- [x] 路由配置
- [x] 备忘录列表页面
- [x] 新建/编辑页面
- [x] 搜索和分类筛选
- [x] CRUD 操作
- [x] Todo 列表页面
- [x] 新建/编辑弹窗
- [x] 分类/筛选/排序

### 待完成
- [ ] 测试和优化

---

## 页面文件结构

```
lib/presentation/
├── providers/
│   ├── repository_providers.dart    # 已存在
│   ├── todo_providers.dart          # 新增
│   └── memo_providers.dart          # 已存在
├── screens/
│   ├── todo/
│   │   └── todo_screen.dart         # 更新
│   └── features/memo/
│       ├── memo_list_screen.dart    # 已存在
│       └── memo_edit_screen.dart    # 已存在
└── widgets/
    ├── todo/
    │   ├── todo_category_chips.dart # 新增
    │   ├── todo_list_tile.dart      # 新增
    │   ├── completed_section.dart   # 新增
    │   ├── empty_todo.dart          # 新增
    │   └── todo_edit_dialog.dart    # 新增
    └── memo/
        ├── category_chips.dart      # 已存在
        ├── memo_card.dart           # 已存在
        └── ...
```

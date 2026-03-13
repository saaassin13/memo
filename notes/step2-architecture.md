# 备忘录 App 架构设计 (Step 2)

## 技术选型

| 类别 | 选择 | 说明 |
|------|------|------|
| 框架 | Flutter 3.x | 跨平台，性能好 |
| 语言 | Dart 3.x | Flutter 官方语言 |
| 状态管理 | Riverpod | 轻量、编译安全、易测试 |
| 路由 | GoRouter | 声明式路由，支持深层链接 |
| 本地存储 | Drift (SQLite) | 类型安全，ORM 支持 |
| UI 组件 | Material Design 3 | Google 官方设计语言 |

---

## 项目结构 (Clean Architecture)

```
lib/
├── main.dart                    # 入口文件
├── app.dart                     # App 根组件
│
├── core/                        # 核心层（公共代码）
│   ├── constants/               # 常量定义
│   ├── theme/                   # 主题配置
│   ├── utils/                   # 工具类
│   └── extensions/              # 扩展方法
│
├── data/                        # 数据层
│   ├── database/                # 数据库相关
│   │   ├── database.dart        # 数据库配置
│   │   └── tables/              # 数据表定义
│   ├── repositories/            # 仓库实现
│   └── models/                  # 数据模型
│
├── domain/                      # 领域层
│   ├── entities/                # 实体定义
│   ├── repositories/            # 仓库接口
│   └── usecases/                # 用例（可选）
│
├── presentation/                # 表现层
│   ├── providers/               # Riverpod Provider
│   ├── screens/                 # 页面
│   │   ├── home/                # 应用首页
│   │   ├── todo/                # Todo 页面
│   │   ├── calendar/            # 日历页面
│   │   ├── profile/             # 我的页面
│   │   └── features/            # 功能模块
│   │       ├── memo/            # 备忘录
│   │       ├── diary/           # 日记
│   │       ├── countdown/       # 纪念日
│   │       ├── account/         # 记账
│   │       ├── goal/            # 目标
│   │       └── weight/          # 体重
│   └── widgets/                 # 公共组件
│
└── router/                      # 路由配置
    └── app_router.dart          # 路由定义
```

---

## 状态管理 (Riverpod)

### Provider 结构

```dart
// 数据库 Provider
final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

// 备忘录 Providers
final memoRepositoryProvider = Provider<MemoRepository>((ref) {
  return MemoRepository(ref.watch(databaseProvider));
});

final memosProvider = StreamProvider<List<Memo>>((ref) {
  return ref.watch(memoRepositoryProvider).watchAll();
});

// Todo Providers
final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  return TodoRepository(ref.watch(databaseProvider));
});

final todosProvider = StreamProvider<List<Todo>>((ref) {
  return ref.watch(todoRepositoryProvider).watchAll();
});

// 日历 Providers
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());
final calendarModeProvider = StateProvider<CalendarMode>((ref) => CalendarMode.month);

// 等等...
```

---

## 数据模型

### 备忘录 (Memo)
```dart
class Memo {
  final int? id;
  final String title;
  final String content;
  final String? category;      // 分类：工作/生活/学习
  final bool isPinned;         // 是否置顶
  final DateTime? remindTime;  // 提醒时间
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### 待办 (Todo)
```dart
class Todo {
  final int? id;
  final String title;
  final String? description;
  final String category;       // 分类：工作/生活/学习/杂项
  final bool isCompleted;
  final DateTime? dueDate;     // 截止时间
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### 日记 (Diary)
```dart
class Diary {
  final int? id;
  final DateTime date;
  final String? weather;       // 天气
  final String content;
  final List<String> images;   // 图片路径
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### 纪念日 (Countdown)
```dart
class Countdown {
  final int? id;
  final String name;
  final DateTime targetDate;
  final String? category;      // 生日/节日/重要日
  final bool isRepeat;         // 是否重复
  final DateTime createdAt;
}
```

### 记账 (Account)
```dart
class Account {
  final int? id;
  final double amount;
  final String type;           // 收入/支出
  final String category;       // 餐饮/交通/购物等
  final String? note;
  final DateTime date;
  final DateTime createdAt;
}
```

### 目标 (Goal)
```dart
class Goal {
  final int? id;
  final String name;
  final int totalSteps;
  final int completedSteps;
  final DateTime? deadline;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### 体重 (Weight)
```dart
class Weight {
  final int? id;
  final double value;
  final DateTime date;
  final DateTime createdAt;
}
```

---

## 路由设计

```dart
// 底部导航 + 子路由
final router = GoRouter(
  initialLocation: '/home',
  routes: [
    // 底部导航壳
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScaffold(navigationShell: navigationShell);
      },
      branches: [
        // 应用 Tab
        StatefulShellBranch(routes: [
          GoRoute(path: '/home', builder: (_, __) => HomeScreen()),
          GoRoute(path: '/memo', builder: (_, __) => MemoListScreen()),
          GoRoute(path: '/memo/edit', builder: (_, __) => MemoEditScreen()),
          GoRoute(path: '/diary', builder: (_, __) => DiaryScreen()),
          GoRoute(path: '/countdown', builder: (_, __) => CountdownScreen()),
          GoRoute(path: '/account', builder: (_, __) => AccountScreen()),
          GoRoute(path: '/goal', builder: (_, __) => GoalScreen()),
          GoRoute(path: '/weight', builder: (_, __) => WeightScreen()),
        ]),
        // Todo Tab
        StatefulShellBranch(routes: [
          GoRoute(path: '/todo', builder: (_, __) => TodoScreen()),
        ]),
        // 日历 Tab
        StatefulShellBranch(routes: [
          GoRoute(path: '/calendar', builder: (_, __) => CalendarScreen()),
        ]),
        // 我的 Tab
        StatefulShellBranch(routes: [
          GoRoute(path: '/profile', builder: (_, __) => ProfileScreen()),
        ]),
      ],
    ),
  ],
);
```

---

## 数据库设计 (Drift)

```dart
// 表定义示例
class Memos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get content => text()();
  TextColumn get category => text().nullable()();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  DateTimeColumn get remindTime => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
```

---

## 依赖关系图

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation 层                       │
│  (Screens, Widgets, Providers)                          │
└─────────────────────┬───────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────┐
│                      Domain 层                           │
│  (Entities, Repository Interfaces)                      │
└─────────────────────┬───────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────┐
│                      Data 层                             │
│  (Database, Repository Implementations, Models)         │
└─────────────────────────────────────────────────────────┘
```

---

## 下一步

1. 创建 Flutter 项目
2. 配置 pubspec.yaml 依赖
3. 搭建项目结构
4. 实现数据库层
5. 实现各功能模块

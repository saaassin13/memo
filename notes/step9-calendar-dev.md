# 日历页面开发 (Step 9)

## 开发进度

### Phase 1: 基础框架 ✅

- [x] 创建 CalendarScreen
- [x] 实现月视图
- [x] 实现日期选择

**文件**: `lib/presentation/screens/calendar/calendar_screen.dart`

### Phase 2: 视图切换 ✅

- [x] 实现周视图
- [x] 实现日视图
- [x] 视图切换动画

**实现内容**:
- `_ViewModeSwitch` - 日/周/月模式切换按钮
- `_MonthView` - 月视图网格
- `_WeekView` - 周视图7列布局
- `_DayView` - 日视图时间轴
- AnimatedSwitcher 实现300ms过渡动画

### Phase 3: 事件数据 ✅

- [x] 创建 calendar_providers.dart
- [x] 待办事件按日期筛选
- [x] 备忘事件按提醒时间筛选
- [x] 纪念日事件（倒计时）
- [x] 体重记录

**文件**: `lib/presentation/providers/calendar_providers.dart`

**Providers**:
```dart
// 视图模式
final calendarViewModeProvider = StateProvider<CalendarViewMode>

// 选中日期
final selectedDateProvider = StateProvider<DateTime>

// 当前月份
final currentMonthProvider = StateProvider<DateTime>

// 事件类型筛选
final eventTypeFilterProvider = StateProvider<Set<CalendarEventType>>

// 待办事件（按日期）
final todoEventsProvider = Provider.family<AsyncValue<List<Todo>>, DateTime>

// 备忘事件（按日期）
final memoEventsProvider = Provider.family<AsyncValue<List<Memo>>, DateTime>

// 纪念日事件
final countdownEventsProvider = Provider<AsyncValue<List<Countdown>>>

// 体重记录（按日期）
final weightEventsProvider = Provider.family<AsyncValue<Weight?>, DateTime>

// 综合事件
final dayEventsProvider = Provider.family<AsyncValue<List<CalendarEvent>>, DateTime>
```

### Phase 4: 交互功能 ✅

- [x] 今日事件卡片
- [x] 筛选功能
- [x] 新增按钮菜单

**实现内容**:
- `_DayEvents` - 显示选中日期的所有事件
- `_CalendarEventCard` - 统一事件卡片组件
- `_FilterSheet` - 事件类型筛选弹窗
- `_AddOption` - 新增菜单（待办/备忘/纪念日/体重）

### Phase 5: 辅助功能 ✅

- [x] 创建 other_providers.dart
- [x] 纪念日列表 Provider
- [x] 体重记录 Provider

**文件**: `lib/presentation/providers/other_providers.dart`

---

## 核心代码结构

### 日历页面组件树

```
CalendarScreen
├── _ViewModeSwitch (日/周/月切换)
├── _MonthNavigator (月份导航)
├── AnimatedSwitcher
│   ├── _MonthView (月视图)
│   │   └── GridView (7x6日期网格)
│   ├── _WeekView (周视图)
│   │   └── Row (7列日期)
│   │   └── _DayEvents (事件列表)
│   └── _DayView (日视图)
│       └── _DayEvents (事件列表)
├── _FilterSheet (筛选弹窗)
└── _AddMenu (新增菜单)
```

### 事件类型

```dart
enum CalendarEventType {
  memo,        // 备忘 - 蓝色 #667EEA
  todo,        // 待办 - 绿色 #11998E
  anniversary, // 纪念日 - 粉色 #F5576C
  goal,        // 目标 - 橙色 #F59E0B
  weight,      // 体重 - 紫色 #8B5CF6
}
```

### 综合事件模型

```dart
class CalendarEvent {
  final String id;
  final CalendarEventType type;
  final DateTime date;
  final String title;
  final String? subtitle;
  final dynamic data; // 原始数据
}
```

---

## 路由跳转

| 来源 | 目标 | 路由 |
|------|------|------|
| 新增待办 | 待办页面 | `/todo` |
| 新增备忘 | 备忘编辑 | `/memo/new` |
| 新增纪念日 | TODO | - |
| 记录体重 | TODO | - |

---

## 待完成项

- [ ] 纪念日编辑页面
- [ ] 体重记录弹窗
- [ ] 目标功能（目标实体已存在）
- [ ] 事件点击跳转详情
- [ ] 月视图事件标记点显示

---

## 视觉设计

与待办页面保持一致:
- 主色调: #667EEA → #764BA2
- 待办色: #11998E → #38EF7D
- 圆角: 16px / 24px
- 阴影: 0 2-10px rgba(0,0,0,0.04)
- 动画: 200-300ms ease-in-out

---

## 文件清单

| 文件 | 说明 |
|------|------|
| `lib/presentation/screens/calendar/calendar_screen.dart` | 日历页面 |
| `lib/presentation/providers/calendar_providers.dart` | 日历状态管理 |
| `lib/presentation/providers/other_providers.dart` | 纪念日/体重 Providers |
| `notes/step8-calendar-design.md` | 设计文档 |
| `notes/step9-calendar-dev.md` | 本开发文档 |

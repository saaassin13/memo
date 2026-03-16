# 纪念日功能开发 (Step 11)

## 开发进度

### Phase 1: 数据层 ✅

- [x] 创建 Anniversary 实体
- [x] 创建 Anniversaries 数据库表
- [x] 更新数据库版本 (v3 → v4)
- [x] 创建 AnniversaryRepository 接口
- [x] 创建 AnniversaryRepositoryImpl 实现
- [x] 注册 AnniversaryRepositoryProvider

**文件清单:**

| 文件 | 操作 | 说明 |
|------|------|------|
| `lib/domain/entities/anniversary.dart` | ✅ 已创建 | 纪念日实体 |
| `lib/data/database/tables/anniversaries.dart` | ✅ 已创建 | 数据库表定义 |
| `lib/data/database/database.dart` | ✅ 已修改 | 注册表 + 升级 schemaVersion 到 4 |
| `lib/domain/repositories/anniversary_repository.dart` | ✅ 已创建 | 仓储接口 |
| `lib/data/repositories/anniversary_repository_impl.dart` | ✅ 已创建 | 仓储实现 |
| `lib/presentation/providers/repository_providers.dart` | ✅ 已修改 | 添加 anniversaryRepositoryProvider |

---

### Phase 2: 状态管理 ✅

- [x] 创建 anniversary_providers.dart
- [x] 实现 anniversariesProvider (数据流)
- [x] 实现 filteredAnniversariesProvider (搜索过滤 + 排序)
- [x] 实现 anniversarySearchProvider (搜索状态)
- [x] 实现 upcomingAnniversariesProvider (即将到来)

**文件清单:**

| 文件 | 操作 | 说明 |
|------|------|------|
| `lib/presentation/providers/anniversary_providers.dart` | ✅ 已创建 | 纪念日状态管理 |

---

### Phase 3: 列表页面 ✅

- [x] 创建 AnniversaryScreen
- [x] 实现顶部导航栏 + 搜索功能
- [x] 实现 AnniversaryTile 列表项组件
- [x] 实现倒数天数显示逻辑
- [x] 实现空状态提示
- [x] 实现 FAB 按钮
- [x] 实现长按操作菜单 (编辑/删除)

**文件清单:**

| 文件 | 操作 | 说明 |
|------|------|------|
| `lib/presentation/screens/anniversary/anniversary_screen.dart` | ✅ 已创建 | 列表主页面 |
| `lib/presentation/widgets/anniversary/anniversary_tile.dart` | ✅ 已创建 | 列表项组件 |
| `lib/presentation/widgets/anniversary/empty_anniversary.dart` | ✅ 已创建 | 空状态组件 |

---

### Phase 4: 新增/编辑页面 ✅

- [x] 创建 AnniversaryEditScreen
- [x] 实现标题输入
- [x] 实现日期选择器 (公历/农历切换)
- [x] 实现提醒时间选择
- [x] 实现重复方式选择
- [x] 实现关系选择
- [x] 实现手机号输入
- [x] 实现备忘输入
- [x] 实现保存/取消逻辑

**文件清单:**

| 文件 | 操作 | 说明 |
|------|------|------|
| `lib/presentation/screens/anniversary/anniversary_edit_screen.dart` | ✅ 已创建 | 编辑页面 (内含日期/关系/提醒选择器) |

---

### Phase 5: 农历集成 ✅

- [x] 创建农历工具类 LunarCalendar
- [x] 实现公历转农历
- [x] 实现农历转公历
- [x] Anniversary 实体集成农历
- [x] 编辑页面显示农历对应日期
- [x] 列表卡片显示完整日期

**文件清单:**

| 文件 | 操作 | 说明 |
|------|------|------|
| `lib/core/utils/lunar_calendar.dart` | ✅ 已创建 | 农历工具类 (1900-2100年数据) |
| `lib/domain/entities/anniversary.dart` | ✅ 已修改 | 集成农历计算 (nextDate/displayDateFull) |
| `lib/presentation/screens/anniversary/anniversary_edit_screen.dart` | ✅ 已修改 | 显示农历日期 + 公历/农历切换按钮 |
| `lib/presentation/widgets/anniversary/anniversary_tile.dart` | ✅ 已修改 | 显示完整日期 (含农历/公历对应) |

---

### Phase 6: 底部导航集成 ✅

- [x] 更新底部导航栏，添加纪念日 Tab
- [x] 更新路由配置

**文件清单:**

| 文件 | 操作 | 说明 |
|------|------|------|
| `lib/presentation/widgets/main_scaffold.dart` | ✅ 已修改 | 添加纪念日 Tab (粉色主题) |
| `lib/router/app_router.dart` | ✅ 已修改 | 添加纪念日路由 |

---

## 已创建文件列表

| 文件 | 说明 | 状态 |
|------|------|------|
| `lib/domain/entities/anniversary.dart` | 纪念日实体 (含农历计算) | ✅ |
| `lib/data/database/tables/anniversaries.dart` | 数据库表定义 (12个字段) | ✅ |
| `lib/domain/repositories/anniversary_repository.dart` | 仓储接口 (watchAll/getById/insert/update/delete) | ✅ |
| `lib/data/repositories/anniversary_repository_impl.dart` | 仓储实现 | ✅ |
| `lib/presentation/providers/anniversary_providers.dart` | 状态管理 (4个Provider) | ✅ |
| `lib/presentation/screens/anniversary/anniversary_screen.dart` | 列表页面 (搜索/FAB/空状态/下拉刷新) | ✅ |
| `lib/presentation/widgets/anniversary/anniversary_tile.dart` | 列表项组件 (倒数天数/关系标签/长按菜单) | ✅ |
| `lib/presentation/widgets/anniversary/empty_anniversary.dart` | 空状态组件 | ✅ |
| `lib/presentation/screens/anniversary/anniversary_edit_screen.dart` | 编辑页面 (所有字段完整实现) | ✅ |
| `lib/core/utils/lunar_calendar.dart` | 农历工具类 (1900-2100年, 公历/农历互转) | ✅ |

## 已修改文件列表

| 文件 | 修改内容 | 状态 |
|------|------|------|
| `lib/data/database/database.dart` | 注册 Anniversaries 表, schemaVersion 3→4, 添加迁移逻辑 | ✅ |
| `lib/presentation/providers/repository_providers.dart` | 添加 anniversaryRepositoryProvider | ✅ |
| `lib/presentation/screens/home/home_screen.dart` | 首页纪念日卡片跳转到 /anniversary | ✅ |
| `lib/router/app_router.dart` | 添加 `/anniversary` 路由 (首页Tab分支下) | ✅ |

## 编辑页面功能

- 标题输入 (必填，最多30字符)
- 日期选择器 (DatePicker，选择公历日期)
- 公历/农历切换按钮 (选择后显示对应日期)
- 提醒时间选择 (当天/提前1-3天/1-2周/1个月)
- 重复方式 (每年重复/不重复)
- 关系选择 (亲人/爱人/朋友/同事/小孩/其他，带颜色标签)
- 自定义关系名称 (选择"其他"时显示)
- 手机号输入 (11位数字限制)
- 备忘输入 (多行文本)
- 保存/取消按钮
- 编辑模式自动填充已有数据

## 列表页面功能

- 粉色主题渐变 AppBar
- 搜索功能 (点击搜索图标展开/收起搜索框)
- 按倒计时排序 (最近的在前)
- 倒数天数大数字显示 (今天！/X天后)
- 日期显示 (公历 + 农历对应)
- 关系标签彩色显示
- 长按弹出操作菜单 (编辑/删除)
- 空状态提示
- 粉色渐变 FAB 按钮
- 下拉刷新

## 农历功能说明

- 农历工具类 `LunarCalendar` 支持 1900-2100 年公历农历互转
- 农历纪念日: 存储对应公历日期 + isLunar=true
- 农历 nextDate 计算: 根据农历月日在当前年重新转换为公历
- 列表卡片显示: 公历日期 (农历对应) 或 农历日期 (公历对应)

---

## 待完成项

---

*文档创建日期: 2026年3月16日*
*最后更新: 2026年3月16日*

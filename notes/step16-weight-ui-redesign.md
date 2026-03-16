# Step 16: 体重页面 UI 改造

## 设计方向

**审美风格**: 温暖有机 / Premium Journal 风格
- 摆脱 Flutter 默认的矩形方框输入控件
- 采用圆润药丸形输入框、卡片式分组、柔和阴影
- 更有温度的配色：米白色背景、柔紫色主色、温润绿色/红色

## 改造范围

### 1. 编辑页面 (WeightEditScreen) — 重点改造
| 元素 | 原设计 | 新设计 |
|------|--------|--------|
| 日期选择 | 灰色矩形边框容器 | 浅紫色药丸形容器，日历图标圆形背景 |
| 体重输入 | TextField + OutlineInputBorder | 无边框卡片式输入区，内嵌大号数字，底部细线 |
| 体脂率 | 同上 | 同上 |
| 运动开关 | 点击切换容器 | iOS 风格 Switch + 渐变色 |
| 运动类型 | 方形边框标签 | 药丸形 ChoiceChip，选中时带图标 |
| 运动时长 | TextField + OutlineInputBorder | 无边框卡片式输入 |
| 备注 | 多行 TextField | 圆角卡片背景，柔和边框 |
| 删除按钮 | OutlinedButton | 文字按钮，更轻量 |
| 整体布局 | 散落的输入项 | Section 卡片分组，带标题 |

### 2. 主页面 (WeightScreen) — 微调
| 元素 | 改造 |
|------|------|
| 今日卡片 | 保持紫色渐变，增加微妙纹理/光泽效果 |
| 历史列表项 | 圆角加大，增加左侧日期彩色标记条 |
| 空状态 | 更柔和的空状态插画风 |

### 3. 统计页面 (WeightStatsScreen) — 微调
| 元素 | 改造 |
|------|------|
| 时间切换 | 胶囊式分段控件 |
| 统计卡片 | 带图标的卡片，渐变色小圆点装饰 |
| 趋势图 | 保持 Canvas，增加渐变填充面积 |

## 技术方案
- 纯 Flutter Material 3 组件，不引入新依赖
- 使用 Container + BoxDecoration 实现自定义样式
- 使用 Switch widget 替代点击容器
- 使用 FilterChip / ChoiceChip 替代自定义标签

## 颜色系统
```dart
// 主色
const primaryPurple = Color(0xFF8B5CF6);
const lightPurple = Color(0xFFF3F0FF);    // 淡紫背景
const softPurple = Color(0xFFE9E0FF);     // 柔紫

// 功能色
const successGreen = Color(0xFF34D399);   // 柔绿
const dangerRed = Color(0xFFF87171);      // 柔红
const warmAmber = Color(0xFFFBBF24);      // 暖琥珀

// 背景
const creamBg = Color(0xFFFAFAFA);        // 奶白色背景
const cardWhite = Color(0xFFFFFFFF);      // 卡片白
```

## 文件清单
| 文件 | 操作 |
|------|------|
| `weight_edit_screen.dart` | 重写 UI 层 |
| `weight_screen.dart` | 微调历史列表 + 空状态 |
| `weight_stats_screen.dart` | 微调切换器 + 卡片 |
| `notes/step16-weight-ui-redesign.md` | 新建 |

---
*文档创建日期: 2026年3月16日*

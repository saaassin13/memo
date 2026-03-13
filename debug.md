# 调试与运行指南

## 环境准备

### 1. Android Studio 虚拟设备

#### 创建虚拟设备
1. 打开 Android Studio
2. 点击 `Tools` → `Device Manager`
3. 点击 `Create Device`
4. 选择设备类型（如 Pixel 7 Pro）
5. 选择系统镜像（推荐 API 34）
6. 点击 `Next` → `Finish`

#### 启动虚拟设备
1. 在 Device Manager 中点击设备旁边的播放按钮
2. 等待系统启动完成

---

## 运行应用

### 方式一：Android Studio 运行
1. 打开项目
2. 点击顶部工具栏的 `Run` → `Run 'main.dart'`
3. 选择目标设备
4. 等待构建和安装

### 方式二：命令行运行

#### 查看可用设备
```bash
flutter devices
```

#### 运行应用
```bash
# 运行到默认设备
flutter run

# 运行到特定设备
flutter run -d <device_id>
flutter run -d emulator-5554

# 运行到 Android
flutter run -d android

# 运行到已连接的设备
flutter run -d <device_name>
```

#### 构建 APK
```bash
# Debug 版
flutter build apk --debug

# Release 版
flutter build apk --release
```

---

## 调试技巧

### 热重载 (Hot Reload)
- 在运行状态下按 `R` 键或点击工具栏的 🔥 按钮
- 保存文件后自动触发

### 热重启 (Hot Restart)
- 在运行状态下按 `Shift + R`
- 重新加载整个应用（状态重置）

### 调试模式
- 在 IDE 中设置断点
- 使用 `debugPrint()` 输出日志

---

## 常用命令

| 命令 | 说明 |
|------|------|
| `flutter pub get` | 获取依赖 |
| `flutter analyze` | 代码分析 |
| `flutter test` | 运行测试 |
| `flutter clean` | 清理构建 |
| `flutter build apk` | 构建 APK |
| `flutter build apk --debug` | 构建 Debug APK |
| `flutter build apk --release` | 构建 Release APK |

---

## 常见问题

### 设备未检测到
```bash
# 重启 adb
adb kill-server
adb start-server

# 检查设备
flutter devices
```

### 构建失败
```bash
# 清理后重新构建
flutter clean
flutter pub get
flutter build apk --debug
```

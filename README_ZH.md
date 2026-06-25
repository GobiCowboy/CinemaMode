# Cinema Mode

[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![平台](https://img.shields.io/badge/平台-macOS%2014+-blue.svg)](https://developer.apple.com/macos/)

一款轻量级 macOS 菜单栏工具，一键隐藏菜单栏和 Dock，让屏幕只保留你想看的内容。

打开，点击，观影。就三步。

## 它能做什么

- 隐藏菜单栏和 Dock（GitHub 版）
- 显示一个极简的悬浮退出按钮，可拖拽到任意位置
- 退出时精确恢复你进入前的系统状态
- 记住你偏好的音量、语言和退出按钮位置

## 系统要求

- macOS 14（Sonoma）或更高版本
- Xcode 16+ 或 Swift 6.0 工具链
- Apple Developer 账号（可选，用于代码签名）

## 构建与运行

### 使用 Swift Package Manager

```bash
git clone https://github.com/<你的用户名>/CinemaMode.git
cd CinemaMode

# 构建并运行
swift build
./script/build_and_run.sh run
```

### 使用 Xcode

```bash
# 在 Xcode 中打开项目
open CinemaMode.xcodeproj
```

### 构建脚本模式

`script/build_and_run.sh` 提供多种运行模式：

```bash
./script/build_and_run.sh run          # 构建并运行
./script/build_and_run.sh --debug       # 构建并在 lldb 下启动
./script/build_and_run.sh --logs         # 构建并查看系统日志
./script/build_and_run.sh --telemetry    # 构建并查看 OSLog
./script/build_and_run.sh --verify       # 构建并验证进程是否正常启动
```

## App Store 发布

```bash
# 归档（推荐通过 Xcode 完成）
xcodebuild archive \
  -project CinemaMode.xcodeproj \
  -scheme CinemaMode \
  -configuration Release \
  -destination 'platform=macOS' \
  -archivePath dist/CinemaMode.xcarchive

# 导出 App Store 包
xcodebuild -exportArchive \
  -archivePath dist/CinemaMode.xcarchive \
  -exportPath dist/AppStoreExport \
  -exportOptionsPlist Config/AppStore/ExportOptions.plist
```

> **注意**：App Store 版（`com.cinemamode.app`）需要有效的 Apple Developer Program 会员资格。导出前需先在 [App Store Connect](https://appstoreconnect.apple.com/) 创建 App 记录。

## 两个版本的区别

| | GitHub 版 | App Store 版 |
|---|---|---|
| Bundle ID | 开发用 | `com.cinemamode.app` |
| Dock 自动隐藏 | ✅ | ❌ |
| 沙盒 | ❌ | ✅ |
| Apple Events | ❌ | ✅（仅音量控制） |
| 分发方式 | 签名后分享 | App Store |

## 架构说明

```
CinemaMode/                  ← App & UI 层（SwiftUI + AppKit 桥接）
├── App/                     ← 应用生命周期、菜单栏入口
├── Services/                ← 系统 UI 控制（浮窗、设置、系统状态管理）
└── Views/                   ← SwiftUI 视图

CinemaModeCore/              ← 业务逻辑（纯 Swift）
├── Models/                  ← 数据模型
├── Services/                ← CinemaModeService（状态机）
├── Stores/                  ← PreferencesStore
└── Support/                 ← 错误、日志、本地化

Tests/                       ← 单元测试
docs/                        ← 产品需求和架构文档
```

设计要点：

- **系统控制用 AppKit**：菜单栏、浮窗、窗口管理
- **用户内容用 SwiftUI**：设置页和退出按钮
- **状态机驱动**：enter → active → exiting → idle，失败自动恢复
- **LSUIElement**：无 Dock 图标，纯菜单栏应用

## 开源协议

[MIT](LICENSE)

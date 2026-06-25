# Cinema Mode

[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![平台](https://img.shields.io/badge/平台-macOS%2014+-blue.svg)](https://developer.apple.com/macos/)

> 🎬 **可在 [App Store](https://apps.apple.com/cn/search?term=Cinema%20Mode%20for%20Mac) 下载** — 搜索「Cinema Mode」即可安装。

一款轻量级 macOS 菜单栏工具。一键隐藏菜单栏和 Dock，让屏幕只保留你想看的内容。

打开，点击，观影。就三步。

## 它能做什么

- 隐藏菜单栏和 Dock
- 显示一个极简的悬浮退出按钮，可拖拽到任意位置
- 退出时精确恢复你进入前的系统状态
- 记住你偏好的音量和退出按钮位置

## 下载方式

**最简单的方式：** 前往 [Mac App Store](https://apps.apple.com/cn/search?term=Cinema%20Mode%20for%20Mac) 搜索 **「Cinema Mode」** 直接下载。

**从源码构建：** 克隆本仓库后运行 `./script/build_and_run.sh`，详见下方「构建与运行」。

## 系统要求

- macOS 14（Sonoma）或更高版本
- Apple Developer 账号（仅自行签名分发时需要）

## 构建与运行

```bash
# 克隆并构建
git clone https://github.com/<你的用户名>/CinemaMode.git
cd CinemaMode
swift build

# 运行
./script/build_and_run.sh run

# 调试模式
./script/build_and_run.sh --debug

# 查看运行日志
./script/build_and_run.sh --logs
```

### 用 Xcode 打开

```bash
open CinemaMode.xcodeproj
```

## 开源协议

[MIT](LICENSE)

# 202 项目目录结构

## 1. 规划目录结构

```text
project-root/
  README.md
  docs/
    000_document_index.md
    100_requirements_architecture/
    200_foundation/
    300_features/
    900_project_memory/
    990_archive/
  CinemaMode/
    App/
      CinemaModeApp.swift
      AppDelegate.swift
    Views/
      MainControlView.swift
      ExitFloatingView.swift
      Components/
    Services/
      CinemaModeService.swift
    Platform/
      PresentationController.swift
      FloatingPanelController.swift
      PointerActivityMonitor.swift
    Stores/
      PreferencesStore.swift
      RuntimeStateStore.swift
    Models/
      CinemaModeState.swift
      PresentationSnapshot.swift
      FloatingWindowState.swift
    Support/
      Logger.swift
      AppError.swift
  CinemaModeTests/
    Services/
    Platform/
    Stores/
  scripts/
    build_and_run.sh
```

## 2. 目录说明

| 路径 | 用途 | 规则 |
|------|------|------|
| `docs/` | 项目文档 | 按编号维护；代码变更时同步更新相关文档 |
| `CinemaMode/App/` | 应用入口和生命周期 | 只做启动、注入和恢复编排 |
| `CinemaMode/Views/` | SwiftUI 用户界面 | 不直接调用 AppKit 系统控制 |
| `CinemaMode/Services/` | 业务服务和状态机 | 统一编排进入、退出、恢复 |
| `CinemaMode/Platform/` | AppKit 桥接 | 只放系统 UI、浮窗、鼠标活动等平台能力 |
| `CinemaMode/Stores/` | 偏好和运行时状态存储 | 不保存隐私内容 |
| `CinemaMode/Models/` | 状态和数据模型 | 只放纯模型，不依赖 AppKit 窗口实例 |
| `CinemaMode/Support/` | 日志、错误、扩展等基础设施 | 可被多层复用，不写业务流程 |
| `CinemaModeTests/` | 测试 | 与源码目录结构对应 |
| `scripts/` | 本地开发脚本 | 脚本必须可重复执行，不写个人绝对路径 |

## 3. 文件放置规则

| 文件类型 | 放哪里 | 命名规则 |
|----------|--------|----------|
| App 入口 | `CinemaMode/App/` | `<AppName>App.swift`, `AppDelegate.swift` |
| 页面 / UI | `CinemaMode/Views/` | 以主要视图命名，如 `MainControlView.swift` |
| 可复用 UI | `CinemaMode/Views/Components/` | 以组件名命名 |
| 业务逻辑 | `CinemaMode/Services/` | `<Domain>Service.swift` |
| AppKit 桥接 | `CinemaMode/Platform/` | `<Capability>Controller.swift` 或 `<Capability>Monitor.swift` |
| 数据模型 | `CinemaMode/Models/` | 名词命名，如 `CinemaModeState.swift` |
| 数据读写 | `CinemaMode/Stores/` | `<Entity>Store.swift` |
| 日志模块 | `CinemaMode/Support/` | `Logger.swift` |
| 公共错误 | `CinemaMode/Support/` | `AppError.swift` |
| 测试 | `CinemaModeTests/` | `<TypeName>Tests.swift` |

## 4. 禁止事项

- 不把 AppKit 系统控制直接写进 SwiftUI view。
- 不在多个文件里重复保存“是否处于观影模式”的状态。
- 不绕过 `CinemaModeService` 直接进入或退出观影模式。
- 不把 `NSWindow`、`NSPanel` 等长生命周期对象塞进普通模型。
- 不保存网页内容、播放器信息或用户正在观看的内容。
- 不把构建产物、Xcode 用户状态、临时文件提交到 Git。
- 不新增无说明的目录。

## 5. 变更记录

| 日期 | 变更内容 | 原因 |
|------|----------|------|
| 2026-06-18 | 初始化项目结构规划。 | 文档阶段。 |

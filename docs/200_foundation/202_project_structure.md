# 202 项目目录结构

## 1. 规划目录结构

```text
project-root/
  README.md
  Package.swift
  script/
    build_and_run.sh
  .codex/
    environments/
      environment.toml
  docs/
    000_document_index.md
    100_requirements_architecture/
    200_foundation/
    300_features/
    900_project_memory/
    990_archive/
  Sources/
    CinemaMode/
      App/
        CinemaModeApp.swift
        AppEnvironment.swift
        MenuBarStatusItemController.swift
      Views/
        MenuBarIconView.swift
        ExitFloatingView.swift
      Services/
        SystemLogger.swift
        SystemPresentationController.swift
        FloatingPanelController.swift
        SystemPointerActivityMonitor.swift
      Models/
        CinemaModeState.swift
        PresentationSnapshot.swift
        FloatingWindowState.swift
      Support/
        AppError.swift
    CinemaModeCore/
      Services/
        CinemaModeService.swift
      Models/
        CinemaModePhase.swift
        FloatingAnchor.swift
        PresentationSnapshot.swift
        FloatingWindowState.swift
      Support/
        AppError.swift
  CinemaModeTests/
    CinemaModeServiceTests.swift
```

## 2. 目录说明

| 路径 | 用途 | 规则 |
|------|------|------|
| `docs/` | 项目文档 | 按编号维护；代码变更时同步更新相关文档 |
| `Sources/CinemaMode/App/` | 应用入口和生命周期 | 只做启动、注入、状态栏入口和恢复编排 |
| `Sources/CinemaMode/Views/` | SwiftUI 用户界面 | 不直接调用 AppKit 系统控制 |
| `Sources/CinemaMode/Services/` | 平台实现和系统桥接 | 统一编排进入、退出、恢复 |
| `Sources/CinemaMode/Support/` | 错误类型等基础设施 | 不保存隐私内容 |
| `Sources/CinemaMode/Models/` | 状态和数据模型 | 只放纯模型，不依赖 AppKit 窗口实例 |
| `Sources/CinemaModeCore/Services/` | 共享业务服务 | 状态机与流程编排 |
| `Sources/CinemaModeCore/Models/` | 共享状态和数据模型 | 只放纯模型，不依赖 AppKit 窗口实例 |
| `Sources/CinemaModeCore/Support/` | 日志、错误、扩展等基础设施 | 可被多层复用，不写业务流程 |
| `CinemaModeTests/` | 测试 | 与源码目录结构对应 |
| `scripts/` | 本地开发脚本 | 脚本必须可重复执行，不写个人绝对路径 |

## 3. 文件放置规则

| 文件类型 | 放哪里 | 命名规则 |
|----------|--------|----------|
| App 入口 | `Sources/CinemaMode/App/` | `<AppName>App.swift` |
| 页面 / UI | `Sources/CinemaMode/Views/` | 以主要视图命名，如 `ExitFloatingView.swift` |
| 可复用 UI | `Sources/CinemaMode/Views/Components/` | 以组件名命名 |
| 业务逻辑 | `Sources/CinemaModeCore/Services/` | `<Domain>Service.swift` |
| 平台桥接 | `Sources/CinemaMode/Services/` | `<Capability>Controller.swift` 或 `<Capability>Monitor.swift` |
| 数据模型 | `Sources/CinemaModeCore/Models/` | 名词命名，如 `CinemaModePhase.swift` |
| 数据读写 | 后续若引入 | `<Entity>Store.swift` |
| 日志模块 | `Sources/CinemaMode/Services/` | `SystemLogger.swift` |
| 公共错误 | `Sources/CinemaModeCore/Support/` | `AppError.swift` |
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
| 2026-06-18 | 对齐当前 `Sources/` 目录结构。 | 代码路径更新。 |
| 2026-06-19 | 移除 `MenuBarMenuView.swift`，状态栏入口改为原生状态菜单。 | 对齐最新实现。 |
| 2026-06-19 | 移除 `AppDelegate.swift`，应用入口改为纯 AppKit 生命周期。 | 对齐最新实现。 |

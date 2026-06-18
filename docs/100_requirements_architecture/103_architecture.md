# 103 技术架构

## 1. 架构目标

Cinema Mode 的架构目标不是功能多，而是行为可靠、退出可靠、认知负担低。

核心约束：

- SwiftUI 负责入口、状态展示和普通 UI。
- AppKit 只负责 SwiftUI 不适合处理的系统级边界：应用 presentation options、浮窗窗口层级、鼠标事件监听。
- 进入前必须保存原始状态，退出时必须恢复。
- 任何失败路径都优先恢复系统状态。

## 2. 应用分层

| 层级 | 职责 | 示例目录 |
|------|------|----------|
| App 层 | 应用入口、scene 定义、生命周期恢复 | `CinemaMode/App/` |
| 页面层 | 菜单栏入口、浮窗 SwiftUI 内容 | `CinemaMode/Views/` |
| 业务层 | 观影模式状态机、进入/退出流程编排 | `CinemaMode/Services/` |
| 平台层 | AppKit 桥接、系统 UI 控制、浮窗窗口管理、鼠标活动监听 | `CinemaMode/Platform/` |
| 数据层 | 用户偏好、运行时状态快照 | `CinemaMode/Stores/` |
| 基础设施层 | 日志、配置、错误类型 | `CinemaMode/Support/` |

## 3. 模块划分

| 模块 | 职责 | 允许依赖 | 禁止依赖 |
|------|------|----------|----------|
| `CinemaModeApp` | 声明应用入口、注入服务、处理启动恢复 | Services, Stores, Support | 直接操作 `NSApplication.presentationOptions` |
| `MenuBarMenuView` | 提供菜单栏里的进入/退出/退出应用入口 | Services | AppKit 细节 |
| `MenuBarIconView` | 菜单栏图标展示 | AppKit, Bundle icon | 业务逻辑 |
| `ExitFloatingView` | 显示圆形退出按钮和 hover 状态 | Services | 系统 UI 控制 |
| `CinemaModeService` | 观影模式状态机，编排进入、退出、异常恢复 | Platform, Stores, Support | 直接写日志到控制台 |
| `PresentationController` | 保存和设置 `NSApplication.PresentationOptions` | AppKit, Support | UI 文案和业务判断 |
| `FloatingPanelController` | 创建、定位、显示、隐藏退出浮窗 | AppKit, SwiftUI hosting | 业务状态决策 |
| `PointerActivityMonitor` | 监听鼠标移动和静止状态，输出透明度意图 | AppKit, Support | 直接修改系统 presentation options |
| `PreferencesStore` | 保存非敏感偏好，例如浮窗位置 | Foundation | AppKit 窗口对象 |
| `Logger` | 统一结构化日志 | Foundation, OSLog | 业务逻辑 |

## 4. 数据流

```text
用户点击菜单栏入口
  ↓
MenuBarMenuView
  ↓
CinemaModeService.enter()
  ↓
PresentationController 保存原始状态并隐藏菜单栏 / Dock
  ↓
FloatingPanelController 显示退出浮窗
  ↓
PointerActivityMonitor 输出鼠标状态
  ↓
ExitFloatingView 根据状态显示透明度
```

```text
用户点击退出浮窗
  ↓
ExitFloatingView
  ↓
CinemaModeService.exit()
  ↓
PresentationController 恢复原始状态
  ↓
FloatingPanelController 关闭浮窗
  ↓
PointerActivityMonitor 停止监听
```

## 5. 状态机

| 状态 | 含义 | 可进入状态 |
|------|------|------------|
| `idle` | 未进入观影模式 | `entering` |
| `entering` | 正在保存状态、隐藏系统 UI、创建浮窗 | `active`, `recovering`, `failed` |
| `active` | 观影模式已开启 | `exiting`, `recovering` |
| `exiting` | 正在恢复状态和关闭浮窗 | `idle`, `recovering` |
| `recovering` | 异常恢复中，优先恢复系统 UI | `idle`, `failed` |
| `failed` | 进入或退出失败 | `idle`, `recovering` |

## 6. 系统 UI 控制边界

| 控制项 | MVP 策略 | 备注 |
|--------|----------|------|
| 菜单栏 | 作为主要入口常驻显示 | 进入前保存原始 options |
| Dock | 使用 AppKit presentation options 隐藏或自动隐藏 | 与菜单栏选项组合必须合法 |
| 退出浮窗 | 使用独立浮动 panel | 不依赖主窗口是否可见 |
| 鼠标移动 | 只监听用于浮窗透明度，不识别应用或内容 | 不推断用户是否观看视频 |
| 权限 | MVP 避免需要辅助功能权限的方案 | 不要求用户理解权限机制 |

## 7. 边界规则

| 规则 | 说明 |
|------|------|
| 页面层不直接调用 AppKit 系统控制 | 统一经过 `CinemaModeService`，避免状态散乱。 |
| AppKit 桥接必须小而明确 | 平台层只暴露进入、退出、浮窗、鼠标状态等窄接口。 |
| 进入前必须保存状态 | 没有保存成功不得继续进入观影模式。 |
| 退出失败必须记录并继续恢复 | 不允许用户被困在无退出入口的状态。 |
| 不识别播放器和网站 | MVP 不做内容检测，保护简单性和隐私边界。 |
| 日志不记录敏感路径或网页内容 | 只记录功能状态、错误类型和必要上下文。 |

## 8. 外部依据

- Apple Developer Documentation: `NSApplication.PresentationOptions` 说明菜单栏与 Dock 相关选项存在组合约束。
- Apple Developer Documentation: `NSPanel` 适合承载辅助窗口或浮动面板。

## 9. 架构变更记录

| 日期 | 变更 | 原因 |
|------|------|------|
| 2026-06-18 | 初始化 MVP 架构，确定 SwiftUI + 窄 AppKit 桥接方案。 | 开始文档阶段。 |

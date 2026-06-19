# 103 技术架构

## 1. 架构目标

Cinema Mode 的架构目标不是功能多，而是行为可靠、退出可靠、认知负担低。

核心约束：

- SwiftUI 负责状态展示、设置页和普通 UI，菜单栏入口由 AppKit 状态栏承载。
- AppKit 只负责 SwiftUI 不适合处理的系统级边界：设置窗口、系统 chrome 覆盖层、浮窗窗口层级、鼠标事件监听。
- 进入前必须保存原始状态，退出时必须恢复。
- 任何失败路径都优先恢复系统状态。

## 2. 应用分层

| 层级 | 职责 | 示例目录 |
|------|------|----------|
| App 层 | 状态栏入口、scene 定义、生命周期恢复 | `Sources/CinemaMode/App/` |
| 页面层 | 浮窗和设置页 SwiftUI 内容 | `Sources/CinemaMode/Views/` |
| 业务层 | 观影模式状态机、进入/退出流程编排 | `Sources/CinemaModeCore/Services/` |
| 平台层 | AppKit 桥接、系统 UI 控制、浮窗和设置窗口管理、鼠标活动监听 | `Sources/CinemaMode/Services/` |
| 数据层 | 用户偏好、运行时状态快照 | `Sources/CinemaModeCore/Models/` |
| 基础设施层 | 日志、配置、错误类型 | `Sources/CinemaModeCore/Support/` |
| 偏好层 | 用户设置持久化 | `Sources/CinemaModeCore/Stores/` |

## 3. 模块划分

| 模块 | 职责 | 允许依赖 | 禁止依赖 |
|------|------|----------|----------|
| `CinemaModeApp` | 声明应用生命周期、注入服务、处理启动恢复 | Services, Support | 直接操作 `NSApplication.presentationOptions` |
| `MenuBarStatusItemController` | 声明和维护状态栏入口、原生状态菜单、进入/退出命令 | Services | 业务状态机 |
| `MenuBarIconView` | 菜单栏图标样式 | AppKit, Bundle icon | 业务逻辑 |
| `SettingsWindowController` | 打开和维护设置窗口 | AppKit, SwiftUI hosting | 业务状态机 |
| `SettingsView` | 观影偏好设置页 | Services | 系统 UI 控制 |
| `ExitFloatingView` | 显示圆形退出按钮、拖动和 hover 状态 | Services | 系统 UI 控制 |
| `CinemaModeService` | 观影模式状态机，编排进入、退出、异常恢复 | Platform, Stores, Support | 直接写日志到控制台 |
| `SystemPresentationController` | 保存原始状态并显示系统 chrome 覆盖层 | AppKit, Support | UI 文案和业务判断 |
| `FloatingPanelController` | 创建、定位、显示、隐藏退出浮窗 | AppKit, SwiftUI hosting | 业务状态决策 |
| `PointerActivityMonitor` | 监听鼠标移动和静止状态，输出透明度意图 | AppKit, Support | 直接修改系统 presentation options |
| `PreferencesStore` | 保存非敏感偏好 | Foundation | AppKit 窗口对象 |
| `Logger` | 统一结构化日志 | Foundation, OSLog | 业务逻辑 |

## 4. 数据流

```text
用户点击状态栏图标
  ↓
MenuBarStatusItemController
  ↓
CinemaModeService.enter()
  ↓
SystemPresentationController 保存原始状态并显示系统 chrome 覆盖层
  ↓
PreferencesStore 提供观影偏好
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
SystemPresentationController 恢复原始状态
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
| 菜单栏图标 | 作为主要入口常驻显示 | 进入前保存原始 options |
| Dock | 通过系统 chrome 覆盖层呈现隐藏效果 | 不依赖临时激活 app |
| Activation Policy | 菜单栏 app 保持 `.accessory`，进入时不激活自身 | 避免抢占播放器键盘焦点 |
| Space 锚点 | 不再使用透明锚点窗 | 通过非激活覆盖层避免切桌面和抢焦点 |
| 设置页 | 独立设置窗口承载偏好配置 | 不把偏好塞进主流程 |
| 退出浮窗 | 使用独立浮动 panel | 不依赖主窗口是否可见 |
| 鼠标移动 | 只监听用于浮窗透明度，不识别应用或内容 | 不推断用户是否观看视频 |
| 权限 | MVP 避免需要辅助功能权限的方案 | 不要求用户理解权限机制 |

## 7. 边界规则

| 规则 | 说明 |
|------|------|
| 页面层不直接调用 AppKit 系统控制 | 统一经过 `CinemaModeService`，避免状态散乱。 |
| AppKit 桥接必须小而明确 | 平台层只暴露进入、退出、浮窗、鼠标状态等窄接口。 |
| 进入前必须保存状态 | 没有保存成功不得继续进入观影模式。 |
| 进入时不得抢占前台应用焦点 | 菜单栏 app 只显示覆盖层和浮窗，不主动激活自身。 |
| 不再依赖 Space 锚点 | 当前实现通过覆盖层避免切桌面，不使用透明锚点窗。 |
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
| 2026-06-19 | 改为非激活系统 chrome 覆盖层，保留播放器前台焦点。 | 修复 ESC 不再落到播放器的问题。 |
| 2026-06-19 | 状态栏入口保持原生状态菜单，入口不再承担系统 UI 激活职责。 | 收敛菜单栏 app 的前台行为。 |
| 2026-06-19 | 状态栏入口改为原生状态菜单。 | 解决点击图标不显示功能项的问题。 |
| 2026-06-19 | 新增设置窗口和偏好存储层。 | 对齐新需求。 |

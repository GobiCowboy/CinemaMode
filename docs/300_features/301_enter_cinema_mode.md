# 301 进入观影模式

## 1. 基本信息

| 项 | 内容 |
|----|------|
| 功能编号 | 301 |
| 功能名称 | 进入观影模式 |
| 状态 | 已实现 |
| 相关用户流程 | `102_user_flows.md#f-001-首次打开应用`, `102_user_flows.md#f-002-观看网页视频`, `102_user_flows.md#f-003-观看本地视频` |
| 相关数据模型 | `203_data_model.md#cinemamodestate`, `203_data_model.md#presentationsnapshot` |

## 2. 功能目标

用户通过一次点击进入低干扰观影状态：

- 隐藏菜单栏和 Dock。
- 保存进入前系统显示状态，方便退出时恢复。
- 创建退出浮窗，让用户不会被困住。
- 不要求用户理解权限、系统设置或快捷键。

## 3. 用户流程

1. 用户打开 Safari、IINA、VLC 或其他内容应用。
2. 用户点击菜单栏上的 Cinema Mode 入口。
3. 系统检查当前是否已经处于观影模式。
4. 系统保存当前 `NSApplication.PresentationOptions`。
5. 系统应用观影模式 presentation options。
6. 系统显示退出浮窗。
7. 用户看到菜单栏和 Dock 消失，屏幕进入低干扰状态。

## 4. 页面与交互

| 页面 / 区域 | 元素 | 交互行为 | 状态 |
|-------------|------|----------|------|
| 菜单栏入口 | 进入按钮 | 点击后调用 `CinemaModeService.enter()` | idle |
| 菜单栏入口 | 状态反馈 | 进入中避免重复点击 | entering |
| 系统屏幕 | 菜单栏 / Dock | 进入成功后隐藏或自动隐藏 | active |
| 屏幕右下角 | 退出浮窗 | 进入成功后显示 | active |

## 5. 涉及数据

| 数据 | 来源 | 用途 | 对应模型 |
|------|------|------|----------|
| 当前状态 | `CinemaModeService` | 防止重复进入和错误流转 | `CinemaModeState` |
| 原始 presentation options | `NSApplication.shared.presentationOptions` | 退出时恢复 | `PresentationSnapshot` |
| 进入时间 | 系统时间 | 日志和状态追踪 | `CinemaModeState` |

## 6. 实现步骤

| 步骤 | 文件 / 模块 | 做什么 | 完成标准 |
|:----:|------------|--------|----------|
| 1 | `CinemaMode/Models/CinemaModeState.swift` | 定义状态机 phase | 覆盖 idle、entering、active、exiting、recovering、failed |
| 2 | `CinemaMode/Platform/PresentationController.swift` | 封装保存和应用 presentation options | UI 层不能直接接触 AppKit options |
| 3 | `CinemaMode/Services/CinemaModeService.swift` | 实现 `enter()` 编排 | 重复进入不会创建重复浮窗 |
| 4 | `CinemaMode/Platform/FloatingPanelController.swift` | 提供 `show()` 接口供进入后调用 | 进入成功后浮窗可见 |
| 5 | `CinemaMode/Views/MenuBarMenuView.swift` | 接入进入按钮 | 用户一次点击即可触发 |
| 6 | `CinemaMode/Support/Logger.swift` | 记录进入流程日志 | 成功、失败路径有日志 |

## 7. 接口 / 函数

| 名称 | 类型 | 输入 | 输出 | 说明 |
|------|------|------|------|------|
| `CinemaModeService.enter()` | async function | 无 | `Result<Void, AppError>` | 主进入流程 |
| `PresentationController.capture()` | function | 无 | `PresentationSnapshot` | 保存进入前状态 |
| `PresentationController.applyCinemaOptions()` | function | `PresentationSnapshot` | `Result<Void, AppError>` | 应用观影模式系统选项 |
| `FloatingPanelController.show()` | function | anchor / opacity | `Result<Void, AppError>` | 显示退出浮窗 |

## 8. 日志设计

| 场景 | level | module | action | message | context |
|------|-------|--------|--------|---------|---------|
| 开始进入 | info | `cinemaMode` | `enter.start` | Start entering cinema mode | `phase` |
| 状态快照成功 | info | `presentation` | `snapshot.capture` | Presentation snapshot captured | `optionsSummary` |
| 应用系统选项成功 | info | `presentation` | `options.apply` | Cinema presentation options applied | `optionsSummary` |
| 浮窗显示成功 | info | `floatingPanel` | `show` | Exit floating panel shown | `anchor` |
| 重复进入 | warn | `cinemaMode` | `enter.ignored` | Enter ignored because mode is already active | `phase` |
| 进入失败 | error | `cinemaMode` | `enter.failed` | Failed to enter cinema mode | `errorType` |

不记录：用户正在观看的内容、网页地址、视频文件完整路径。

## 9. 复用检查

| 检查项 | 结论 |
|--------|------|
| 已有类似功能？ | 无，MVP 首个核心功能 |
| 已有类似实现？ | 无，需新增 `CinemaModeService` 和 `PresentationController` |
| 已有可复用能力？ | 日志接口按 206 设计 |
| 命中待抽象记录？ | 是，`presentation options 保存 / 恢复` 和 `状态机流转保护` |

## 10. 本次开发策略

| 决定 | 说明 |
|------|------|
| 抽象封装 | presentation 控制必须集中到 `PresentationController` |
| 是否记录到待抽象 | 是 |
| 处理原因 | 301 负责进入，303 负责退出，二者共享系统状态控制 |

## 11. 相关文件

| 文件 | 作用 | 状态 |
|------|------|------|
| `Sources/CinemaModeCore/Services/CinemaModeService.swift` | 进入流程编排 | 已创建 |
| `Sources/CinemaMode/Services/SystemPresentationController.swift` | 系统显示状态控制 | 已创建 |
| `Sources/CinemaMode/Services/FloatingPanelController.swift` | 退出浮窗显示 | 已创建 |
| `Sources/CinemaMode/Views/MenuBarMenuView.swift` | 用户入口 | 已创建 |
| `Sources/CinemaMode/Views/MenuBarIconView.swift` | 菜单栏图标 | 已创建 |
| `Sources/CinemaMode/Services/SystemLogger.swift` | 统一日志 | 已创建 |

## 12. 验收

| 验收项 | 判断方式 | 结果 |
|--------|----------|:----:|
| 主流程可用 | `swift test` + `./script/build_and_run.sh --verify` | 已通过 |
| 重复点击可处理 | 单测覆盖 | 已通过 |
| 失败可恢复 | 单测覆盖 | 已通过 |
| 日志正常输出 | 代码审查 + 单测 | 已通过 |
| 无裸 `print` | `rg "print\\(" Sources` | 已通过 |
| 文档索引已更新 | 000 和 901 已记录 | 已完成 |

## 13. 变更记录

| 日期 | 更新内容 | 涉及文件 |
|------|----------|----------|
| 2026-06-18 | 初始化进入观影模式功能文档。 | 本文件、000、901 |

# 904 问题记录

## 问题总表

| 编号 | 日期 | 问题摘要 | 影响功能 | 严重程度 | 状态 |
|------|------|----------|----------|:--------:|:----:|
| I-001 | 2026-06-18 | 需要验证菜单栏和 Dock presentation options 的合法组合 | 301, 303 | 中 | 已规避 |
| I-002 | 2026-06-18 | 需要验证浮窗在播放器全屏或多屏场景下是否始终可见 | 302, 303 | 高 | 未解决 |
| I-003 | 2026-06-19 | 菜单栏 app 浮窗出现但系统菜单栏未隐藏 | 301, 303 | 高 | 已解决 |
| I-004 | 2026-06-19 | 进入观影模式时会抢占前台焦点，导致 ESC 不再落给播放器 | 301, 303 | 高 | 已解决 |
| I-005 | 2026-06-19 | 菜单栏 app 入口生命周期与空 scene 耦合过紧，启动会立刻退出 | 301, 303 | 中 | 已解决 |

状态：未解决 / 已解决 / 不再复现 / 已规避

---

## 问题详情

### I-001 presentation options 合法组合

**出现位置**

技术设计阶段，`SystemPresentationController`。

**问题现象**

macOS 对菜单栏和 Dock 隐藏相关选项存在组合约束，错误组合可能导致进入失败或行为不符合预期。

**日志线索**

后续实现中记录 `presentation.overlay.apply`、`presentation.chromeCover.show` 的成功、失败和错误类型。

**原因**

系统级 presentation options 不是任意组合。

**处理方式**

在 `SystemPresentationController` 内集中保存原始状态并显示系统 chrome 覆盖层，退出时恢复。

**如何避免**

禁止业务层和 UI 层直接设置 `NSApplication.presentationOptions`。

### I-002 浮窗多屏和全屏层级验证

**出现位置**

功能 302、303。

**问题现象**

当用户使用播放器全屏、浏览器全屏或外接显示器时，退出浮窗可能被遮挡、定位错误或出现在非当前屏幕。

**日志线索**

后续实现中记录 `floatingPanel.show`、`floatingPanel.reposition`、`floatingPanel.close`。

**原因**

macOS 多屏、Spaces、全屏应用和窗口层级组合复杂。

**处理方式**

实现阶段用真实 `.app` 手动验证；浮窗定位逻辑集中到 `FloatingPanelController`。

**如何避免**

每次修改浮窗窗口层级、屏幕定位或全屏行为后，必须重新执行 204 的手动验收场景。

### I-003 accessory 状态下 presentation options 未隐藏菜单栏

**出现位置**

`SystemPresentationController.applyCinemaMode(using:)`。

**问题现象**

用户点击进入观影模式后，退出浮窗正常出现，但系统菜单栏没有隐藏。

**日志线索**

统一日志中能看到 `cinemaMode.enter.start`、`presentation.overlay.apply`、`presentation.chromeCover.show`、`floatingPanel.show`、`cinemaMode.enter.success`，说明状态机和浮窗流程已经执行；如果后续继续点击，会出现 `cinemaMode.enter.ignored`，说明服务已进入 active。

**原因**

应用作为菜单栏工具以 `.accessory` 启动。直接设置 `NSApplication.presentationOptions` 时，系统菜单栏隐藏没有可靠生效。

**处理方式**

进入观影模式时不再激活自身，只显示非激活覆盖层并保持播放器焦点；退出时隐藏覆盖层并恢复原始状态。

**如何避免**

不要在 UI 层或菜单项里直接设置 presentation options。任何改变菜单栏或 Dock 显示状态的逻辑必须经过 `SystemPresentationController`，并保留 `activationBefore`、`activationAfter`、`actualOptionsRawValue` 日志字段。

### I-004 进入观影模式时会抢占前台焦点，导致 ESC 不再落给播放器

**出现位置**

`SystemPresentationController.applyCinemaMode(using:)`，以及状态栏入口触发进入的菜单链路。

**问题现象**

用户在视频播放时进入观影模式后，播放器不再接收 ESC 之类的键盘事件。

**日志线索**

统一日志在进入时会记录 `presentation.overlay.apply` 和 `presentation.chromeCover.show`，但不再出现 `NSApp.activate` 或 `activationAnchorWindow` 相关上下文。

**原因**

旧方案曾尝试激活 CinemaMode 自己来影响系统 UI，结果把前台焦点从播放器抢走了。

**处理方式**

进入观影模式时不再激活自身，只显示非激活覆盖层并尽量保留原播放器前台焦点。退出时只关闭覆盖层和浮窗，恢复原始状态。

**如何避免**

任何进入流程都不能再引入 `NSApp.activate`、临时 `.regular` policy 或 Space 锚点窗。

### I-005 空 scene 导致启动不稳定

**出现位置**

`Sources/CinemaMode/App/CinemaModeApp.swift`。

**问题现象**

早期入口依赖空 SwiftUI scene，某些启动路径会让应用刚被拉起就退出。

**日志线索**

LaunchServices 日志里会看到应用被 spawn 后迅速结束，`pgrep -x CinemaMode` 抓不到持续进程。

**原因**

菜单栏工具的生命周期没有被明确的 AppKit delegate 持住。

**处理方式**

改为纯 AppKit 生命周期入口，`NSApplicationDelegate` 持有 `AppEnvironment`，并在启动时建立状态栏入口。

**如何避免**

菜单栏工具如果不需要主窗口，不要依赖一个空 scene 撑生命周期。

## 变更记录

| 日期 | 变更内容 |
|------|----------|
| 2026-06-18 | 初始化问题记录。 |
| 2026-06-19 | 记录并修复 accessory 状态下菜单栏未隐藏问题。 |
| 2026-06-19 | 记录进入观影模式时前台焦点被抢占的问题与修复。 |
| 2026-06-19 | 记录纯 AppKit 生命周期入口替换空 scene 的修复。 |

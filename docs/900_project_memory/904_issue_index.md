# 904 问题记录

## 问题总表

| 编号 | 日期 | 问题摘要 | 影响功能 | 严重程度 | 状态 |
|------|------|----------|----------|:--------:|:----:|
| I-001 | 2026-06-18 | 需要验证菜单栏和 Dock presentation options 的合法组合 | 301, 303 | 中 | 已规避 |
| I-002 | 2026-06-18 | 需要验证浮窗在播放器全屏或多屏场景下是否始终可见 | 302, 303 | 高 | 未解决 |
| I-003 | 2026-06-19 | 菜单栏 app 浮窗出现但系统菜单栏未隐藏 | 301, 303 | 高 | 已解决 |

状态：未解决 / 已解决 / 不再复现 / 已规避

---

## 问题详情

### I-001 presentation options 合法组合

**出现位置**

技术设计阶段，`PresentationController`。

**问题现象**

macOS 对菜单栏和 Dock 隐藏相关选项存在组合约束，错误组合可能导致进入失败或行为不符合预期。

**日志线索**

后续实现中记录 `presentation.options.apply` 的成功、失败和错误类型。

**原因**

系统级 presentation options 不是任意组合。

**处理方式**

在 `PresentationController` 内集中生成合法 options，进入前保存原始 options，退出时恢复。

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

统一日志中能看到 `cinemaMode.enter.start`、`presentation.options.apply`、`floatingPanel.show`、`cinemaMode.enter.success`，说明状态机和浮窗流程已经执行；如果后续继续点击，会出现 `cinemaMode.enter.ignored`，说明服务已进入 active。

**原因**

应用作为菜单栏工具以 `.accessory` 启动。直接设置 `NSApplication.presentationOptions` 时，系统菜单栏隐藏没有可靠生效。

**处理方式**

进入观影模式前，在 `SystemPresentationController` 内临时执行 `NSApp.setActivationPolicy(.regular)` 和 `NSApp.activate(ignoringOtherApps: true)`，再设置 `.autoHideMenuBar` 和 `.autoHideDock`。退出恢复 presentation options 后，再将应用切回 `.accessory`。

**如何避免**

不要在 UI 层或菜单项里直接设置 presentation options。任何改变菜单栏或 Dock 显示状态的逻辑必须经过 `SystemPresentationController`，并保留 `activationBefore`、`activationAfter`、`actualOptionsRawValue` 日志字段。

### I-004 进入观影模式时跳回其他桌面

**出现位置**

`SystemPresentationController.applyCinemaMode(using:)`，以及状态栏入口触发进入的菜单链路。

**问题现象**

用户正在当前桌面或全屏视频里点击进入观影模式，结果系统焦点被带回 `CinemaMode` 之前所在的桌面，看起来像跳到了 Codex 页面。

**日志线索**

统一日志显示 `presentation.options.apply` 每次都会记录 `activationBefore=NSApplicationActivationPolicy(rawValue: 1)`、`activationAfter=NSApplicationActivationPolicy(rawValue: 0)`，说明进入前一定发生了从 `.accessory` 到 `.regular` 的前台切换。如果 `frontmostBefore` 和当前视频应用一致，但用户视觉上被切桌面，问题就在 Space 归属而不是状态机。

**原因**

为了让菜单栏和 Dock 隐藏，应用必须临时成为前台 app。但如果前台切换时没有绑定当前 Space，macOS 可能会把用户带回该 app 之前所属的桌面。菜单 popover 未先关闭时，这种切换更容易显得突兀。

**处理方式**

进入前先关闭状态栏 popover；随后创建一个透明 1x1 激活锚点窗，并给它设置 `moveToActiveSpace`，再执行 `NSApp.activate(ignoringOtherApps: true)`。这样前台切换会落在用户当前桌面，而不是把用户切回别的 Space。

**如何避免**

任何需要临时把菜单栏 app 提升为前台的改动，都必须同时考虑 Space 行为。保留 `frontmostBefore`、`frontmostAfter`、`anchorFrame` 日志字段，避免只看菜单栏是否隐藏而忽略桌面跳转。

## 变更记录

| 日期 | 变更内容 |
|------|----------|
| 2026-06-18 | 初始化问题记录。 |
| 2026-06-19 | 记录并修复 accessory 状态下菜单栏未隐藏问题。 |
| 2026-06-19 | 记录进入观影模式时跳回其他桌面的问题与修复。 |

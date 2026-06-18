# 303 退出并恢复

## 1. 基本信息

| 项 | 内容 |
|----|------|
| 功能编号 | 303 |
| 功能名称 | 退出并恢复 |
| 状态 | 已实现 |
| 相关用户流程 | `102_user_flows.md#f-004-临时退出观影模式`, `102_user_flows.md#f-005-异常恢复` |
| 相关数据模型 | `203_data_model.md#cinemamodestate`, `203_data_model.md#presentationsnapshot`, `203_data_model.md#floatingwindowstate` |

## 2. 功能目标

用户点击浮窗后自然退出观影模式：

- 恢复进入前菜单栏和 Dock 状态。
- 恢复为菜单栏工具的 `.accessory` 激活策略。
- 关闭进入时创建的当前 Space 激活锚点。
- 停止鼠标活动监听。
- 关闭退出浮窗。
- 将状态机回到 idle。
- 失败时优先恢复系统显示状态，避免用户被困住。

## 3. 用户流程

1. 用户移动鼠标并发现退出浮窗。
2. 用户悬停浮窗，浮窗完全可见。
3. 用户点击浮窗。
4. 系统进入 exiting 状态。
5. 系统恢复进入前 presentation options。
6. 系统关闭当前 Space 激活锚点。
7. 系统将应用恢复为 `.accessory`。
8. 系统停止鼠标监听并关闭浮窗。
9. 系统回到 idle。

## 4. 页面与交互

| 页面 / 区域 | 元素 | 交互行为 | 状态 |
|-------------|------|----------|------|
| 退出浮窗 | 圆形按钮 | 点击触发退出 | active |
| 系统 UI | 菜单栏 / Dock | 恢复进入前状态 | exiting |
| 应用状态 | activation policy | 退出成功后恢复为 `.accessory` | idle |
| 退出浮窗 | 浮窗窗口 | 退出成功后关闭 | idle |
| 主入口 | 进入按钮 | 退出后可再次进入 | idle |

## 5. 涉及数据

| 数据 | 来源 | 用途 | 对应模型 |
|------|------|------|----------|
| 原始 presentation options | 301 保存的快照 | 恢复系统状态 | `PresentationSnapshot` |
| activation policy | 固定策略 | 退出后恢复菜单栏工具形态 | 运行时状态 |
| Space 激活锚点 | 301 创建的透明锚点窗 | 退出时释放，避免残留前台切换状态 | 运行时状态 |
| 当前状态 | `CinemaModeService` | 防止重复退出 | `CinemaModeState` |
| 浮窗状态 | `FloatingPanelController` | 关闭浮窗 | `FloatingWindowState` |
| 恢复重试次数 | `PresentationSnapshot` | 记录恢复异常 | `PresentationSnapshot` |

## 6. 实现步骤

| 步骤 | 文件 / 模块 | 做什么 | 完成标准 |
|:----:|------------|--------|----------|
| 1 | `CinemaMode/Services/CinemaModeService.swift` | 实现 `exit()` 状态机流程 | 只执行一次退出 |
| 2 | `CinemaMode/Platform/PresentationController.swift` | 实现 `restore(snapshot:)` | 恢复进入前 options |
| 3 | `CinemaMode/Platform/PointerActivityMonitor.swift` | 退出时停止监听 | 退出后不再触发透明度更新 |
| 4 | `CinemaMode/Platform/FloatingPanelController.swift` | 退出时关闭浮窗 | 浮窗窗口释放 |
| 5 | `CinemaMode/App/AppDelegate.swift` | 启动或终止时兜底恢复 | 异常退出后不残留沉浸状态 |
| 6 | `CinemaMode/Support/Logger.swift` | 记录退出和恢复日志 | 成功、失败、重试可排查 |

## 7. 接口 / 函数

| 名称 | 类型 | 输入 | 输出 | 说明 |
|------|------|------|------|------|
| `CinemaModeService.exit()` | async function | 无 | `Result<Void, AppError>` | 主退出流程 |
| `CinemaModeService.recoverIfNeeded()` | function | 无 | Void | 启动或异常状态恢复 |
| `PresentationController.restore(snapshot:)` | function | `PresentationSnapshot` | `Result<Void, AppError>` | 恢复系统显示状态 |
| `FloatingPanelController.close()` | function | 无 | Void | 关闭退出浮窗 |
| `PointerActivityMonitor.stop()` | function | 无 | Void | 停止鼠标监听 |

## 8. 日志设计

| 场景 | level | module | action | message | context |
|------|-------|--------|--------|---------|---------|
| 开始退出 | info | `cinemaMode` | `exit.start` | Start exiting cinema mode | `phase` |
| 恢复成功 | info | `presentation` | `options.restore` | Presentation options restored | `restoreAttemptCount` |
| 浮窗关闭 | info | `floatingPanel` | `close` | Exit floating panel closed | 无 |
| 退出成功 | info | `cinemaMode` | `exit.success` | Cinema mode exited | `duration` |
| 重复退出 | warn | `cinemaMode` | `exit.ignored` | Exit ignored because mode is not active | `phase` |
| 异常恢复 | warn | `cinemaMode` | `recover` | Recovering inconsistent cinema mode state | `reason` |
| 恢复失败 | error | `presentation` | `options.restore.failed` | Failed to restore presentation options | `errorType`, `restoreAttemptCount` |

不记录：网页地址、视频文件路径、窗口标题、用户内容。

## 9. 复用检查

| 检查项 | 结论 |
|--------|------|
| 已有类似功能？ | 301 进入流程共享状态机和 presentation 控制 |
| 已有类似实现？ | 需要复用 301 的 `PresentationController` |
| 已有可复用能力？ | `CinemaModeService`, `FloatingPanelController`, `Logger` |
| 命中待抽象记录？ | 是，`presentation options 保存 / 恢复`、`状态机流转保护`、`浮窗 show / close 幂等处理` |

## 10. 本次开发策略

| 决定 | 说明 |
|------|------|
| 复用现有规划 | 复用 301/302 规划的 service、presentation、floating panel |
| 是否记录到待抽象 | 是 |
| 处理原因 | 退出是安全底线，必须和进入共享同一状态来源 |

## 11. 相关文件

| 文件 | 作用 | 状态 |
|------|------|------|
| `Sources/CinemaModeCore/Services/CinemaModeService.swift` | 退出和恢复编排 | 已创建 |
| `Sources/CinemaMode/Services/SystemPresentationController.swift` | 恢复系统显示状态 | 已创建 |
| `Sources/CinemaMode/Services/FloatingPanelController.swift` | 关闭浮窗 | 已创建 |
| `Sources/CinemaMode/Services/SystemPointerActivityMonitor.swift` | 停止鼠标监听 | 已创建 |
| `Sources/CinemaMode/App/AppDelegate.swift` | 生命周期兜底恢复 | 已创建 |

## 12. 验收

| 验收项 | 判断方式 | 结果 |
|--------|----------|:----:|
| 点击退出可用 | 单测 + 运行验证 | 已通过 |
| 浮窗关闭 | 单测 + 运行验证 | 已通过 |
| 重复退出安全 | 单测 | 已通过 |
| 异常恢复 | 单测 | 已通过 |
| 日志正常输出 | 代码审查 + 单测 | 已通过 |
| 无裸 `print` | `rg "print\\(" Sources` | 已通过 |
| 文档索引已更新 | 000 和 901 已记录 | 已完成 |

## 13. 变更记录

| 日期 | 更新内容 | 涉及文件 |
|------|----------|----------|
| 2026-06-18 | 初始化退出并恢复功能文档。 | 本文件、000、901 |
| 2026-06-19 | 补充退出时恢复 `.accessory` 激活策略。 | 本文件、103、904 |
| 2026-06-19 | 补充退出时释放当前 Space 激活锚点。 | 本文件、103、904 |

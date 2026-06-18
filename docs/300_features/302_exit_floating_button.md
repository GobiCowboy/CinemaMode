# 302 浮窗退出入口

## 1. 基本信息

| 项 | 内容 |
|----|------|
| 功能编号 | 302 |
| 功能名称 | 浮窗退出入口 |
| 状态 | 已设计 |
| 相关用户流程 | `102_user_flows.md#f-002-观看网页视频`, `102_user_flows.md#f-003-观看本地视频`, `102_user_flows.md#f-004-临时退出观影模式` |
| 相关数据模型 | `203_data_model.md#floatingwindowstate`, `203_data_model.md#pointervisibilitystate`, `203_data_model.md#userpreferences` |

## 2. 功能目标

在观影模式中提供一个始终存在、低干扰、可发现、可点击的退出入口：

- 默认位于右下角。
- 圆形、无边框、内容为 🎬。
- 鼠标静止时约 5% 透明度。
- 鼠标移动时约 70% 透明度。
- 鼠标悬停时 100% 透明度。

## 3. 用户流程

1. 用户进入观影模式。
2. 系统在右下角创建退出浮窗。
3. 用户不移动鼠标，浮窗几乎不可见。
4. 用户移动鼠标，浮窗变得可发现。
5. 用户悬停浮窗，浮窗完全可见。
6. 用户点击浮窗，触发 303 退出并恢复。

## 4. 页面与交互

| 页面 / 区域 | 元素 | 交互行为 | 状态 |
|-------------|------|----------|------|
| 右下角浮窗 | 圆形按钮 | 显示 🎬，无边框 | active |
| 右下角浮窗 | opacity | 鼠标静止约 5% | idle pointer |
| 右下角浮窗 | opacity | 鼠标移动约 70% | moving pointer |
| 右下角浮窗 | opacity | 鼠标悬停 100% | hovering pointer |
| 右下角浮窗 | 点击 | 调用 `CinemaModeService.exit()` | active |

## 5. 涉及数据

| 数据 | 来源 | 用途 | 对应模型 |
|------|------|------|----------|
| 浮窗锚点 | 默认值 / 偏好 | 定位右下角 | `FloatingWindowState` |
| 当前透明度 | 鼠标状态映射 | 降低干扰并保持可发现 | `FloatingWindowState` |
| 鼠标活动状态 | `PointerActivityMonitor` | 控制透明度 | `PointerVisibilityState` |
| 是否 hover | 浮窗 view | 进入 100% 可点击状态 | `FloatingWindowState` |

## 6. 实现步骤

| 步骤 | 文件 / 模块 | 做什么 | 完成标准 |
|:----:|------------|--------|----------|
| 1 | `CinemaMode/Views/ExitFloatingView.swift` | 实现圆形 🎬 按钮和 hover 状态 | 视觉简洁，无边框 |
| 2 | `CinemaMode/Platform/FloatingPanelController.swift` | 创建浮动 panel 并承载 SwiftUI view | 不依赖主窗口 |
| 3 | `CinemaMode/Platform/PointerActivityMonitor.swift` | 监听鼠标移动和静止 | 可输出 idle/moving |
| 4 | `CinemaMode/Models/FloatingWindowState.swift` | 定义浮窗状态 | opacity 有明确范围 |
| 5 | `CinemaMode/Stores/PreferencesStore.swift` | 保存默认 anchor | MVP 默认右下角 |
| 6 | `CinemaMode/Services/CinemaModeService.swift` | 将浮窗点击连接到退出流程 | 点击后触发 303 |

## 7. 接口 / 函数

| 名称 | 类型 | 输入 | 输出 | 说明 |
|------|------|------|------|------|
| `FloatingPanelController.show(anchor:)` | function | `FloatingAnchor` | `Result<Void, AppError>` | 显示浮窗 |
| `FloatingPanelController.updateOpacity(_:)` | function | Double | Void | 更新透明度 |
| `FloatingPanelController.reposition()` | function | 无 | Void | 屏幕变化后重新定位 |
| `PointerActivityMonitor.start(onChange:)` | function | callback | Void | 开始监听鼠标状态 |
| `PointerActivityMonitor.stop()` | function | 无 | Void | 停止监听 |
| `ExitFloatingView.onExit` | callback | 无 | Void | 点击时触发退出 |

## 8. 日志设计

| 场景 | level | module | action | message | context |
|------|-------|--------|--------|---------|---------|
| 显示浮窗 | info | `floatingPanel` | `show` | Exit floating panel shown | `anchor`, `screenCount` |
| 重新定位 | info | `floatingPanel` | `reposition` | Exit floating panel repositioned | `anchor` |
| 关闭前点击 | info | `floatingPanel` | `exit.click` | Exit floating button clicked | 无 |
| 鼠标状态变化 | debug | `pointer` | `visibility.change` | Pointer visibility state changed | `activity`, `targetOpacity` |
| 浮窗创建失败 | error | `floatingPanel` | `show.failed` | Failed to show exit floating panel | `errorType` |

不记录：鼠标坐标轨迹、具体观看内容、窗口标题。

## 9. 复用检查

| 检查项 | 结论 |
|--------|------|
| 已有类似功能？ | 无，MVP 首个浮窗功能 |
| 已有类似实现？ | 无，需新增浮窗和鼠标监听平台层 |
| 已有可复用能力？ | `CinemaModeService` 负责状态机，`Logger` 负责日志 |
| 命中待抽象记录？ | 是，`浮窗 show / close 幂等处理` |

## 10. 本次开发策略

| 决定 | 说明 |
|------|------|
| 抽象封装 | 浮窗窗口生命周期集中到 `FloatingPanelController` |
| 是否记录到待抽象 | 是 |
| 处理原因 | 302 显示浮窗，303 关闭浮窗，必须共享同一控制器 |

## 11. 相关文件

| 文件 | 作用 | 状态 |
|------|------|------|
| `CinemaMode/Views/ExitFloatingView.swift` | 浮窗 SwiftUI 内容 | 待创建 |
| `CinemaMode/Platform/FloatingPanelController.swift` | 浮窗窗口控制 | 待创建 |
| `CinemaMode/Platform/PointerActivityMonitor.swift` | 鼠标活动监听 | 待创建 |
| `CinemaMode/Models/FloatingWindowState.swift` | 浮窗状态 | 待创建 |
| `CinemaMode/Stores/PreferencesStore.swift` | 非敏感偏好 | 待创建 |

## 12. 验收

| 验收项 | 判断方式 | 结果 |
|--------|----------|:----:|
| 默认右下角 | 进入后浮窗位于可见屏幕右下角 | 未验收 |
| 鼠标静止 5% | 停止移动后几乎不可见 | 未验收 |
| 鼠标移动 70% | 移动鼠标后可发现 | 未验收 |
| 鼠标悬停 100% | hover 后完全可见且可点击 | 未验收 |
| 多屏可见 | 外接屏和切换屏幕后仍可点击 | 未验收 |
| 日志正常输出 | show/reposition/click 有日志 | 未验收 |
| 文档索引已更新 | 000 和 901 已记录 | 已完成 |

## 13. 变更记录

| 日期 | 更新内容 | 涉及文件 |
|------|----------|----------|
| 2026-06-18 | 初始化浮窗退出入口功能文档。 | 本文件、000、901 |


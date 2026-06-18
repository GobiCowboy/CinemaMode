# 901 功能索引

## 状态选项

| 状态 | 含义 |
|------|------|
| 计划中 | 已记录，尚未开始设计 |
| 已设计 | 功能文档已写完 |
| 开发中 | 正在编码 |
| 已实现 | 代码已完成，待验收 |
| 已验收 | 验收通过 |
| 已废弃 | 不再需要 |

---

## 功能总表

| 编号 | 功能名称 | 状态 | 功能文档 | 相关代码 | 关联实现 | 复用 / 抽象提示 |
|------|----------|------|----------|----------|----------|-----------------|
| 301 | 进入观影模式 | 已实现 | 300_features/301_enter_cinema_mode.md | `Sources/CinemaMode/App/CinemaModeApp.swift`, `Sources/CinemaMode/Views/MenuBarIconView.swift`, `Sources/CinemaMode/Views/MenuBarMenuView.swift`, `Sources/CinemaModeCore/Services/CinemaModeService.swift`, `Sources/CinemaMode/Services/SystemPresentationController.swift`, `Sources/CinemaMode/Services/FloatingPanelController.swift` | `CinemaModeService`, `PresentationController` | 与 303 共用 presentation 状态恢复能力 |
| 302 | 浮窗退出入口 | 已实现 | 300_features/302_exit_floating_button.md | `Sources/CinemaMode/Services/FloatingPanelController.swift`, `Sources/CinemaMode/Services/SystemPointerActivityMonitor.swift`, `Sources/CinemaMode/Views/ExitFloatingView.swift` | `FloatingPanelController`, `PointerActivityMonitor` | 与 303 共用浮窗关闭能力 |
| 303 | 退出并恢复 | 已实现 | 300_features/303_exit_and_restore.md | `Sources/CinemaModeCore/Services/CinemaModeService.swift`, `Sources/CinemaMode/Services/SystemPresentationController.swift`, `Sources/CinemaMode/Services/FloatingPanelController.swift`, `Sources/CinemaMode/Services/SystemPointerActivityMonitor.swift` | `CinemaModeService`, `PresentationController`, `FloatingPanelController` | 与 301 共用状态机和 presentation 控制 |

## 记录规则

- 每新增一个功能文档，必须在这里增加一行。
- 只写一行摘要，不写功能细节。功能细节见对应 `300_features/` 文档。
- 状态变化时及时更新。
- 代码落地后补齐「相关代码」真实路径。

## 变更记录

| 日期 | 变更内容 |
|------|----------|
| 2026-06-18 | 初始化 MVP 功能索引。 |
| 2026-06-18 | 完成 301-303 功能文档设计，状态更新为已设计。 |
| 2026-06-18 | 完成 301-303 初版实现，状态更新为已实现。 |
| 2026-06-18 | 补充菜单栏入口与可拖动浮窗的真实代码路径。 |

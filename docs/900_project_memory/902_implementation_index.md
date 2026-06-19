# 902 实现索引

| 实现能力 | 首次出现功能 | 相关功能 | 当前位置 | 是否已抽象 | 说明 |
|----------|-------------|----------|----------|------------|------|
| 日志记录 | 206_logging_system.md | 全局 | `Sources/CinemaMode/Services/SystemLogger.swift` | 是 | 基础设施，已接入服务和平台层 |
| 菜单栏入口 | 301 | 301 | `Sources/CinemaMode/App/CinemaModeApp.swift`, `Sources/CinemaMode/Views/MenuBarIconView.swift`, `Sources/CinemaMode/App/MenuBarStatusItemController.swift` | 否 | 作为应用入口的极简菜单栏图标与原生状态菜单 |
| 设置页入口 | 304 | 304 | `Sources/CinemaMode/Services/SettingsWindowController.swift`, `Sources/CinemaMode/Views/SettingsView.swift`, `Sources/CinemaMode/App/MenuBarStatusItemController.swift` | 否 | 独立设置窗口和菜单入口 |
| 轻量偏好存储 | 304 | 304 | `Sources/CinemaModeCore/Stores/PreferencesStore.swift` | 是 | 保存观影偏好并回读 |
| 轻量语言映射 | 304 | 304 | `Sources/CinemaModeCore/Support/AppLanguage.swift` | 是 | 菜单栏与设置页文案切换 |
| 观影模式状态机 | 301 | 301, 303 | `Sources/CinemaModeCore/Services/CinemaModeService.swift` | 是 | 统一管理进入、退出、恢复 |
| 系统 chrome 覆盖层控制 | 301 | 301, 303 | `Sources/CinemaMode/Services/SystemPresentationController.swift` | 是 | 保存原始状态并显示覆盖层，退出时恢复 |
| 退出浮窗控制 | 302 | 302, 303 | `Sources/CinemaMode/Services/FloatingPanelController.swift` | 是 | 创建、定位、拖动、关闭浮窗 |
| 鼠标活动监听 | 302 | 302 | `Sources/CinemaMode/Services/SystemPointerActivityMonitor.swift` | 是 | 将鼠标状态映射到透明度 |

## 记录规则

只记录可能被多个功能复用的实现方式，例如：

- 日志记录
- 状态机
- 系统显示状态控制
- 浮窗窗口管理
- 错误恢复
- 配置读取

不要记录每个普通函数。

## 状态选项

| 状态 | 含义 |
|------|------|
| 规划中 | 文档已确定，代码未实现 |
| 是 | 已抽象为公共模块，可直接复用 |
| 否 | 尚未抽象，仍分散在具体功能中 |
| 已废弃 | 不再使用 |

## 变更记录

| 日期 | 变更内容 |
|------|----------|
| 2026-06-18 | 初始化实现索引。 |
| 2026-06-18 | 完成核心实现并更新真实文件路径。 |
| 2026-06-18 | 补充菜单栏入口和浮窗拖动能力。 |
| 2026-06-19 | 补充设置窗口与偏好存储的真实实现路径。 |

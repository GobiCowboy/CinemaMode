# 902 实现索引

| 实现能力 | 首次出现功能 | 相关功能 | 当前位置 | 是否已抽象 | 说明 |
|----------|-------------|----------|----------|------------|------|
| 日志记录 | 206_logging_system.md | 全局 | `CinemaMode/Support/Logger.swift` | 规划中 | 基础设施，后续实现阶段创建 |
| 观影模式状态机 | 301 | 301, 303 | `CinemaMode/Services/CinemaModeService.swift` | 规划中 | 统一管理进入、退出、恢复 |
| presentation options 控制 | 301 | 301, 303 | `CinemaMode/Platform/PresentationController.swift` | 规划中 | 保存和恢复菜单栏 / Dock 状态 |
| 退出浮窗控制 | 302 | 302, 303 | `CinemaMode/Platform/FloatingPanelController.swift` | 规划中 | 创建、定位、关闭浮窗 |
| 鼠标活动监听 | 302 | 302 | `CinemaMode/Platform/PointerActivityMonitor.swift` | 规划中 | 将鼠标状态映射到透明度 |
| 偏好读取 | 302 | 302 | `CinemaMode/Stores/PreferencesStore.swift` | 规划中 | MVP 只保存非敏感轻量偏好 |

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

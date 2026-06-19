# 304 设置与偏好

## 1. 基本信息

| 项 | 内容 |
|----|------|
| 功能编号 | 304 |
| 功能名称 | 设置与偏好 |
| 状态 | 开发中 |
| 相关用户流程 | `102_user_flows.md#f-006-打开设置页`, `102_user_flows.md#f-007-保存偏好` |
| 相关数据模型 | `203_data_model.md#cinemamodepreferences` |

## 2. 功能目标

提供一个独立的设置页，让普通 Mac 用户在不学习系统原理的前提下配置观影模式偏好：

- 勿扰模式
- 音量
- 亮度
- 退出恢复
- Esc 退出

设置页不承担内容识别、不承担播放器适配，只负责用户偏好。

## 3. 用户流程

1. 用户从菜单栏菜单打开 `Settings...`。
2. 系统显示独立设置窗口。
3. 用户调整勿扰、音量、亮度和退出偏好。
4. 系统即时保存偏好。
5. 下次进入观影模式时读取这些偏好。

## 4. 页面与交互

| 页面 / 区域 | 元素 | 交互行为 | 状态 |
|-------------|------|----------|------|
| 设置页 | 勿扰模式开关 | 控制是否在观影模式启用勿扰 | on/off |
| 设置页 | 音量滑块 | 设置观影时的目标音量 | 0-100 |
| 设置页 | 亮度滑块 | 设置观影时的目标内屏亮度 | 0-100 |
| 设置页 | 恢复音量开关 | 控制退出时是否恢复原音量 | on/off |
| 设置页 | 恢复亮度开关 | 控制退出时是否恢复原亮度 | on/off |
| 设置页 | Esc 退出开关 | 控制是否允许 Esc 退出观影模式 | on/off |

## 5. 涉及数据

| 数据 | 来源 | 用途 | 对应模型 |
|------|------|------|----------|
| 勿扰模式 | 设置页 | 进入观影模式时应用用户偏好 | `CinemaModePreferences` |
| 目标音量 | 设置页 | 进入时预设观影音量 | `CinemaModePreferences` |
| 目标亮度 | 设置页 | 进入时预设内屏亮度 | `CinemaModePreferences` |
| 退出恢复开关 | 设置页 | 退出时决定是否恢复原状态 | `CinemaModePreferences` |
| Esc 退出开关 | 设置页 | 决定是否保留 Esc 兜底 | `CinemaModePreferences` |

## 6. 实现步骤

| 步骤 | 文件 / 模块 | 做什么 | 完成标准 |
|:----:|------------|--------|----------|
| 1 | `Sources/CinemaModeCore/Stores/PreferencesStore.swift` | 保存并读取用户偏好 | 重新启动后设置仍在 |
| 2 | `Sources/CinemaMode/Views/SettingsView.swift` | 实现设置页 UI | 可直接调整偏好 |
| 3 | `Sources/CinemaMode/Services/SettingsWindowController.swift` | 打开和管理设置窗口 | 菜单项可打开设置页 |
| 4 | `Sources/CinemaMode/App/MenuBarStatusItemController.swift` | 提供设置菜单入口 | 菜单项可发现 |
| 5 | 后续进入流程 | 读取设置并应用 | 偏好能影响观影模式 |

## 7. 日志设计

| 场景 | level | module | action | message | context |
|------|-------|--------|--------|---------|---------|
| 打开设置页 | info | `menuBar` | `settings.tap` | Settings requested from status menu | `phase` |
| 保存偏好 | debug | `preferences` | `save` | Preference updated | `key` |

## 8. 复用检查

| 检查项 | 结论 |
|--------|------|
| 已有类似功能？ | 无，首次引入设置页 |
| 已有类似实现？ | 无，需新增偏好存储和设置窗口 |
| 已有可复用能力？ | 菜单栏入口、SwiftUI 表单、UserDefaults |
| 命中待抽象记录？ | 暂无明显重复 |

## 9. 本次开发策略

| 决定 | 说明 |
|------|------|
| 新增实现 | 以独立设置页承载偏好配置 |
| 是否记录到待抽象 | 暂不记录 |
| 处理原因 | 这是观影模式的第一层用户配置，不应塞进主流程 |

## 10. 相关文件

| 文件 | 作用 | 状态 |
|------|------|------|
| `Sources/CinemaModeCore/Stores/PreferencesStore.swift` | 偏好持久化 | 已创建 |
| `Sources/CinemaMode/Views/SettingsView.swift` | 设置页 UI | 已创建 |
| `Sources/CinemaMode/Services/SettingsWindowController.swift` | 设置窗口 | 已创建 |
| `Sources/CinemaMode/App/MenuBarStatusItemController.swift` | 菜单栏设置入口 | 已修改 |

## 11. 验收

| 验收项 | 判断方式 | 结果 |
|--------|----------|:----:|
| 设置页可打开 | 菜单栏点击 `Settings...` | 待验收 |
| 偏好可保存 | 单测 + 重启后检查 | 已部分完成 |
| 界面易懂 | 代码审查 + 手动试用 | 待验收 |
| 不要求学习系统原理 | 设计审查 | 已通过 |

## 12. 变更记录

| 日期 | 更新内容 | 涉及文件 |
|------|----------|----------|
| 2026-06-19 | 新增设置与偏好功能文档，作为新需求基线。 | 本文件、101、102、203 |

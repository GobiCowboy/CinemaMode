# 203 数据模型

## 1. 实体总览

| 实体 | 用途 | 相关功能 |
|------|------|----------|
| `CinemaModeState` | 描述观影模式状态机当前状态 | 301, 303 |
| `PresentationSnapshot` | 保存进入前的系统显示状态 | 301, 303 |
| `FloatingWindowState` | 描述退出浮窗位置、透明度和 hover 状态 | 302, 303 |
| `PointerVisibilityState` | 描述鼠标静止、移动、悬停状态 | 302 |
| `UserPreferences` | 保存非敏感用户偏好 | 302 |
| `LogEvent` | 统一日志事件结构 | 全局 |

---

## 2. 实体详情

### CinemaModeState

#### 字段

| 字段 | 类型 | 必填 | 默认值 | 约束 | 说明 |
|------|------|:----:|--------|------|------|
| `phase` | enum | 是 | `idle` | `idle / entering / active / exiting / recovering / failed` | 当前状态机阶段 |
| `enteredAt` | Date? | 否 | nil | active 后存在 | 进入观影模式时间 |
| `lastError` | AppError? | 否 | nil | 失败时存在 | 最近一次错误 |

#### 关系

| 关联实体 | 关系类型 | 说明 |
|----------|:--------:|------|
| `PresentationSnapshot` | 一对一 | active 状态需要保存进入前状态 |
| `FloatingWindowState` | 一对一 | active 状态需要浮窗状态 |

#### 生命周期

| 阶段 | 位置 | 说明 |
|------|------|------|
| 创建 | `CinemaModeService.enter()` | 用户点击进入时创建或更新 |
| 更新 | `CinemaModeService` | 状态机流转时更新 |
| 删除 | 不删除 | 回到 `idle` 后清空运行时字段 |

### PresentationSnapshot

#### 字段

| 字段 | 类型 | 必填 | 默认值 | 约束 | 说明 |
|------|------|:----:|--------|------|------|
| `originalOptions` | `NSApplication.PresentationOptions` | 是 | 无 | 进入前读取 | 用于退出时恢复 |
| `capturedAt` | Date | 是 | 当前时间 | 无 | 保存时间 |
| `restoreAttemptCount` | Int | 是 | 0 | 非负 | 恢复重试次数 |

#### 关系

| 关联实体 | 关系类型 | 说明 |
|----------|:--------:|------|
| `CinemaModeState` | 一对一 | 观影模式进入后必须存在 |

#### 生命周期

| 阶段 | 位置 | 说明 |
|------|------|------|
| 创建 | `PresentationController.capture()` | 设置新 presentation options 前创建 |
| 更新 | `PresentationController.restore()` | 恢复失败时更新重试次数 |
| 删除 | `CinemaModeService.exit()` | 成功恢复后清空 |

### FloatingWindowState

#### 字段

| 字段 | 类型 | 必填 | 默认值 | 约束 | 说明 |
|------|------|:----:|--------|------|------|
| `screenID` | String? | 否 | nil | 可为空 | 浮窗所在屏幕标识 |
| `anchor` | enum | 是 | `bottomRight` | MVP 固定右下角 | 浮窗锚点 |
| `opacity` | Double | 是 | 0.05 | 0.05...1.0 | 当前透明度 |
| `isHovered` | Bool | 是 | false | 无 | 鼠标是否悬停 |
| `isVisible` | Bool | 是 | false | 无 | 浮窗是否存在且可见 |

#### 关系

| 关联实体 | 关系类型 | 说明 |
|----------|:--------:|------|
| `PointerVisibilityState` | 一对一 | 鼠标状态决定透明度 |

#### 生命周期

| 阶段 | 位置 | 说明 |
|------|------|------|
| 创建 | `FloatingPanelController.show()` | 进入观影模式时创建 |
| 更新 | `PointerActivityMonitor` | 鼠标移动、静止、悬停时更新 |
| 删除 | `FloatingPanelController.close()` | 退出观影模式时关闭 |

### PointerVisibilityState

#### 字段

| 字段 | 类型 | 必填 | 默认值 | 约束 | 说明 |
|------|------|:----:|--------|------|------|
| `activity` | enum | 是 | `idle` | `idle / moving / hovering` | 鼠标状态 |
| `targetOpacity` | Double | 是 | 0.05 | 0.05 / 0.70 / 1.00 | 目标透明度 |
| `lastMovedAt` | Date? | 否 | nil | 无 | 最近移动时间 |

#### 生命周期

| 阶段 | 位置 | 说明 |
|------|------|------|
| 创建 | `PointerActivityMonitor.start()` | 浮窗显示后创建 |
| 更新 | `PointerActivityMonitor` | 根据鼠标事件和定时器更新 |
| 删除 | `PointerActivityMonitor.stop()` | 退出观影模式时停止 |

### UserPreferences

#### 字段

| 字段 | 类型 | 必填 | 默认值 | 约束 | 说明 |
|------|------|:----:|--------|------|------|
| `preferredAnchor` | enum | 是 | `bottomRight` | MVP 只使用右下角 | 后续可扩展 |
| `hasSeenFirstLaunch` | Bool | 是 | false | 无 | 是否首次打开过 |

#### 生命周期

| 阶段 | 位置 | 说明 |
|------|------|------|
| 创建 | `PreferencesStore` | 首次启动默认生成 |
| 更新 | `PreferencesStore` | 偏好变化时更新 |
| 删除 | 不主动删除 | 用户卸载或清除应用数据 |

### LogEvent

#### 字段

| 字段 | 类型 | 必填 | 默认值 | 约束 | 说明 |
|------|------|:----:|--------|------|------|
| `timestamp` | Date | 是 | 当前时间 | 无 | 事件时间 |
| `level` | enum | 是 | `info` | `debug / info / warn / error` | 日志等级 |
| `module` | String | 是 | 无 | 非空 | 模块名 |
| `action` | String | 是 | 无 | 非空 | 动作名 |
| `message` | String | 是 | 无 | 简短 | 事件说明 |
| `context` | Dictionary | 否 | nil | 不含敏感内容 | 结构化上下文 |

## 3. 数据边界

- 不保存用户观看的网站、视频标题、播放器名称或文件路径。
- 不保存截图、音频、键盘输入或鼠标轨迹。
- 只保存产品运行所需的状态、偏好和非敏感日志上下文。

## 4. 变更记录

| 日期 | 变更内容 | 原因 |
|------|----------|------|
| 2026-06-18 | 初始化数据模型。 | 文档阶段。 |

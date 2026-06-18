# 206 日志系统

## 1. 日志模块位置

| 项目 | 路径 |
|------|------|
| logger 模块 | `CinemaMode/Support/Logger.swift` |
| 日志输出目录 | macOS unified logging |
| 日志配置文件 | 暂无，MVP 使用代码内固定 subsystem/category |
| subsystem | `com.cinemamode.app` |

## 2. 日志等级

| 等级 | 使用场景 |
|------|----------|
| debug | 开发调试，生产默认少用 |
| info | 应用启动、进入成功、退出成功、状态变化 |
| warn | 可恢复问题、重复点击、状态不一致 |
| error | 进入失败、恢复失败、浮窗创建失败、不可恢复异常 |

## 3. 日志格式

每条日志必须包含：

| 字段 | 说明 | 必填 |
|------|------|:----:|
| timestamp | 时间，由 OSLog 记录 | 是 |
| level | 日志等级 | 是 |
| module | 模块名 | 是 |
| action | 动作名 | 是 |
| message | 简短说明 | 是 |
| context | 上下文，必须脱敏 | 否 |
| error | 错误对象 | 否 |
| stack | Swift 一般不默认记录堆栈，必要时补充 | 否 |

## 4. 调用接口

接口设计：

```swift
logger.debug(module, action, message, context)
logger.info(module, action, message, context)
logger.warn(module, action, message, context)
logger.error(module, action, message, error, context)
```

约束：

- `module`、`action`、`message` 必填。
- `context` 只允许基础类型和已脱敏内容。
- 平台层和服务层必须使用统一 logger。

## 5. 禁止写法

```swift
print("111")
print("进来了")
print(error)
```

禁止原因：缺少 module、action、context，无法定位来源，且容易泄露信息。

## 6. 必须打日志的流程

| 流程 | module | action | 必须记录 |
|------|--------|--------|----------|
| 应用启动 | `app` | `launch` | 成功 / 启动恢复 |
| 进入观影模式开始 | `cinemaMode` | `enter.start` | 当前 phase |
| 保存 presentation 快照 | `presentation` | `snapshot.capture` | 成功 / 失败 |
| 设置 presentation options | `presentation` | `options.apply` | 成功 / 失败 |
| 显示浮窗 | `floatingPanel` | `show` | 成功 / 失败 |
| 鼠标状态变化 | `pointer` | `visibility.change` | debug 级别，状态变化即可 |
| 退出开始 | `cinemaMode` | `exit.start` | 当前 phase |
| 恢复 presentation options | `presentation` | `options.restore` | 成功 / 失败 / 重试次数 |
| 关闭浮窗 | `floatingPanel` | `close` | 成功 / 已关闭 |
| 异常恢复 | `cinemaMode` | `recover` | 原因 / 结果 |
| 用户可见错误 | `app` | `userVisibleError` | 错误类型 / 简短提示 |

## 7. 敏感信息规则

禁止写入日志：

- 用户正在观看的网站、标题、视频内容。
- 本地视频完整路径。
- 截图、音频、键盘输入、鼠标轨迹。
- 密码、token、secret。
- 未脱敏的系统路径或个人目录。

允许记录：

- 功能状态，例如 `idle`、`active`、`recovering`。
- 非敏感错误类型。
- 浮窗 anchor，例如 `bottomRight`。
- 屏幕数量、是否重新定位等非内容信息。

## 8. 日志验收

| 检查项 | 状态 |
|--------|:----:|
| logger 模块已建立 | 未开始 |
| 核心功能使用统一 logger | 未开始 |
| 失败路径有 error 日志 | 未开始 |
| 每条日志含 module + action | 未开始 |
| 无 `print` 调试 | 未开始 |
| 无敏感信息泄露 | 未开始 |

## 9. 变更记录

| 日期 | 变更内容 | 原因 |
|------|----------|------|
| 2026-06-18 | 初始化日志系统设计。 | 文档阶段。 |

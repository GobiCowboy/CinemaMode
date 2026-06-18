# 206 日志系统

## 1. 日志模块位置

| 项目 | 路径 |
|------|------|
| logger 模块 | |
| 日志输出目录 | |
| 日志配置文件 | |

## 2. 日志等级

| 等级 | 使用场景 |
|------|----------|
| debug | 开发调试，生产默认关闭 |
| info | 关键流程开始、成功、状态变化 |
| warn | 非致命异常、用户输入异常、可恢复问题 |
| error | 功能失败、系统异常、不可恢复问题 |

## 3. 日志格式

每条日志必须包含：

| 字段 | 说明 | 必填 |
|------|------|:----:|
| timestamp | 时间 | 是 |
| level | 日志等级 | 是 |
| module | 模块名 | 是 |
| action | 动作名 | 是 |
| message | 简短说明 | 是 |
| context | 上下文（结构化数据） | 否 |
| error | 错误对象 | 否 |
| stack | 错误堆栈 | 否 |

## 4. 调用接口

> 以下为接口设计规范，具体语法按项目语言调整。核心约束：每条日志必须传 module、action、message 三个参数。

```
logger.debug(module, action, message[, context])
logger.info(module, action, message[, context])
logger.warn(module, action, message[, context])
logger.error(module, action, message[, error[, context]])
```

## 5. 禁止写法

```
console.log("111")
console.log("进来了")
console.log(data)
```

禁止原因：缺少 module、action、context，无法定位来源，排查时没有价值。

## 6. 必须打日志的流程

| 流程 | 必须记录 |
|------|----------|
| 应用启动 | 成功 / 失败 |
| 配置加载 | 成功 / 缺失配置 / 配置非法 |
| 文件导入 | 开始 / 成功 / 失败 |
| 数据保存 | 开始 / 成功 / 失败 |
| 导出操作 | 开始 / 成功 / 失败 |
| 外部调用 | 开始 / 成功 / 失败（含耗时） |
| 用户可见错误 | 错误类型 / 用户提示内容 |

## 7. 敏感信息规则

禁止写入日志：
- 密码、token、secret
- 用户隐私内容
- 未脱敏的完整凭据
- 不必要的文件完整内容

写文件路径时只记文件名、扩展名、大小，不记敏感绝对路径。

## 8. 日志验收

| 检查项 | 状态 |
|--------|:----:|
| logger 模块已建立 | ❌ |
| 核心功能使用统一 logger | ❌ |
| 失败路径有 error 日志 | ❌ |
| 每条日志含 module + action | ❌ |
| 无 console.log | ❌ |
| 无敏感信息泄露 | ❌ |

# 201 运行环境和配置

## 1. 运行环境

| 项目 | 版本 / 要求 |
|------|-------------|
| 语言 / 运行时 | Swift，使用本机 Xcode 附带 toolchain |
| 操作系统 | 开发机 macOS；MVP 目标系统暂定 macOS 14+ |
| IDE | Xcode，后续实现阶段创建工程后确认具体版本 |
| 包管理器 | Swift Package Manager，仅在需要第三方依赖时使用 |
| 数据库 | 无数据库；轻量偏好使用 UserDefaults / AppStorage |
| 日志 | OSLog + 项目 `Logger` 封装 |

## 2. 本地启动

当前阶段尚未创建 Xcode 工程。实现阶段创建工程后，以实际 scheme 为准。

```bash
# 运行测试
swift test

# 运行应用
./script/build_and_run.sh

# 仅验证构建和启动
./script/build_and_run.sh --verify
```

如后续采用 Swift Package + 生成工程方式，需要同步更新本文件。

## 3. 环境变量

MVP 不依赖环境变量。

| 名称 | 用途 | 示例 | 是否敏感 |
|------|------|------|----------|
| 无 | 无 | 无 | 否 |

## 4. 配置文件

| 文件 | 用途 | 是否提交 Git |
|------|------|--------------|
| `.gitignore` | 忽略 `.DS_Store`、构建产物和 Xcode 用户数据 | 是 |
| `README.md` | 项目说明 | 是 |
| `docs/` | 项目需求、架构、功能和记忆文档 | 是 |
| `Package.swift` | SwiftPM 工程入口 | 是 |
| `script/build_and_run.sh` | 本地构建、打包和启动脚本 | 是 |
| `.codex/environments/environment.toml` | Codex Run 按钮配置 | 是 |
| `dist/CinemaMode.app` | 运行时生成的 app bundle | 否 |
| `*.xcuserdata/` | Xcode 用户本地状态 | 否 |

## 5. 本地数据位置

| 数据 | 路径 | 说明 |
|------|------|------|
| 日志文件 | macOS unified logging，由 Console.app 或 `log` 命令查看 | 不单独写明文日志文件 |
| 用户配置 | `UserDefaults`，bundle id 对应域 | 保存浮窗偏好、最后状态标记等非敏感数据 |
| 临时文件 | 暂无 | MVP 不需要临时文件 |
| 构建产物 | Xcode DerivedData 或项目 `.build/` | 不提交 Git |

## 6. 凭据规则

- MVP 不需要 API Key、token、密码或云端凭据。
- 如后续加入更新检查、崩溃上报或远程配置，必须先更新本文件和 206 日志系统。
- 密码、token、secret 不写入代码、不写入日志、不提交 Git。

## 7. 变更记录

| 日期 | 变更内容 | 原因 |
|------|----------|------|
| 2026-06-18 | 初始化运行环境配置。 | 文档阶段。 |

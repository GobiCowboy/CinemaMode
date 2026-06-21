# 205 构建和发布

## 1. 构建

当前阶段尚未创建 Xcode 工程。实现阶段创建后更新实际 scheme、bundle id 和签名配置。

```bash
# Debug 构建
xcodebuild -scheme CinemaMode -configuration Debug build

# Release 构建
xcodebuild -scheme CinemaMode -configuration Release build

# 测试
xcodebuild test -scheme CinemaMode -configuration Debug
```

## 2. 版本号规则

| 字段 | 规则 |
|------|------|
| Marketing Version | `主版本.次版本.修订号`，MVP 从 `0.1.0` 开始 |
| Build Number | 使用递增整数或 CI 构建号 |
| Git Tag | 发布时使用 `v0.1.0` 格式 |

版本示例：

| 阶段 | 版本 |
|------|------|
| MVP 内测 | `0.1.0` |
| 修复补丁 | `0.1.1` |
| 下一轮功能 | `0.2.0` |

## 3. 发布前检查

1. 运行 `xcodebuild test`。
2. 运行 Release 构建。
3. 检查进入和退出观影模式。
4. 检查异常恢复。
5. 检查日志正常输出。
6. 检查没有 `print` 调试语句。
7. 检查没有敏感信息进入日志。
8. 检查文档索引已更新。
9. 检查功能索引已更新。
10. 检查签名和公证策略。

## 4. 发布产物

| 产物 | 路径 | 用途 |
|------|------|------|
| `.app` | `build/Release/CinemaMode.app` | 本地运行和打包 |
| `.dmg` | `dist/CinemaMode-<version>.dmg` | 面向普通用户分发 |
| `.zip` | `dist/CinemaMode-<version>.zip` | 备用分发 |
| Release notes | `docs/990_archive/releases/` 或 GitHub Release | 记录版本变化 |

## 5. 签名和公证

MVP 面向普通 Mac 用户，发布前需要避免“无法打开”类体验。

| 项 | 策略 |
|----|------|
| 开发阶段 | 可使用本地开发签名 |
| 内测阶段 | 优先使用 Developer ID 签名 |
| 公开分发 | 需要签名、公证和 stapling |
| 权限说明 | MVP 避免申请复杂权限 |

## 6. App Store 版本补充

App Store 版与 GitHub 分发版要分开看待：

| 项 | 要求 |
|----|------|
| 沙盒 | App Store 版必须启用 App Sandbox |
| 签名 | 使用 Apple Distribution 证书 |
| 自动化能力 | 如果继续用 AppleScript 调系统音量，需要补 `com.apple.security.automation.apple-events` 和用途说明 |
| 版本标记 | 通过 `CinemaModeEdition=appstore` 固定为 App Store 配置 |
| 上传方式 | 使用 Xcode Archive / Organizer 或等价的正式归档流程 |

App Store 版不包含 GitHub 版的 Dock 自动隐藏能力，也不依赖用户额外安装脚本或命令行工具。

## 7. 回滚方式

| 场景 | 回滚方式 |
|------|----------|
| 发布包不可用 | 回到上一 Git tag 重新构建 |
| 新版本退出异常 | 立即下架该版本，恢复上一版本下载 |
| 日志发现恢复失败 | 暂停发布，优先修复 303 |

## 8. 变更记录

| 日期 | 变更内容 | 原因 |
|------|----------|------|
| 2026-06-18 | 初始化构建和发布计划。 | 文档阶段。 |

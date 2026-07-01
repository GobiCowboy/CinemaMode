# 205 构建和发布

## 1. 构建

当前阶段已创建 Xcode 工程 `CinemaMode.xcodeproj`，可直接用于 archive 与后续发布配置。

```bash
# Debug 构建
xcodebuild -scheme CinemaMode -project CinemaMode.xcodeproj -configuration Debug -destination 'platform=macOS' build

# Release 构建
xcodebuild -scheme CinemaMode -project CinemaMode.xcodeproj -configuration Release -destination 'platform=macOS' build

# 测试
xcodebuild test -scheme CinemaMode -project CinemaMode.xcodeproj -configuration Debug -destination 'platform=macOS'

# 归档
xcodebuild -scheme CinemaMode -project CinemaMode.xcodeproj -configuration Release -destination 'platform=macOS' archive -archivePath dist/CinemaMode.xcarchive

# 导出 / 上传
xcodebuild -exportArchive -archivePath dist/CinemaMode.xcarchive -exportPath dist/AppStoreExport -exportOptionsPlist Config/AppStore/ExportOptions.plist
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

MVP 面向普通 Mac 用户，发布前需要避免”无法打开”类体验。

| 项 | 策略 |
|----|------|
| 开发阶段 | 可使用本地开发签名 |
| 内测阶段 | 优先使用 Developer ID 签名 |
| 公开分发 | 需要签名、公证和 stapling |
| 权限说明 | MVP 避免申请复杂权限 |

### 公证凭证配置

本机钥匙串中已配置以下公证凭证，可直接使用：

| Profile 名称 | 状态 |
|-------------|------|
| `Apple-Notary` | ✅ 可用 |
| `QuickHub-Notary` | ✅ 可用 |

**注意：** `security find-generic-password` 查不到 notary 凭证，因为 notarytool 使用独立的 keychain item 类型。验证凭证是否存在的正确方式：

```bash
xcrun notarytool history --keychain-profile “Apple-Notary” 2>&1
```

如果输出 `Successfully received submission history.` 则凭证有效。

如果凭证不存在，需要先存储：

```bash
xcrun notarytool store-credentials “Apple-Notary” \
  --apple-id “你的Apple ID” \
  --team-id “4UNNXY925R”
```

然后按提示输入 App 专用密码（在 https://appleid.apple.com → 登录与安全 → App 专用密码 生成）。

### 完整发布流程（签名 → 公证 → Stapler）

```bash
# 1. Developer ID 签名 + hardened runtime
codesign --force --deep --options runtime --timestamp \
  -s “Developer ID Application: jin guo (4UNNXY925R)” \
  “dist/CinemaMode-0.1.0.app”

# 2. 打包 zip（公证只能上传 zip，不能直接传 .app）
ditto -c -k --sequesterRsrc --keepParent \
  “dist/CinemaMode-0.1.0.app” “dist/CinemaMode-0.1.0.zip”

# 3. 提交公证
xcrun notarytool submit “dist/CinemaMode-0.1.0.zip” \
  --keychain-profile “Apple-Notary” --wait

# 4. Stapler 写入公证票据（只对 .app 生效，zip 不能 stapler）
xcrun stapler staple “dist/CinemaMode-0.1.0.app”

# 5. 验证
codesign --verify --deep --strict --verbose=2 “dist/CinemaMode-0.1.0.app”
spctl -a -vv “dist/CinemaMode-0.1.0.app”
```

验证通过后 `spctl` 应输出 `source=Notarized Developer ID`。

### 为什么必须公证

未公证的 .app 在用户机器上打开时会弹警告：
> Apple could not verify “<app>” is free of malware that may harm your Mac or compromise your privacy.

即使有 Developer ID 签名也会弹，必须完成公证 + stapler 才会消失。

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

当前试跑结果：

- `xcodebuild archive` 已成功生成 `CinemaMode.xcodeproj` 的 macOS `.app` archive。
- `xcodebuild -exportArchive` 在 App Store Connect 查询阶段失败，报错为 `Downloading App Information`。
- 日志显示 App Store Connect 当前没有找到 bundle id `com.cinemamode.app` 对应的 app 记录。
- 下一步需要先在 App Store Connect 创建该 app 记录，再继续导出或上传。

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
| 2026-06-21 | 补充 Xcode 工程、App Store 归档与导出命令，并记录当前发布试跑结果。 | 已完成工程壳，开始正式发布验证。 |

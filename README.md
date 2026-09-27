# GodSend

<p align="center">
  <img src="app/assets/logo.png" alt="GodSend" width="96" />
</p>

**GodSend** 是一款纯局域网文件 / 文本互传工具。设备在局域网内通过 mDNS 自动发现并直连传输，**无需注册、无需登录、无需任何服务器，数据不出内网**。

## 平台

- **Windows x64**（CI 自动构建便携版 zip）
- **Android arm64-v8a**（CI 自动构建 APK）

## 构建产物

推送代码到 GitHub 后，Actions 会自动构建：

| Job | 产物 |
|-----|------|
| `Windows x64` | `GodSend-windows-x64-<版本>.zip`（便携版，解压即用） |
| `Android arm64` | `GodSend-android-arm64-v8a-<版本>.apk`（CI 使用 debug 证书签名） |

产物在 Actions 页面的 Artifacts 中下载。

## 本地构建

依赖 Flutter stable（最新版）。

```bash
# Windows
cd app
./scripts/windows_font_assets.ps1 enable
flutter build windows --release
# 产物在 build/windows/x64/runner/Release/

# Android arm64
cd app
flutter build apk --release --flavor direct --target-platform android-arm64 --split-per-abi
# 产物在 build/app/outputs/flutter-apk/
```

> Android release 签名：若缺少 `key.properties`，构建会自动回退到本地 debug keystore（CI 已自动生成）。

## 行为说明

- **开机自启**：默认关闭（Windows 设置页可手动开启）。
- **纯局域网**：应用不内置任何服务器端点，不会产生外网流量；不支持自建信令或云端中转。
- **WebDAV**：保留（可接内网 NAS 浏览 / 上传 / 下载）。

## 许可证

**SPDX:** `AGPL-3.0-or-later`（详见 [LICENSE](LICENSE)）

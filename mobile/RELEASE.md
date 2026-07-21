# Flutter 运行、打包与发布

在 `mobile` 目录执行本文命令：

```powershell
cd F:\work\my-work\NewApp\mobile
flutter pub get
```

## 1. 后端接口地址

地址由 `--dart-define=API_BASE_URL=...` 注入，读取代码在 `lib/api_client.dart`。

| 环境 | 地址 |
| --- | --- |
| Android 模拟器 | `http://10.0.2.2:9999/api` |
| Android 真机 | `http://电脑局域网IP:9999/api` |
| iOS 模拟器 | `http://localhost:9999/api` |
| iPhone 真机 | `http://电脑局域网IP:9999/api` |
| 正式包 | `https://公网域名/api` |

地址应包含 `/api`，末尾不要加 `/`。例如：

```text
https://api.example.com/api
```

VS Code 地址配置在仓库根目录 `.vscode/launch.json`。修改地址后重新按 `F5`。

## 2. VS Code 运行与 Hot Reload

安装 VS Code 的 Flutter、Dart 扩展，然后打开仓库根目录 `NewApp`。

### 选择设备

1. 点击 VS Code 右下角设备名称或 `No Device`。
2. 或按 `Ctrl+Shift+P`，执行 `Flutter: Select Device`。
3. 启动模拟器可执行 `Flutter: Launch Emulator`。
4. 在“运行和调试”中选择 Flutter 配置，按 `F5`。

可选配置：

- `Flutter · Android 模拟器`
- `Flutter · Android 真机（修改电脑 IP）`
- `Flutter · iOS 模拟器`
- `Flutter · 生产 HTTPS 接口调试`

如果看不到配置，执行：

```text
Ctrl+Shift+P → Developer: Reload Window
```

### Android 模拟器

```powershell
flutter emulators
flutter emulators --launch 模拟器ID
flutter devices

flutter run -d 设备ID `
  --dart-define=API_BASE_URL=http://10.0.2.2:9999/api
```

### Android 真机

手机开启开发者选项和 USB 调试：

```powershell
adb devices
flutter devices

flutter run -d 设备ID `
  --dart-define=API_BASE_URL=http://电脑局域网IP:9999/api
```

显示 `unauthorized` 时，在手机上确认 USB 调试授权。

### Android 无线调试

```powershell
adb pair 手机IP:配对端口
adb connect 手机IP:调试端口
flutter devices
```

### iOS 模拟器

仅限 macOS：

```bash
open -a Simulator
flutter devices
flutter run -d "iPhone 16 Pro" \
  --dart-define=API_BASE_URL=http://localhost:9999/api
```

iPhone 真机还需要在 Xcode 的 Runner → Signing & Capabilities 中选择 Team。

### Hot Reload

`flutter run` 和 VS Code `F5` 默认支持 Hot Reload：

- 保存 Dart 文件：自动 Hot Reload。
- 终端按 `r`：Hot Reload。
- 终端按 `R`：Hot Restart。
- VS Code 闪电按钮：Hot Reload。

修改 Manifest、Info.plist、原生插件或原生代码后，需要停止并重新运行。

## 3. 无正式签名打包

Android Debug APK 会自动使用 Debug Key 签名，可安装测试，但不能上架。

```powershell
flutter build apk --debug `
  --dart-define=API_BASE_URL=http://电脑局域网IP:9999/api
```

产物：

```text
build\app\outputs\flutter-apk\app-debug.apk
```

安装：

```powershell
adb install -r build\app\outputs\flutter-apk\app-debug.apk
```

iOS 无证书只能构建模拟器版本：

```bash
flutter build ios --simulator --debug \
  --dart-define=API_BASE_URL=http://localhost:9999/api
```

## 4. Android 正式签名与打包

### 首次生成密钥

```powershell
keytool -genkeypair -v `
  -keystore android/app/upload-keystore.jks `
  -storetype JKS -keyalg RSA -keysize 2048 `
  -validity 10000 -alias upload

Copy-Item android/key.properties.example android/key.properties
```

填写 `android/key.properties`：

```properties
storePassword=密钥库密码
keyPassword=密钥密码
keyAlias=upload
storeFile=app/upload-keystore.jks
```

JKS 和密码配置不能提交 Git，必须安全备份。

### Google Play AAB

```powershell
.\tool\build_android_release.ps1 `
  -ApiBaseUrl https://api.example.com/api `
  -Format aab `
  -BuildName 1.0.0 `
  -BuildNumber 1
```

产物：

```text
build\app\outputs\bundle\release\app-release.aab
```

### 正式 APK

```powershell
.\tool\build_android_release.ps1 `
  -ApiBaseUrl https://api.example.com/api `
  -Format apk `
  -BuildName 1.0.0 `
  -BuildNumber 1
```

产物：

```text
build\app\outputs\flutter-apk\app-release.apk
```

## 5. iOS 正式 IPA

仅限配置好 Apple Developer、Xcode Team 和签名的 macOS：

```bash
chmod +x tool/build_ios_release.sh
./tool/build_ios_release.sh https://api.example.com/api 1.0.0 1
```

产物：

```text
build/ios/ipa/*.ipa
```

先上传 TestFlight 验证，再提交 App Store 审核。

## 6. Shorebird 线上热更新

开发 Hot Reload 与线上 Patch 不同。线上热更新必须先发布 Shorebird 基础版本。

### 一次性初始化

```powershell
.\tool\init_shorebird.ps1
```

它会登录 Shorebird 并生成 `shorebird.yaml`。

### 第一个可热更新 Android 版本

```powershell
.\tool\shorebird_release.ps1 `
  -Action release -Platform android `
  -ApiBaseUrl https://api.example.com/api `
  -BuildName 1.0.0 -BuildNumber 1
```

将生成的正式包提交商店。用户安装这个基础版本后才能接收 Patch。

### 发布 Android Patch

```powershell
.\tool\shorebird_release.ps1 `
  -Action patch -Platform android `
  -ApiBaseUrl https://api.example.com/api
```

### iOS Release / Patch

```bash
./tool/shorebird_release.sh release ios https://api.example.com/api 1.0.0 1
./tool/shorebird_release.sh patch ios https://api.example.com/api
```

设备通常在一次启动时下载 Patch，完全关闭后再次启动应用生效。

以下变化不能只发 Patch，必须增加 BuildNumber、重新打包并上架：

- 原生插件、权限、Manifest、Info.plist。
- Gradle、Kotlin、Swift、Pod、Flutter 引擎。
- 签名、应用 ID、图标、启动图。

## 7. 上架与版本

版本格式：

```text
version: 1.0.0+1
```

- `1.0.0`：BuildName，用户看到的版本号。
- `1`：BuildNumber，每次重新上传商店必须递增。

上架前确认：

- 生产接口使用公网 HTTPS。
- Android/iOS 使用正式签名，密钥已备份。
- 真机验证登录、数据录入、AI、导出和错误状态。
- 隐私政策、权限说明、截图和商店资料完整。
- Google Play 上传 AAB；国内商店按要求上传 APK/AAB。
- iOS 先走 TestFlight，再提交 App Review。

## 8. 常见问题

### VS Code F5 调试 Markdown

确认打开的是仓库根目录，并执行 `Developer: Reload Window`，然后在运行面板选择 Flutter 配置。

### Manifest 合并或旧缓存错误

```powershell
flutter clean
flutter pub get
```

然后重新按 `F5`。

### 真机连接不到电脑后端

- 手机与电脑处于同一网络。
- 使用电脑局域网 IP，不使用 `localhost`。
- 后端监听 `0.0.0.0`。
- 防火墙允许后端端口。

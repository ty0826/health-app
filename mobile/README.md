# 健康管家移动端

Android 和 iOS 共用的 Flutter 客户端。业务代码、状态与 REST API 契约位于 `lib`，平台工程分别位于 `android` 和 `ios`。

## 本机 Flutter SDK

仓库内已下载 Flutter stable 到 `.tools/flutter`（该目录已被 Git 忽略）：

```powershell
..\.tools\flutter\bin\flutter.bat --version
..\.tools\flutter\bin\flutter.bat pub get
..\.tools\flutter\bin\flutter.bat run
```

## API 地址

默认地址：

- Android 模拟器：`http://10.0.2.2:9999/api`
- iOS 模拟器：`http://localhost:9999/api`

真机或生产环境通过编译参数覆盖：

```bash
flutter run --dart-define=API_BASE_URL=https://api.example.com/api
flutter build apk --dart-define=API_BASE_URL=https://api.example.com/api
flutter build ios --dart-define=API_BASE_URL=https://api.example.com/api
```

iOS 编译、签名和归档必须在安装了 Xcode 的 macOS 上执行。

## 正式发布与热更新

Android 正式签名、AAB/APK、iOS IPA、Google Play/App Store/国内安卓商店上架，以及 Shorebird 热更新流程见 [RELEASE.md](RELEASE.md)。

项目已提供：

- `tool/build_android_release.ps1`：生成正式签名 AAB 或 APK。
- `tool/build_ios_release.sh`：在 macOS 生成 App Store IPA。
- `tool/init_shorebird.ps1`：使用项目所有者账号完成一次性 Shorebird 绑定。
- `tool/shorebird_release.ps1` / `.sh`：创建 Shorebird Release 或 Patch。

Shorebird 的 `app_id` 必须通过账号登录执行 `shorebird init` 生成，不能提交虚假占位值。

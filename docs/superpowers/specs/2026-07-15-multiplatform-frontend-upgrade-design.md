# 多端前端升级设计

## 目标

将现有 Taro 前端迁移到 Vite 构建体系，并在共享业务源码的基础上支持微信小程序、H5、Android 和 iOS。

## 技术路线

- 所有 Taro 包统一升级到 4.2.0。
- 微信小程序和 H5 使用 `@tarojs/vite-runner` 与 Vite 4。
- Android/iOS 使用 `@tarojs/rn-runner`、React Native 0.73 和 Expo 50。
- Vite 不参与 React Native 构建；React Native 继续使用 Metro。
- 共享页面、状态管理、请求层和业务模型；仅在平台能力不一致时提供 `.rn.ts` 或 `.rn.tsx` 实现。

## 依赖兼容策略

现有 NutUI React Taro 只明确支持 H5 和小程序，无法作为 React Native 公共运行时依赖。本次移除根组件中的 `ConfigProvider`，并将登录页 NutUI `Button` 替换为 Taro `Button`。

现有 `echarts4taro3` 面向 Vue/Taro H5/小程序，且当前源码没有实际使用。本次移除该依赖，避免阻塞 React Native 安装。后续需要复杂图表时再分别选择 Web/小程序和 React Native 兼容实现。

## 构建配置

`config/index.ts` 切换为 Vite compiler，并保留现有小程序和 H5 CSS Modules、pxtransform、静态资源复制配置。

React Native 使用现有 `index.js` 和 `metro.config.js` 入口，补充 RN runner、Expo、React Native 及所需运行时依赖。输出目录按平台区分，避免微信小程序、H5 和 RN 构建互相覆盖。

## 平台脚本

提供以下命令：

- `dev:weapp`、`build:weapp`
- `dev:h5`、`build:h5`
- `dev:android`、`build:android`
- `dev:ios`、`build:ios`
- `typecheck`

Android/iOS 开发命令先由 Taro 生成 RN bundle/临时工程，再交由 Expo/原生工具运行。iOS 最终打包需要 macOS、Xcode 和 Apple Developer 账号；Windows 环境只验证依赖、配置、TypeScript 和可生成的 RN 构建产物。

## 应用配置

增加 Expo 应用配置，包含：

- 应用名：健康管家
- Android package：`com.healthmanager.app`
- iOS bundle identifier：`com.healthmanager.app`
- 版本：`1.0.0`
- 屏幕方向：portrait
- 基础图标、启动图和权限声明

本次不接入 Apple Health、Health Connect、推送通知、相机或定位权限。

## 网络配置

API 基础地址从编译环境变量读取。默认值仅服务本地 H5/开发者工具；Android 模拟器、真机和 iOS 必须通过环境变量配置可访问的局域网或 HTTPS 地址。

## 验证策略

- Node.js 20+ 下重新安装依赖。
- TypeScript 类型检查通过。
- 微信小程序生产构建通过。
- H5 生产构建通过。
- React Native bundle/config 检查通过。
- Windows 环境尽可能验证 Android；iOS 最终原生构建在 macOS 环境执行。

## 非目标

- 不为四端重新设计 UI。
- 不接入原生健康数据平台。
- 不保证所有第三方组件自动跨端，遇到差异使用平台文件隔离。
- 不在 Windows 环境生成或签名 IPA。


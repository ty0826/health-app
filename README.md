# 健康管家

基于 Spring Boot 的个人健康管理系统，分别提供 Taro 与 Flutter 客户端。

## 项目结构

```text
NewApp/
├── frontend/  # Taro：微信小程序、H5
├── mobile/    # Flutter：Android、iOS
├── backend/   # Spring Boot + MyBatis-Plus REST API
└── docs/      # 设计与部署文档
```

三个客户端共用 `backend` 的 `/api` 接口和 JWT 登录协议，彼此没有运行时依赖。

## 后端

后端需要 JDK 17、Maven 与 MySQL。数据库迁移由 Flyway 在启动时执行。

```bash
cd backend
mvn spring-boot:run
```

默认接口地址为 `http://localhost:9999/api`，OpenAPI JSON 位于 `http://localhost:9999/v3/api-docs`。

## Taro（H5 / 微信小程序）

```bash
cd frontend
corepack enable
pnpm install
pnpm test
pnpm build:all
```

详细说明见 `frontend/运行说明.md`。

## Flutter（Android / iOS）

```bash
cd mobile
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:9999/api
```

仓库内已下载的 Flutter stable SDK 位于被 Git 忽略的 `.tools/flutter`。iOS 工程与业务代码同样位于 `mobile`，最终编译和签名需要 macOS 与 Xcode。详细说明见 `mobile/README.md`。

## 生产环境变量

生产后端至少需要设置：`SPRING_PROFILES_ACTIVE=prod`、`DB_URL`、`DB_USERNAME`、`DB_PASSWORD`、`JWT_SECRET`、`AI_API_URL`、`AI_API_KEY` 与 `AI_MODEL`。不要提交真实密码、JWT 密钥或 AI API Key。

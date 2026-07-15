# 健康管家

[![CI](https://github.com/ty0826/health-app/actions/workflows/ci.yml/badge.svg)](https://github.com/ty0826/health-app/actions/workflows/ci.yml)

一个基于 Taro、React、Spring Boot 和 MySQL 的个人健康管理应用，包含每日健康记录、趋势统计、提醒设置、数据导出和 AI 健康助手等功能。

## 项目结构

```text
NewApp/
├── frontend/   # Taro + React + TypeScript 前端
├── backend/    # Spring Boot + MyBatis-Plus 后端
└── docs/       # 设计与实施文档
```

## 当前技术栈

- 前端：Taro 4、React 18、TypeScript、Zustand、SCSS
- 后端：Spring Boot 2.7、MyBatis-Plus、Flyway、MySQL、JWT、OpenAPI
- AI：OpenAI 兼容 Chat Completions API

## 后端运行

1. 创建空的 MySQL 数据库。应用启动时由 Flyway 自动执行 `backend/src/main/resources/db/migration` 中的迁移。
2. 本地开发默认使用 `local` profile；生产环境必须设置 `SPRING_PROFILES_ACTIVE=prod` 和以下环境变量：

```text
DB_URL
DB_USERNAME
DB_PASSWORD
JWT_SECRET
AI_API_URL
AI_API_KEY
AI_MODEL
```

3. 启动后端：

```bash
cd backend
mvn spring-boot:run
```

默认接口地址为 `http://localhost:9999/api`。

OpenAPI JSON 位于 `http://localhost:9999/v3/api-docs`，Swagger UI 位于 `http://localhost:9999/swagger-ui.html`。

## 前端运行

前端使用 Node.js 22、pnpm 11 和 Taro 4.2。微信小程序/H5 由 Vite 构建，Android/iOS 使用 Taro React Native + Expo。完整说明见 `frontend/运行说明.md`。

```bash
cd frontend
corepack enable
pnpm install
pnpm test
pnpm dev:weapp
```

完整容器化和部署流程见 `docs/deployment.md`。

## 安全说明

不要提交真实数据库密码、JWT 密钥或 AI API Key。生产环境配置不提供敏感默认值，缺少变量时应用应直接启动失败。登录和注册密码由前端通过 HTTPS 原样提交，仅后端使用 BCrypt 存储和校验。


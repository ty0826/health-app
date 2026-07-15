# 健康管家

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
- 后端：Spring Boot 2.7、MyBatis-Plus、MySQL、JWT
- AI：OpenAI 兼容 Chat Completions API

## 后端运行

1. 创建 MySQL 数据库并执行 `backend/src/main/resources/schema.sql`。
2. 根据需要设置环境变量：

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

## 前端运行

前端使用 Node.js 22、pnpm 11 和 Taro 4.2。微信小程序/H5 由 Vite 构建，Android/iOS 使用 Taro React Native + Expo。完整说明见 `frontend/运行说明.md`。

```bash
cd frontend
corepack enable
pnpm install
pnpm dev:weapp
```

## 安全说明

不要提交真实数据库密码、JWT 密钥或 AI API Key。生产环境必须通过环境变量提供这些配置。


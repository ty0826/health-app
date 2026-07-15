# 生产化加固补全设计

## 目标

补全此前稳定性改造中未真正闭环的安全、数据迁移、参数校验、异常处理、接口文档、自动化测试和部署流程，使项目能够在 Node.js 22 + pnpm、Spring Boot 2.7、MySQL 8 的组合下可靠开发、测试和部署。

## 当前差距

1. 前端仍使用固定盐 MD5 后再提交密码，后端 BCrypt 实际哈希的是 MD5 摘要，而不是用户原始密码。
2. `/health/record` 已统一，但前端状态接口仍保留无效的更新记录 ID 参数。
3. 敏感配置支持环境变量，但生产环境没有独立配置约束，JWT 仍存在默认密钥。
4. `schema.sql` 中的唯一索引只对新建表有效，既有数据库不会自动迁移。
5. 健康统计已忽略缺失值，但健康数据请求字段缺少范围校验。
6. 当前仅有 6 个 Service 单元测试，登录失败、数据隔离、请求校验、异常响应和 API 文档没有覆盖。
7. 没有统一异常处理、OpenAPI 文档、Docker Compose 和 GitHub Actions。
8. 后端接口说明仍保留固定盐 MD5 的过期描述。

## 总体方案

保持 Spring Boot 2.7、Java 8、Taro 4.2、React 18 和现有 API 主体结构，避免同时进行框架大版本升级。后端继续负责密码哈希、用户身份识别、数据隔离和业务校验；前端只提交用户输入的密码，并要求生产传输使用 HTTPS。

数据库结构改由 Flyway 管理。新数据库按 V1 初始化，既有数据库使用 baseline 版本 1 接入，然后执行 V2 去重和唯一索引迁移。部署采用 MySQL、Spring Boot API、H5/Nginx 三个容器；微信小程序与 Android/iOS 仍使用各自平台的发布流程。

## 密码与认证

- 删除前端 `encryptPassword`、固定盐和 `crypto-js` 依赖。
- 登录、注册请求直接提交用户输入的密码；生产环境必须通过 HTTPS。
- 后端使用 `BCryptPasswordEncoder` 编码和校验密码。
- 允许清空现有测试用户后重新注册，不兼容旧 MD5 或“BCrypt(MD5)”密码。
- 增加正确密码、错误密码、不存在用户、重复用户名和 BCrypt 存储格式测试。
- 清理后端接口说明中的 MD5 示例，改为服务端 BCrypt 流程。

## 数据库迁移与唯一约束

- 引入 Flyway，并将完整初始结构放入 `V1__initial_schema.sql`。
- V1 保留普通 `(user_id, record_date)` 索引，确保 V2 对新旧数据库执行相同的升级路径。
- V2 对相同用户和日期的历史记录只保留 ID 最大的一条，然后删除普通索引并建立 `uk_user_date` 唯一索引。
- 配置 `baseline-on-migrate=true`、baseline 版本 1，使已有结构但没有 Flyway 历史表的数据库从 V2 开始迁移。
- MySQL 数据库本身由部署环境创建，Flyway 只管理表结构，不在迁移脚本中执行 `CREATE DATABASE` 或 `USE`。
- `HealthDataService` 保留按用户和日期更新或新增的业务语义，数据库唯一约束提供并发兜底。

## 参数校验与错误响应

`HealthDataRequest` 增加以下边界：

- 日期必须是 `yyyy-MM-dd`，缺省时使用当天。
- 步数：0–200000。
- 心率：20–250。
- 睡眠时长：0–24 小时。
- 体重：1–500 kg。
- 收缩压：40–300 mmHg。
- 舒张压：30–200 mmHg。
- 血糖：0.1–50 mmol/L。
- 热量：0–20000 kcal。
- 饮水量：0–20000 ml。
- 心情：1–5。
- 备注：最多 500 字符。

Controller 使用 `@Valid`，分页、统计天数和导出格式继续在 Service 层校验。日期解析错误、字段校验错误和非法查询参数均返回统一的 400 业务响应。

新增异常体系：

- `BusinessException` 表示可预期业务错误，并携带业务码。
- `GlobalExceptionHandler` 统一处理业务异常、Bean Validation、参数类型错误、非法参数和未知异常。
- 用户不存在或密码错误统一返回认证失败，避免通过错误信息枚举用户名。
- 重复用户名返回 409，资源不存在返回 404，未认证返回 401，未知异常返回 500。
- Controller 不再自行 `try/catch RuntimeException`。

## 接口一致性与 OpenAPI

- 前端删除 `updateRecord(id, data)` 中无效的 ID，统一暴露 `saveRecord(data)` 或等价的单一写入方法。
- 后端继续使用 `POST /api/health/record` 实现每日记录新增或更新。
- 引入与 Spring Boot 2.7 兼容的 springdoc-openapi 1.x。
- 提供 `/v3/api-docs` 和 `/swagger-ui.html`。
- OpenAPI 配置声明 Bearer JWT 安全方案，并为登录、注册和系统公开接口保留匿名访问。
- JWT 拦截器排除 Swagger/OpenAPI 静态资源和文档端点。

## 测试设计

测试分为四层：

1. `UserServiceTest`：BCrypt 存储、成功登录、错误密码、用户不存在、重复用户名。
2. `HealthDataServiceTest`：缺失值平均数、无值结果、统计天数、分页、导出格式、每日新增与更新时始终携带当前用户 ID。
3. Controller/异常测试：请求字段边界、错误 JSON 结构、业务异常状态码、Controller 从请求属性取得当前用户 ID。
4. MyBatis 数据隔离测试：使用测试数据库插入两个用户的数据，验证列表、日期范围和单日查询不会返回其他用户记录。

前端使用 Vitest 测试登录和注册请求不再执行 MD5，并继续执行 TypeScript 检查和微信、H5、RN 三端构建。

所有 Java 测试通过 `mvn test` 执行；所有前端测试和构建通过 pnpm 执行，不引入 npm 或 yarn 命令。

## 环境配置

- `application.yml` 保存通用非敏感配置。
- `application-local.yml` 提供本地数据库地址和明确标注的开发默认值。
- `application-prod.yml` 只读取 `DB_URL`、`DB_USERNAME`、`DB_PASSWORD`、`JWT_SECRET`、`JWT_EXPIRATION`、`AI_API_URL`、`AI_API_KEY`、`AI_MODEL`，敏感值不提供默认值。
- 根目录 `.env.example` 记录 Docker Compose 所需变量，不包含真实凭据。
- 前端继续使用 `TARO_APP_API_BASE_URL` 和 `EXPO_PUBLIC_API_BASE_URL`。
- 部署文档明确生产 JWT 密钥长度、HTTPS、数据库备份和 Flyway 迁移前检查。

## 容器化与部署

- 后端 Dockerfile 使用 Maven 多阶段构建，运行阶段只包含 JRE 和应用 JAR。
- H5 Dockerfile 使用 Node.js 22 + Corepack + pnpm 构建，再由 Nginx 提供静态文件和 SPA fallback。
- `docker-compose.yml` 编排 MySQL 8、后端和 H5，包含健康检查、依赖顺序、持久化卷和环境变量。
- Compose 不容器化微信小程序、Android 或 iOS 构建；这些目标继续按前端运行说明执行。
- GitHub Actions 在 push 和 pull request 时执行后端测试、前端冻结锁文件安装、Vitest、TypeScript 检查以及微信/H5/RN 构建。
- 部署文档覆盖首次部署、数据库备份、迁移、升级、健康检查和回滚步骤。

## 验收标准

- 仓库业务代码和运行文档中不存在固定盐 MD5 密码流程。
- 新注册用户的数据库密码是直接基于用户输入生成的 BCrypt 哈希。
- 既有数据库能够通过 Flyway V2 获得 `(user_id, record_date)` 唯一约束。
- 非法健康数据、非法分页和非法统计参数返回结构一致的 400 响应。
- Swagger UI 可访问并显示 JWT Bearer 认证方式。
- 自动化测试覆盖登录、健康记录、数据隔离、统计计算和异常处理。
- `mvn test`、`pnpm test`、`pnpm typecheck`、微信/H5/RN 构建全部成功。
- Docker Compose 能启动 MySQL、API 和 H5，API 与 H5 健康检查通过。
- GitHub Actions 只使用 Node.js 22 和 pnpm。

## 本轮不包含

- Spring Boot 3 或 Java 21 升级。
- 旧 MD5 密码在线兼容迁移。
- Kubernetes、云厂商专属资源或自动生产发布。
- 在 Windows 本地生成 iOS 安装包。
- 修改现有页面视觉设计。

# 部署说明

## 组成

Docker Compose 运行三个服务：

- MySQL 8：持久化业务数据。
- backend：Spring Boot API，启动时自动执行 Flyway 数据库迁移。
- h5：Node.js 22 + pnpm 构建后由非 root Nginx 提供静态文件，并将 `/api/` 代理到 backend。

微信小程序、Android 和 iOS 不在 Compose 中构建，仍按 `frontend/运行说明.md` 使用对应平台工具发布。

## 首次部署

1. 安装 Docker Engine 和 Docker Compose v2。
2. 复制 `.env.example` 为 `.env`。
3. 替换数据库密码、Root 密码、JWT 密钥和 AI API Key。JWT 密钥至少使用 32 字节随机值。
4. 构建并启动：

```bash
docker compose config
docker compose build
docker compose up -d
docker compose ps
```

5. 验证：

```bash
curl http://localhost:9999/api/system/app-info
curl http://localhost:9999/v3/api-docs
curl http://localhost:8080/healthz
```

生产环境应在 Compose 前部署 TLS 反向代理，禁止通过明文 HTTP 传输登录或注册密码。

## 数据库迁移

Flyway 在 backend 启动时执行 `backend/src/main/resources/db/migration`。

- 新数据库执行 V1 初始化和后续迁移。
- 已有数据库没有 Flyway 历史表时，以版本 1 baseline，然后执行 V2。
- V2 会先删除同一用户同一天的旧重复记录，只保留 ID 最大的记录，再增加唯一约束。

升级前必须备份：

```bash
docker compose exec -T mysql sh -c 'exec mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE"' > health_manager_backup.sql
```

## 更新发布

```bash
git pull --ff-only
docker compose build
docker compose up -d
docker compose ps
docker compose logs --tail=200 backend
```

发布后检查登录、健康记录写入、统计接口、Swagger 和 H5 页面。

## 回滚

应用回滚使用上一提交或上一镜像重新构建：

```bash
git checkout <previous-commit>
docker compose build backend h5
docker compose up -d backend h5
```

数据库迁移默认只前进。若迁移造成不可接受的问题，应停止 backend、恢复发布前备份，再启动旧版本。不要在没有备份的情况下手工修改 `flyway_schema_history`。

## 日志与维护

```bash
docker compose logs -f backend
docker compose logs -f mysql
docker compose restart backend
docker compose down
```

普通停止不要使用 `docker compose down -v`，该命令会删除 MySQL 持久化卷。

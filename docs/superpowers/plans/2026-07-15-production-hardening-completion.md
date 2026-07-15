# Production Hardening Completion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete the authentication, database migration, validation, exception handling, OpenAPI, testing, containerization, and CI work defined in the production hardening design.

**Architecture:** Keep Spring Boot 2.7/Java 8 and Taro 4.2. Passwords are sent unchanged over HTTPS and hashed only by the backend; Flyway owns schema evolution; controllers delegate errors to one global handler; Docker Compose runs MySQL, API, and H5 while GitHub Actions verifies every supported build with Node.js 22 and pnpm.

**Tech Stack:** Java 8, Spring Boot 2.7.18, MyBatis-Plus, Flyway, MySQL 8, springdoc-openapi 1.x, JUnit 5, Mockito, H2, Node.js 22, pnpm 11.13.0, Vitest, Taro 4.2, Docker Compose, GitHub Actions

---

### Task 1: Remove client-side MD5 and test raw password requests

**Files:**
- Modify: `frontend/package.json`
- Modify: `frontend/src/store/userStore.ts`
- Delete: `frontend/src/utils/encrypt.ts`
- Create: `frontend/src/store/userStore.test.ts`

- [ ] Add Vitest and a `test` script, then write tests mocking `../utils/request` and asserting login/register send the original password.
- [ ] Run `pnpm test -- userStore.test.ts` and confirm it fails because the request contains the fixed-salt MD5 digest.
- [ ] Remove `encryptPassword` calls, delete `crypto-js` and its type package, and delete `encrypt.ts`.
- [ ] Run `pnpm test`, `pnpm typecheck`, and `pnpm install --lockfile-only` until they pass with a pnpm-only lockfile.
- [ ] Commit with `fix: hash passwords only on the server`.

Expected request assertion:

```ts
expect(post).toHaveBeenCalledWith('/user/login', {
  username: 'alice',
  password: 'StrongPassword123',
})
```

### Task 2: Introduce typed business errors and complete authentication tests

**Files:**
- Create: `backend/src/main/java/com/health/exception/BusinessException.java`
- Modify: `backend/src/main/java/com/health/service/UserService.java`
- Modify: `backend/src/test/java/com/health/service/UserServiceTest.java`

- [ ] Add failing tests for wrong password, unknown user, and duplicate username.
- [ ] Run `mvn -Dtest=UserServiceTest test` and confirm the new tests fail because `RuntimeException` and distinguishable login messages are still used.
- [ ] Implement `BusinessException(int code, String message)` and change both unknown-user and wrong-password login failures to code 401 with message `用户名或密码错误`.
- [ ] Return code 409 for duplicate usernames and keep BCrypt encoding/matching unchanged.
- [ ] Run `mvn -Dtest=UserServiceTest test` and confirm all authentication tests pass.
- [ ] Commit with `refactor: standardize authentication errors`.

### Task 3: Add request validation and global exception handling

**Files:**
- Modify: `backend/src/main/java/com/health/dto/HealthDataRequest.java`
- Modify: `backend/src/main/java/com/health/controller/HealthDataController.java`
- Modify: `backend/src/main/java/com/health/controller/UserController.java`
- Create: `backend/src/main/java/com/health/exception/GlobalExceptionHandler.java`
- Create: `backend/src/test/java/com/health/controller/GlobalExceptionHandlerTest.java`
- Create: `backend/src/test/java/com/health/controller/HealthDataControllerTest.java`

- [ ] Write failing MockMvc tests for out-of-range health data, malformed dates, business exceptions, and unexpected exceptions.
- [ ] Run the two controller test classes and verify 400/401/409/500 expectations fail before the handler exists.
- [ ] Add Bean Validation constraints matching the approved design and apply `@Valid` to the record endpoint.
- [ ] Implement one `@RestControllerAdvice` returning `Result.error(code, message)` for validation, `BusinessException`, illegal arguments, and unknown failures.
- [ ] Remove local login/register `try/catch` blocks from `UserController`.
- [ ] Run controller tests and the full Maven test suite.
- [ ] Commit with `feat: validate health requests and handle errors globally`.

Validation example:

```java
@Min(value = 20, message = "心率不能低于 20")
@Max(value = 250, message = "心率不能高于 250")
private Integer heartRate;
```

### Task 4: Make database evolution executable with Flyway

**Files:**
- Modify: `backend/pom.xml`
- Delete: `backend/src/main/resources/schema.sql`
- Create: `backend/src/main/resources/db/migration/V1__initial_schema.sql`
- Create: `backend/src/main/resources/db/migration/V2__health_data_unique_user_date.sql`
- Modify: `backend/src/main/resources/application.yml`
- Create: `backend/src/test/resources/application-test.yml`
- Create: `backend/src/test/resources/schema-test.sql`
- Create: `backend/src/test/java/com/health/mapper/HealthDataMapperIsolationTest.java`

- [ ] Add H2 test dependency and write a failing mapper integration test inserting data for two users and asserting user-scoped queries return only one user's rows.
- [ ] Run the mapper test and confirm it fails before test database configuration exists.
- [ ] Add Flyway, move the initial schema into V1, and create V2 that retains the highest ID duplicate before replacing `idx_user_date` with `uk_user_date`.
- [ ] Configure Flyway baseline version 1 and disable Flyway only for the H2 mapper test profile using `schema-test.sql`.
- [ ] Run mapper tests and all Maven tests.
- [ ] Commit with `feat: manage schema changes with flyway`.

Migration core:

```sql
DELETE old_row
FROM health_data old_row
JOIN health_data newest
  ON newest.user_id = old_row.user_id
 AND newest.record_date = old_row.record_date
 AND newest.id > old_row.id;

ALTER TABLE health_data DROP INDEX idx_user_date;
ALTER TABLE health_data ADD UNIQUE KEY uk_user_date (user_id, record_date);
```

### Task 5: Expand health record and statistics coverage

**Files:**
- Modify: `backend/src/test/java/com/health/service/HealthDataServiceTest.java`
- Modify: `frontend/src/store/healthStore.ts`

- [ ] Add failing tests proving add/update operations always use the authenticated user ID and the newest value is selected for each date.
- [ ] Run `mvn -Dtest=HealthDataServiceTest test` and confirm the new behavioral assertions fail where coverage is missing.
- [ ] Make only the minimal service changes required by those tests.
- [ ] Replace frontend `addRecord`/`updateRecord(id, data)` with a single `saveRecord(data)` method and update its page caller.
- [ ] Run Maven tests, frontend tests, and typecheck.
- [ ] Commit with `test: cover health data isolation and upserts`.

### Task 6: Publish OpenAPI documentation with JWT security

**Files:**
- Modify: `backend/pom.xml`
- Create: `backend/src/main/java/com/health/config/OpenApiConfig.java`
- Modify: `backend/src/main/java/com/health/config/JwtConfig.java`
- Create: `backend/src/test/java/com/health/config/OpenApiConfigTest.java`

- [ ] Add a failing test that inspects the generated `OpenAPI` bean for title, version, and `bearerAuth` HTTP bearer scheme.
- [ ] Run the test and confirm it fails because no OpenAPI bean exists.
- [ ] Add `springdoc-openapi-ui` 1.7.0 and create the documented bean.
- [ ] Exclude `/v3/api-docs/**`, `/swagger-ui/**`, and `/swagger-ui.html` from JWT interception.
- [ ] Run OpenAPI and full backend tests.
- [ ] Commit with `feat: add authenticated openapi documentation`.

### Task 7: Separate local and production environment configuration

**Files:**
- Modify: `backend/src/main/resources/application.yml`
- Create: `backend/src/main/resources/application-local.yml`
- Create: `backend/src/main/resources/application-prod.yml`
- Create: `.env.example`
- Modify: `README.md`
- Modify: `backend/接口调用流程说明.md`
- Modify: `frontend/运行说明.md`

- [ ] Move local defaults into the local profile and leave production secrets without defaults.
- [ ] Document required database, JWT, AI, frontend, and Compose variables.
- [ ] Remove fixed-salt MD5 instructions and describe raw-over-HTTPS plus server-side BCrypt.
- [ ] Run repository scans confirming no business-code MD5 salt or real secret remains.
- [ ] Commit with `docs: harden environment and authentication guidance`.

### Task 8: Add production-oriented containers and Compose

**Files:**
- Create: `backend/Dockerfile`
- Create: `backend/.dockerignore`
- Create: `frontend/Dockerfile`
- Create: `frontend/.dockerignore`
- Create: `frontend/nginx.conf`
- Create: `docker-compose.yml`
- Create: `docs/deployment.md`

- [ ] Create multi-stage images pinned to Maven/Temurin Java 8 and Node.js 22, with non-root runtime users and health checks.
- [ ] Configure Nginx SPA fallback and `/api/` proxy to the backend service.
- [ ] Compose MySQL 8, backend, and H5 with named volumes, environment variables, health checks, and conditional dependencies.
- [ ] Validate using `docker compose config` and, when Docker is available, `docker compose build` followed by service health checks.
- [ ] Document backup, migration, deployment, upgrade, rollback, and platform-specific mobile release steps.
- [ ] Commit with `feat: add containerized deployment stack`.

### Task 9: Add pnpm-only continuous integration and final verification

**Files:**
- Create: `.github/workflows/ci.yml`
- Modify: `README.md`

- [ ] Add backend and frontend CI jobs for Java 8, Node.js 22, pnpm 11.13.0, frozen install, tests, typecheck, and WeChat/H5/RN builds.
- [ ] Ensure no workflow uses npm, npx, or yarn.
- [ ] Run `mvn test`, `pnpm test`, `pnpm typecheck`, `pnpm build:weapp`, `pnpm build:h5`, `pnpm build:rn`, `pnpm exec expo config --type public`, and `pnpm exec expo install --check`.
- [ ] Run `git diff --check`, inspect ignored build output, and verify the worktree is clean after committing.
- [ ] Push `codex/core-stability-multiplatform` without merging to `main`.


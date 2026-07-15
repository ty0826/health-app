# Core Stability Update Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Improve authentication security, configuration safety, health statistics correctness, API consistency, and regression coverage.

**Architecture:** Preserve the existing Spring Boot/Taro structure. Replace MD5 with BCrypt, validate service inputs, enforce one health record per user/date, and keep the existing daily upsert endpoint as the single frontend write API.

**Tech Stack:** Java 8, Spring Boot 2.7, MyBatis-Plus, JUnit 5, Mockito, Taro, TypeScript

---

### Task 1: BCrypt authentication

**Files:**
- Modify: `backend/pom.xml`
- Test: `backend/src/test/java/com/health/service/UserServiceTest.java`
- Modify: `backend/src/main/java/com/health/service/UserService.java`

- [ ] Write tests asserting registration stores a BCrypt hash and login uses BCrypt matching.
- [ ] Run `mvn -Dtest=UserServiceTest test` and confirm failure because MD5 is still used.
- [ ] Add `spring-security-crypto`, inject a `BCryptPasswordEncoder`, and replace MD5 hashing/matching.
- [ ] Re-run the focused test and confirm it passes.

### Task 2: Health calculation and input validation

**Files:**
- Test: `backend/src/test/java/com/health/service/HealthDataServiceTest.java`
- Modify: `backend/src/main/java/com/health/service/HealthDataService.java`

- [ ] Write tests proving missing values do not dilute averages and invalid page, size, days, and format values are rejected.
- [ ] Run `mvn -Dtest=HealthDataServiceTest test` and confirm the expected failures.
- [ ] Add focused validation helpers and metric-specific average calculations.
- [ ] Re-run the focused test and confirm it passes.

### Task 3: Configuration and database constraints

**Files:**
- Modify: `backend/src/main/resources/application.yml`
- Modify: `backend/src/main/resources/schema.sql`

- [ ] Replace fixed credentials and secrets with environment-variable placeholders and safe development defaults.
- [ ] Replace `idx_user_date` with unique key `uk_user_date`.
- [ ] Verify configuration resource processing with `mvn test`.

### Task 4: Frontend API consistency

**Files:**
- Modify: `frontend/src/store/healthStore.ts`
- Modify: `frontend/src/utils/request.ts`

- [ ] Remove the unsupported `/health/record/{id}` request and route updates through `/health/record`.
- [ ] Read the API base URL from the Taro build environment with a local fallback.
- [ ] Confirm no unsupported endpoint remains with `rg '/health/record/\$\{id\}' frontend/src`.

### Task 5: Full backend verification

**Files:** none

- [ ] Run `mvn test` and confirm all new tests execute and pass.
- [ ] Inspect the schema and configuration for the unique key and environment placeholders.


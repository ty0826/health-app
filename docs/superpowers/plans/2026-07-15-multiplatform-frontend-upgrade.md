# Multiplatform Frontend Upgrade Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the shared Taro application for WeChat Mini Program and H5 with Vite, and prepare Android/iOS builds with Taro React Native and Expo.

**Architecture:** Use Taro Vite runner for web/mini-program targets and Taro RN runner with Metro for native targets. Keep shared application code and remove third-party runtime dependencies that do not support React Native.

**Tech Stack:** Node.js 22, pnpm 11, Taro 4.2, Vite 4, React 18, React Native 0.73, Expo 50, Metro

---

### Task 1: Align dependencies and scripts

**Files:**
- Modify: `frontend/package.json`
- Create: `frontend/pnpm-lock.yaml`

- [x] Align all Taro packages at 4.2.0 and add Vite/RN/Expo dependencies.
- [x] Remove webpack runner, NutUI, and the unused incompatible ECharts package.
- [x] Add Node 22 engine requirement, pnpm package manager metadata, and per-platform scripts.
- [x] Reinstall dependencies with Node 22 + pnpm and confirm the lockfile resolves one Taro version.

### Task 2: Switch web and mini-program builds to Vite

**Files:**
- Modify: `frontend/config/index.ts`

- [x] Change the compiler to Vite and remove webpack-specific hooks.
- [x] Preserve CSS Modules, pxtransform, static resources, and H5 public path settings.
- [x] Run WeChat and H5 production builds and fix only migration-related incompatibilities.

### Task 3: Make shared application code RN-compatible

**Files:**
- Modify: `frontend/src/app.tsx`
- Modify: `frontend/src/subpackages/login/pages/login/index.tsx`
- Modify platform-specific files only where build errors require them.

- [x] Remove NutUI `ConfigProvider`.
- [x] Replace NutUI login `Button` with `@tarojs/components` Button.
- [x] Run TypeScript and RN bundle checks, adding `.rn.tsx` adapters only for confirmed incompatibilities.

### Task 4: Add native application configuration

**Files:**
- Modify: `frontend/metro.config.js`
- Modify: `frontend/index.js`
- Create: `frontend/app.json`
- Create: `frontend/eas.json`

- [x] Configure Expo application name, slug, Android package, iOS bundle identifier, version, orientation, and build profiles.
- [x] Keep Metro integrated with `@tarojs/rn-supporter`.
- [x] Add development, preview, and production EAS profiles without credentials in source control.

### Task 5: Documentation and verification

**Files:**
- Modify: `frontend/运行说明.md`

- [x] Document Node 22, pnpm, four platform commands, API URL setup, Android prerequisites, and macOS/iOS requirements.
- [x] Run typecheck, WeChat build, H5 build, and RN configuration/bundle checks.
- [x] Record any verification that cannot run on Windows as a platform prerequisite rather than reporting it as passed.


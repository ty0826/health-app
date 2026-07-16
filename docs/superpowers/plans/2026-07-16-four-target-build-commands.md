# Four-Target Build Commands Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Provide unambiguous build commands for H5, WeChat Mini Program, Android, and iOS without duplicate RN bundling or overwritten local outputs.

**Architecture:** Resolve the Taro output directory through a small pure function, keep RN bundling as an internal verification command, and delegate final Android/iOS packaging directly to EAS. Package-script contract tests protect the public command surface.

**Tech Stack:** Node.js 22, pnpm 11, TypeScript, Vitest, Taro 4.2, Vite 4, React Native 0.73, Expo 50, EAS CLI

---

### Task 1: Test platform output isolation

**Files:**
- Create: `frontend/config/output-root.test.ts`
- Create: `frontend/config/output-root.ts`
- Modify: `frontend/config/index.ts`

- [ ] **Step 1: Write the failing output mapping test**

```ts
import { describe, expect, it } from 'vitest'
import { resolveOutputRoot } from './output-root'

describe('resolveOutputRoot', () => {
  it.each([
    ['h5', 'dist/h5'],
    ['weapp', 'dist/weapp'],
    ['rn', 'dist/rn'],
    [undefined, 'dist'],
  ])('maps %s to %s', (target, expected) => {
    expect(resolveOutputRoot(target)).toBe(expected)
  })
})
```

- [ ] **Step 2: Run the test and confirm it fails because `output-root.ts` does not exist**

Run: `pnpm test -- config/output-root.test.ts`

- [ ] **Step 3: Implement `resolveOutputRoot` and use it in Taro config**

```ts
const targetOutputRoots: Record<string, string> = {
  h5: 'dist/h5',
  weapp: 'dist/weapp',
  rn: 'dist/rn',
}

export const resolveOutputRoot = (target?: string): string =>
  (target && targetOutputRoots[target]) || 'dist'
```

- [ ] **Step 4: Run the test and confirm it passes**

Run: `pnpm test -- config/output-root.test.ts`

### Task 2: Test and simplify the public build scripts

**Files:**
- Create: `frontend/scripts/build-scripts.test.ts`
- Modify: `frontend/package.json`
- Modify: `frontend/scripts/build-rn.mjs`

- [ ] **Step 1: Write a failing package-script contract test**

The test reads `package.json` and asserts that Android/iOS call EAS directly, `build:apps` uses `--platform all`, `build:all` calls the two local builds plus `build:apps`, and the old public `build:rn` name is replaced with `verify:rn`.

- [ ] **Step 2: Run the test and confirm the existing scripts fail the new contract**

Run: `pnpm test -- scripts/build-scripts.test.ts`

- [ ] **Step 3: Apply the minimal script changes**

```json
{
  "verify:rn": "node scripts/build-rn.mjs",
  "build:android": "eas build --platform android --profile production",
  "build:ios": "eas build --platform ios --profile production",
  "build:apps": "eas build --platform all --profile production",
  "build:all": "pnpm run build:weapp && pnpm run build:h5 && pnpm run build:apps"
}
```

Update `build-rn.mjs` to validate `dist/rn/index.bundle`.

- [ ] **Step 4: Run the contract test and all unit tests**

Run: `pnpm test`

### Task 3: Update documentation and verify deliverables

**Files:**
- Modify: `frontend/运行说明.md`

- [ ] **Step 1: Document only the four deliverables and the optional RN verification command**
- [ ] **Step 2: Run `pnpm typecheck`**
- [ ] **Step 3: Run `pnpm build:weapp` and verify `dist/weapp/app.json` exists**
- [ ] **Step 4: Run `pnpm build:h5` and verify `dist/h5/index.html` exists without removing the WeChat output**
- [ ] **Step 5: Run `pnpm verify:rn` and verify `dist/rn/index.bundle` exists**
- [ ] **Step 6: Run `pnpm exec eas config` to validate Expo/EAS configuration without starting a signed cloud build**

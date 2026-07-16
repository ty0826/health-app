# Four-Target Build Commands Design

## Goal

Expose only the four deliverables the project needs: H5, WeChat Mini Program, Android App, and iOS App. Remove the misleading public React Native bundle build and prevent local web/mini-program artifacts from overwriting each other.

## Command model

- `pnpm build:h5` builds H5 into `frontend/dist/h5`.
- `pnpm build:weapp` builds the WeChat Mini Program into `frontend/dist/weapp`.
- `pnpm build:android` triggers an EAS production Android build.
- `pnpm build:ios` triggers an EAS production iOS build.
- `pnpm build:apps` triggers Android and iOS together through one EAS build.
- `pnpm build:all` builds H5 and WeChat locally, then triggers both native builds.
- `pnpm verify:rn` remains available only as a React Native/Metro compilation check and writes to `frontend/dist/rn`.

Android and iOS commands must not call `verify:rn` first. EAS performs the native release bundle step, so pre-bundling locally would duplicate work and the generated local bundle is not the final APK/AAB/IPA.

## Platform constraints

H5 and WeChat builds are fully local. Android and iOS use EAS production builders so the same commands work from Windows. A true local iOS IPA build is not possible on Windows because it requires macOS and Xcode.

## Output isolation

Taro selects the output directory from `TARO_ENV`:

- `h5` -> `dist/h5`
- `weapp` -> `dist/weapp`
- `rn` -> `dist/rn`
- unknown/no target -> `dist`

## Verification

Automated tests assert the output-directory mapping and package script contract. Verification also runs TypeScript, Vitest, H5 build, WeChat build, and the RN compilation check. EAS native builds are configuration-checked locally but require EAS authentication and signing credentials to produce store artifacts.

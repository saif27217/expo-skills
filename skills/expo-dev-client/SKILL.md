---
name: expo-dev-client
description: "Build and install Expo development builds (expo-dev-client) when you outgrow Expo Go: EAS config, distribution, and local/cloud build flows."
risk: medium
source: https://github.com/sickn33/antigravity-awesome-skills/blob/main/skills/expo-dev-client/SKILL.md
source_type: upstream-mirror
verification: "Verified against docs.expo.dev 2026-11 (Expo SDK 58, development-builds reference)."
license: MIT
---

# Expo Development Builds (expo-dev-client)

## When to Use

Use when you've outgrown **Expo Go** — you need a native development build because you're
using native modules, Apple targets, config plugins, remote push notifications, or
App/Universal Links. Expo Go only runs a limited subset of the SDK and cannot use custom
native code or config plugins.

> **Verification note (2026-11):** this skill was checked against current Expo docs. The
> workflow and config below are accurate. Only the upstream `cli.version: ">= 16.0.1"`
> floor was bumped to the current CLI (27.5.0) — no functional changes needed.

## Prerequisite

```bash
npx expo install expo-dev-client
npx expo start   # Metro dev server
```

## EAS Configuration

Ensure `eas.json` has a `development` build profile:

```json
{
  "cli": {
    "version": ">= 27.5.0",
    "appVersionSource": "remote"
  },
  "build": {
    "production": {
      "autoIncrement": true
    },
    "development": {
      "autoIncrement": true,
      "developmentClient": true,
      "distribution": "internal"
    }
  },
  "submit": {
    "production": {},
    "development": {}
  }
}
```

Key settings:
- `developmentClient: true` — bundles expo-dev-client into the build
- `autoIncrement: true` — auto-increments build numbers
- `appVersionSource: "remote"` — EAS is the source of truth for version numbers

## Distribution choices

Development builds install via **internal/ad hoc** distribution (physical iOS devices must
be registered). Options:

- **Simulator**: add `"ios": { "simulator": true }` to a dedicated development profile.
  A signed device `.ipa` is NOT a simulator `.app` archive — match profile/target/output.
- **Physical device**: use the default dev profile (ad hoc / internal distribution).
- **TestFlight**: DO NOT submit a development-client profile as a routine step. Use a
  separate store-distribution build/profile and follow current App Store Connect docs.
  Submissions publish an external artifact and require the user's authorization.

## Building

Pick ONE method:

### 1. Local (no Expo cloud) — needs Xcode / Android Studio
```bash
npx expo run:ios --device      # or: npx expo run:ios (simulator)
npx expo run:android
```
Rebuild the native app only after adding native-code libs, changing app config, or
upgrading the SDK: `npx expo prebuild --clean`, then build again.

### 2. Cloud build (EAS) — no native toolchain needed
```bash
eas build --platform ios --profile development
eas build --platform android --profile development
```

### 3. Local build with EAS CLI
```bash
eas build --platform ios --profile development --local
```

After install, start Metro with `npx expo start`. Launch the app from the launcher or
`npx expo run` on device; it connects to the dev server.

## Installing the build

- **iOS simulator**: `xcrun simctl install booted path/to/app.app` then open it
- **Android emulator/device**: `adb install path/to/app.apk`
- Physical iOS: OpenSimulator/companion or ad hoc install via a provisioning device list

## Notes / pitfalls

- Cloud builds may consume quota and require signing credentials
- `eas credentials` manages Apple signing / Google service credentials
- Verify the exact build profile, target platform, and output artifact before installing
- Verify every stage by real execution (build completes, app launches, connects to Metro)

## Limitations

- Only use when the task matches this product's scope
- Verify current docs, pricing, quotas, and device-registration rules before acting
- Generated examples are not a substitute for environment tests / user approval for
  costly or signing-sensitive actions
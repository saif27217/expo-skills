---
name: expo-deployment
description: "Deploy Expo apps with EAS: build and submit iOS and Android releases, configure build and submit profiles, manage versions, deploy web bundles or API routes via EAS Hosting."
risk: critical
source: https://github.com/sickn33/antigravity-awesome-skills/blob/main/skills/expo-deployment/SKILL.md
source_type: upstream-mirror
verification: "Verified against docs.expo.dev 2026-11 (EAS CLI 27.5.0, Expo SDK 58)."
license: MIT
---

# Deployment (EAS)

## When to Use

Use when you need to deploy Expo apps to production with EAS — build and submit to the
iOS App Store, Google Play, and TestFlight; configure `eas.json` build/submit profiles;
manage app versions; and deploy web bundles/API routes via EAS Hosting.

> **Verification note (2026-11):** this skill was corrected against current Expo docs.
> The key fix: `resourceClass` uses **`default`, `medium`, or `large`** — NOT the stale
> `m-medium` value found in the upstream mirror. Current EAS CLI is **27.5.0**.

## References

- `references/workflows.md` — CI/CD workflows, PR previews
- `references/testflight.md` — iOS TestFlight beta submissions
- `references/app-store-metadata.md` — App Store metadata / ASO
- `references/play-store.md` — Google Play submissions
- `references/ios-app-store.md` — iOS App Store submission

Before cloud builds / submissions / deployments, confirm project, account, artifact,
track/channel and cost. Pinning a reviewed CLI version is recommended for automation.

## Quick Start

```bash
npm install -g eas-cli
eas login        # or: EXPO_TOKEN=... for CI
eas init         # links/creates the EAS project
eas build:configure   # generates eas.json build profiles
```

## Build Commands

```bash
# iOS App Store build
eas build -p ios --profile production

# Android Play Store build
eas build -p android --profile production

# Both platforms
eas build --profile production
```

## Submit to Stores

```bash
# Build + submit to App Store Connect
eas build -p ios --profile production --auto-submit

# Build + submit to Play Store
eas build -p android --profile production --auto-submit
```

`--auto-submit` runs the submit step against the store config in the `submit` profile.

## Web Deployment (EAS Hosting)

```bash
npx expo export -p web
eas deploy            # preview / PR-preview URL
eas deploy --prod     # promote to production
```

`eas deploy` ships the web bundle AND Expo Router API routes together on Expo Hosting.
For authoring API routes, see `expo-api-routes`.

## eas.json (corrected)

```json
{
  "cli": {
    "version": ">= 27.5.0",
    "appVersionSource": "remote"
  },
  "build": {
    "production": {
      "autoIncrement": true,
      "ios": {
        "resourceClass": "medium"
      }
    },
    "development": {
      "developmentClient": true,
      "distribution": "internal"
    }
  },
  "submit": {
    "production": {
      "ios": {
        "appleId": "your@email.com",
        "ascAppId": "1234567890"
      },
      "android": {
        "serviceAccountKeyPath": "./google-service-account.json",
        "track": "internal"
      }
    }
  }
}
```

**Key facts (verified):**
- `cli.resourceClass` enum is **`default | medium | large`** (platform-specific defaults
  `medium`). `m-medium` is stale/DO-NOT-USE.
- `cli.appVersionSource: "remote"` + `build.<profile>.autoIncrement: true` makes EAS the
  source of truth for `android.versionCode` / `ios.buildNumber`.
- `cli.version` is a minimum-floor. Set it to (or above) your reviewed CLI version.

## Platform-Specific

### iOS
- `eas build -p ios --profile production --auto-submit` for quick TestFlight submissions
- Configure Apple credentials: `eas credentials`
- See `references/testflight.md` / `references/ios-app-store.md`

### Android
- Google Play service account in `submit.production.android`
- Track order: internal → closed → open → production

### Web
- EAS Hosting gives preview URLs per PR; production uses your custom domain
- Custom domain assignment is **dashboard-only** (Hosting settings, DNS verify → SSL →
  CNAME/A record; premium feature) — not `eas.json`
- See `references/workflows.md` for CI/CD

## Version Management

```bash
eas build:version:get        # latest version on EAS servers
eas build:version:set -p ios # interactive; verify project/value
eas build:version:sync       # sync value into native code
```

## Monitoring

```bash
eas build:list
eas build:view [BUILD_ID]
```

## Limitations

- Only use when the task matches this product's scope.
- Verify commands, pricing, quotas, credentials, and deployment effect against current
  official docs before making changes.
- Generated examples are not a substitute for environment tests / security review /
  user approval for costly or destructive actions.
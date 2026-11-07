---
name: react-native-dev
description: |
  React Native and Expo engineering guide covering components, styling, animations, navigation,
  state management, forms, networking, performance optimization, testing, native capabilities,
  and engineering (project structure, deployment, SDK upgrades, CI/CD).
  Use when: building React Native or Expo apps, implementing animations or native UI, managing
  state, fetching data, writing tests, optimizing performance, deploying to App Store/Play Store,
  setting up CI/CD, upgrading Expo SDK, or configuring Tailwind/NativeWind.
risk: medium
source: https://github.com/MiniMax-AI/skills/blob/main/skills/react-native-dev/SKILL.md
source_type: upstream-mirror
verification: "Verified against docs.expo.dev 2026-11 (Expo SDK 58.0.23, React 19.3). SDK/reference tables corrected where stale."
license: MIT
metadata:
  version: "1.0.1"
  category: mobile
---

# React Native & Expo Development Guide

A practical guide for building production-ready React Native and Expo applications. Covers UI, animations, state, testing, performance, and deployment.

> **Verification note (2026-11):** this skill was mirrored and corrected. Current baseline:
> **Expo SDK 58.0.23, React 19.3.0, EAS CLI 27.5.0.** Changes vs the upstream MiniMax mirror:
> 1. The SDK-changelog table now extends to SDK 58 and flags historical rows as reference only.
> 2. The API-routes/Cloudflare framing in `references/networking.md` was aligned to the
>    corrected `expo-api-routes` skill (Node.js `node:fs` IS available as an in-memory FS on
>    Expo Hosting; generic Cloudflare-limits claims are not asserted as fact).
> 3. `references/styling.md` NativeWind guidance clarified: **v4 = stable** (tailwindcss v3);
>    **v5 = current rc** (tailwindcss v4 + react-native-css) — see `expo-tailwind-setup`.

## References

Consult these resources as needed:

- `references/navigation.md` — Expo Router: Stack, Tabs, NativeTabs (`headerLargeTitle`), links, modals, sheets, context menus
- `references/components.md` — FlashList patterns, `expo-image`, safe areas, native controls, blur/glass, storage
- `references/styling.md` — StyleSheet, NativeWind/Tailwind, platform styles, theming, dark mode
- `references/animations.md` — Reanimated 3: entering/exiting, shared values, gestures, scroll-driven
- `references/state-management.md` — Zustand (selectors, persist), Jotai (atoms, derived), React Query, Context
- `references/forms.md` — React Hook Form + Zod: validation, multi-step, dynamic arrays
- `references/networking.md` — fetch wrapper, React Query (optimistic updates), auth tokens, offline, API routes
- `references/performance.md` — Profiling workflow, FlashList + `memo`, bundle analysis, TTI, memory leaks
- `references/testing.md` — Jest, React Native Testing Library, E2E with Maestro
- `references/native-capabilities.md` — Camera, location, permissions hooks, haptics, notifications, biometrics
- `references/engineering.md` — Project layout, path aliases, SDK upgrades, EAS build/submit, CI/CD, DOM components

## Quick Reference

### Component Preferences

| Purpose | Use | Instead of |
|---------|-----|------------|
| Lists | `FlashList` (`@shopify/flash-list`) + `memo` items | `FlatList` (no view recycling) |
| Images | `expo-image` | RN `<Image>` (no cache, no WebP) |
| Press | `Pressable` | `TouchableOpacity` (legacy) |
| Audio | `expo-audio` | `expo-av` (deprecated) |
| Video | `expo-video` | `expo-av` (deprecated) |
| Animations | Reanimated 3 | RN Animated API (limited) |
| Gestures | Gesture Handler | PanResponder (legacy) |
| Platform check | `process.env.EXPO_OS` | `Platform.OS` |
| Context | `React.use()` (React 19+) | `React.useContext()` |
| Safe area scroll | `contentInsetAdjustmentBehavior="automatic"` | `<SafeAreaView>` |
| SF Symbols | `expo-image` with `source="sf:name"` | `expo-symbols` |

### State Management

| State Type | Solution |
|------------|----------|
| Local UI state | `useState` / `useReducer` |
| Shared app state | Zustand or Jotai |
| Server / async data | React Query |
| Form state | React Hook Form + Zod |

### Performance Priorities

| Priority | Issue | Fix |
|----------|-------|-----|
| CRITICAL | Long list jank | `FlashList` + memoized items |
| CRITICAL | Large bundle | Avoid barrel imports, enable R8 |
| HIGH | Too many re-renders | Zustand selectors, React Compiler |
| HIGH | Slow startup | Disable bundle compression, native nav |
| MEDIUM | Animation drops | Only animate `transform`/`opacity` |

## New Project Init

```bash
# 1. Create project
npx create-expo-app@latest my-app --template blank-typescript
cd my-app

# 2. Install Expo Router + core deps
npx expo install expo-router react-native-safe-area-context react-native-screens

# 3. (Optional) Common extras
npx expo install expo-image react-native-reanimated react-native-gesture-handler
```

Then configure:
1. Set entry: `package.json` → `"main": "expo-router/entry"`
2. Add scheme in `app.json`: `"scheme": "my-app"`
3. Delete `App.tsx` and `index.ts`
4. Create `app/_layout.tsx` as root Stack layout
5. Create `app/(tabs)/_layout.tsx` for tab navigation
6. Create route files in `app/(tabs)/`

For web support, also install: `npx expo install react-native-web react-dom @expo/metro-runtime`

## Core Principles
- **Consult references before writing** — read the matching reference for patterns/pitfalls.
- **Try Expo Go first** (`npx expo start`). Custom builds (`eas build`) only when using local
  Expo modules, Apple targets, or third-party native modules not in Expo Go.
- **Conditional rendering**: `{count > 0 && <Text />}`, not `{count && <Text />}` (renders "0").
- **Animation rule**: only animate `transform` and `opacity` — GPU-composited, no layout thrash.
- **Imports**: import directly from source, not barrel files — avoids bundle bloat.
- **Route files**: use kebab-case; never co-locate components/types/utils in `app/`.

## Checklist

### New Project Setup
- [ ] `tsconfig.json` path aliases configured
- [ ] `EXPO_PUBLIC_API_URL` env var set per environment
- [ ] Root layout has `GestureHandlerRootView` (if using gestures)
- [ ] `contentInsetAdjustmentBehavior="automatic"` on all scroll views
- [ ] `FlashList` instead of `FlatList` for lists > 20 items

### Before Shipping
- [ ] Profile in `--profile` mode, fix frames > 16ms
- [ ] Bundle analyzed (`source-map-explorer`), no barrel imports
- [ ] R8 enabled for Android
- [ ] Unit + component tests for critical paths
- [ ] E2E flows for login, core feature, checkout
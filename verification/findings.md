# Verification findings (2026-11)

Grounding: EAS CLI 27.5.0, Expo SDK 58.0.23, tailwindcss 4.3.5,
nativewind 5.0.0-rc.1 / 4.2.7 stable, react-native-css 3.0.7.
Source docs: `docs.expo.dev` (markdown endpoints), all fetched live during this review.

## expo-deployment

- `eas build:version:get` / `set -p ios` — real commands, signatures confirmed in
  `eas/cli.md`.
- `eas deploy` (preview) / `eas deploy --prod` — confirmed.
- `appVersionSource: "remote"` + `autoIncrement: true` — matches
  `build-reference/app-versions.md`.
- ❌ `resourceClass: "m-medium"` — INVALID. `eas/json.md` enum is `default | medium | large`.
  `m-medium` appears nowhere in current Expo docs. Fixed to `"medium"`.
- `cli.version: ">= 16.0.1"` — outdated floor; bumped to `>= 27.5.0`.

## expo-api-routes

- ✅ Expo Hosting is built on Cloudflare Workers (V8 isolates, partial Node.js). Confirmed
  in `eas/hosting/introduction.md` and `reference/worker-runtime.md`.
- `+api.ts`, named HTTP-method exports, dynamic `[id]+api.ts`, `expo-server` — all current.
- ❌ "No Node.js filesystem (fs unavailable)" — outdated. Worker-runtime table lists
  `node:fs` ✓ "Supported, with in-memory filesystem". Fixed.
- ⚠️ "30 s timeout", "WebSockets require Durable Objects", "no native modules" — generic
  Cloudflare claims, NOT restated in current Expo docs. Flagged as unverified at the
  Expo layer; do not assert as fact without confirming.
- Error handling now uses `expo-server` `StatusError` / auto-405 / auto-500 (SDK 54+).
- Custom domain assignment is dashboard-only + premium; not `eas.json`.

## expo-dev-client

- All config (`developmentClient`, `distribution: internal`, `appVersionSource`) and the
  three build methods (local `expo run:*`, cloud EAS build, `--local` EAS build) verified
  against `develop/development-builds/introduction.md`.
- TestFlight caveat (don't submit dev-client profile) is correct guidance.
- Only change: `cli.version` floor bumped.

## expo-tailwind-setup

- ✅ Standard Tailwind v4 install (`tailwindcss` + `@tailwindcss/postcss` + `postcss`) and
  Metro web requirement — matches `guides/tailwind.md`.
- ⚠️ Pinned `nativewind@5.0.0-preview.2` (upstream) — current v5 is `5.0.0-rc.1`, stable
  4.2.7. Updated.
- ⚠️ Pinned `react-native-css@0.0.0-nightly.5ce6396` — current is `3.0.7`. Updated.
- Universal styling per current docs = NativeWind / Uniwind external libs; standard Tailwind
  is web-only.

## react-native-dev (MiniMax-AI/skills)

- General-purpose RN/Expo engineering guide (SKILL.md + 10 references), scope = breadth, not
  deployment.
- ✅ Accurate: React 19 (`use()` ↦ `useContext`, `<Context>` provides) — confirmed, SDK 54+ and
  current templates ship React 19.3.0; `expo-av` deprecated → `expo-audio`/`expo-video`;
  `--template blank-typescript` still valid (58.0.32); `process.env.EXPO_OS`.
- ⚠️ SDK table stopped at SDK 55 — extended to 58 with verified changelog facts
  (56 = RN 0.85/React 19.2; 57 = RN 0.86; 58 = iOS 27, App Intents, SPM, New Arch default).
- ⚠️ networking API-routes repeated the stale "Cloudflare Workers / no fs" frame — corrected
  per our `expo-api-routes` (`node:fs` IS available in-memory; partial Node.js support).
- ⚠️ NativeWind section was v4-only — clarified v4 (stable, tailwindcss v3) vs v5 rc
  (tailwindcss v4 + react-native-css 3.0.7), pointing to `expo-tailwind-setup`.
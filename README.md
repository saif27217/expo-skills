# expo-skills

Verified, corrected Expo skills for Hermes-style agents. Originally mirrored from
[`sickn33/antigravity-awesome-skills`](https://github.com/sickn33/antigravity-awesome-skills)
(upstream: `github.com/expo/skills`), each re-verified against current Expo docs and
corrected where the upstream had drifted.

## Skills

| Skill | Path | Status |
|---|---|---|
| **expo-deployment** | `skills/expo-deployment/SKILL.md` | ✅ corrected — `resourceClass` is `medium` (not stale `m-medium`) |
| **expo-api-routes** | `skills/expo-api-routes/SKILL.md` | ✅ corrected — `node:fs` IS supported (in-memory); Cloudflare limits flagged as unverified |
| **expo-dev-client** | `skills/expo-dev-client/SKILL.md` | ✅ verified accurate; version floor bumped |
| **expo-tailwind-setup** | `skills/expo-tailwind-setup/SKILL.md` | ✅ corrected — modern NativeWind v5 rc + react-native-css 3.x (not old preview/nightly) |
| **react-native-dev** | `skills/react-native-dev/` (SKILL.md + 10 references) | ✅ cross-verified 2026-11 — SDK table extended to 58; Cloudflare runtime framing corrected; NativeWind v4/v5 clarified |

## Verification

Verified 2026-11 against:
- `docs.expo.dev/eas/json` (eas.json schema)
- `docs.expo.dev/eas/cli` (EAS CLI reference)
- `docs.expo.dev/build-reference/app-versions` (version management)
- `docs.expo.dev/eas/hosting/*` (Hosting, custom domains)
- `docs.expo.dev/eas/hosting/reference/worker-runtime` (Cloudflare Workers runtime)
- `docs.expo.dev/router/web/api-routes` (API routes)
- `docs.expo.dev/develop/development-builds/*` (dev client)
- `docs.expo.dev/guides/tailwind` (Tailwind CSS)

Current package baseline: EAS CLI 27.5.0, Expo SDK 58.0.23, tailwindcss 4.3.5,
nativewind 5.0.0-rc.1 / 4.2.7 (stable), react-native-css 3.0.7.

## Key corrections vs upstream

1. **expo-deployment**: upstream `eas.json` used `resourceClass: "m-medium"` — invalid.
   Valid enum is `default | medium | large`.
2. **expo-api-routes**: upstream claimed `node:fs` unavailable. Expo Hosting's
   worker-runtime reference confirms `node:fs` is **supported (in-memory filesystem)**.
   Generic Cloudflare-limit claims (30 s timeout, WebSockets→Durable Objects) kept but
   labeled as not restated at the Expo layer.
3. **expo-t-tailwind setup**: upstream pinned `nativewind@5.0.0-preview.2` and
   `react-native-css@0.0.0-nightly.*`. Current: NativeWind v5 `5.0.0-rc.1` (stable 4.2.7)
   and `react-native-css@3.0.7`.

## Related

Our host-specific Expo workflow lives in the Hermes skill `mobile-app-dev`
(devops category) — headless Linux scaffold → verify → serve → `eas update` to Expo Go.
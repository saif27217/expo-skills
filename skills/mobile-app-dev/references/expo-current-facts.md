# Verifying third-party Expo/EAS recipes against current reality

Expo skills/docs drift fast (EAS CLI, SDK, nativewind all move within months).
Before trusting any recipe copied from a third-party repo or blog, verify the
specific claims, not just the overall approach.

## Verification method (fast, scriptable)
1. Expo docs are served as clean Markdown for agents: append `.md` to any
   `docs.expo.dev/<path>` URL and fetch it directly (e.g.
   `https://docs.expo.dev/eas/json.md`, `.../build-reference/app-versions.md`).
   The HTML pages are heavy Next.js shells; `.md` is the source of truth and
discards the UI. Full map: `https://docs.expo.dev/llms.txt`.
2. Ground the skill's pinned versions/lines against live npm:
   `npm view eas-cli version`, `npm view expo version` (SDK), and for the
   styling stack `npm view nativewind version` + `npm view nativewind versions
   --json` (latest on a major line may be an `-rc`/`-preview`, check the whole
   list), `npm view react-native-css version`, `npm view tailwindcss version`.
3. Grep the fetched `.md` for the exact enum/flag/command the skill claims
   (e.g. `resourceClass`, `eas build:version:set`, `eas deploy --prod`) —
   absence in current docs is the strongest signal of a stale claim.
4. Confirm binary routing claims ("runs on X runtime") against the docs that
   actually cover that hosting layer, not the general framework page.

## Corrected facts (verified vs current docs)
- `eas.json` `build.<profile>.ios.resourceClass` enum is `default, medium,
  large`. The `m-medium` value in upstream `expo/skills` examples is invalid
  and appears in no current Expo doc. Use `medium`.
- Expo Hosting IS built on Cloudflare Workers (V8 isolates, partial Node.js
  compat): UI routes and `+api.ts` server routes deploy via `eas deploy
  (preview)` / `eas deploy --prod` (production).
- `node:fs` IS available in Expo Hosting API routes (in-memory filesystem) —
  the "no filesystem" claim is stale. WebSockets do still need Durable Objects.
- Server-route error handling now uses the `expo-server` library's `StatusError`
  and auto-405/auto-500 behavior (SDK ≥54), not raw Cloudflare idioms.
- Custom domains for Expo Hosting are configured in the dashboard (verification
  TXT → SSL CNAME → CNAME/A record; premium plan only), NOT in `eas.json`.
- NativeWind: current stable is v4; the v5 line is at `5.0.0-rc.x` (earlier
  `5.0.0-preview.*` pins in recipes are stale). `react-native-css` is now a
  released `3.x`, not a `0.0.0-nightly.*` pin. Tailwind v4 pairs with
  `@tailwindcss/postcss`.
- EAS version mgmt: `cli.appVersionSource: remote` + `build.<profile>
  .autoIncrement: true`; read/write with `eas build:version:get/set`, sync
  natives with `eas build:version:sync`.
- Expo SDK → RN/React mapping (verified): 54=React 19 (`use()` replaces
  `useContext`, `<Context>` replaces `<Context.Provider>`, `forwardRef` gone),
  React Compiler available; 56=RN 0.85 + React 19.2; 57=RN 0.86;
  58 (current, verified Nov 2026)=iOS 27/App Intents/SPM, New Architecture
  default, `@expo/agent-cli`. Current templates ship React 19.3. When auditing a
  recipe, check which SDK generation it targets before judging its React APIs
  current.

## Pitfall: docs restructure silent-404s
Expo reorganized docs (old `build-reference/*` paths now 404). If a fetched
`docs.expo.dev/<path>.md` returns a 404 shell or near-empty body, the route
moved — pull `llms.txt` and grep for the current path rather than assuming the
page is gone or the feature removed.

## Pitfall: upstream SDK-version tables go stale silently
Broad engineering guides embed an SDK changelog table that stops updating,
then keep reading as authoritative years later. Treat any hardcoded SDK→RN/React
version table in a recipe as a suspect snapshot: re-derive the current row from
the changelog and `npm view expo-template-<name> dependencies.react` before
trusting it, and judge a recipe's React APIs by the SDK generation it targets.
A guide that says "verify against the changelog" ages better than a frozen table.

## Source lineage: a mirror inherits its upstream's errors
A recipe repo that mirrors another skill set (e.g.
`sickn33/antigravity-awesome-skills` mirrors `expo/skills`) carries its upstream's
drift verbatim. When a claim is wrong, the error belongs to the upstream — fix it
in place against current docs regardless of which repo surfaced it; do not treat
the mirror as an independent source to re-verify on every fresh read.

## Reuse-first: verified Expo skills already exist
Five Expo skills were verified against current docs. `expo-deployment`,
`expo-api-routes`, `expo-dev-client`, `expo-tailwind-setup` and the broader
`react-native-dev` engineering guide (SKILL.md + 10 topic references) live in
this library (mirrored to `saif27217/hermes-skills`) and standalone at
`saif27217/expo-skills` (public): `expo-deployment`, `expo-api-routes`,
`expo-dev-client`, `expo-tailwind-setup`, `react-native-dev`. Before re-verifying or rewriting a
recipe from scratch, reference these — they already carry the corrections in this
file.

## Nuance: `cli.version` is a minimum floor
`eas.json` `cli.version` is a lower bound, not a pin. A stale-low value (e.g.
`>= 16.0.1`) is semantically harmless because the current CLI satisfies it —
bumping it to current is cosmetic cleanup, not a bug fix. Real breakage comes
from an enum/flag/schema value that does not exist (like `m-medium`), not from a
low floor.

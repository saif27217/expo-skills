---
name: mobile-app-dev
description: Use when scaffolding or deploying Expo/React Native apps.
version: 1.3.0
author: sak
license: MIT
metadata:
  hermes:
    tags: [expo, react-native, mobile, eas, deployment]
    related_skills: [ssh-mastery, termux-endpoint]
---

# Expo / React Native app development (headless Linux host)

## When to Use
Any request to create, scaffold, run, or deploy an Expo / React Native app
(from scratch or extending lab-app), including getting it onto a phone via
Expo Go or pushing updates to Expo's CDN.

Build on the host, run on the phone via Expo Go. Verify every stage by real execution.

## Core workflow
1. Scaffold: `npm create expo@latest <name>` (default template). NEVER `--template empty` — resolves to a bogus npm package; reset manually instead (`rm src/components/** src/app/explore.tsx`, keep `_layout.tsx`).
2. Code: expo-router screens under `src/app/`; custom hooks `src/hooks/use-*.ts`; pure testable logic in `src/utils/`.
3. Verify: `npx tsc -p tsconfig.json --noEmit` + `npm test` (node:test on utils).
4. Serve: `npx expo start --port 8081`. Phone: Termux `ssh -N -L 8081:localhost:8081 user@vps`, Expo Go "Enter URL manually".
5. Deploy (permanent): `npm install eas-cli` → commit clean git tree → `EXPO_TOKEN=*** eas update -p android --environment production --branch production -m "..."` (v27 form; full verified sequence incl. token handling in `references/commands.md`).
6. Open in Expo Go (published updates): sign in to Expo Go with the SAME account, open the **Projects tile** for the slug — it loads the latest published update with no dev server/tunnel/URL. If it shows a cached version, pull-to-refresh on the "This version is cached" prompt. Typing `expo.dev/@acct/slug` into Expo Go or opening it in a browser shows the expo.dev web page (project slug text centered) — that is NOT the app. Verify CDN after each `eas update`: GET `https://u.expo.dev/<project-uuid>` with headers `expo-runtime-version`, `expo-channel-name`, `expo-platform`, `Accept: multipart/mixed` and grep the response for the update group ID the update command printed.

## Pitfalls (one-liners)
- Pure-black screen in every runtime = `_layout.tsx` renders no screens: expo-router's layout IS the render root, so it must `<Stack>` every screen (`<Stack><Home/><A/><B/></Stack>` inside ThemeProvider, screens imported as `import Home from './index'` via their `export default`). A layout wrapping only StatusBar renders nothing → black; `Link` never fixes this.
- Never `git add -A` blindly: `dist*/` build outputs (dist_serve, dist/) get committed and bloat uploads; `.gitignore` them before the first `eas build`/`update`.
- `expo publish` is dead in SDK ≥53; the only push is `eas update` (asset bundle channel).
- Signed tour tunnels need login or `EXPO_TOKEN=... npx expo start --tunnel`; tunnels expire ~15 min idle — never quote them as permanent.
- `npx eas` fails ("could not determine executable") until `eas-cli` is npm-installed. With a project-local install, invoke `node_modules/.bin/eas` / `node_modules/.bin/expo` directly — do not hunt for them on PATH or under `~/.bin`; `timeout expo` and bare `expo` both miss.
- eas-cli v27 eas.json top level allows only `{cli, build, submit}`; a top-level `"production"` profile is rejected (`"production" is not allowed`). Correct minimal setup: eas.json = `{"cli":{"version":">= 27.5.0"}}` then `eas update -p android --environment production --branch production -m "..." --non-interactive` (`--channel` is legacy, `--auto` takes git branch name).
- EAS auth without login: `EXPO_TOKEN=... eas whoami` BEFORE any eas command; token exists only as live env, never persisted (see commands.md publish block).
- eas-cli v27 `--platform` accepts ONE value from `android|ios|all` (`-p android,ios` and repeated `-p` both error). For both targets in one call use `-p all`.
- eas update fingerprint step can crash with `The "paths[1]" argument must be of type string` AFTER bundles upload — rerun with `EAS_SKIP_AUTO_FINGERPRINT=1`; bundles are re-exported cheaply on retry.
- Publish-scope tokens reject eas-cli READ commands (`eas channel:view`, history queries) with "bearer token is invalid" — that is a scope limit, not a failed publish. Proof of ship = the `✔ Published!` line + update group ID the `eas update` call itself printed, cross-checked via the CDN GET recipe; never retry eas-cli reads against the token to "confirm".
- CDN GET only exposes PUBLIC channels (e.g. `production`); a `development`-branch update returns "There is no channel named development" anonymously — do not loop over channel-name variants; the eas receipt is the proof, Expo Go loads the dev branch via the Projects tile for the signed-in account.
- If `eas update` ITSELF (which publish-scope tokens allow) starts rejecting "bearer token is invalid" after previously publishing fine, the token was ROTATED/expired — refresh it. That is not the read-scope limit; do not chase GraphQL endpoints or rebuild, the app is unchanged. Keep a fresh `EXPO_TOKEN` before shipping.
- `terminal(background=true)` runs with a FRESH env: foreground `export EXPO_TOKEN` does not carry into background commands — always inline `EXPO_TOKEN=... <cmd>`.
- `eas init`/`eas update` non-interactive require `--account` (or `owner` in app config) and `--environment`; robot tokens cannot set the project icon (cosmetic GraphQL 401).
- expo-router v58 `Link` prop is `href`, not `to`.
- SDK 58 templates call no `SplashScreen.preventAutoHideAsync()`; calling it without a matching `hideAsync()` leaves the splash (project-name text) covering the app — omit it, or hide it.
- `TextInput` accepts ONLY `Text` children at runtime (nested `Text` fine); a `View`/`ScrollView` child crashes the screen at render while `tsc` stays clean. Put results as capped rows of nested `Text` joined by `'\n'` inside the TextInput, siblings below it.
- If a user reports a blank screen showing only the project slug centered, suspect wrong open method (project web page), not code: our screens' titles differ from the slug, and eas output + CDN grep already proved a fresh bundle — fix the launch procedure before touching source. Set `"displayName"` (inside the `expo` object, app.json) to a human title so the tile/splash never reads as the slug; shipping an app.json change needs a fresh `eas update`.
- To prove the live bundle contains the UI: `npx expo export -p android`, then `strings dist/_expo/static/js/android/entry-*.hbc | grep "<UI string>"` — SDK 58 ships Hermes bytecode (`.hbc`), not plain JS, so direct grep fails; and re-fetching eascdn signed asset URLs returns 403 (signatures expire). Trust the local export strings + manifest group-ID grep, never asset downloads.
- TS excludes test files from app build (`tsconfig` exclude); `node:test`/`node:assert` types resolve via package.json `types` field, not `@types/node` alone.
- Dev server port conflict: old `expo start` process holds :8081; kill the pid (it's printed in CommandError) before relaunch.
- Search-results bug 'only N matches text, no rows': TWO layers — (a) the search util's default `limit` (e.g. `searchTests(q, limit=15)`) silently truncates, so the count line always reads exactly 15; raise the cap and let the VIEW cap rows with 'showing first N · scroll for more'. (b) result rows rendered as TextInput siblings with `flex: 1` collapse to 0px once matches exceed viewport → wrap rows in a `ScrollView` sibling (ScrollView as SIBLING of TextInput is safe; only as its CHILD it crashes) with natural-height rows. Headless check: after typing a common query, count divs with `offsetHeight>15` containing badge text.
- When a util's default param/cap changes, node:test assertions pinning the old value fail — update them in the same commit (`npm test` = `node --test --experimental-strip-types 'src/utils/*.test.ts'`).
- Screen icons: `NativeTabs.Trigger.Label` takes plain strings only, so icons in the tab bar must be emoji prefixed to the label; mirror the same emoji in the screen header. `\u{...}` pictograph escapes are opaque in source — confirm the intended glyph by reading the rendered innerText before shipping (a wrong codepoint like U+1F3CB silently renders a weightlifter). Prefer emoji over `@expo/vector-icons` for anything shown in the tab bar or needing headless verification: emoji render from system fonts on both RN-web and Android, while vector-icons render as PUA glyphs a browser check cannot validate.
- Overview/home screens: compute every displayed number at runtime from the SAME dataset constant the search uses (totals, per-category counts, distinct partner names via `new Set(...)`), never hardcode counts — the UI stays truthful when the dataset changes. Structure: title + subtitle with counts, flex-row stat cards, legend card explaining badge vocabulary with the actual partner names, one how-to hint line.
- Large spreadsheet→app data: ship as committed JSON (`src/data/x.json`) + generated TS constant module; extractor checkpoints per chunk to workspace + progress.json (resume-safe). In-app counts must use EXACT source enum spellings ('Schedule' not 'Scheduled') — verify rendered stats against source Counter() before deploy. RN-web UI is verifiable headlessly: `expo start --port` + browser fill/click + innerText checks.

- Detail cards for directory app: wire `Linking.openURL('tel:' + digits)` for Call and `Linking.openURL('https://maps.google.com/?q=' + encodeURIComponent(name + ', ' + area + ', City'))` for Directions. Filter contact strings to >=7 digits before `tel:` — dataset mixes real numbers with placeholders (`0000-00000000`) and malformed lengths that dial garbage. The maps deep-link makes stored street addresses optional, so prefer it over scraping address data; RN-web renders these as buttons via the press handler (no raw `href` in the DOM — verify by innerText, not a `tel:` grep).

## References
- `references/commands.md` — exact verified command sequences incl. token handling
- `references/layout.md` — verified src/ layout and file roles
- `references/expo-current-facts.md` — how to verify any third-party Expo/EAS/nativewind recipe against current docs + live versions, and corrected facts (EAS Hosting runtime, nativewind status)
- `scripts/sync-repos.sh` — mirrors canonical skill to hermes-skills + expo-skills and pushes; run after every edit to this skill.

## Repo mirrors
`~/.hermes/skills/devops/mobile-app-dev` is canonical. One-way mirrors (never hand-edit): `/home/sak/hermes-skills/devops/mobile-app-dev` and `/home/sak/expo-skills/skills/mobile-app-dev`. After ANY edit here, `bash scripts/sync-repos.sh` re-copies, commits and pushes both.
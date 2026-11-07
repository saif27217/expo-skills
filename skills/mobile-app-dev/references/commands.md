# Verified command sequences (Expo SDK 58, Node 22)

## Scaffold
```bash
npm create expo@latest lab-app   # default template; --template empty is broken (bogus npm pkg)
# manual reset (what scripts/reset-project.js does):
rm -f src/app/explore.tsx src/global.css src/constants/theme.ts
rm -rf src/components src/hooks src/assets
# then rewrite src/app/_layout.tsx to ThemeProvider+StatusBar minimum
```

## Verify
```bash
npx tsc -p tsconfig.json --noEmit
npm test   # node --test --experimental-strip-types on src/utils/*.test.ts
```
tsconfig `exclude: ["src/**/*.test.ts"]` — TS6 resolves node:test types via the
package.json "types" field; without exclude the app build breaks.

## Serve
```bash
npx expo start --port 8081          # non-TTY: prints only "Waiting on http://localhost:8081"
# phone: ssh -N -L 8081:localhost:8081 sak@vps ; Expo Go Enter URL manually
# signed tour URL (anywhere):
EXPO_TOKEN=*** npx expo start --tunnel --port 8081
# URL printed: https://c-<account-slug>-<rand>.on.expo.app — verify:
curl -sL -A "Mozilla/5.0" "$URL" | head -c 400   # expect expo-reset HTML/bundle
```
Tunnel URL is ephemeral (dies when process exits / idle). Kill stale holder:
CommandError prints pid — `kill <pid>` before relaunch.

## Publish (EAS Update) — verified sequence
```bash
npm install eas-cli   # required; npx eas otherwise fails "could not determine executable"
git commit -am "..."  # clean tree required; commit HEAD must contain the fix
# 1. Access token: https://expo.dev/accounts/<acct>/settings/tokens, scope
#    "Manage projects and publish your updates". NEVER persist token values
#    in files/memory/chat — the secrets-redaction policy replaces stored copies
#    with a 3-char placeholder that fails "The bearer token is invalid"; the
#    user must re-supply it each time it is needed.
# 2. Verify auth WITHOUT echoing the token:
EXPO_TOKEN=*** eas whoami   # expect "Accounts: • <acct> (Role: Developer)"
# 3. (first time only) put project on EAS:
EXPO_TOKEN=*** eas init --account drsaifbiochems-team --non-interactive
#    -> prints project URL + project UUID; writes app.json owner/id
# 4. Publish to channel (v27 form; --channel is rejected):
EXPO_TOKEN=*** eas update -p android --environment production --branch production --message "..." --non-interactive
# expo-cli warning "--non-interactive is not supported, use $CI=1" is harmless.
# Report from output: Update group ID, Android update ID, runtime version,
# Commit sha (MUST equal pushed HEAD sha), EAS Dashboard URL. Phone: the
# installed production build picks the group up on next launch; an Expo Go
# session opened via dev-server URL is unaffected by eas updates.
```
Expo Go deep link: https://expo.dev/@drsaifbiochems-team/lab-app
CDN verify (multipart manifest, not JSON):
```bash
curl -s "https://u.expo.dev/<project-uuid>" \
  -H "expo-runtime-version: 1.0.0" -H "expo-channel-name: production" \
  -H "expo-platform: android" -H "Accept: multipart/mixed" | head -c 400
# expect: boundary + manifest JSON with launchAsset.url
```
Robot token limits: cannot set project icon (ProfileImageUploadSessionEntity 401 — cosmetic).
Iterating: edit → git commit → eas update again (runtime version bumps automatically
when code changes; SDK 58 uses expo runtime-version:query policy `SDK_VERSION`).
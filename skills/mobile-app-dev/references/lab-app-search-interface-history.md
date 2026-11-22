# lab-app — tests screen: search-interface history (what was vetoed, and why rejections must stay gone)

Repo `/home/sak/lab-app`, screen `src/app/tests.tsx`. Android-only project, EAS account
`drsaifbiochems-team`, eas-cli v27. Vetoes are per-update-group, so every rejection is a
NEW update group on the tracked branch, never an in-place tweak.

## Hard constraints (user vetoes — never reintroduce)
1. Filter chips: no `scope`/`tat` filter state, no `Filters` param, no `suggestTests` UI wiring.
   `src/utils/lab-search.ts` still exports that API; the screen never imports it. Grep
   `tests.tsx` for `scope|tat:|Filters|suggestTests|applied|Filters applied|didYouMean` → 0.
2. A–Z jump rail (44 letter chips, 44px Pressables) — removed. Letter selection state (`letterSel`)
   does not exist; `browseLetter`/`letterFor` are not imported.
3. Recent-search chip strip (`↦ zinc`) — removed. `recents`/`setRecents` state does not exist;
   `onText` is exactly `setQuery(v)`. Search mode = match line then rows, nothing between.
4. Net result: the horizontal rail (`railScroll`) is gone for BOTH modes; its styles
   (`railScroll`, `railChip`, `railChipText`, `azHeader`) were deleted from the styles object.

## What survived the vetoes (do not "clean up" these)
- Browse keeps per-letter section headers inside the results ScrollView:
  `styles.groupHeader`, rendered from `g.letter ? … : null`, plus `🔷` glyph
  (`\u{1F537}`) and the `★ Pinned · n` group hoisted above letter groups.
- ★ pin button (`styles.pinBtn`, 44px) on the detail card, `favNames`/`toggleFav`,
  `pinTag`, pinned count in the menu line.
- Detail card stays open across query changes (no `setOpenKey('')` in `onText`) +
  `openKey === openTest.name` scroll hint.
- TAT colour bands + raw worst-range line (`tatBandText`) + critical notes above reference data.

## Branch truth (the trap that cost 3 wasted publishes)
- `eas branch:list` / `branch:view <branch>` shows the newest update per branch.
- The Expo Go client tracks the branch with recent timestamps — in this project that is
  `development`, NOT `production`. Publishing to any other branch updates zero devices
  ("still seeing the old UI" = wrong branch, not a failed publish).
- `eas branch:delete <name>` works for cleanup; v27 has NO `rollback` and NO `branch:revert`
  (only create/delete/list/rename/view).

## Veto = republish the previous tree (the only mechanism)
```bash
git checkout <pre-feature-commit> -- src
export EXPO_TOKEN='<re-supplied each session; inline, never stored>'
EAS_SKIP_AUTO_FINGERPRINT=1 npx eas update -p android \
  --environment production --branch development --non-interactive \
  --message "<what is being vetoed>"
git checkout HEAD -- src   # unless the veto is the new working state
```
Gotchas: `--environment` REQUIRED, `--channel` rejected by v27; `EAS_SKIP_AUTO_FINGERPRINT=1`
avoids the adaptive-icon fingerprint crash (see hospital-app memory); commit the vetoed
screen first so `--message` maps to a `git log` line for rollback.

## Current landing state (as of this commit chain)
`git log` on `src/app/tests.tsx`, oldest→newest:
- `f10ef3c` 10-Nov baseline (search box + results, no chips)
- `6ab9b6e` TAT colour bands + raw range + criticals-first
- `743dc1b` A–Z rail + sticky letter header  ← VETOED
- `92df3f5` recent-search chips + ★ pin + pinned section + card survives query change
- `5f75c45` A–Z rail deleted (letters gone; section headers kept)
- `7bc2efa` recent-search chips deleted (search = match line + rows)

Newest `development` update group: `d5cc9c76-1597-4101-b266-9e916cd766d0` (commit `7bc2efa`).
Rollback handles: `12311edf-…` (chips kept, no rail), `e03fc3f4-…` (rail + chips),
`6a0f9e46-…` (TAT only, no pin/rail/chips).

## Verification before declaring a search change done
```bash
grep -c "<vetoed identifiers>" src/app/tests.tsx   # 0
npx tsc --noEmit                                   # exit 0 (no files on cmdline: tsconfig exists)
npm test                                           # 13 pass / 0 fail
```
Then in the dev build (Playwright/Browser Use): search "zinc" → expect
`⚗️ Lab tests — 518 on file` → `3 matches · scroll for more` → rows, with no rail lines and
no `↦` chips; browse mode → `Full menu · 518 tests · 268 in-house · 249 outsourced` then
`🔷 # · 51` headers; DOM scan for aria-labels containing `Search again`/`Browse tests` → [].
Dev server runs at `:8091` in this session.

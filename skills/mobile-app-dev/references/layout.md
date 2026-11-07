# Verified src/ layout (Expo SDK 58, expo-router v5)

```
src/
  app/
    _layout.tsx   InitialTheme + ThemeProvider (useAutoMode via useColorScheme)
                  + StatusBar; one per root screen
    index.tsx     route "/" — home screen
    stats.tsx     route "/stats"; reached via Link href="/stats" (v58: href, NOT to)
  hooks/
    use-stopwatch.ts   RN-style hook: useCallback/useEffects/useSuspense shape;
                       custom hooks are src/hooks/use-*.ts (single exported useX)
  utils/
    format.ts          pure functions (formatReading(value, unit, decimals),
                       Infinity -> "— unit")
    format.test.ts     node:test + node:assert, run via npm test; EXCLUDED from build
assets/icons           generated icon.png (PWA/Android icon; not app icon)
```

Notes:
- Screens render as `export const Screen = () => ...` / `export index.tsx` pattern;
  expo-router file → URL mapping is src/app (configured via app config
  `expo.router.root` default "src/app").
- Screenshots from Expo Go / browser web-build are the cheapest UI verification;
  `curl -s <tunnel-or-lan>` returning the expo-reset HTML proves Metro serves
  the web bundle — necessary but not sufficient for runtime correctness.
- Disk: this VPS runs ~92% full; node_modules ~200 MB per project — check
  `df -h /` before scaffolding a second project.
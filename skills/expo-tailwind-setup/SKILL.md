---
name: expo-tailwind-setup
description: "Set up Tailwind CSS in an Expo app: standard Tailwind v4 (web) and universal styling via NativeWind / react-native-css."
risk: medium
source: https://github.com/sickn33/antigravity-awesome-skills/blob/main/skills/expo-tailwind-setup/SKILL.md
source_type: upstream-mirror
verification: "Verified against docs.expo.dev 2026-11 (Expo SDK 58, Tailwind CSS guide)."
license: MIT
---

# Tailwind CSS in Expo

## When to Use

Use when adding Tailwind CSS to an Expo (React Native / Expo Router) project — either
standard Tailwind v4 for **web-only** styling, or universal (iOS/Android/Web) styling via
**NativeWind**.

> **Verification note (2026-11):** the upstream mirror pinned old preview builds. Current
> matrix: `tailwindcss@4.3.5`, `@tailwindcss/postcss@4.3.5`, **NativeWind latest v5 is
> `5.0.0-rc.1`** (stable = 4.2.7), **`react-native-css@3.0.7`**. Avoid old `5.0.0-preview.*`
> and `0.0.0-nightly.*` pins — use the rc/stable releases.

## Approach A — Standard Tailwind v4 (web only)

Standard Tailwind supports **only the web platform**. For universal component styling use
Approach B (NativeWind) or Uniwind.

```bash
npx expo install tailwindcss @tailwindcss/postcss postcss --dev
```

Ensure `app.json` uses Metro for web:
```json
{
  "expo": {
    "web": { "bundler": "metro" }
  }
}
```

Configure via PostCSS (`postcss.config.js` uses the `@tailwindcss/postcss` plugin), with a
`global.css` (Tailwind v4 directives) imported from the entry file. Use `@tailwindcss/postcss`
— not the `tailwindcss` PostCSS plugin directly (v4 moved to the plugin).

## Approach B — Universal styling (NativeWind + react-native-css)

Current recommended libraries: **NativeWind** and **Uniwind** (see
`https://www.nativewind.dev/` and `https://uniwind.dev/`). react-native-css provides the
CSS runtime for React Native.

```bash
# NativeWind v5 (current rc)
npm install nativewind@5.0.0-rc.1 react-native-css@3.0.7 tailwindcss@^4 @tailwindcss/postcss
```

Add the Metro + Babel plugins per current NativeWind/react-native-css setup instructions —
the exact naming has evolved across previews, so follow the lib's current docs.

### CSS-wrapped components

react-native-css requires explicit CSS-element wrapping. Create reusable wrapped
components:

```ts
// src/tw/view.tsx
import { useCssElement } from 'react-native-css';
import { View as RNView } from 'react-native';

export const View = useCssElement(RNView, 'div');
```

Wrap the component set you use (View, Text, ScrollView, TextInput, Image, Animated, etc.)
so Tailwind utility classes style them at runtime.

## Customization (@theme)

Use Tailwind v4's CSS-first config in `global.css` with `@theme`:

```css
@import "tailwindcss";

@theme {
  --color-brand: #4f46e5;
}
```

Reference the variable as a token (e.g. `text-brand`) inside wrapped components.

## Platform color variables

For platform-aware values, combine Tailwind tokens with `Platform.select()` or the
`useUnstableNativeVariable`-style hooks that read `--*` theme variables — follow the
react-native-css docs for the current API.

## Notes / pitfalls

- **Version pinning**: don't reuse old preview/nightly pins from upstream mirrors. Verify
  the current versions with `npm view` before installing.
- Standard Tailwind v4 is **web-only**; universal styling requires NativeWind/Uniwind.
- Everything must be exercised by real execution: configure, then run a screen that uses
  utilities and confirm styles apply on the target platform.
- Metro + Babel plugin config has changed across NativeWind previews — defer to the
  package's official setup guide, not a fixed snippet.

## Limitations

- Only use when the task matches this product's scope
- Verify current package versions, plugin config, and web-vs-universal trade-offs against
  current docs before installation
- Generated examples are not a substitute for environment tests
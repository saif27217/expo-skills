---
name: expo-api-routes
description: "Author Expo Router server-side API routes (+api.ts) and deploy them to Expo Hosting (Cloudflare Workers runtime) with env secrets and edge databases."
risk: medium
source: https://github.com/sickn33/antigravity-awesome-skills/blob/main/skills/expo-api-routes/SKILL.md
source_type: upstream-mirror
verification: "Verified against docs.expo.dev 2026-11 (Expo SDK 58, Expo Hosting worker-runtime reference)."
license: MIT
---

# API Routes (Expo Router, Expo Hosting)

## When to Use

Use when you need server-side code inside an Expo Router app — `+api.ts` route files in
`src/app/`, deployable to Expo Hosting or other custom-server providers, with env secrets
and edge database options.

> **Verification note (2026-11):** Expo Hosting is confirmed to run on the **Cloudflare
> Workers runtime** (V8 isolates, partial Node.js compat). Two corrections vs the upstream
> mirror: (1) **`node:fs` IS available** (in-memory filesystem) — the "fs unavailable" claim
> is outdated; (2) generic Cloudflare limits (30 s timeout, WebSockets→Durable Objects) are
> plausible but **not restated at the Expo layer** — verify on Expo Hosting before relying.

## File Structure

Route files use the `+api` suffix, one HTTP method per named export:

```ts
// src/app/hello+api.ts
export function GET(request: Request) {
  return Response.json({ hello: 'world' });
}
```

Dynamic routes use brackets:

```ts
// src/app/blog/[post]+api.ts
export async function GET(request: Request, { post }: Record<string, string>) {
  return Response.json({ post });
}
```

Server features (API routes / server functions) require a **custom server**, deployed to
Expo Hosting or Bun / Express / Netlify / Vercel. SDK 54+ ships the `expo-server` runtime
library with `StatusError`, request metadata, and task-scheduling utilities.

## Requests

```ts
export async function POST(request: Request) {
  const body = await request.json();                 // JSON body
  const url = new URL(request.url);
  return Response.json({ query: url.searchParams.get('q') });
}
```

- **Request body**: `await request.json()`
- **Query params**: `new URL(request.url).searchParams`
- **Method mismatches** return `405`; thrown errors return `500` automatically (SDK 54+).

## Runtime & Limitations (validated for Expo Hosting)

Expo Hosting = **Cloudflare Workers runtime** — V8 isolates, not full Node.js processes.

- **Node.js compat is partial but real** — `node:fs` is supported (in-memory filesystem),
  as are `node:http`/`https` (except server functionality), `node:crypto`, `node:stream`,
  `node:zlib`, `node:test`. Unimplemented: `node:worker_threads`, `node:readline`,
  `node:punycode`.
- **No full Node process**, so heavy CPU/long-running work is unsuitable.
- **WebSockets / persistent connections**: plain API routes are request/response; for
  sockets use Workers Durable Objects semantics — confirm current limits on Expo Hosting.
- `fetch`, `Web Crypto`, `process.env` are available.

### When to AVOID API routes
- **Data already public** — fetch it directly from the client
- **No secrets required** — static data, client-safe ops
- **Real-time updates** — use WebSockets or a service (e.g. Supabase Realtime)
- **Simple CRUD** — consider managed backends (Firebase, Supabase, Convex)

## Environment Variables

Server-side secrets via `process.env` (`EXPO_PUBLIC_*` is NOT required on the server):

```bash
eas env:create --name MY_SECRET --value secret-value --environment production
eas env:list
```

## Databases (edge-appropriate)

Since storage is edge-based, use cloud/edge DBs:
- **Turso** — distributed SQLite
- **Cloudflare D1** — SQLite at the edge
- **PlanetScale / Neon / Supabase** — managed Postgres/SQLite

## Client-side calls

Relative fetch works against the dev-server origin in development. In production, set the
API origin in `app.json` under the `expo-router` plugin config (`origin` field). Use the
configured origin for native calls — do not assume a relative URL works identically across
platforms.

## Custom Domains

Custom-domain assignment is a **dashboard action** (Expo Hosting settings: DNS verify →
SSL → CNAME/A record) and a **premium** feature — not configured in `eas.json`.

## Limitations

- Only use when the task matches this product's scope.
- Verify runtime limits / module support against the current Expo Hosting
  worker-runtime reference (`/eas/hosting/reference/worker-runtime`) — support is
  evolving.
- Do not assume full Node.js API availability on the edge runtime.
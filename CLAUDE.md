# Foundry

AI-native monorepo boilerplate by Devizer. pnpm + Turborepo + Next.js + Express + Supabase + shared TypeScript package.

## Commands

```bash
pnpm dev          # Start all apps (web :3000, server :3001)
pnpm build        # Build all apps
pnpm lint         # Lint all apps
pnpm test         # Run all tests
pnpm format       # Format all files with Prettier
pnpm format:check # Check formatting

# Database
./scripts/generate-types.sh  # Regenerate TypeScript types from Supabase
./scripts/db-reset.sh        # Reset database + seed + regenerate types
./scripts/db-seed.sh         # Seed only

# Secrets (1Password)
pnpm secrets                 # Populate .env files from 1Password

# Setup
./scripts/setup.sh           # First-time setup (install, supabase, types)
./scripts/rename-project.sh <name>  # Rename @foundry → @yourproject
```

## Architecture

```
foundry/
├── apps/
│   ├── web/         @foundry/web     Next.js 15 + Tailwind v4 + Supabase SSR
│   ├── server/      @foundry/server  Express 5 + tsx + Supabase service role
│   ├── supabase/    @foundry/supabase Migrations, seed, email templates
│   └── docs/        @foundry/docs    Mintlify documentation site
├── packages/
│   └── shared/      @foundry/shared  Types, constants (no build step)
└── scripts/                          Setup, DB, rename utilities
```

### Data Flow

```
┌─────────────────────────────────────────────┐
│           DigitalOcean App Platform         │
│  ┌─────────────────┐  ┌──────────────────┐  │
│  │ /  → web        │  │ /backend → server│  │
│  │ (Next.js :3000) │  │ (Express :3001)  │  │
│  └────────┬────────┘  └────────┬─────────┘  │
└───────────┼────────────────────┼────────────┘
            │                    │
       ┌────▼────────────────────▼────┐
       │       Supabase (Cloud)       │
       │  Auth (magic link) + PG+RLS  │
       └──────────────────────────────┘
```

Both web and server connect directly to Supabase. No inter-service communication.

## Patterns

### Add a new page

Create `apps/web/src/app/<route>/page.tsx`:

```tsx
export default function MyPage() {
  return <main className="mx-auto max-w-4xl p-8">...</main>
}
```

For protected pages, add auth check:

```tsx
import { redirect } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'

export default async function ProtectedPage() {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) redirect('/')
  return <main>...</main>
}
```

### Add an API route (Next.js)

Create `apps/web/src/app/api/<route>/route.ts`:

```tsx
import { NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

export async function GET() {
  const supabase = await createClient()
  const { data } = await supabase.from('table').select()
  return NextResponse.json(data)
}
```

### Add an Express route

1. Create `apps/server/src/routes/<name>.ts`:

```tsx
import { Router } from 'express'

export const myRouter = Router()

myRouter.get('/', async (_req, res) => {
  res.json({ data: [] })
})
```

2. Register in `apps/server/src/index.ts`:

```tsx
import { myRouter } from './routes/my-route'
app.use('/my-route', myRouter)
```

### Add a database migration

1. Create SQL file: `apps/supabase/migrations/NNN_description.sql`
2. Write migration SQL (CREATE TABLE, ALTER, etc.)
3. Always add RLS policies for new tables
4. Run: `cd apps/supabase && supabase migration up`
5. Regenerate types: `./scripts/generate-types.sh`

### Add a shared type

1. Add to `packages/shared/src/types.ts`
2. Export from `packages/shared/src/index.ts`
3. Import in apps: `import { MyType } from '@foundry/shared'`

## Conventions

- **TypeScript**: Strict mode, `noUncheckedIndexedAccess` enabled
- **Formatting**: Prettier — 150 char width, single quotes, no semicolons
- **Imports**: Use `@/*` alias in web app (maps to `src/*`). Use `@foundry/shared` for shared code.
- **Components**: Server components by default. Add `'use client'` only when needed (hooks, event handlers, browser APIs).
- **Naming**: kebab-case files, PascalCase components, camelCase functions/variables
- **CSS**: Tailwind v4 utility classes. Custom theme vars in `globals.css` via `@theme inline`. No `tailwind.config.ts` — Tailwind v4 is CSS-first.
- **Error handling**: Use Sentry for error tracking. Error boundaries in `error.tsx` and `global-error.tsx`. Express has global error middleware.
- **Testing**: Vitest for all packages. `jsdom` environment for web tests. Tests live next to source files (`*.test.ts` / `*.test.tsx`).

## Supabase

### Auth flow

```
User clicks "Sign In" → Supabase sends magic link email
  → User clicks link → /auth/callback?code=XXX
  → route.ts exchanges code for session (sets cookie)
  → redirect to /dashboard

Every request → middleware.ts refreshes session cookie
  → If expired, user is unauthenticated (no forced redirect on all pages)
```

### Client usage

- **Browser**: `import { createClient } from '@/lib/supabase/client'` — uses `createBrowserClient` from `@supabase/ssr`
- **Server components / route handlers**: `import { createClient } from '@/lib/supabase/server'` — uses `createServerClient` with cookie handling
- **Express server**: `import { supabase } from './lib/supabase'` — uses service role key (bypasses RLS)

### Adding tables

1. Create migration in `apps/supabase/migrations/`
2. Always enable RLS: `ALTER TABLE public.my_table ENABLE ROW LEVEL SECURITY;`
3. Add policies for SELECT, INSERT, UPDATE, DELETE as needed
4. Run migration: `cd apps/supabase && supabase migration up`
5. Regenerate types: `./scripts/generate-types.sh`

### RLS pattern

```sql
-- Users can only access their own data
CREATE POLICY "Users can view own data" ON public.my_table
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own data" ON public.my_table
  FOR INSERT WITH CHECK (auth.uid() = user_id);
```

## Secrets Management (1Password)

Secrets are managed via [1Password CLI](https://developer.1password.com/docs/cli/get-started) using `.env.tpl` template files. These templates use `op://` references that get resolved to real values at inject time.

### How it works

```
.env.tpl  (committed, contains op:// references)
    ↓  op inject
.env.local / .env  (git-ignored, contains real secrets)
```

- `.env.tpl` files are checked into git — they contain no secrets, only `op://Vault/Item/Field` references
- `.env` / `.env.local` files are git-ignored — they contain the resolved secret values
- The `pnpm secrets` command runs `op inject` on each `.tpl` file to produce the corresponding env file

### Quick start

```bash
# 1. Install the 1Password CLI
brew install 1password-cli

# 2. Sign in (first time only)
op signin

# 3. Populate all env files
pnpm secrets
```

### Template files

| Template | Output | App |
|----------|--------|-----|
| `apps/web/.env.tpl` | `apps/web/.env.local` | Next.js web app |
| `apps/server/.env.tpl` | `apps/server/.env` | Express server |

### 1Password vault setup

Create a vault called **Foundry** (or rename the `op://` references in the `.tpl` files) with these items:

| Item | Fields |
|------|--------|
| **Supabase** | `url`, `anon-key`, `service-role-key` |
| **PostHog** | `public-key`, `personal-api-key`, `project-id` |
| **Sentry** | `web-dsn`, `server-dsn` |

### Manual op commands (for reference)

```bash
# Inject a single template
op inject -i apps/web/.env.tpl -o apps/web/.env.local --force

# Read a single secret
op read "op://Foundry/Supabase/anon-key"

# List items in the Foundry vault
op item list --vault Foundry
```

### Adding new secrets

1. Add the secret to 1Password (in the Foundry vault)
2. Add the `op://` reference to the relevant `.env.tpl` file
3. Add a placeholder to the corresponding `.env.example` file (for non-1Password users)
4. Run `pnpm secrets` to regenerate your local env files

## Deployment

### DigitalOcean App Platform

Configure via `.do/app.yaml.example`:

- **Web**: `pnpm build --filter=@foundry/web`, run `cd apps/web && pnpm start`, port 3000
- **Server**: `pnpm build --filter=@foundry/server`, run `cd apps/server && pnpm start`, port 3001
- **Routing**: `/` → web, `/backend` → server (prefix stripped by DO)
- **Deploy**: Link GitHub repo, auto-deploy on push to main

### Environment variables

Set in DO App Platform dashboard or `.do/app.yaml`:
- Web needs: `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`, `NEXT_PUBLIC_SITE_URL`
- Server needs: `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`, `PORT`, `ALLOWED_ORIGINS`
- Optional: `NEXT_PUBLIC_POSTHOG_KEY`, `NEXT_PUBLIC_SENTRY_DSN`, `SENTRY_DSN`

## Observability

### PostHog (analytics)

- Client-side only via `posthog-js`
- Proxied through `/ingest/*` rewrites in `next.config.ts` (avoids ad blockers)
- Sourcemap upload via `@posthog/nextjs-config` (conditional on `POSTHOG_PERSONAL_API_KEY`)
- Set `NEXT_PUBLIC_POSTHOG_KEY` to enable

### Sentry (error tracking)

- **Web**: `@sentry/nextjs` — client, server, and edge configs
  - `sentry.client.config.ts` — browser error tracking
  - `sentry.server.config.ts` — server-side error tracking
  - `sentry.edge.config.ts` — edge runtime tracking
  - `instrumentation.ts` — hooks into Next.js server instrumentation
  - `error.tsx` + `global-error.tsx` — error boundaries that report to Sentry
- **Server**: `@sentry/node` — Express error handler via `Sentry.setupExpressErrorHandler(app)`
- Set `NEXT_PUBLIC_SENTRY_DSN` (web) and `SENTRY_DSN` (server) to enable

## Common tasks

### First-time setup
```bash
git clone <repo> && cd <repo>
./scripts/setup.sh
cp apps/web/.env.example apps/web/.env.local
cp apps/server/.env.example apps/server/.env
# Fill in env values
pnpm dev
```

### Add a new feature (full stack)
1. Migration: `apps/supabase/migrations/002_my_feature.sql`
2. Run migration + generate types: `./scripts/db-reset.sh`
3. Shared types: update `packages/shared/src/types.ts` if needed
4. Server route: `apps/server/src/routes/my-feature.ts`
5. Web page: `apps/web/src/app/my-feature/page.tsx`
6. Test: add `*.test.ts` files next to implementation

### Customize the project
```bash
./scripts/rename-project.sh myproject
pnpm install
# Update README.md, CLAUDE.md with your project details
```

## Future: JWT Auth for Express

Currently the Express server uses a Supabase service role key (bypasses RLS). For user-scoped requests from the web app to the server:

```typescript
// Web app: pass the user's JWT to the server
const { data: { session } } = await supabase.auth.getSession()
const res = await fetch('/backend/my-route', {
  headers: { Authorization: `Bearer ${session?.access_token}` }
})

// Server: verify the JWT
import { createClient } from '@supabase/supabase-js'
const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)
const { data: { user }, error } = await supabase.auth.getUser(req.headers.authorization?.replace('Bearer ', ''))
```

This pattern lets the server act on behalf of authenticated users with RLS enforced.

## Anti-patterns

- **Don't** use `tailwind.config.ts` — Tailwind v4 is CSS-first, configure via `@theme inline` in `globals.css`
- **Don't** import from `@foundry/shared/src/...` — use `@foundry/shared` (the package export)
- **Don't** use `getSession()` for auth checks — use `getUser()` which validates the JWT server-side
- **Don't** create API routes for things Supabase handles (CRUD with RLS) — use Supabase client directly
- **Don't** put secrets in `NEXT_PUBLIC_*` env vars — those are exposed to the browser
- **Don't** skip RLS on new tables — every table must have `ENABLE ROW LEVEL SECURITY`
- **Don't** use `postcss.config.js` — use `postcss.config.mjs` (ESM)
- **Don't** bundle the Express server — use `tsx` directly in production

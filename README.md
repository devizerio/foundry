# Foundry

The AI-native monorepo boilerplate. Clone, setup, build with Claude Code.

## Stack

- **Frontend**: Next.js 15 + Tailwind CSS v4 + shadcn/ui
- **Backend**: Express 5 + TypeScript (tsx)
- **Database**: Supabase (Postgres + Auth + RLS)
- **Shared**: TypeScript types & constants package
- **Monorepo**: pnpm workspaces + Turborepo
- **Observability**: PostHog (analytics) + Sentry (errors)
- **Deployment**: DigitalOcean App Platform
- **CI**: GitHub Actions (lint + test + build)
- **AI Context**: CLAUDE.md — comprehensive LLM context

## Quick Start

```bash
# Create from template
gh repo create my-project --template devizerio/foundry --clone
cd my-project

# Rename the project
./scripts/rename-project.sh myproject

# Setup (installs deps, starts Supabase, generates types)
./scripts/setup.sh

# Configure environment
cp apps/web/.env.example apps/web/.env.local
cp apps/server/.env.example apps/server/.env

# Start development
pnpm dev
```

Open [http://localhost:3000](http://localhost:3000).

## Architecture

```
foundry/
├── apps/
│   ├── web/         Next.js — frontend + SSR auth
│   ├── server/      Express — API server
│   ├── supabase/    Migrations + config + email templates
│   └── docs/        Mintlify documentation
├── packages/
│   └── shared/      Types + constants (no build step)
├── scripts/         Setup, DB, and rename utilities
├── CLAUDE.md        AI context for Claude Code
└── .github/         CI workflow
```

## What Makes Foundry Different

**CLAUDE.md is a first-class feature.** It gives Claude Code complete context about your project's architecture, conventions, and patterns. Ask Claude to add a page, API route, or database table — it knows exactly how.

## Commands

| Command | Description |
|---------|-------------|
| `pnpm dev` | Start all apps |
| `pnpm build` | Build all apps |
| `pnpm test` | Run all tests |
| `pnpm lint` | Lint all apps |
| `pnpm format` | Format with Prettier |
| `./scripts/setup.sh` | First-time setup |
| `./scripts/rename-project.sh <name>` | Rename the project |
| `./scripts/db-reset.sh` | Reset database + types |
| `./scripts/generate-types.sh` | Regenerate TS types |

## Documentation

See [apps/docs](./apps/docs) for full documentation, or run `cd apps/docs && pnpm dev` for local preview.

## Contributing

1. Fork the repo
2. Create a branch
3. Make changes
4. Run `pnpm lint && pnpm test && pnpm build`
5. Submit a PR

## License

MIT

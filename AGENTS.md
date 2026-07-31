# AGENTS.md

## Cursor Cloud specific instructions

This is a monorepo for **The Couch Is Dirty Podcast** with three components:

- `admin/` — Next.js 15 + React 19 creator dashboard (TypeScript). This is the only component that builds and runs in the Linux cloud environment.
- `ios/` — Native SwiftUI iPhone app. Requires macOS + Xcode and **cannot be built or run in this Linux environment**.
- `supabase/` — Postgres schema, RLS policies, and Deno Edge Functions. `supabase start` (local stack) requires Docker + the Supabase CLI, neither of which is preinstalled here. The migrations under `supabase/migrations/` are plain SQL and the RSS-sync function lives in `supabase/functions/rss-sync/`.

### Admin dashboard (`admin/`) — primary runnable app

- Dev server: `npm run dev --prefix admin` (serves on http://localhost:3000). Standard scripts are in `admin/package.json`.
- Type check: `npm run typecheck --prefix admin` (`tsc --noEmit`). This is the reliable static check.
- Build: `npm run build --prefix admin`.
- The dashboard homepage renders **without a live Supabase backend** — it shows placeholder KPIs and a static RSS Sync panel. Supabase env vars are only needed for auth/data features that are not yet wired into the homepage, so placeholder values in `admin/.env.local` (copied from `admin/.env.example`) are sufficient to run the dev server.

### Gotchas

- `npm run lint` (`next lint`) is **not usable non-interactively**: no ESLint config is committed, so it prompts to create one and hangs. Use `npm run typecheck` (and `npm run build`, which also validates types) for verification instead of `lint`.
- `admin/.env.local` is gitignored and not committed; recreate it from `admin/.env.example` if missing.

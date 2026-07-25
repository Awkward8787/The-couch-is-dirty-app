# Setup Guide

## 1. Clone and Configure

```bash
git clone <repo-url>
cd "The Couch is Dirty podcast app"
```

## 2. Supabase Project

### Create Project

Project ref: `zqbkznmwyvulxbzwsgea`  
API URL: `https://zqbkznmwyvulxbzwsgea.supabase.co`

> **Note:** The project URL must match your JWT `ref` claim. If your dashboard shows a different hostname, use the URL from **Project Settings → API**.

### Apply Migrations

**Option A — Supabase Dashboard (recommended)**

1. Open [Supabase SQL Editor](https://supabase.com/dashboard/project/zqbkznmwyvulxbzwsgea/sql/new)
2. Paste and run each file in order:
   - `supabase/migrations/20260725000001_initial_schema.sql`
   - `supabase/migrations/20260725000002_rls_policies.sql`
   - `supabase/migrations/20260725000003_storage_and_seed.sql`
   - `supabase/migrations/20260725000004_seed_rss_source.sql`

### Official RSS Feed

```
https://media.rss.com/the-couch-is-dirty-podcast/feed.xml
```

Migration `20260725000004_seed_rss_source.sql` registers this feed automatically. The feed currently contains **8 episodes** (Season 1, explicit, hosted on RSS.com).

After migrations, trigger a sync:

```bash
supabase functions deploy rss-sync
curl -X POST "https://zqbkznmwyvulxbzwsgea.supabase.co/functions/v1/rss-sync" \
  -H "Authorization: Bearer YOUR_SERVICE_ROLE_OR_ADMIN_JWT" \
  -H "Content-Type: application/json" \
  -d '{"manual": true}'
```

**Option B — CLI** (requires `supabase login` with project access)

```bash
cd supabase
cp .env.example .env   # fill in values
supabase link --project-ref zqbkznmwyvulxbzwsgea
supabase db push
```

### Migrations

Migrations run in order:

1. `20260725000001_initial_schema.sql` — tables, types, triggers
2. `20260725000002_rls_policies.sql` — RLS on all tables
3. `20260725000003_storage_and_seed.sql` — storage buckets, account deletion

### Deploy Edge Functions

```bash
supabase functions deploy rss-sync
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

Schedule RSS sync via Supabase Dashboard → Database → Extensions → pg_cron, or external cron hitting the function.

### Create First Admin

After signing up via the app or Supabase Auth:

```sql
update public.profiles
set role = 'admin'
where id = '<your-user-uuid>';
```

### Insert RSS Source

Already handled by migration `20260725000004_seed_rss_source.sql`:

```
https://media.rss.com/the-couch-is-dirty-podcast/feed.xml
```

## 3. Admin Dashboard

```bash
cd admin
cp .env.example .env.local
npm install
npm run dev
```

Deploy to Vercel:

```bash
vercel --prod
```

Set environment variables in Vercel dashboard matching `.env.example`.

## 4. iOS App

### Open Project

```bash
open ios/TCIDPodcast.xcodeproj
```

### Configure

1. Select **TCIDPodcast** target → Signing & Capabilities
2. Team: your Apple Developer team
3. Bundle Identifier: `com.tcidpodcast.app`
4. Add capabilities:
   - Sign in with Apple
   - Background Modes → Audio
   - Push Notifications (optional, for community alerts)

### Supabase Keys

Add to build settings (User-Defined):

| Key | Value |
|-----|-------|
| `SUPABASE_URL` | Your Supabase URL |
| `SUPABASE_ANON_KEY` | Your anon key |

Or create `ios/Config.xcconfig` (gitignored) from `.env.example`.

### Build & Run

Select iPhone simulator → Run (⌘R)

```bash
xcodebuild -project ios/TCIDPodcast.xcodeproj \
  -scheme TCIDPodcast \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build
```

## 5. Apple Developer Setup

1. Register App ID: `com.tcidpodcast.app`
2. Enable Sign in with Apple
3. Create APNs key for push notifications
4. Configure App Store Connect listing (see `docs/app-store/`)

## 6. Legal Pages (Required for App Review)

Host at tcidpodcast.com:

- `/privacy` — Privacy Policy
- `/terms` — Terms of Use
- `/community-guidelines` — Community Guidelines
- `/support` — Support contact

Update URLs in `app_settings` table if different.

## 7. App Review Demo Account

Create a test user with known credentials for Apple reviewers:

```sql
-- After user signs up
update public.profiles set role = 'user' where username = 'appreview';
```

Document credentials in App Store Connect Review Notes (not in git).

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Migrations fail on storage | Ensure storage extension enabled |
| RLS blocks reads | Verify episode `status = 'published'` |
| iOS build duplicate @main | Only `App/TCIDPodcastApp.swift` should have @main |
| Admin 401 | Check `ADMIN_ALLOWED_EMAILS` matches signed-in email |

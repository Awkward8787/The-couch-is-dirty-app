# Setup Guide

## 1. Clone and configure

```bash
git clone <repo-url>
cd "The Couch is Dirty podcast app"
```

## 2. Appwrite (backend)

| Setting | Value |
|---------|--------|
| Endpoint | `https://api.tcidpodcast.com/v1` |
| Project ID | `tcidpodcast` |
| Database ID | `tcid` (verify in Console) |

### Console tasks

1. Register Apple platform: bundle ID **`com.tcidpodcast.app`**
2. Verify collections: `episodes`, `profiles`, `posts`, `post_comments`, etc.
3. Configure **Teams** for RBAC: `members`, `moderators`, `admins`
4. Set collection permissions (see `docs/ios/FEED_SETUP.md`)

### Seed episodes (optional)

```bash
# Requires temporary API key — see docs/ios/SEED_EPISODES.md
python3 scripts/seed_appwrite_episodes.py
```

### Official RSS feed

```
https://media.rss.com/the-couch-is-dirty-podcast/feed.xml
```

## 3. Admin dashboard

```bash
cd admin
cp .env.example .env.local   # Appwrite endpoint, project ID, admin emails
npm install
npm run dev
```

Deploy to Vercel with the same Appwrite env vars from `.env.example`.

**Administrator access:** Sign in with Appwrite Account **`Anthony@vibevirtue.com`** (password set in Appwrite Console). That email must appear in `ADMIN_ALLOWED_EMAILS` and belong to the **`admins`** team.

## 4. iOS app

```bash
open Tcidapp.xcworkspace
```

1. **Signing:** Team + bundle ID `com.tcidpodcast.app`
2. **Secrets:** copy `ios/TCIDPodcast/Resources/Secrets.plist.example` → `Secrets.plist`
3. Build & run on simulator or device

See [docs/ios/APPWRITE_SETUP.md](./ios/APPWRITE_SETUP.md) for full iOS setup.

## Environment variables

### iOS (`Secrets.plist` — gitignored)

| Key | Example |
|-----|---------|
| `APPWRITE_ENDPOINT` | `https://api.tcidpodcast.com/v1` |
| `APPWRITE_PROJECT_ID` | `tcidpodcast` |
| `APPWRITE_DATABASE_ID` | `tcid` |

### Admin (`.env.local` — gitignored)

| Key | Purpose |
|-----|---------|
| `APPWRITE_ENDPOINT` | API base URL |
| `APPWRITE_PROJECT_ID` | Project ID |
| `APPWRITE_API_KEY` | Server-only key (Console) |
| `ADMIN_ALLOWED_EMAILS` | Comma-separated admin emails (e.g. `Anthony@vibevirtue.com`) |

## Troubleshooting

| Issue | Fix |
|-------|-----|
| iOS auth 401 | Register `com.tcidpodcast.app` as Apple platform in Appwrite |
| Empty episodes | Publish docs with `status = published` or run seed script |
| Feed empty | Run `scripts/setup_appwrite_feed.py` (see FEED_SETUP.md) |
| Admin 401 | Email must be in `ADMIN_ALLOWED_EMAILS` + `admins` team |

## Legal pages

Host at tcidpodcast.com:

- `/privacy`
- `/terms`
- `/community-guidelines`

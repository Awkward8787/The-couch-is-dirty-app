# Architecture — The Couch Is Dirty Podcast

## Overview

Three-tier monorepo: native iOS client, Next.js admin dashboard, Supabase backend.

```
┌─────────────────┐     HTTPS      ┌──────────────────┐
│  iOS App        │◄──────────────►│  Supabase        │
│  SwiftUI/MVVM   │                │  Postgres + Auth │
│  AVFoundation   │                │  Storage + Edge  │
└─────────────────┘                └────────┬─────────┘
                                          │
┌─────────────────┐     HTTPS             │
│  Admin Dashboard│◄──────────────────────┘
│  Next.js/Vercel │
└─────────────────┘
```

## iOS (`/ios`)

### Architecture: MVVM

| Layer | Responsibility |
|-------|----------------|
| **Views** | SwiftUI UI, accessibility, navigation |
| **ViewModels** | `@Observable`, async state, user actions |
| **Services** | Supabase API, audio engine, Keychain |
| **Models** | Codable types mirroring Postgres schema |

### Key Services (planned)

- `AuthService` — Sign in with Apple, email OTP, session
- `EpisodeService` — List, search, save, download
- `AudioPlayerService` — AVPlayer, MPNowPlayingInfoCenter, background
- `CommunityService` — Posts, comments, reactions
- `NotificationService` — APNs registration, preferences

### Audio Pipeline

```
Episode audio URL → AVPlayer → MPNowPlayingInfoCenter
                              → MPRemoteCommandCenter
                              → Background task + interruption handling
                              → listening_progress sync (authenticated)
```

Guest users listen without auth; progress stored locally until sign-in.

## Admin (`/admin`)

- Next.js 15 App Router, TypeScript
- Supabase SSR auth with admin email allowlist
- Server actions for episode upload, RSS trigger, moderation
- Deployed to Vercel; env vars from `.env.local`

## Supabase (`/supabase`)

### Tables

| Table | Purpose |
|-------|---------|
| `profiles` | User profile, role, notification prefs, account status |
| `episodes` | Podcast episodes (RSS + manual) |
| `episode_chapters` | Timestamped chapters |
| `listening_progress` | Playback position per user |
| `saved_episodes` | User bookmarks |
| `episode_downloads` | Offline download records |
| `community_posts` | Discussions, questions |
| `comments` | Threaded replies |
| `reactions` | Likes on posts/comments |
| `reports` | User content reports |
| `blocked_users` | User blocks |
| `moderation_actions` | Audit log |
| `notifications` | In-app notifications |
| `rss_sources` | Feed configuration |
| `rss_sync_logs` | Sync history |
| `device_push_tokens` | APNs tokens |
| `app_settings` | Public config (URLs, rate limits) |
| `episode_plays` | Privacy-friendly analytics |
| `prohibited_words` | Profanity filter list |

### Edge Functions

| Function | Trigger | Purpose |
|----------|---------|---------|
| `rss-sync` | Cron + manual | Parse RSS, dedupe GUID, import episodes |
| `send-push` | Admin action | APNs notifications |

### RLS Model

- **Anonymous/guest:** Read published episodes and chapters only
- **Authenticated user:** Own profile, progress, saves, community CRUD (own content)
- **Moderator:** Review reports, remove content, warn/suspend
- **Admin:** Episodes, RSS, storage, moderation, analytics

Helper functions: `is_admin()`, `is_admin_only()`, `is_account_active()`, `is_blocked()`.

## Authentication Flow

1. **Guest** — Browse and play episodes without account
2. **Community** — Requires account (13+ age gate, guidelines acceptance)
3. **Sign in with Apple** — Primary OAuth via Supabase Auth
4. **Email OTP** — Magic link / one-time code via Supabase Auth
5. **Admin** — Same auth + email in `ADMIN_ALLOWED_EMAILS` + `profiles.role = admin`

## RSS Sync Flow

```
Admin sets feed URL → rss_sources
Cron / manual → rss-sync Edge Function
  → Fetch HTTPS feed
  → Parse title, artwork, items
  → Upsert by rss_guid
  → Skip manually_edited_fields
  → Log to rss_sync_logs
```

## Community Moderation Flow

```
User reports content → reports (pending)
Admin reviews → moderation_actions (audit)
  → remove_content / warn / suspend / ban
Reporter notified → notifications
```

## Security

- HTTPS only; no hardcoded secrets
- Keychain for iOS tokens
- Server-side authorization via RLS
- Rate limiting on posts (`post_rate_limits`)
- Content hash duplicate detection
- Input validation (Zod admin, Swift + server)
- Account deletion via `delete_user_account()` RPC

## Deployment

| Component | Target |
|-----------|--------|
| iOS | App Store / TestFlight |
| Admin | Vercel |
| Supabase | Supabase Cloud (must be live for App Review) |
| Legal pages | tcidpodcast.com |

## Design System

- Background: `#000000`
- Cards: `#1C1C1E`
- Text: `#FFFFFF` / `#8E8E93`
- Accent: `#EB1C24` (tabs, progress, badges, primary actions only)
- SF Symbols, Dynamic Type, 44pt touch targets

Reference mockups: `docs/design-reference/`

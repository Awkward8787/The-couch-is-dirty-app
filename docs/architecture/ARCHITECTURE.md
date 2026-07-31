# Architecture — The Couch Is Dirty Podcast

## Overview

Three-tier monorepo: native iOS client, Next.js admin dashboard, **Appwrite** backend (self-hosted).

```
┌─────────────────┐     HTTPS      ┌──────────────────┐
│  iOS App        │◄──────────────►│  Appwrite        │
│  SwiftUI/MVVM   │                │  Auth + Databases│
│  AVFoundation   │                │  Storage + Teams │
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
| **ViewModels / @Observable stores** | Async state, user actions |
| **Services** | Appwrite SDK, audio engine, feed realtime |
| **Models** | Codable types aligned with Appwrite collections |

### Key services

- `AuthService` — Appwrite Account sessions, Teams-based roles
- `EpisodeService` / `EpisodeCatalog` — Published episodes from Appwrite
- `FeedService` / `FeedStore` — Home social feed + realtime
- `AudioPlayerService` — AVPlayer, Lock Screen, background audio

### Audio pipeline

```
Episode audio URL → AVPlayer → MPNowPlayingInfoCenter
                              → MPRemoteCommandCenter
                              → Background task + interruption handling
                              → listening progress (authenticated, planned)
```

Guest users listen without auth; community posting requires sign-in.

## Admin (`/admin`)

- Next.js 15 App Router, TypeScript
- **Appwrite** server SDK (Phase 7) with admin email allowlist
- Episode upload, RSS trigger, moderation (planned)
- Deployed to Vercel; env vars from `.env.local`

## Appwrite

Endpoint: `https://api.tcidpodcast.com/v1` · Project: `tcidpodcast`

### Collections (primary)

| Collection | Purpose |
|------------|---------|
| `profiles` | User profile, role, account status |
| `episodes` | Podcast episodes (RSS + manual) |
| `posts` | Home social feed |
| `post_comments` | Feed comments |
| `guest_applications` | Be a Guest applications |
| `favorite_episodes` | User bookmarks |

See `docs/ios/FEED_SETUP.md` and setup scripts under `scripts/`.

### Storage buckets

| Bucket | Purpose |
|--------|---------|
| `avatars` | Profile avatars |
| `episode-images` | Cover art |
| `post-images` | Feed attachments |
| `guest-uploads` | Guest application files |

### RBAC (Teams + permissions)

| Team ID | Purpose |
|---------|---------|
| `members` | Member-only features |
| `moderators` | Moderation tools |
| `admins` | Administrator (sole owner: Silk Bone Jones) |

iOS resolves roles from Appwrite Teams in `AuthService`. **Collection permissions in Appwrite Console are the security boundary** — client checks are UX only.

## Authentication flow

1. **Guest listener** — Browse and play episodes without account
2. **Signed-in user** — Appwrite email/password; default team → `user`
3. **Member / moderator / admin** — Appwrite Teams membership
4. **Admin dashboard** — Appwrite Account + `ADMIN_ALLOWED_EMAILS` + `admins` team

## RSS / episodes

Episodes imported via `scripts/seed_appwrite_episodes.py` or admin tools (planned). Official feed:

`https://media.rss.com/the-couch-is-dirty-podcast/feed.xml`

## Community / feed

Home tab: Be a Guest + composer + `posts` collection with Appwrite Realtime.

Community tab: episode discussions (planned); roles displayed from Teams.

## Security

- HTTPS only; no API keys in the iOS app
- Appwrite collection + storage permissions
- Server API keys only in admin `.env.local` (never commit)
- Input validation (Zod admin, Swift + Appwrite rules)

## Deployment

| Component | Target |
|-----------|--------|
| iOS | App Store / TestFlight |
| Admin | Vercel |
| Backend | Self-hosted Appwrite (`api.tcidpodcast.com`) |
| Legal pages | tcidpodcast.com |

## Design system

- Background: `#000000`
- Cards: `#1C1C1E`
- Text: `#FFFFFF` / `#8E8E93`
- Accent: `#EB1C24`
- SF Symbols, Dynamic Type, 44pt touch targets

Reference mockups: `docs/design-reference/`

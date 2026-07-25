# Project Status

**Last updated:** 2026-07-25  
**Current phase:** 2 complete → ready for Phase 3 (Authentication)

## Completed (Phase 1)

- [x] Monorepo structure (`ios/`, `admin/`, `supabase/`, `docs/`)
- [x] PostgreSQL schema — 16+ tables with indexes and constraints
- [x] Row Level Security policies on all tables
- [x] Storage buckets and policies (audio, covers, avatars)
- [x] Account deletion function (GDPR-style)
- [x] RSS sync Edge Function (parse, dedupe by GUID, preserve manual edits)
- [x] iOS project relocated to `ios/TCIDPodcast.xcodeproj`
- [x] Bundle ID set to `com.tcidpodcast.app`, deployment target iOS 18
- [x] iOS MVVM folder structure, design tokens, onboarding shell
- [x] Domain models aligned with Supabase schema
- [x] `PrivacyInfo.xcprivacy` stub
- [x] Admin Next.js scaffold with Supabase client helper
- [x] `.env.example` files for all packages
- [x] Design reference mockups copied to `docs/design-reference/`
- [x] README and architecture documentation

## Remaining Work

### Phase 2 — Design System ✅
- [x] Branded components (header, cards, chips, progress, play button)
- [x] Now Playing card, episode rows, mini player
- [x] Community discussion and comment cards
- [x] Home, Episodes, Community, Profile tab screens
- [x] Mock data service with seeded preview content
- [x] Supabase credentials configured (gitignored Secrets.plist, .env.local)
- [x] iOS build verified

### Phase 3 — Auth
- Sign in with Apple
- Email OTP via Supabase Auth
- Guest listening (no account required)
- Keychain session storage

### Phase 4 — Episodes & RSS
- Supabase episode service
- Episode list with filters, search, pull-to-refresh
- RSS manual refresh trigger

### Phase 5 — Audio Player
- AVFoundation + MediaPlayer
- Background audio, Lock Screen, Control Center
- Progress persistence

### Phase 6 — Community
- Posts, comments, reactions
- Moderation, reporting, blocking
- Profanity filter, rate limits

### Phase 7 — Admin Dashboard
- Full dashboard per mockup
- Upload, RSS sync UI, moderation queue

### Phase 8 — Privacy & Accessibility
- Legal pages live at tcidpodcast.com
- VoiceOver, Dynamic Type, Reduce Motion

### Phase 9 — Tests
- Unit, UI, RLS integration tests

### Phase 10 — App Store
- TestFlight build, submission checklist

## Blockers

| Blocker | Resolution |
|---------|------------|
| Supabase migrations not applied | Run SQL in Dashboard → SQL Editor (see docs/SETUP.md) |
| Official podcast RSS URL | ✅ `media.rss.com/the-couch-is-dirty-podcast/feed.xml` (8 episodes) |
| Sign in with Apple capability | Enable in Apple Developer portal for `com.tcidpodcast.app` |
| App icon 1024×1024 | Export from logo asset for App Store |

## Next Command

```bash
# Apply Supabase migrations (Dashboard → SQL Editor, paste each migration file)
# Then Phase 3:
open ios/TCIDPodcast.xcodeproj
```

## Verification Checklist (Phase 1)

- [ ] `supabase db reset` applies all migrations without error (requires Supabase CLI + project)
- [x] iOS project builds in Xcode without warnings (`BUILD SUCCEEDED`)
- [x] `admin/npm run build` succeeds after `npm install`
- [x] No secrets committed to git

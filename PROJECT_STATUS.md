# Project Status

**Last updated:** 2026-07-31  
**Current phase:** Appwrite integration + auth/RBAC in progress

## Completed

- [x] Monorepo structure (`ios/`, `admin/`, `docs/`)
- [x] Appwrite backend (self-hosted `api.tcidpodcast.com`, project `tcidpodcast`)
- [x] iOS Appwrite SDK — episodes, feed, auth, Teams RBAC
- [x] iOS project: `Tcidapp.xcworkspace` / `TCIDPodcast`
- [x] Bundle ID `com.tcidpodcast.app`, deployment target iOS 18
- [x] SwiftUI design system, four-tab shell
- [x] Home live feed (posts + realtime), Episodes, Community, Profile
- [x] Audio playback + mini player
- [x] Admin Next.js scaffold (Appwrite env template)
- [x] `.env.example` / `Secrets.plist.example` templates
- [x] README and architecture documentation

## In progress

### Auth & RBAC (Appwrite)
- [x] Email/password sign-in via Appwrite Account
- [x] Session restore on launch
- [x] Teams-based roles (`guest`, `user`, `member`, `moderator`, `admin`)
- [ ] Sole administrator enforcement (Silk Bone Jones) in Appwrite Teams
- [ ] Guest browse mode synced to Appwrite profile
- [ ] Collection permissions aligned with role rules

### Episodes & feed
- [x] Episode list from Appwrite (+ mock fallback)
- [x] Home feed from Appwrite `posts`
- [ ] RSS sync automation (script / admin UI)

## Remaining work

### Phase 7 — Admin dashboard (Appwrite)
- Appwrite server auth for admin
- Upload, moderation queue, RSS sync UI

### Phase 8 — Privacy & accessibility
- Legal pages at tcidpodcast.com
- VoiceOver, Dynamic Type, Reduce Motion

### Phase 9 — Tests
- Unit, UI, Appwrite permission integration tests

### Phase 10 — App Store
- TestFlight, submission checklist

## Blockers

| Blocker | Resolution |
|---------|------------|
| Appwrite collection permissions | Configure in Console (see `docs/ios/FEED_SETUP.md`) |
| Official RSS URL | ✅ `media.rss.com/the-couch-is-dirty-podcast/feed.xml` |
| Sign in with Apple | Enable capability + Appwrite OAuth (planned) |
| Admin dashboard auth | Wire Appwrite in `admin/` (Phase 7) |

## Next command

```bash
open Tcidapp.xcworkspace
```

## Verification checklist

- [x] iOS simulator build succeeds
- [x] iOS device build succeeds (`CFBundleIdentifier` valid)
- [x] Single backend only (Appwrite) — legacy SQL backend removed from repo
- [ ] Appwrite `admins` team contains only Silk Bone Jones
- [x] `admin/npm run build` succeeds after `npm install`

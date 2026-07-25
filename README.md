# The Couch Is Dirty Podcast

Production-ready monorepo for the **The Couch Is Dirty Podcast** iPhone app, creator admin dashboard, and Supabase backend.

| Property | Value |
|----------|-------|
| App name | The Couch Is Dirty Podcast |
| Bundle ID | `com.tcidpodcast.app` |
| Domain | [tcidpodcast.com](https://tcidpodcast.com) |
| Min iOS | 18.0 |
| Architecture | SwiftUI MVVM + Next.js + Supabase |

## Repository Structure

```
├── ios/                  Native SwiftUI iPhone app (MVVM)
├── admin/                Next.js creator dashboard (Vercel)
├── supabase/             PostgreSQL schema, RLS, Edge Functions
├── docs/                 Architecture, setup, legal, App Store
└── PROJECT_STATUS.md     Current phase, blockers, next command
```

## Quick Start

### Prerequisites

- Xcode 26+ with iOS 26 SDK (deployment target iOS 18)
- Node.js 20+
- [Supabase CLI](https://supabase.com/docs/guides/cli)
- Apple Developer account (for Sign in with Apple, TestFlight)

### 1. Supabase

```bash
cd supabase
cp .env.example .env   # fill in values
supabase start         # local stack
supabase db reset      # apply migrations
```

### 2. Admin Dashboard

```bash
cd admin
cp .env.example .env.local
npm install
npm run dev
```

Open [http://localhost:3000](http://localhost:3000)

### 3. iOS App

```bash
open ios/TCIDPodcast.xcodeproj
```

Configure Supabase URL and anon key in Xcode build settings (`SUPABASE_URL`, `SUPABASE_ANON_KEY`).

## Execution Phases

| Phase | Scope | Status |
|-------|-------|--------|
| 1 | Architecture, database, setup docs | ✅ Complete |
| 2 | SwiftUI design system | ✅ Complete |
| 3 | Authentication & guest listening | **Next** |
| 4 | Episodes & RSS | Pending |
| 5 | Audio player | Pending |
| 6 | Community & moderation | Pending |
| 7 | Creator dashboard | Pending |
| 8 | Privacy, security, accessibility | Pending |
| 9 | Tests | Pending |
| 10 | TestFlight & App Store checklist | Pending |

See [PROJECT_STATUS.md](./PROJECT_STATUS.md) for detailed progress.

## Documentation

- [Architecture](./docs/architecture/ARCHITECTURE.md)
- [Setup Guide](./docs/SETUP.md)
- [App Store Checklist](./docs/app-store/APP_STORE_CHECKLIST.md)

## Security

- No secrets in git — use `.env.example` templates
- Row Level Security on every Supabase table
- HTTPS-only networking
- Keychain token storage (iOS)
- Sign in with Apple + email OTP

## License

Proprietary — The Couch Is Dirty Podcast / tcidpodcast.com

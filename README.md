# The Couch Is Dirty Podcast

Production-ready monorepo for **The Couch Is Dirty Podcast** iPhone app, creator admin dashboard, and **Appwrite** backend.

| Property | Value |
|----------|-------|
| App name | The Couch Is Dirty Podcast |
| Bundle ID | `com.tcidpodcast.app` |
| Domain | [tcidpodcast.com](https://tcidpodcast.com) |
| Min iOS | 18.0 |
| Architecture | SwiftUI MVVM + Next.js + Appwrite |

## Repository Structure

```
├── ios/                  Native SwiftUI iPhone app (MVVM)
├── admin/                Next.js creator dashboard (Vercel)
├── docs/                 Architecture, setup, Appwrite, App Store
└── PROJECT_STATUS.md     Current phase, blockers, next command
```

## Quick Start

### Prerequisites

- Xcode 26+ with iOS 26 SDK (deployment target iOS 18)
- Node.js 20+
- Apple Developer account (for Sign in with Apple, TestFlight)
- Appwrite Console access for project **`tcidpodcast`**

### 1. Appwrite backend

Self-hosted endpoint: `https://api.tcidpodcast.com/v1`

See [docs/ios/APPWRITE_SETUP.md](./docs/ios/APPWRITE_SETUP.md) and [docs/SETUP.md](./docs/SETUP.md).

### 2. Admin dashboard

```bash
cd admin
cp .env.example .env.local
npm install
npm run dev
```

Open [http://localhost:3001](http://localhost:3001)

### 3. iOS app

```bash
open Tcidapp.xcworkspace
```

Copy `ios/TCIDPodcast/Resources/Secrets.plist.example` → `Secrets.plist` with Appwrite endpoint and project ID (no API keys in the app).

## Execution Phases

| Phase | Scope | Status |
|-------|-------|--------|
| 1 | Architecture, Appwrite schema, setup docs | ✅ Complete |
| 2 | SwiftUI design system | ✅ Complete |
| 3 | Authentication & guest listening | In progress |
| 4 | Episodes & RSS | In progress |
| 5 | Audio player | Pending |
| 6 | Community & moderation | Pending |
| 7 | Creator dashboard (Appwrite) | Pending |
| 8 | Privacy, security, accessibility | Pending |
| 9 | Tests | Pending |
| 10 | TestFlight & App Store checklist | Pending |

See [PROJECT_STATUS.md](./PROJECT_STATUS.md) for detailed progress.

## Documentation

- [Architecture](./docs/architecture/ARCHITECTURE.md)
- [Setup Guide](./docs/SETUP.md)
- [Appwrite iOS Setup](./docs/ios/APPWRITE_SETUP.md)
- [App Store Checklist](./docs/app-store/APP_STORE_CHECKLIST.md)

## Security

- No secrets in git — use `.env.example` / `Secrets.plist.example` templates
- Appwrite collection permissions + Teams for RBAC
- HTTPS-only networking
- Appwrite Account sessions on iOS (no API keys in the client)

## License

Proprietary — The Couch Is Dirty Podcast / tcidpodcast.com

# Automate Appwrite from Cursor

Use a **temporary server API key** so Cursor (or you) can create collections, buckets, and seed data without clicking every Console field.

## Safe handoff (recommended)

Do **not** paste the key into chat if you can avoid it. Prefer an environment variable in the agent terminal / secrets.

### 1. Create a temporary API key

1. Open Appwrite Console → project **tcidpodcast**
2. **Overview** / **Settings** → **API Keys** → **Create API Key**
3. Fill in:
   - **Name:** `temp-cursor-feed` (or `temp-rss-seed`)
   - **Expire:** **1 hour** (shortest you can)
   - **Scopes** (only what you need right now):

| Task | Scopes |
|------|--------|
| Feed setup (`posts` + `post-images`) | `databases.read`, `databases.write`, `buckets.read`, `buckets.write` |
| RSS episode seed | `databases.read`, `databases.write` |
| Full Cursor automation (same day) | both sets above |

4. Create → **copy the secret once**

### 2. Give Cursor the key (pick one)

**Option A — env var in this workspace (best)**

In the agent / Cloud Agent terminal:

```bash
export APPWRITE_API_KEY='PASTE_KEY_HERE'
export APPWRITE_ENDPOINT='https://api.tcidpodcast.com/v1'
export APPWRITE_PROJECT_ID='tcidpodcast'
export APPWRITE_DATABASE_ID='episodes'
```

Then tell Cursor: *“API key is in APPWRITE_API_KEY — run feed setup.”*

**Option B — paste once in chat**

Say: *“Use this temporary Appwrite API key for feed setup only, then remind me to delete it:”* and paste the key.

Cursor will run scripts with `APPWRITE_API_KEY`. After success, **delete the key** in Console.

### 3. What Cursor can run for you

```bash
# Create posts collection + attributes + post-images bucket
python3 scripts/setup_appwrite_feed.py

# Import RSS episodes (optional / already done once)
python3 scripts/seed_appwrite_episodes.py
```

### 4. Delete the key

Appwrite Console → API Keys → delete **`temp-cursor-feed`**.

Never put this key in the iOS app, `Info.plist`, git, or long-lived Cursor memories.

## How automation works

| Piece | Value |
|-------|--------|
| Endpoint | `https://api.tcidpodcast.com/v1` |
| Auth header | `X-Appwrite-Key: <api key>` |
| Project header | `X-Appwrite-Project: tcidpodcast` |
| Scripts | `scripts/setup_appwrite_feed.py`, `scripts/seed_appwrite_episodes.py` |

The iOS app only uses the **public** endpoint + project ID (no API key). User sessions use email/password.

## Optional: keep a Cursor secret for the project

If your Cursor Cloud environment supports secrets, store:

- `APPWRITE_API_KEY` — temporary only; rotate often
- or better: create a dedicated short-lived key per task

Long-term automation without pasting keys each time = short-lived keys + env secrets, not committing keys to the repo.

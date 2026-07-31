# Automate Appwrite from Cursor

Use a **temporary server API key** so Cursor can create collections, buckets, seed data, and fix schema without clicking every Console field.

## 1-hour Cursor session key (use this)

Create **one** key for this hour with the scopes below. That covers feed setup **and** follow-up changes (attributes, buckets, teams/roles, users, reseeding).

### Create the key

1. Appwrite Console → project **tcidpodcast**
2. **API Keys** → **Create API Key**
3. Fill in:
   - **Name:** `temp-cursor-1h`
   - **Expire:** **1 hour**
4. Enable these **scopes** (check every box in this list):

| Scope | Why we need it this hour |
|-------|---------------------------|
| `databases.read` | Inspect collections / attributes / documents |
| `databases.write` | Create `posts`, attributes, indexes, seed docs |
| `buckets.read` | Inspect storage buckets |
| `buckets.write` | Create / update `post-images` (and other buckets) |
| `files.read` | Verify uploaded post images / artwork |
| `files.write` | Seed or fix files if needed |
| `users.read` | Debug sign-in / author IDs |
| `users.write` | Fix test users if needed (optional but handy) |
| `teams.read` | Inspect `members` / `moderators` / `admins` for roles |
| `teams.write` | Add you to a team so Feed posts get the right badge |

If your Console groups scopes (e.g. “Databases”, “Storage”, “Users”, “Teams”), turn **read + write** on for each of those four groups.

5. Create → **copy the secret once**

### Do **not** enable (unless we ask later)

- `functions.*` — not used yet  
- `messaging.*` / push — not in v1  
- `sites.*` / `vcs.*` — unrelated  
- Anything labeled “full access” / `*` if a narrower list works — prefer the table above  

---

## Hand the key to Cursor

**Option A — env var (best)**

```bash
export APPWRITE_API_KEY='PASTE_KEY_HERE'
export APPWRITE_ENDPOINT='https://api.tcidpodcast.com/v1'
export APPWRITE_PROJECT_ID='tcidpodcast'
export APPWRITE_DATABASE_ID='episodes'
```

Then say: *“API key is exported — run feed setup.”*

**Option B — paste once in chat**

Say: *“Use this `temp-cursor-1h` key for this hour, then remind me to delete it:”* and paste the secret.

---

## What Cursor can run

```bash
# Create posts collection + attributes + post-images bucket
python3 scripts/setup_appwrite_feed.py

# Re-import RSS episodes if needed
python3 scripts/seed_appwrite_episodes.py
```

After the hour (or when we’re done): Console → API Keys → delete **`temp-cursor-1h`**.

Never put this key in the iOS app, `Info.plist`, or git.

## How automation works

| Piece | Value |
|-------|--------|
| Endpoint | `https://api.tcidpodcast.com/v1` |
| Auth | `X-Appwrite-Key: <api key>` |
| Project | `X-Appwrite-Project: tcidpodcast` |
| Scripts | `scripts/setup_appwrite_feed.py`, `scripts/seed_appwrite_episodes.py` |

The iOS app only uses the public endpoint + project ID (no API key).

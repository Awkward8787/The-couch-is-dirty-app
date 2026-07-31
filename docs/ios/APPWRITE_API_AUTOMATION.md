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

### Recommended: Cursor Secrets tab (persistent across runs)

Agents **cannot** create dashboard secrets for you. Add them here:

1. Open [cursor.com/dashboard/cloud-agents](https://cursor.com/dashboard/cloud-agents)
2. Open **Environments** (or the **Secrets** tab)
3. Select the environment used for **The-couch-is-dirty-app** (create one if this repo has none yet)
4. Add secrets (prefer **Runtime Secret** so values stay redacted in chat):

| Name | Value | Type |
|------|-------|------|
| `APPWRITE_API_KEY` | your `temp-cursor-1h` (or rotated) secret | Runtime Secret |
| `APPWRITE_ENDPOINT` | `https://api.tcidpodcast.com/v1` | Environment Variable |
| `APPWRITE_PROJECT_ID` | `tcidpodcast` | Environment Variable |
| `APPWRITE_DATABASE_ID` | `episodes` | Environment Variable |

5. Save → start a **new** Cloud Agent run (existing runs won’t pick up new secrets)

Then say: *“Use APPWRITE_API_KEY from env — run feed setup.”*

### Option A — env var in this workspace (current session only)

```bash
export APPWRITE_API_KEY='PASTE_KEY_HERE'
export APPWRITE_ENDPOINT='https://api.tcidpodcast.com/v1'
export APPWRITE_PROJECT_ID='tcidpodcast'
export APPWRITE_DATABASE_ID='episodes'
```

Then say: *“API key is exported — run feed setup.”*

### Option B — paste once in chat

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

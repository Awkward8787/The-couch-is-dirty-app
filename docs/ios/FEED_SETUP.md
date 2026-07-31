# Feed Setup — required for Home to show posts

The Home tab is **only** the live community feed. It stays empty until Appwrite has a `posts` table and `post-images` bucket.

---

## Path A — Automate with Cursor (recommended)

### Step 1 — Create a temporary API key

1. Appwrite Console → project **tcidpodcast**
2. **API Keys** → **Create API Key**
3. Name: `temp-cursor-feed`
4. Expire: **1 hour**
5. Scopes:
   - `databases.read`
   - `databases.write`
   - `buckets.read`
   - `buckets.write`
6. Copy the secret

Details: [APPWRITE_API_AUTOMATION.md](./APPWRITE_API_AUTOMATION.md)

### Step 2 — Hand the key to Cursor

In the agent terminal:

```bash
export APPWRITE_API_KEY='PASTE_YOUR_KEY_HERE'
```

Then tell Cursor: **“API key is exported — run feed setup.”**

Or paste the key once in chat and ask Cursor to run:

```bash
python3 scripts/setup_appwrite_feed.py
```

### Step 3 — Delete the key

Console → API Keys → delete **`temp-cursor-feed`**.

### Step 4 — Test the app

Clean build → Feed tab → sign in → post → pull to refresh.

---

## Path B — Manual Console (click-by-click)

### 1. Create table `posts`

1. Databases → open database ID **`episodes`**
2. **Create table / collection**
3. Name: `Posts`
4. ID: **`posts`** (exact)

**Permissions**

- Read: **Any**
- Create: **Users**
- Update / Delete: **Users**
- Prefer **document security** on (app sets per-post owner rules)

**Attributes** (one by one)

| Key | Type | Required | Size / default |
|-----|------|----------|----------------|
| `author_id` | String | Yes | 64 |
| `author_name` | String | Yes | 120 |
| `author_role` | String | Yes | 32 |
| `body` | String | No | 2000 |
| `link_url` | String | No | 2000 |
| `image_file_id` | String | No | 64 |
| `post_kind` | String | Yes | 16 |
| `like_count` | Integer | No | default `0` |

`author_role` values: `user`, `member`, `moderator`, `admin`  
(from Teams: `members`, `moderators`, `admins`)

### 2. Create bucket `post-images`

1. Storage → Create bucket  
2. Bucket ID: **`post-images`**  
3. Max size: **2MB**  
4. Extensions: `jpg`, `jpeg`, `png`, `webp`  
5. Read: **Any** · Create: **Users**  
6. File security: on (recommended)

---

## Dark logo

`ios/TCIDPodcast/Assets.xcassets/PodcastLogoDark.imageset/`

Used on Enter screen, app header, and launch splash.

## What the app shows

- **Feed:** live user posts only (stored + logged in Appwrite)
- **Community:** role status (no mock feed)
- **Episodes:** Appwrite episodes (not mixed into Feed)

# Seed RSS Episodes into Appwrite

Imports all episodes from the official RSS feed into database/collection `episodes`.

## 1. Create a temporary API key

1. Open Appwrite Console → project **TCID Podcast**
2. Left sidebar → **Overview** (or project settings) → **API Keys**  
   If you don’t see it: click the project name → **Settings** → **API credentials / API Keys**
3. Click **Create API Key**
4. Fill in:
   - **Name:** `temp-rss-seed`
   - **Expire:** pick a short time (1 hour / 1 day)
   - **Scopes:** enable at least:
     - `databases.read`
     - `databases.write`
5. Create the key
6. **Copy the secret key** immediately (you only see it once)

## 2. Run the import

In Terminal, from the project root:

```bash
export APPWRITE_API_KEY='PASTE_YOUR_KEY_HERE'
python3 scripts/seed_appwrite_episodes.py
```

You should see 8 lines like `created:…` or `updated:…` for each episode title.

## 3. Delete the API key

Back in Appwrite Console → API Keys → delete **`temp-rss-seed`**.

Never put this key in the iOS app.

## 4. Refresh the iOS app

Pull down on the Episodes tab (or relaunch). You should see all RSS episodes with playable audio.

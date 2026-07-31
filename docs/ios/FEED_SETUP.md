# Feed Setup — required for Home to show posts

The Home tab is **only** the live community feed. It will stay empty until Appwrite has a `posts` table.

## 1. Create table `posts`

1. Appwrite Console → Databases → open database ID **`episodes`**
2. **Create table**
3. Name: `Posts`
4. Table ID: **`posts`** (type exactly)

### Permissions
- Read: **Any**
- Create: **Users**
- Update / Delete: **Users**

### Attributes (create one by one)

| Key | Type | Required | Size |
|-----|------|----------|------|
| `author_id` | String | Yes | 64 |
| `author_name` | String | Yes | 120 |
| `author_role` | String | Yes | 32 |
| `body` | String | No | 2000 |
| `link_url` | String | No | 2000 |
| `image_file_id` | String | No | 64 |
| `post_kind` | String | Yes | 16 |
| `like_count` | Integer | No | default 0 |

`author_role` values: `user`, `member`, `moderator`, `admin`  
(from Appwrite Teams: `members`, `moderators`, `admins`)

## 2. Create bucket `post-images`

1. Storage → Create bucket  
2. Bucket ID: **`post-images`**  
3. Max size: 2MB  
4. Extensions: jpg, jpeg, png, webp  
5. Read: Any · Create: Users  

## 3. Dark logo in the app

Put your dark logo PNGs in:

`ios/TCIDPodcast/Assets.xcassets/PodcastLogoDark.imageset/`

Used on:
- Enter screen (only logo + “Enter the site”)
- App header (top of every tab)
- Loading splash / launch screen

## 4. What the app shows

- **Feed tab (Home):** live user posts only — text, photo, or video link — stored in Appwrite `posts`, with `author_role` from Teams.
- **Community tab:** role status + links (no fake mock discussions).
- **Episodes tab:** real Appwrite episodes — not mixed into the Feed.

## 5. Test

1. Rebuild app (Clean Build Folder, delete app, ⌘R)  
2. Enter screen shows **PodcastLogoDark** only  
3. Open **Feed** — header uses dark logo  
4. Sign in → post text / photo / video link  
5. Pull to refresh — posts stay stored in Appwrite and show for everyone

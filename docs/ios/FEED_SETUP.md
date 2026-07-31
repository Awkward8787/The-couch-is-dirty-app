# Home Feed Setup (Appwrite)

Storage-safe community feed for the iOS Home tab.

## What users can post

- Short text
- One compressed photo (JPEG, resized, ~1.2MB max)
- Video **links** (YouTube / direct `.mp4`) played **inside the app**
- No video file uploads (protects your server disk)

## 1. Create `posts` table

Appwrite → Databases → database ID **`episodes`** → **Create table**

| Field | Value |
|-------|--------|
| Name | Posts |
| Table ID | `posts` |

### Permissions
- **Read:** Any  
- **Create:** Users  
- **Update/Delete:** Users (document-level also set by the app for the author)

### Attributes

| Key | Type | Required | Size / notes |
|-----|------|----------|--------------|
| `author_id` | String | Yes | 64 |
| `author_name` | String | Yes | 120 |
| `body` | String | No | 2000 |
| `link_url` | String | No | 2000 |
| `image_file_id` | String | No | 64 |
| `post_kind` | String | Yes | 16 (`text`, `link`, `image`) |
| `like_count` | Integer | No | default `0` |

### Index
- Order by `$createdAt` descending (default is fine)

## 2. Create `post-images` bucket

Appwrite → Storage → **Create bucket**

| Field | Value |
|-------|--------|
| Name | Post Images |
| Bucket ID | `post-images` |
| Max file size | 2MB (or lower) |
| Allowed file extensions | `jpg`, `jpeg`, `png`, `webp` |

Permissions:
- **Read:** Any  
- **Create:** Users  
- **Update/Delete:** Users  

## 3. Test in the app

1. Rebuild (**⌘R**)
2. Open **Home**
3. Sign in (composer prompt or Profile)
4. Post text, a YouTube link, and/or one photo
5. Confirm video plays **in the feed card** (not Safari)

## Storage tips

- Prefer video links over uploads
- Photos are compressed on device before upload
- One image per post
- Moderate / delete old posts in Appwrite Console if disk fills up

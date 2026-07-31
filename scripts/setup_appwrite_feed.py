#!/usr/bin/env python3
"""Create Appwrite feed resources: `posts` collection + `post-images` bucket.

Usage:
  export APPWRITE_API_KEY='your-temporary-api-key'
  python3 scripts/setup_appwrite_feed.py

Recommended 1-hour Cursor key scopes:
  databases.read/write, buckets.read/write, files.read/write,
  users.read/write, teams.read/write

Never commit the API key. Delete it in Appwrite Console when finished.
"""

from __future__ import annotations

import json
import os
import sys
import time
import urllib.error
import urllib.request

ENDPOINT = os.environ.get("APPWRITE_ENDPOINT", "https://api.tcidpodcast.com/v1").rstrip("/")
PROJECT_ID = os.environ.get("APPWRITE_PROJECT_ID", "tcidpodcast")
DATABASE_ID = os.environ.get("APPWRITE_DATABASE_ID", "episodes")
POSTS_ID = os.environ.get("APPWRITE_POSTS_COLLECTION_ID", "posts")
BUCKET_ID = os.environ.get("APPWRITE_POST_IMAGES_BUCKET_ID", "post-images")

# Collection-level defaults; documents still set their own permissions.
POSTS_PERMISSIONS = [
    'read("any")',
    'create("users")',
    'update("users")',
    'delete("users")',
]

BUCKET_PERMISSIONS = [
    'read("any")',
    'create("users")',
    'update("users")',
    'delete("users")',
]

STRING_ATTRS = [
    ("author_id", 64, True),
    ("author_name", 120, True),
    ("author_role", 32, True),
    ("body", 2000, False),
    ("link_url", 2000, False),
    ("image_file_id", 64, False),
    ("post_kind", 16, True),
]


def require_api_key() -> str:
    key = os.environ.get("APPWRITE_API_KEY", "").strip()
    if not key:
        print(
            "Missing APPWRITE_API_KEY.\n\n"
            "1. Appwrite Console → API Keys → Create API Key\n"
            "2. Name: temp-feed-setup  ·  Expire: 1 hour\n"
            "3. Scopes: databases, buckets, files, users, teams (read+write)\n"
            "4. Then:\n"
            "     export APPWRITE_API_KEY='...'\n"
            "     python3 scripts/setup_appwrite_feed.py\n",
            file=sys.stderr,
        )
        sys.exit(1)
    return key


def request(
    method: str,
    path: str,
    api_key: str,
    body: dict | None = None,
    ok_statuses: set[int] | None = None,
) -> tuple[int, dict | list | None]:
    ok_statuses = ok_statuses or {200, 201}
    data = None if body is None else json.dumps(body).encode("utf-8")
    req = urllib.request.Request(
        f"{ENDPOINT}{path}",
        data=data,
        method=method,
        headers={
            "Content-Type": "application/json",
            "X-Appwrite-Project": PROJECT_ID,
            "X-Appwrite-Key": api_key,
        },
    )
    try:
        with urllib.request.urlopen(req) as response:
            raw = response.read().decode("utf-8")
            payload = json.loads(raw) if raw else None
            return response.status, payload
    except urllib.error.HTTPError as exc:
        raw = exc.read().decode("utf-8", errors="replace")
        try:
            payload = json.loads(raw) if raw else None
        except json.JSONDecodeError:
            payload = {"message": raw}
        if exc.code in ok_statuses:
            return exc.code, payload
        message = ""
        if isinstance(payload, dict):
            message = str(payload.get("message") or payload)
        raise RuntimeError(f"{method} {path} → HTTP {exc.code}: {message or raw}") from exc


def collection_exists(api_key: str) -> bool:
    status, _ = request(
        "GET",
        f"/databases/{DATABASE_ID}/collections/{POSTS_ID}",
        api_key,
        ok_statuses={200, 404},
    )
    return status == 200


def ensure_posts_collection(api_key: str) -> None:
    if collection_exists(api_key):
        print(f"ok: collection `{POSTS_ID}` already exists")
        return

    request(
        "POST",
        f"/databases/{DATABASE_ID}/collections",
        api_key,
        {
            "collectionId": POSTS_ID,
            "name": "Posts",
            "permissions": POSTS_PERMISSIONS,
            "documentSecurity": True,
            "enabled": True,
        },
    )
    print(f"created: collection `{POSTS_ID}`")


def list_attribute_keys(api_key: str) -> set[str]:
    status, payload = request(
        "GET",
        f"/databases/{DATABASE_ID}/collections/{POSTS_ID}/attributes",
        api_key,
        ok_statuses={200},
    )
    if status != 200 or not isinstance(payload, dict):
        return set()
    attrs = payload.get("attributes") or []
    return {str(a.get("key")) for a in attrs if isinstance(a, dict) and a.get("key")}


def ensure_string_attribute(api_key: str, key: str, size: int, required: bool) -> None:
    existing = list_attribute_keys(api_key)
    if key in existing:
        print(f"ok: attribute `{key}`")
        return

    request(
        "POST",
        f"/databases/{DATABASE_ID}/collections/{POSTS_ID}/attributes/string",
        api_key,
        {
            "key": key,
            "size": size,
            "required": required,
            "array": False,
        },
    )
    print(f"created: attribute `{key}` (string/{size})")
    wait_for_attribute(api_key, key)


def ensure_integer_attribute(api_key: str, key: str, required: bool = False, default: int = 0) -> None:
    existing = list_attribute_keys(api_key)
    if key in existing:
        print(f"ok: attribute `{key}`")
        return

    body: dict = {
        "key": key,
        "required": required,
        "array": False,
    }
    if not required:
        body["default"] = default

    request(
        "POST",
        f"/databases/{DATABASE_ID}/collections/{POSTS_ID}/attributes/integer",
        api_key,
        body,
    )
    print(f"created: attribute `{key}` (integer)")
    wait_for_attribute(api_key, key)


def wait_for_attribute(api_key: str, key: str, timeout_sec: float = 60.0) -> None:
    deadline = time.time() + timeout_sec
    while time.time() < deadline:
        status, payload = request(
            "GET",
            f"/databases/{DATABASE_ID}/collections/{POSTS_ID}/attributes/{key}",
            api_key,
            ok_statuses={200, 404},
        )
        if status == 200 and isinstance(payload, dict):
            attr_status = str(payload.get("status") or "")
            if attr_status in {"available", "stuck"}:
                if attr_status == "stuck":
                    print(f"warn: attribute `{key}` status is stuck — check Console")
                return
            if attr_status == "failed":
                raise RuntimeError(f"Attribute `{key}` failed to create: {payload}")
        time.sleep(1.0)
    raise RuntimeError(f"Timed out waiting for attribute `{key}`")


def ensure_created_at_index(api_key: str) -> None:
    """Optional index so orderDesc($createdAt) stays fast as the feed grows."""
    status, payload = request(
        "GET",
        f"/databases/{DATABASE_ID}/collections/{POSTS_ID}/indexes",
        api_key,
        ok_statuses={200},
    )
    indexes = []
    if status == 200 and isinstance(payload, dict):
        indexes = payload.get("indexes") or []
    for index in indexes:
        if isinstance(index, dict) and index.get("key") == "created_at_desc":
            print("ok: index `created_at_desc`")
            return

    try:
        request(
            "POST",
            f"/databases/{DATABASE_ID}/collections/{POSTS_ID}/indexes",
            api_key,
            {
                "key": "created_at_desc",
                "type": "key",
                "attributes": ["$createdAt"],
                "orders": ["DESC"],
            },
        )
        print("created: index `created_at_desc`")
    except RuntimeError as exc:
        # Some Appwrite builds index $createdAt differently; feed still works without it.
        print(f"skip: index create failed ({exc})")


def bucket_exists(api_key: str) -> bool:
    status, _ = request(
        "GET",
        f"/storage/buckets/{BUCKET_ID}",
        api_key,
        ok_statuses={200, 404},
    )
    return status == 200


def ensure_post_images_bucket(api_key: str) -> None:
    if bucket_exists(api_key):
        print(f"ok: bucket `{BUCKET_ID}` already exists")
        return

    request(
        "POST",
        "/storage/buckets",
        api_key,
        {
            "bucketId": BUCKET_ID,
            "name": "Post Images",
            "permissions": BUCKET_PERMISSIONS,
            "fileSecurity": True,
            "enabled": True,
            "maximumFileSize": 2_000_000,
            "allowedFileExtensions": ["jpg", "jpeg", "png", "webp"],
            "compression": "none",
            "encryption": True,
            "antivirus": False,
        },
    )
    print(f"created: bucket `{BUCKET_ID}`")


def main() -> int:
    api_key = require_api_key()
    print(f"endpoint={ENDPOINT}")
    print(f"project={PROJECT_ID}")
    print(f"database={DATABASE_ID}")
    print("---")

    try:
        ensure_posts_collection(api_key)
        for key, size, required in STRING_ATTRS:
            ensure_string_attribute(api_key, key, size, required)
        ensure_integer_attribute(api_key, "like_count", required=False, default=0)
        ensure_created_at_index(api_key)
        ensure_post_images_bucket(api_key)
    except RuntimeError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1

    print("---")
    print("Feed setup complete.")
    print("Next: delete the temporary API key in Appwrite Console, then rebuild the iOS app.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

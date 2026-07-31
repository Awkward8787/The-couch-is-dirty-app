#!/usr/bin/env python3
"""Create Appwrite avatar resources: `avatars` bucket, `profiles` collection, post avatar field.

Usage:
  export APPWRITE_API_KEY='your-temporary-api-key'
  python3 scripts/setup_appwrite_avatars.py

Recommended API key scopes:
  databases.read/write, buckets.read/write, files.read/write, users.read/write

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
PROFILES_ID = os.environ.get("APPWRITE_PROFILES_COLLECTION_ID", "profiles")
POSTS_ID = os.environ.get("APPWRITE_POSTS_COLLECTION_ID", "posts")
AVATARS_BUCKET_ID = os.environ.get("APPWRITE_AVATARS_BUCKET_ID", "avatars")

PROFILE_PERMISSIONS = [
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

PROFILE_STRING_ATTRS = [
    ("display_name", 120, False),
    ("username", 64, False),
    ("bio", 2000, False),
    ("avatar_url", 64, False),
    ("role", 32, False),
    ("account_status", 32, False),
]


def require_api_key() -> str:
    key = os.environ.get("APPWRITE_API_KEY", "").strip()
    if not key:
        print(
            "Missing APPWRITE_API_KEY.\n\n"
            "1. Appwrite Console → API Keys → Create API Key\n"
            "2. Scopes: databases, buckets, files (read+write)\n"
            "3. Then:\n"
            "     export APPWRITE_API_KEY='...'\n"
            "     python3 scripts/setup_appwrite_avatars.py\n",
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


def collection_exists(api_key: str, collection_id: str) -> bool:
    status, _ = request(
        "GET",
        f"/databases/{DATABASE_ID}/collections/{collection_id}",
        api_key,
        ok_statuses={200, 404},
    )
    return status == 200


def list_attribute_keys(api_key: str, collection_id: str) -> set[str]:
    status, payload = request(
        "GET",
        f"/databases/{DATABASE_ID}/collections/{collection_id}/attributes",
        api_key,
        ok_statuses={200},
    )
    if status != 200 or not isinstance(payload, dict):
        return set()
    attrs = payload.get("attributes") or []
    return {str(a.get("key")) for a in attrs if isinstance(a, dict) and a.get("key")}


def wait_for_attribute(api_key: str, collection_id: str, key: str, timeout_sec: float = 60.0) -> None:
    deadline = time.time() + timeout_sec
    while time.time() < deadline:
        status, payload = request(
            "GET",
            f"/databases/{DATABASE_ID}/collections/{collection_id}/attributes/{key}",
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


def ensure_string_attribute(
    api_key: str,
    collection_id: str,
    key: str,
    size: int,
    required: bool,
) -> None:
    existing = list_attribute_keys(api_key, collection_id)
    if key in existing:
        print(f"ok: {collection_id}.{key}")
        return

    request(
        "POST",
        f"/databases/{DATABASE_ID}/collections/{collection_id}/attributes/string",
        api_key,
        {
            "key": key,
            "size": size,
            "required": required,
            "array": False,
        },
    )
    print(f"created: {collection_id}.{key} (string/{size})")
    wait_for_attribute(api_key, collection_id, key)


def ensure_profiles_collection(api_key: str) -> None:
    if collection_exists(api_key, PROFILES_ID):
        print(f"ok: collection `{PROFILES_ID}` already exists")
    else:
        request(
            "POST",
            f"/databases/{DATABASE_ID}/collections",
            api_key,
            {
                "collectionId": PROFILES_ID,
                "name": "Profiles",
                "permissions": PROFILE_PERMISSIONS,
                "documentSecurity": True,
                "enabled": True,
            },
        )
        print(f"created: collection `{PROFILES_ID}`")

    for key, size, required in PROFILE_STRING_ATTRS:
        ensure_string_attribute(api_key, PROFILES_ID, key, size, required)


def ensure_posts_avatar_attribute(api_key: str) -> None:
    if not collection_exists(api_key, POSTS_ID):
        print(f"skip: collection `{POSTS_ID}` not found — run setup_appwrite_feed.py first")
        return

    ensure_string_attribute(api_key, POSTS_ID, "author_avatar_url", 64, False)


def bucket_exists(api_key: str, bucket_id: str) -> bool:
    status, _ = request(
        "GET",
        f"/storage/buckets/{bucket_id}",
        api_key,
        ok_statuses={200, 404},
    )
    return status == 200


def ensure_avatars_bucket(api_key: str) -> None:
    if bucket_exists(api_key, AVATARS_BUCKET_ID):
        print(f"ok: bucket `{AVATARS_BUCKET_ID}` already exists")
        return

    request(
        "POST",
        "/storage/buckets",
        api_key,
        {
            "bucketId": AVATARS_BUCKET_ID,
            "name": "Avatars",
            "permissions": BUCKET_PERMISSIONS,
            "fileSecurity": True,
            "enabled": True,
            "maximumFileSize": 500_000,
            "allowedFileExtensions": ["jpg", "jpeg", "png", "webp"],
            "compression": "none",
            "encryption": True,
            "antivirus": False,
        },
    )
    print(f"created: bucket `{AVATARS_BUCKET_ID}`")


def main() -> int:
    api_key = require_api_key()
    print(f"endpoint={ENDPOINT}")
    print(f"project={PROJECT_ID}")
    print(f"database={DATABASE_ID}")
    print("---")

    try:
        ensure_avatars_bucket(api_key)
        ensure_profiles_collection(api_key)
        ensure_posts_avatar_attribute(api_key)
    except RuntimeError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1

    print("---")
    print("Avatar setup complete.")
    print("Resources: avatars bucket, profiles.avatar_url, posts.author_avatar_url")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

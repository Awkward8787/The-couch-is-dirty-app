#!/usr/bin/env python3
"""One-time RSS → Appwrite episode import for TCID Podcast.

Usage:
  export APPWRITE_API_KEY='your-api-key'
  python3 scripts/seed_appwrite_episodes.py

Creates/updates published episodes from the official RSS feed.
Never commit the API key. Delete the key in Appwrite Console after import.
"""

from __future__ import annotations

import json
import os
import re
import sys
import urllib.error
import urllib.parse
import urllib.request
from email.utils import parsedate_to_datetime
from xml.etree import ElementTree as ET

ENDPOINT = os.environ.get("APPWRITE_ENDPOINT", "https://api.tcidpodcast.com/v1").rstrip("/")
PROJECT_ID = os.environ.get("APPWRITE_PROJECT_ID", "tcidpodcast")
DATABASE_ID = os.environ.get("APPWRITE_DATABASE_ID", "episodes")
COLLECTION_ID = os.environ.get("APPWRITE_COLLECTION_ID", "episodes")
RSS_URL = os.environ.get(
    "TCID_RSS_URL",
    "https://media.rss.com/the-couch-is-dirty-podcast/feed.xml",
)


def require_api_key() -> str:
    key = os.environ.get("APPWRITE_API_KEY", "").strip()
    if not key:
        print(
            "Missing APPWRITE_API_KEY.\n"
            "Create a temporary API key in Appwrite Console with databases.write, "
            "then run:\n"
            "  export APPWRITE_API_KEY='...'\n"
            "  python3 scripts/seed_appwrite_episodes.py",
            file=sys.stderr,
        )
        sys.exit(1)
    return key


def fetch_rss_episodes() -> list[dict]:
    with urllib.request.urlopen(RSS_URL) as response:
        xml_bytes = response.read()
    root = ET.fromstring(xml_bytes)
    episodes: list[dict] = []

    for item in root.findall(".//item"):
        title = (item.findtext("title") or "").strip()
        if not title:
            continue

        description = (item.findtext("description") or "").strip()
        description = re.sub(r"<!\[CDATA\[|<!\{CDATA\{|CDATA\[|\]\]>", " ", description, flags=re.I)
        description = re.sub("<[^<]+?>", "", description)
        description = re.sub(r"\s+", " ", description).strip()

        guid = (item.findtext("guid") or "").strip()
        pub = (item.findtext("pubDate") or "").strip()
        enclosure = item.find("enclosure")
        audio_url = enclosure.get("url") if enclosure is not None else ""
        duration_raw = (
            item.findtext("{http://www.itunes.com/dtds/podcast-1.0.dtd}duration") or ""
        )
        image = item.find("{http://www.itunes.com/dtds/podcast-1.0.dtd}image")
        cover_art_url = image.get("href") if image is not None else ""

        duration_seconds = None
        if duration_raw.isdigit():
            duration_seconds = int(duration_raw)
        elif ":" in duration_raw:
            parts = [int(part) for part in duration_raw.split(":")]
            while len(parts) < 3:
                parts.insert(0, 0)
            duration_seconds = parts[0] * 3600 + parts[1] * 60 + parts[2]

        published_at = None
        if pub:
            try:
                published_at = parsedate_to_datetime(pub).isoformat()
            except (TypeError, ValueError, IndexError):
                published_at = None

        slug = re.sub(r"[^a-z0-9]+", "-", title.lower()).strip("-")
        episode = {
            "title": title,
            "status": "published",
            "source": "rss",
            "slug": slug,
            "description": description[:10000] if description else None,
            "audio_url": audio_url or None,
            "cover_art_url": cover_art_url or None,
            "rss_guid": guid or None,
            "duration_seconds": duration_seconds,
            "is_explicit": False,
            "published_at": published_at,
            "play_count": 0,
        }
        episodes.append({key: value for key, value in episode.items() if value is not None})

    return episodes


def appwrite_request(
    method: str,
    path: str,
    api_key: str,
    payload: dict | None = None,
    query: dict[str, list[str]] | None = None,
) -> dict:
    url = f"{ENDPOINT}{path}"
    if query:
        pairs: list[tuple[str, str]] = []
        for key, values in query.items():
            for value in values:
                pairs.append((key, value))
        url = f"{url}?{urllib.parse.urlencode(pairs)}"

    data = None if payload is None else json.dumps(payload).encode("utf-8")
    request = urllib.request.Request(
        url,
        data=data,
        method=method,
        headers={
            "Content-Type": "application/json",
            "X-Appwrite-Project": PROJECT_ID,
            "X-Appwrite-Key": api_key,
        },
    )

    try:
        with urllib.request.urlopen(request) as response:
            body = response.read().decode("utf-8")
            return json.loads(body) if body else {}
    except urllib.error.HTTPError as error:
        detail = error.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"{method} {path} failed ({error.code}): {detail}") from error


def find_existing_by_guid(api_key: str, rss_guid: str) -> str | None:
    # Appwrite 1.9 query syntax is JSON objects, not the older equal("x", ...) strings.
    result = appwrite_request(
        "GET",
        f"/databases/{DATABASE_ID}/collections/{COLLECTION_ID}/documents",
        api_key,
        query={
            "queries[]": [
                json.dumps(
                    {
                        "method": "equal",
                        "attribute": "rss_guid",
                        "values": [rss_guid],
                    }
                ),
                json.dumps({"method": "limit", "values": [1]}),
            ]
        },
    )
    documents = result.get("documents") or []
    if not documents:
        return None
    return documents[0].get("$id")


def upsert_episode(api_key: str, episode: dict) -> str:
    rss_guid = episode.get("rss_guid")
    existing_id = find_existing_by_guid(api_key, rss_guid) if rss_guid else None

    if existing_id:
        appwrite_request(
            "PATCH",
            f"/databases/{DATABASE_ID}/collections/{COLLECTION_ID}/documents/{existing_id}",
            api_key,
            payload={"data": episode},
        )
        return f"updated:{existing_id}"

    created = appwrite_request(
        "POST",
        f"/databases/{DATABASE_ID}/collections/{COLLECTION_ID}/documents",
        api_key,
        payload={
            "documentId": "unique()",
            "data": episode,
            "permissions": ['read("any")'],
        },
    )
    return f"created:{created.get('$id')}"


def main() -> None:
    api_key = require_api_key()
    episodes = fetch_rss_episodes()
    print(f"Importing {len(episodes)} episodes from RSS…")
    print(f"Target: {ENDPOINT} / db={DATABASE_ID} / collection={COLLECTION_ID}")

    for episode in episodes:
        result = upsert_episode(api_key, episode)
        print(f"  {result}  {episode['title']}")

    print("Done. Delete the temporary API key in Appwrite Console.")


if __name__ == "__main__":
    main()

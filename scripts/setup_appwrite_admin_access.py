#!/usr/bin/env python3
"""Ensure Appwrite teams exist and the admin user is on `admins`.

Usage:
  export APPWRITE_API_KEY='...'
  python3 scripts/setup_appwrite_admin_access.py

Optional password reset (local only — do not commit):
  export ADMIN_NEW_PASSWORD='YourNewPassword123!'
  python3 scripts/setup_appwrite_admin_access.py
"""

from __future__ import annotations

import json
import os
import sys
import urllib.error
import urllib.request

import urllib.parse

ENDPOINT = os.environ.get("APPWRITE_ENDPOINT", "https://api.tcidpodcast.com/v1").rstrip("/")
PROJECT_ID = os.environ.get("APPWRITE_PROJECT_ID", "tcidpodcast")
ADMIN_EMAIL = os.environ.get("ADMIN_EMAIL", "anthony@vibevirtue.com").strip().lower()
ADMIN_USER_ID = os.environ.get("ADMIN_USER_ID", "ADMIN")
TEAMS = ["members", "moderators", "admins"]


def require_api_key() -> str:
    key = os.environ.get("APPWRITE_API_KEY", "").strip()
    if not key:
        print("Missing APPWRITE_API_KEY.", file=sys.stderr)
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
            return response.status, json.loads(raw) if raw else None
    except urllib.error.HTTPError as exc:
        raw = exc.read().decode("utf-8", errors="replace")
        try:
            payload = json.loads(raw) if raw else None
        except json.JSONDecodeError:
            payload = {"message": raw}
        if exc.code in ok_statuses:
            return exc.code, payload
        message = payload.get("message") if isinstance(payload, dict) else raw
        raise RuntimeError(f"{method} {path} → HTTP {exc.code}: {message}") from exc


def find_user_id(api_key: str, email: str) -> str:
    status, payload = request(
        "GET",
        f"/users?search={urllib.parse.quote(email)}",
        api_key,
        ok_statuses={200},
    )
    if status != 200 or not isinstance(payload, dict):
        raise RuntimeError("Could not search users.")
    users = payload.get("users") or []
    for user in users:
        if str(user.get("email", "")).lower() == email:
            return str(user["$id"])
    raise RuntimeError(f"No Appwrite user found for {email}")


def ensure_team(api_key: str, team_id: str) -> None:
    status, _ = request(
        "GET",
        f"/teams/{team_id}",
        api_key,
        ok_statuses={200, 404},
    )
    if status == 200:
        print(f"ok: team `{team_id}`")
        return

    request(
        "POST",
        "/teams",
        api_key,
        {
            "teamId": team_id,
            "name": team_id.replace("_", " ").title(),
            "roles": ["owner", "admin", "member"],
        },
    )
    print(f"created: team `{team_id}`")


def user_on_team(api_key: str, team_id: str, user_id: str) -> bool:
    status, payload = request(
        "GET",
        f"/teams/{team_id}/memberships",
        api_key,
        ok_statuses={200},
    )
    if status != 200 or not isinstance(payload, dict):
        return False
    memberships = payload.get("memberships") or []
    return any(str(m.get("userId")) == user_id for m in memberships if isinstance(m, dict))


def add_user_to_team(api_key: str, team_id: str, user_id: str) -> None:
    if user_on_team(api_key, team_id, user_id):
        print(f"ok: {user_id} already on `{team_id}`")
        return

    request(
        "POST",
        f"/teams/{team_id}/memberships",
        api_key,
        {
            "userId": user_id,
            "roles": ["owner"],
        },
    )
    print(f"added: {user_id} → `{team_id}`")


def maybe_reset_password(api_key: str, user_id: str) -> None:
    new_password = os.environ.get("ADMIN_NEW_PASSWORD", "").strip()
    if not new_password:
        return
    if len(new_password) < 8:
        raise RuntimeError("ADMIN_NEW_PASSWORD must be at least 8 characters.")

    request(
        "PATCH",
        f"/users/{user_id}/password",
        api_key,
        {"password": new_password},
    )
    print(f"updated: password for user `{user_id}`")


def main() -> int:
    api_key = require_api_key()
    user_id = os.environ.get("ADMIN_USER_ID", "").strip() or find_user_id(api_key, ADMIN_EMAIL)

    print(f"endpoint={ENDPOINT}")
    print(f"project={PROJECT_ID}")
    print(f"admin_email={ADMIN_EMAIL}")
    print(f"admin_user_id={user_id}")
    print("---")

    try:
        for team_id in TEAMS:
            ensure_team(api_key, team_id)
        add_user_to_team(api_key, "admins", user_id)
        maybe_reset_password(api_key, user_id)
    except RuntimeError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1

    print("---")
    print("Admin access setup complete.")
    print("Sign in at http://localhost:3001/login with:")
    print(f"  email: {ADMIN_EMAIL}")
    print("  password: your Appwrite password (or ADMIN_NEW_PASSWORD if you set it)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

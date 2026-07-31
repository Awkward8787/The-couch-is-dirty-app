import type { Models } from "node-appwrite";
import {
  GUEST_APPLICATION_STATUSES,
  type AdminGuestApplication,
  type GuestApplicationStatus,
} from "./types";

function readString(data: Record<string, unknown>, keys: string[]): string | null {
  for (const key of keys) {
    const value = data[key];
    if (typeof value === "string" && value.trim()) return value.trim();
  }
  return null;
}

function readStatus(data: Record<string, unknown>): GuestApplicationStatus {
  const raw = readString(data, ["status", "application_status"]);
  if (raw && GUEST_APPLICATION_STATUSES.includes(raw as GuestApplicationStatus)) {
    return raw as GuestApplicationStatus;
  }
  return "pending";
}

export function mapGuestApplication(document: Models.Document): AdminGuestApplication {
  const data = document as Models.Document & Record<string, unknown>;

  return {
    id: document.$id,
    name:
      readString(data, ["name", "applicant_name", "display_name", "full_name"]) ??
      "Unknown applicant",
    email: readString(data, ["email", "applicant_email"]),
    topic: readString(data, ["topic", "subject", "episode_topic"]),
    message: readString(data, ["message", "body", "notes", "pitch"]),
    format: readString(data, ["format", "appearance_type", "guest_format"]),
    status: readStatus(data),
    createdAt: document.$createdAt,
  };
}

export function formatGuestDate(isoDate: string): string {
  const date = new Date(isoDate);
  if (Number.isNaN(date.getTime())) return "—";

  return new Intl.DateTimeFormat("en-US", {
    month: "short",
    day: "numeric",
    year: "numeric",
    hour: "numeric",
    minute: "2-digit",
  }).format(date);
}

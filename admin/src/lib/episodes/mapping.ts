import type { Models } from "node-appwrite";
import {
  EPISODE_SOURCES,
  EPISODE_STATUSES,
  type AdminEpisode,
  type EpisodeSource,
  type EpisodeStatus,
} from "./types";

function readString(data: Record<string, unknown>, key: string): string | null {
  const value = data[key];
  if (typeof value === "string") return value.length > 0 ? value : null;
  if (typeof value === "number") return String(value);
  return null;
}

function readNumber(data: Record<string, unknown>, key: string): number | null {
  const value = data[key];
  if (typeof value === "number") return value;
  if (typeof value === "string" && value.trim()) return Number(value);
  return null;
}

function readStatus(data: Record<string, unknown>): EpisodeStatus {
  const raw = readString(data, "status");
  if (raw && EPISODE_STATUSES.includes(raw as EpisodeStatus)) {
    return raw as EpisodeStatus;
  }
  return "draft";
}

function readSource(data: Record<string, unknown>): EpisodeSource {
  const raw = readString(data, "source");
  if (raw && EPISODE_SOURCES.includes(raw as EpisodeSource)) {
    return raw as EpisodeSource;
  }
  return "rss";
}

export function mapEpisodeDocument(document: Models.Document): AdminEpisode {
  const data = document as Models.Document & Record<string, unknown>;

  return {
    id: document.$id,
    title: readString(data, "title") ?? "Untitled episode",
    slug: readString(data, "slug"),
    description: readString(data, "description"),
    status: readStatus(data),
    source: readSource(data),
    audioUrl: readString(data, "audio_url"),
    coverArtUrl: readString(data, "cover_art_url"),
    durationSeconds: readNumber(data, "duration_seconds"),
    publishedAt: readString(data, "published_at"),
    playCount: readNumber(data, "play_count") ?? 0,
    rssGuid: readString(data, "rss_guid"),
  };
}

export function formatEpisodeDuration(seconds: number | null): string {
  if (!seconds || seconds <= 0) return "—";

  const hours = Math.floor(seconds / 3600);
  const minutes = Math.floor((seconds % 3600) / 60);

  if (hours > 0) return `${hours}h ${minutes}m`;
  return `${minutes}m`;
}

export function formatEpisodeDate(isoDate: string | null): string {
  if (!isoDate) return "—";

  const date = new Date(isoDate);
  if (Number.isNaN(date.getTime())) return "—";

  return new Intl.DateTimeFormat("en-US", {
    month: "short",
    day: "numeric",
    year: "numeric",
  }).format(date);
}

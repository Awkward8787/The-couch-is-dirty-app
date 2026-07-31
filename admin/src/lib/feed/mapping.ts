import type { Models } from "node-appwrite";
import { postImageViewUrl } from "@/lib/appwrite/storage";
import {
  MODERATION_STATUSES,
  type AdminFeedComment,
  type AdminFeedPost,
  type ModerationStatus,
} from "./types";

function readString(data: Record<string, unknown>, key: string): string | null {
  const value = data[key];
  if (typeof value === "string") return value.length > 0 ? value : null;
  if (typeof value === "number") return String(value);
  return null;
}

function readNumber(data: Record<string, unknown>, key: string): number {
  const value = data[key];
  if (typeof value === "number") return value;
  if (typeof value === "string" && value.trim()) return Number(value) || 0;
  return 0;
}

function readModerationStatus(data: Record<string, unknown>): ModerationStatus {
  const raw = readString(data, "moderation_status");
  if (raw && MODERATION_STATUSES.includes(raw as ModerationStatus)) {
    return raw as ModerationStatus;
  }
  return "visible";
}

export function mapFeedPost(document: Models.Document): AdminFeedPost {
  const data = document as Models.Document & Record<string, unknown>;
  const imageFileId = readString(data, "image_file_id");

  return {
    id: document.$id,
    authorId: readString(data, "author_id") ?? "unknown",
    authorName: readString(data, "author_name") ?? "Couch Fam",
    authorRole: readString(data, "author_role") ?? "user",
    body: readString(data, "body") ?? "",
    linkUrl: readString(data, "link_url"),
    imageUrl: imageFileId ? postImageViewUrl(imageFileId) : null,
    likeCount: readNumber(data, "like_count"),
    commentCount: readNumber(data, "comment_count"),
    moderationStatus: readModerationStatus(data),
    createdAt: document.$createdAt,
  };
}

export function mapFeedComment(document: Models.Document): AdminFeedComment {
  const data = document as Models.Document & Record<string, unknown>;

  return {
    id: document.$id,
    postId: readString(data, "post_id") ?? "",
    authorId: readString(data, "author_id") ?? "unknown",
    authorName: readString(data, "author_name") ?? "Couch Fam",
    body: readString(data, "body") ?? "",
    createdAt: document.$createdAt,
  };
}

export function formatFeedDate(isoDate: string): string {
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

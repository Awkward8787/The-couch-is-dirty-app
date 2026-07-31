import { Databases, Query } from "node-appwrite";
import { APPWRITE_COLLECTIONS } from "@/lib/appwrite/collections";
import { createAdminClient } from "@/lib/appwrite/server";
import { getAppwriteConfig } from "@/lib/appwrite/config";
import { mapFeedComment, mapFeedPost } from "./mapping";
import type { AdminFeedComment, AdminFeedPost, FeedListFilter, ModerationStatus } from "./types";

export async function listFeedPosts(filter: FeedListFilter = {}): Promise<AdminFeedPost[]> {
  const { databaseId } = getAppwriteConfig();
  const databases = new Databases(createAdminClient());
  const queries = [Query.orderDesc("$createdAt"), Query.limit(50)];

  if (filter.status && filter.status !== "all") {
    queries.push(Query.equal("moderation_status", filter.status));
  }

  const result = await databases.listDocuments(databaseId, APPWRITE_COLLECTIONS.posts, queries);
  return result.documents.map(mapFeedPost);
}

export async function getFeedPost(documentId: string): Promise<AdminFeedPost | null> {
  const { databaseId } = getAppwriteConfig();
  const databases = new Databases(createAdminClient());

  try {
    const document = await databases.getDocument(
      databaseId,
      APPWRITE_COLLECTIONS.posts,
      documentId,
    );
    return mapFeedPost(document);
  } catch {
    return null;
  }
}

export async function listPostComments(postId: string): Promise<AdminFeedComment[]> {
  const { databaseId } = getAppwriteConfig();
  const databases = new Databases(createAdminClient());
  const result = await databases.listDocuments(databaseId, APPWRITE_COLLECTIONS.postComments, [
    Query.equal("post_id", postId),
    Query.orderAsc("$createdAt"),
    Query.limit(100),
  ]);

  return result.documents.map(mapFeedComment);
}

export function parseFeedListFilter(searchParams: {
  status?: string;
}): FeedListFilter {
  const valid: Array<ModerationStatus | "all"> = [
    "all",
    "visible",
    "hidden",
    "removed",
    "reported",
  ];
  const status = searchParams.status;

  return {
    status: valid.includes(status as ModerationStatus | "all")
      ? (status as ModerationStatus | "all")
      : "all",
  };
}

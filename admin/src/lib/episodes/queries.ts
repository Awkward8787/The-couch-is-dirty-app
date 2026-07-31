import { Databases, Query } from "node-appwrite";
import { APPWRITE_COLLECTIONS } from "@/lib/appwrite/collections";
import { createAdminClient } from "@/lib/appwrite/server";
import { getAppwriteConfig } from "@/lib/appwrite/config";
import { mapEpisodeDocument } from "./mapping";
import type { AdminEpisode, EpisodeListFilter, EpisodeSource, EpisodeStatus } from "./types";

function buildListQueries(filter: EpisodeListFilter): string[] {
  const queries = [Query.orderDesc("published_at"), Query.limit(50)];

  if (filter.status && filter.status !== "all") {
    queries.push(Query.equal("status", filter.status));
  }

  if (filter.source && filter.source !== "all") {
    queries.push(Query.equal("source", filter.source));
  }

  return queries;
}

export async function listEpisodes(filter: EpisodeListFilter = {}): Promise<AdminEpisode[]> {
  const { databaseId } = getAppwriteConfig();
  const databases = new Databases(createAdminClient());
  const result = await databases.listDocuments(
    databaseId,
    APPWRITE_COLLECTIONS.episodes,
    buildListQueries(filter),
  );

  return result.documents.map(mapEpisodeDocument);
}

export async function getEpisode(documentId: string): Promise<AdminEpisode | null> {
  const { databaseId } = getAppwriteConfig();
  const databases = new Databases(createAdminClient());

  try {
    const document = await databases.getDocument(
      databaseId,
      APPWRITE_COLLECTIONS.episodes,
      documentId,
    );
    return mapEpisodeDocument(document);
  } catch {
    return null;
  }
}

export function parseEpisodeListFilter(searchParams: {
  status?: string;
  source?: string;
}): EpisodeListFilter {
  const status = searchParams.status;
  const source = searchParams.source;

  const validStatuses: Array<EpisodeStatus | "all"> = [
    "all",
    "draft",
    "scheduled",
    "published",
    "archived",
  ];
  const validSources: Array<EpisodeSource | "all"> = ["all", "rss", "manual"];

  return {
    status: validStatuses.includes(status as EpisodeStatus | "all")
      ? (status as EpisodeStatus | "all")
      : "all",
    source: validSources.includes(source as EpisodeSource | "all")
      ? (source as EpisodeSource | "all")
      : "all",
  };
}

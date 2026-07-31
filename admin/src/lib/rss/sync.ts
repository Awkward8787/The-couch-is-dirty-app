import { Databases, ID, Permission, Query, Role } from "node-appwrite";
import { APPWRITE_COLLECTIONS } from "@/lib/appwrite/collections";
import { createAdminClient } from "@/lib/appwrite/server";
import { getAppwriteConfig } from "@/lib/appwrite/config";
import { OFFICIAL_RSS_FEED_URL } from "@/lib/constants";
import { fetchRssEpisodes, type RssEpisodePayload } from "./parse-feed";

export type RssSyncResult = {
  total: number;
  created: number;
  updated: number;
  skipped: number;
};

async function findEpisodeByGuid(rssGuid: string): Promise<string | null> {
  const { databaseId } = getAppwriteConfig();
  const databases = new Databases(createAdminClient());
  const result = await databases.listDocuments(databaseId, APPWRITE_COLLECTIONS.episodes, [
    Query.equal("rss_guid", rssGuid),
    Query.limit(1),
  ]);

  return result.documents[0]?.$id ?? null;
}

async function upsertEpisode(payload: RssEpisodePayload): Promise<"created" | "updated" | "skipped"> {
  const { databaseId } = getAppwriteConfig();
  const databases = new Databases(createAdminClient());

  if (!payload.rss_guid) return "skipped";

  const existingId = await findEpisodeByGuid(payload.rss_guid);

  if (existingId) {
    await databases.updateDocument(
      databaseId,
      APPWRITE_COLLECTIONS.episodes,
      existingId,
      payload,
    );
    return "updated";
  }

  await databases.createDocument(
    databaseId,
    APPWRITE_COLLECTIONS.episodes,
    ID.unique(),
    payload,
    [Permission.read(Role.any())],
  );
  return "created";
}

export async function syncEpisodesFromRss(
  feedUrl: string = OFFICIAL_RSS_FEED_URL,
): Promise<RssSyncResult> {
  const episodes = await fetchRssEpisodes(feedUrl);
  let created = 0;
  let updated = 0;
  let skipped = 0;

  for (const episode of episodes) {
    const outcome = await upsertEpisode(episode);
    if (outcome === "created") created += 1;
    if (outcome === "updated") updated += 1;
    if (outcome === "skipped") skipped += 1;
  }

  return {
    total: episodes.length,
    created,
    updated,
    skipped,
  };
}

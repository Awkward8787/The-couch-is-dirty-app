import { OFFICIAL_RSS_FEED_URL } from "@/lib/constants";

export type RssEpisodePayload = {
  title: string;
  status: "published";
  source: "rss";
  slug: string;
  description?: string;
  audio_url?: string;
  cover_art_url?: string;
  rss_guid?: string;
  duration_seconds?: number;
  is_explicit: boolean;
  published_at?: string;
  play_count: number;
};

function stripHtml(value: string): string {
  return value.replace(/<[^>]+>/g, " ").replace(/\s+/g, " ").trim();
}

function slugify(title: string): string {
  return title
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

function readTag(block: string, tag: string): string {
  const pattern = new RegExp(`<${tag}[^>]*>([\\s\\S]*?)<\\/${tag}>`, "i");
  const match = block.match(pattern);
  return match?.[1]?.trim() ?? "";
}

function readAttribute(block: string, tag: string, attribute: string): string {
  const pattern = new RegExp(`<${tag}[^>]*\\s${attribute}=["']([^"']+)["']`, "i");
  const match = block.match(pattern);
  return match?.[1]?.trim() ?? "";
}

function parseDuration(raw: string): number | undefined {
  if (!raw) return undefined;
  if (/^\d+$/.test(raw)) return Number(raw);

  const parts = raw.split(":").map((part) => Number(part));
  if (parts.some((part) => Number.isNaN(part))) return undefined;

  while (parts.length < 3) parts.unshift(0);
  const [hours, minutes, seconds] = parts;
  return hours * 3600 + minutes * 60 + seconds;
}

function parsePublishedAt(raw: string): string | undefined {
  if (!raw) return undefined;
  const date = new Date(raw);
  if (Number.isNaN(date.getTime())) return undefined;
  return date.toISOString();
}

export async function fetchRssEpisodes(
  feedUrl: string = OFFICIAL_RSS_FEED_URL,
): Promise<RssEpisodePayload[]> {
  const response = await fetch(feedUrl, { next: { revalidate: 0 } });
  if (!response.ok) {
    throw new Error(`RSS feed request failed (${response.status}).`);
  }

  const xml = await response.text();
  const itemBlocks = xml.match(/<item[\s\S]*?<\/item>/gi) ?? [];
  const episodes: RssEpisodePayload[] = [];

  for (const block of itemBlocks) {
    const title = readTag(block, "title");
    if (!title) continue;

    const description = stripHtml(readTag(block, "description"));
    const guid = readTag(block, "guid");
    const pubDate = readTag(block, "pubDate");
    const audioUrl = readAttribute(block, "enclosure", "url");
    const durationRaw =
      readTag(block, "itunes:duration") || readTag(block, "duration");
    const coverArtUrl =
      readAttribute(block, "itunes:image", "href") ||
      readAttribute(block, "image", "href");

    const episode: RssEpisodePayload = {
      title,
      status: "published",
      source: "rss",
      slug: slugify(title),
      is_explicit: false,
      play_count: 0,
    };

    if (description) episode.description = description.slice(0, 10000);
    if (audioUrl) episode.audio_url = audioUrl;
    if (coverArtUrl) episode.cover_art_url = coverArtUrl;
    if (guid) episode.rss_guid = guid;

    const durationSeconds = parseDuration(durationRaw);
    if (durationSeconds !== undefined) episode.duration_seconds = durationSeconds;

    const publishedAt = parsePublishedAt(pubDate);
    if (publishedAt) episode.published_at = publishedAt;

    episodes.push(episode);
  }

  return episodes;
}

export async function previewRssFeed(feedUrl: string = OFFICIAL_RSS_FEED_URL) {
  const episodes = await fetchRssEpisodes(feedUrl);
  return {
    feedUrl,
    count: episodes.length,
    sampleTitles: episodes.slice(0, 3).map((episode) => episode.title),
  };
}

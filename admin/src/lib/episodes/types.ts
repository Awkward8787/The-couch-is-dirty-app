export const EPISODE_STATUSES = ["draft", "scheduled", "published", "archived"] as const;
export const EPISODE_SOURCES = ["rss", "manual"] as const;

export type EpisodeStatus = (typeof EPISODE_STATUSES)[number];
export type EpisodeSource = (typeof EPISODE_SOURCES)[number];

export type AdminEpisode = {
  id: string;
  title: string;
  slug: string | null;
  description: string | null;
  status: EpisodeStatus;
  source: EpisodeSource;
  audioUrl: string | null;
  coverArtUrl: string | null;
  durationSeconds: number | null;
  publishedAt: string | null;
  playCount: number;
  rssGuid: string | null;
};

export type EpisodeListFilter = {
  status?: EpisodeStatus | "all";
  source?: EpisodeSource | "all";
};

import { TcidCard } from "@/components/ui/tcid-card";
import pageStyles from "@/components/ui/page.module.css";
import { EpisodeFilterBar } from "@/components/features/episodes/episode-filter-bar";
import { EpisodeTable } from "@/components/features/episodes/episode-table";
import type { AdminEpisode } from "@/lib/episodes/types";
import { listEpisodes, parseEpisodeListFilter } from "@/lib/episodes/queries";

type EpisodesPageProps = {
  searchParams: Promise<{ status?: string; source?: string; error?: string }>;
};

const ERROR_MESSAGES: Record<string, string> = {
  publish: "Could not publish that episode.",
  unpublish: "Could not unpublish that episode.",
  archive: "Could not archive that episode.",
};

export default async function EpisodesPage({ searchParams }: EpisodesPageProps) {
  const params = await searchParams;
  const filter = parseEpisodeListFilter(params);
  let episodes: AdminEpisode[] = [];
  let loadError: string | null = null;

  try {
    episodes = await listEpisodes(filter);
  } catch {
    loadError = "Could not load episodes. Check APPWRITE_API_KEY and collection permissions.";
  }

  const bannerError = params.error ? ERROR_MESSAGES[params.error] : null;

  return (
    <>
      <header className={pageStyles.pageHeader}>
        <h1 className={pageStyles.pageTitle}>Episodes</h1>
        <p className={pageStyles.pageSubtitle}>Publish, edit, and manage podcast episodes.</p>
      </header>

      {bannerError ? <p className={pageStyles.error}>{bannerError}</p> : null}
      {loadError ? <p className={pageStyles.error}>{loadError}</p> : null}

      <EpisodeFilterBar status={filter.status ?? "all"} source={filter.source ?? "all"} />

      <TcidCard>
        <EpisodeTable episodes={episodes} />
      </TcidCard>
    </>
  );
}

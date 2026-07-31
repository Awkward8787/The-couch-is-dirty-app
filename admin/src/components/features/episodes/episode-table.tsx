import Image from "next/image";
import Link from "next/link";
import {
  formatEpisodeDate,
  formatEpisodeDuration,
} from "@/lib/episodes/mapping";
import type { AdminEpisode } from "@/lib/episodes/types";
import { publishEpisodeAction, unpublishEpisodeAction } from "@/lib/episodes/actions";
import { TcidButton, TcidButtonLink } from "@/components/ui/tcid-button";
import {
  EpisodeSourceBadge,
  EpisodeStatusBadge,
} from "./episode-filter-bar";
import styles from "./episodes.module.css";

type EpisodeTableProps = {
  episodes: AdminEpisode[];
};

export function EpisodeTable({ episodes }: EpisodeTableProps) {
  if (episodes.length === 0) {
    return <p className={styles.empty}>No episodes match these filters.</p>;
  }

  return (
    <table className={styles.table}>
      <tbody>
        {episodes.map((episode) => (
          <tr key={episode.id} className={styles.row}>
            <td className={styles.cell}>
              {episode.coverArtUrl ? (
                <Image
                  src={episode.coverArtUrl}
                  alt=""
                  width={48}
                  height={48}
                  className={styles.artwork}
                />
              ) : (
                <div className={styles.artworkPlaceholder} aria-hidden />
              )}
            </td>
            <td className={styles.cellTitle}>
              <Link href={`/episodes/${episode.id}`} className={styles.titleLink}>
                {episode.title}
              </Link>
              <div className={styles.meta}>
                {formatEpisodeDate(episode.publishedAt)} · {formatEpisodeDuration(episode.durationSeconds)}
                {episode.playCount > 0 ? ` · ${episode.playCount.toLocaleString()} plays` : ""}
              </div>
            </td>
            <td className={styles.cell}>
              <EpisodeStatusBadge status={episode.status} />
            </td>
            <td className={styles.cell}>
              <EpisodeSourceBadge source={episode.source} />
            </td>
            <td className={styles.cell}>
              <div className={styles.actions}>
                <TcidButtonLink href={`/episodes/${episode.id}`} variant="secondary">
                  Edit
                </TcidButtonLink>
                {episode.status === "published" ? (
                  <form action={unpublishEpisodeAction.bind(null, episode.id)}>
                    <TcidButton type="submit" variant="secondary">
                      Unpublish
                    </TcidButton>
                  </form>
                ) : (
                  <form action={publishEpisodeAction.bind(null, episode.id)}>
                    <TcidButton type="submit">Publish</TcidButton>
                  </form>
                )}
              </div>
            </td>
          </tr>
        ))}
      </tbody>
    </table>
  );
}

import Image from "next/image";
import Link from "next/link";
import { notFound } from "next/navigation";
import {
  archiveEpisodeAction,
  publishEpisodeAction,
  unpublishEpisodeAction,
  updateEpisodeAction,
} from "@/lib/episodes/actions";
import {
  formatEpisodeDate,
  formatEpisodeDuration,
} from "@/lib/episodes/mapping";
import { getEpisode } from "@/lib/episodes/queries";
import { EPISODE_STATUSES } from "@/lib/episodes/types";
import { TcidButton, TcidButtonLink } from "@/components/ui/tcid-button";
import { TcidCard } from "@/components/ui/tcid-card";
import { TcidInput } from "@/components/ui/tcid-input";
import pageStyles from "@/components/ui/page.module.css";
import {
  EpisodeSourceBadge,
  EpisodeStatusBadge,
} from "@/components/features/episodes/episode-filter-bar";
import styles from "@/components/features/episodes/episodes.module.css";

type EpisodeDetailPageProps = {
  params: Promise<{ id: string }>;
  searchParams: Promise<{ saved?: string; error?: string }>;
};

const ERROR_MESSAGES: Record<string, string> = {
  validation: "Check the title and status fields, then try again.",
  save: "Could not save changes. Check Appwrite permissions.",
};

export default async function EpisodeDetailPage({ params, searchParams }: EpisodeDetailPageProps) {
  const { id } = await params;
  const query = await searchParams;
  const episode = await getEpisode(id);

  if (!episode) notFound();

  const updateAction = updateEpisodeAction.bind(null, id);
  const errorMessage = query.error ? ERROR_MESSAGES[query.error] : null;

  return (
    <>
      <header className={pageStyles.pageHeader}>
        <p className={pageStyles.muted}>
          <Link href="/episodes">Episodes</Link> / {episode.title}
        </p>
        <h1 className={pageStyles.pageTitle}>{episode.title}</h1>
        <div className={pageStyles.actions} style={{ marginTop: 12, marginBottom: 0 }}>
          <EpisodeStatusBadge status={episode.status} />
          <EpisodeSourceBadge source={episode.source} />
        </div>
      </header>

      {query.saved ? <p className={styles.success}>Changes saved.</p> : null}
      {errorMessage ? <p className={pageStyles.error}>{errorMessage}</p> : null}

      <div className={styles.detailGrid}>
        <TcidCard>
          <form action={updateAction} className={pageStyles.stack}>
            <TcidInput
              label="Title"
              name="title"
              defaultValue={episode.title}
              required
            />

            <label className={pageStyles.stack} htmlFor="description">
              <span className={pageStyles.muted}>Description</span>
              <textarea
                id="description"
                name="description"
                className={styles.textarea}
                defaultValue={episode.description ?? ""}
              />
            </label>

            <label className={pageStyles.stack} htmlFor="status">
              <span className={pageStyles.muted}>Status</span>
              <select
                id="status"
                name="status"
                className={styles.select}
                defaultValue={episode.status}
              >
                {EPISODE_STATUSES.map((status) => (
                  <option key={status} value={status}>
                    {status}
                  </option>
                ))}
              </select>
            </label>

            {episode.publishedAt ? (
              <input type="hidden" name="published_at" value={episode.publishedAt} />
            ) : null}

            <TcidButton type="submit">Save changes</TcidButton>
          </form>
        </TcidCard>

        <div className={pageStyles.stack}>
          <TcidCard>
            {episode.coverArtUrl ? (
              <Image
                src={episode.coverArtUrl}
                alt=""
                width={280}
                height={280}
                className={styles.artwork}
                style={{ width: "100%", height: "auto" }}
              />
            ) : (
              <div className={styles.artworkPlaceholder} style={{ width: "100%", aspectRatio: "1" }} />
            )}
          </TcidCard>

          <TcidCard className={pageStyles.stack}>
            <div>
              <dt className={pageStyles.muted}>Published</dt>
              <dd className={styles.readonlyField}>{formatEpisodeDate(episode.publishedAt)}</dd>
            </div>
            <div>
              <dt className={pageStyles.muted}>Duration</dt>
              <dd className={styles.readonlyField}>{formatEpisodeDuration(episode.durationSeconds)}</dd>
            </div>
            <div>
              <dt className={pageStyles.muted}>Plays</dt>
              <dd className={styles.readonlyField}>{episode.playCount.toLocaleString()}</dd>
            </div>
            {episode.audioUrl ? (
              <div>
                <dt className={pageStyles.muted}>Audio</dt>
                <dd className={styles.readonlyField}>
                  <a href={episode.audioUrl} target="_blank" rel="noopener noreferrer">
                    Open audio file
                  </a>
                </dd>
              </div>
            ) : null}
          </TcidCard>

          <TcidCard>
            <div className={pageStyles.actions}>
              {episode.status === "published" ? (
                <form action={unpublishEpisodeAction.bind(null, id)}>
                  <TcidButton type="submit" variant="secondary">
                    Unpublish
                  </TcidButton>
                </form>
              ) : (
                <form action={publishEpisodeAction.bind(null, id)}>
                  <TcidButton type="submit">Publish</TcidButton>
                </form>
              )}
              <form action={archiveEpisodeAction.bind(null, id)}>
                <TcidButton type="submit" variant="destructive">
                  Archive
                </TcidButton>
              </form>
              <TcidButtonLink href="/episodes" variant="secondary">
                Back
              </TcidButtonLink>
            </div>
          </TcidCard>
        </div>
      </div>
    </>
  );
}

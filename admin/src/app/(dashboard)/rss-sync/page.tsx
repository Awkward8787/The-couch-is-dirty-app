import { OFFICIAL_RSS_FEED_URL } from "@/lib/constants";
import { previewRssFeed } from "@/lib/rss/parse-feed";
import { syncRssAction } from "@/lib/rss/actions";
import { TcidButton } from "@/components/ui/tcid-button";
import { TcidCard } from "@/components/ui/tcid-card";
import { TcidInput } from "@/components/ui/tcid-input";
import pageStyles from "@/components/ui/page.module.css";
import styles from "@/components/features/episodes/episodes.module.css";

type RssSyncPageProps = {
  searchParams: Promise<{
    total?: string;
    created?: string;
    updated?: string;
    skipped?: string;
    error?: string;
  }>;
};

export default async function RssSyncPage({ searchParams }: RssSyncPageProps) {
  const params = await searchParams;
  let preview: Awaited<ReturnType<typeof previewRssFeed>> | null = null;
  let previewError: string | null = null;

  try {
    preview = await previewRssFeed();
  } catch {
    previewError = "Could not read the RSS feed. Check the URL and try again.";
  }

  const syncComplete = Boolean(params.total);
  const syncFailed = params.error === "sync";

  return (
    <>
      <header className={pageStyles.pageHeader}>
        <h1 className={pageStyles.pageTitle}>RSS sync</h1>
        <p className={pageStyles.pageSubtitle}>
          Import episodes from the official RSS.com feed into Appwrite.
        </p>
      </header>

      {syncComplete ? (
        <p className={styles.success}>
          Sync complete — {params.total} in feed, {params.created} created, {params.updated}{" "}
          updated{params.skipped && params.skipped !== "0" ? `, ${params.skipped} skipped` : ""}.
        </p>
      ) : null}

      {syncFailed ? (
        <p className={pageStyles.error}>
          RSS sync failed. Check the server terminal for details and try again.
        </p>
      ) : null}

      {previewError ? <p className={pageStyles.error}>{previewError}</p> : null}

      <TcidCard className={pageStyles.stack}>
        <TcidInput
          label="RSS feed URL"
          name="rss-feed-url"
          type="url"
          readOnly
          defaultValue={OFFICIAL_RSS_FEED_URL}
        />

        {preview ? (
          <p className={pageStyles.muted}>
            {preview.count} episodes available in feed
            {preview.sampleTitles.length > 0
              ? ` — latest: ${preview.sampleTitles.join(", ")}`
              : ""}
            .
          </p>
        ) : null}

        <form action={syncRssAction}>
          <TcidButton type="submit">Refresh feed</TcidButton>
        </form>

        <p className={pageStyles.muted}>
          Matches the import logic in <code>scripts/seed_appwrite_episodes.py</code>. Existing
          episodes are matched by <code>rss_guid</code> and updated in place.
        </p>
      </TcidCard>
    </>
  );
}

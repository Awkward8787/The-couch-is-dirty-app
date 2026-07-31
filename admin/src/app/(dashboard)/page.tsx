import { OFFICIAL_RSS_FEED_URL, PODCAST_ARTWORK_URL } from "@/lib/constants";
import { getDashboardStats } from "@/lib/dashboard/stats";
import { requireSessionUser } from "@/lib/auth/session";
import { TcidButtonLink } from "@/components/ui/tcid-button";
import { TcidCard } from "@/components/ui/tcid-card";
import { TcidInput } from "@/components/ui/tcid-input";
import { TcidKpiStat } from "@/components/ui/tcid-kpi-stat";
import { TcidSectionHeader } from "@/components/ui/tcid-section-header";
import pageStyles from "@/components/ui/page.module.css";

function formatStat(value: number | undefined) {
  if (value === undefined) return "—";
  return value.toLocaleString();
}

export default async function OverviewPage() {
  const user = await requireSessionUser();
  const stats = await getDashboardStats();
  const firstName = user.name.split(" ")[0] ?? user.name;

  return (
    <>
      <header className={pageStyles.pageHeader}>
        <h1 className={pageStyles.pageTitle}>Welcome back, {firstName}.</h1>
        <p className={pageStyles.pageSubtitle}>
          Real talk. No filter. All on the couch.
        </p>
      </header>

      <section className={pageStyles.kpiGrid}>
        <TcidCard>
          <TcidKpiStat label="Episodes published" value={formatStat(stats?.episodes)} />
        </TcidCard>
        <TcidCard>
          <TcidKpiStat label="Posts in feed" value={formatStat(stats?.posts)} />
        </TcidCard>
        <TcidCard>
          <TcidKpiStat label="Guest applications" value={formatStat(stats?.guestApplications)} />
        </TcidCard>
        <TcidCard>
          <TcidKpiStat label="Plays tracked" value="—" />
        </TcidCard>
      </section>

      <div className={pageStyles.actions}>
        <TcidButtonLink href="/rss-sync" variant="secondary">
          Refresh RSS
        </TcidButtonLink>
        <TcidButtonLink href="/guest-applications" variant="secondary">
          Review guest apps
        </TcidButtonLink>
        <TcidButtonLink href="/episodes" variant="secondary">
          Manage episodes
        </TcidButtonLink>
      </div>

      {!stats ? (
        <TcidCard>
          <p className={pageStyles.muted}>
            Connect <code>APPWRITE_API_KEY</code> in <code>.env.local</code> to load live
            counts from Appwrite.
          </p>
        </TcidCard>
      ) : null}

      <TcidCard>
        <TcidSectionHeader title="RSS sync" actionHref="/rss-sync" actionLabel="Open" />
        <p className={pageStyles.muted}>
          Import episodes automatically from your official RSS.com feed.
        </p>
        <TcidInput
          label="RSS feed URL"
          name="rss-feed-url"
          type="url"
          readOnly
          defaultValue={OFFICIAL_RSS_FEED_URL}
        />
        <div className={pageStyles.actions} style={{ marginBottom: 0, marginTop: 16 }}>
          <TcidButtonLink href="/rss-sync">Refresh feed</TcidButtonLink>
          <span className={pageStyles.muted}>
            Sync runs from the RSS sync page once API key is configured.
          </span>
        </div>
        <p className={pageStyles.muted} style={{ marginTop: 16 }}>
          Podcast artwork:{" "}
          <a href={PODCAST_ARTWORK_URL} target="_blank" rel="noopener noreferrer">
            View cover art
          </a>
        </p>
      </TcidCard>
    </>
  );
}

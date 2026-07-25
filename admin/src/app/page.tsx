import { OFFICIAL_RSS_FEED_URL, PODCAST_ARTWORK_URL } from "@/lib/constants";

export default function DashboardPage() {
  return (
    <main style={{ padding: "2rem", maxWidth: 1200, margin: "0 auto" }}>
      <header style={{ marginBottom: "2rem" }}>
        <h1 style={{ margin: 0 }}>Dashboard</h1>
        <p style={{ color: "var(--muted)" }}>
          Manage your episodes, content, and audience.
        </p>
      </header>

      <section
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(200px, 1fr))",
          gap: "1rem",
          marginBottom: "2rem",
        }}
      >
        {[
          { label: "Total Episodes", value: "—" },
          { label: "Community Members", value: "—" },
          { label: "Total Plays", value: "—" },
        ].map((kpi) => (
          <div
            key={kpi.label}
            style={{
              background: "var(--card)",
              borderRadius: 12,
              padding: "1.25rem",
            }}
          >
            <div style={{ fontSize: "2rem", fontWeight: 700 }}>{kpi.value}</div>
            <div style={{ color: "var(--muted)" }}>{kpi.label}</div>
          </div>
        ))}
      </section>

      <section
        style={{
          background: "var(--card)",
          borderRadius: 12,
          padding: "1.5rem",
          marginBottom: "1.5rem",
        }}
      >
        <h2 style={{ marginTop: 0 }}>RSS Sync</h2>
        <p style={{ color: "var(--muted)", marginBottom: "1rem" }}>
          Import episodes automatically from your official RSS.com feed.
        </p>

        <label
          htmlFor="rss-feed-url"
          style={{ display: "block", marginBottom: "0.5rem", fontSize: "0.875rem" }}
        >
          RSS Feed URL
        </label>
        <input
          id="rss-feed-url"
          type="url"
          readOnly
          defaultValue={OFFICIAL_RSS_FEED_URL}
          style={{
            width: "100%",
            padding: "0.75rem",
            borderRadius: 8,
            border: "1px solid #333",
            background: "#111",
            color: "#fff",
            marginBottom: "1rem",
          }}
        />

        <div style={{ display: "flex", gap: "0.75rem", flexWrap: "wrap" }}>
          <button
            type="button"
            style={{
              padding: "0.75rem 1.25rem",
              borderRadius: 8,
              border: "none",
              background: "var(--accent)",
              color: "#fff",
              fontWeight: 600,
              cursor: "pointer",
            }}
          >
            Refresh Feed
          </button>
          <span style={{ color: "var(--muted)", alignSelf: "center", fontSize: "0.875rem" }}>
            8 episodes available in feed · sync after migrations applied
          </span>
        </div>

        <p style={{ color: "var(--muted)", fontSize: "0.875rem", marginTop: "1rem" }}>
          Podcast artwork:{" "}
          <a href={PODCAST_ARTWORK_URL} target="_blank" rel="noopener noreferrer">
            View cover art
          </a>
        </p>
      </section>

      <p style={{ color: "var(--muted)" }}>
        Full upload, moderation, and analytics tools ship in Phase 7.
      </p>
    </main>
  );
}

import Link from "next/link";
import styles from "./episodes.module.css";
import type { EpisodeSource, EpisodeStatus } from "@/lib/episodes/types";

const STATUS_FILTERS: Array<{ value: EpisodeStatus | "all"; label: string }> = [
  { value: "all", label: "All" },
  { value: "published", label: "Published" },
  { value: "draft", label: "Draft" },
  { value: "scheduled", label: "Scheduled" },
  { value: "archived", label: "Archived" },
];

const SOURCE_FILTERS: Array<{ value: EpisodeSource | "all"; label: string }> = [
  { value: "all", label: "All sources" },
  { value: "rss", label: "From RSS" },
  { value: "manual", label: "Manual" },
];

type EpisodeFilterBarProps = {
  status: EpisodeStatus | "all";
  source: EpisodeSource | "all";
};

function buildHref(status: string, source: string) {
  const params = new URLSearchParams();
  if (status !== "all") params.set("status", status);
  if (source !== "all") params.set("source", source);
  const query = params.toString();
  return query ? `/episodes?${query}` : "/episodes";
}

export function EpisodeFilterBar({ status, source }: EpisodeFilterBarProps) {
  return (
    <div className={styles.bar}>
      {STATUS_FILTERS.map((filter) => (
        <Link
          key={filter.value}
          href={buildHref(filter.value, source)}
          className={[styles.chip, status === filter.value ? styles.chipActive : ""]
            .filter(Boolean)
            .join(" ")}
        >
          {filter.label}
        </Link>
      ))}
      {SOURCE_FILTERS.map((filter) => (
        <Link
          key={filter.value}
          href={buildHref(status, filter.value)}
          className={[styles.chip, source === filter.value ? styles.chipActive : ""]
            .filter(Boolean)
            .join(" ")}
        >
          {filter.label}
        </Link>
      ))}
    </div>
  );
}

export function EpisodeStatusBadge({ status }: { status: EpisodeStatus }) {
  return (
    <span className={[styles.badge, styles[status]].filter(Boolean).join(" ")}>{status}</span>
  );
}

export function EpisodeSourceBadge({ source }: { source: EpisodeSource }) {
  return <span className={[styles.badge, styles.rss].join(" ")}>{source}</span>;
}

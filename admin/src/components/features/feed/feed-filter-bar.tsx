import Link from "next/link";
import styles from "@/components/features/episodes/episodes.module.css";
import type { ModerationStatus } from "@/lib/feed/types";

const STATUS_FILTERS: Array<{ value: ModerationStatus | "all"; label: string }> = [
  { value: "all", label: "All" },
  { value: "visible", label: "Visible" },
  { value: "reported", label: "Reported" },
  { value: "hidden", label: "Hidden" },
  { value: "removed", label: "Removed" },
];

type FeedFilterBarProps = {
  status: ModerationStatus | "all";
};

export function FeedFilterBar({ status }: FeedFilterBarProps) {
  return (
    <div className={styles.bar}>
      {STATUS_FILTERS.map((filter) => {
        const href =
          filter.value === "all" ? "/feed" : `/feed?status=${filter.value}`;
        return (
          <Link
            key={filter.value}
            href={href}
            className={[styles.chip, status === filter.value ? styles.chipActive : ""]
              .filter(Boolean)
              .join(" ")}
          >
            {filter.label}
          </Link>
        );
      })}
    </div>
  );
}

export function FeedStatusBadge({ status }: { status: ModerationStatus }) {
  return (
    <span className={[styles.badge, styles[status] ?? styles.draft].join(" ")}>
      {status}
    </span>
  );
}

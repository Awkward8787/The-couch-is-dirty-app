import Link from "next/link";
import { formatGuestDate } from "@/lib/guests/mapping";
import type { AdminGuestApplication } from "@/lib/guests/types";
import {
  approveGuestApplicationAction,
  declineGuestApplicationAction,
} from "@/lib/guests/actions";
import { TcidButton, TcidButtonLink } from "@/components/ui/tcid-button";
import styles from "@/components/features/episodes/episodes.module.css";

type GuestApplicationListProps = {
  applications: AdminGuestApplication[];
};

function GuestStatusBadge({ status }: { status: AdminGuestApplication["status"] }) {
  return <span className={[styles.badge, styles[status] ?? styles.draft].join(" ")}>{status}</span>;
}

export function GuestApplicationList({ applications }: GuestApplicationListProps) {
  if (applications.length === 0) {
    return <p className={styles.empty}>No guest applications yet.</p>;
  }

  return (
    <div className={styles.stack}>
      {applications.map((application) => (
        <article key={application.id} className={styles.row} style={{ padding: "16px 0" }}>
          <div style={{ display: "flex", gap: 8, alignItems: "center", flexWrap: "wrap" }}>
            <strong>{application.name}</strong>
            <GuestStatusBadge status={application.status} />
          </div>
          {application.email ? <p className={styles.meta}>{application.email}</p> : null}
          {application.topic ? <p style={{ margin: "8px 0 0" }}>{application.topic}</p> : null}
          <p className={styles.meta}>{formatGuestDate(application.createdAt)}</p>
          <div className={styles.actions} style={{ marginTop: 12 }}>
            <TcidButtonLink href={`/guest-applications/${application.id}`} variant="secondary">
              View details
            </TcidButtonLink>
            {application.status === "pending" ? (
              <>
                <form action={approveGuestApplicationAction.bind(null, application.id)}>
                  <TcidButton type="submit">Approve</TcidButton>
                </form>
                <form action={declineGuestApplicationAction.bind(null, application.id)}>
                  <TcidButton type="submit" variant="destructive">
                    Decline
                  </TcidButton>
                </form>
              </>
            ) : null}
          </div>
        </article>
      ))}
    </div>
  );
}

export function GuestFilterBar({ status }: { status: string }) {
  const filters = [
    { value: "all", label: "All" },
    { value: "pending", label: "Pending" },
    { value: "approved", label: "Approved" },
    { value: "declined", label: "Declined" },
  ];

  return (
    <div className={styles.bar}>
      {filters.map((filter) => {
        const href =
          filter.value === "all"
            ? "/guest-applications"
            : `/guest-applications?status=${filter.value}`;
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

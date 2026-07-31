import Link from "next/link";
import { notFound } from "next/navigation";
import {
  approveGuestApplicationAction,
  declineGuestApplicationAction,
  resetGuestApplicationAction,
} from "@/lib/guests/actions";
import { formatGuestDate } from "@/lib/guests/mapping";
import { getGuestApplication } from "@/lib/guests/queries";
import { TcidButton, TcidButtonLink } from "@/components/ui/tcid-button";
import { TcidCard } from "@/components/ui/tcid-card";
import pageStyles from "@/components/ui/page.module.css";
import styles from "@/components/features/episodes/episodes.module.css";

type GuestDetailPageProps = {
  params: Promise<{ id: string }>;
  searchParams: Promise<{ saved?: string }>;
};

export default async function GuestApplicationDetailPage({
  params,
  searchParams,
}: GuestDetailPageProps) {
  const { id } = await params;
  const query = await searchParams;
  const application = await getGuestApplication(id);
  if (!application) notFound();

  return (
    <>
      <header className={pageStyles.pageHeader}>
        <p className={pageStyles.muted}>
          <Link href="/guest-applications">Guest applications</Link> / {application.name}
        </p>
        <h1 className={pageStyles.pageTitle}>{application.name}</h1>
      </header>

      {query.saved ? <p className={styles.success}>Application updated.</p> : null}

      <TcidCard className={pageStyles.stack}>
        <div>
          <dt className={pageStyles.muted}>Status</dt>
          <dd className={styles.readonlyField}>{application.status}</dd>
        </div>
        {application.email ? (
          <div>
            <dt className={pageStyles.muted}>Email</dt>
            <dd className={styles.readonlyField}>{application.email}</dd>
          </div>
        ) : null}
        {application.format ? (
          <div>
            <dt className={pageStyles.muted}>Format</dt>
            <dd className={styles.readonlyField}>{application.format}</dd>
          </div>
        ) : null}
        {application.topic ? (
          <div>
            <dt className={pageStyles.muted}>Topic</dt>
            <dd className={styles.readonlyField}>{application.topic}</dd>
          </div>
        ) : null}
        {application.message ? (
          <div>
            <dt className={pageStyles.muted}>Message</dt>
            <dd className={styles.readonlyField}>{application.message}</dd>
          </div>
        ) : null}
        <div>
          <dt className={pageStyles.muted}>Submitted</dt>
          <dd className={styles.readonlyField}>{formatGuestDate(application.createdAt)}</dd>
        </div>

        <div className={styles.actions}>
          {application.status !== "approved" ? (
            <form action={approveGuestApplicationAction.bind(null, id)}>
              <TcidButton type="submit">Approve</TcidButton>
            </form>
          ) : null}
          {application.status !== "declined" ? (
            <form action={declineGuestApplicationAction.bind(null, id)}>
              <TcidButton type="submit" variant="destructive">
                Decline
              </TcidButton>
            </form>
          ) : null}
          {application.status !== "pending" ? (
            <form action={resetGuestApplicationAction.bind(null, id)}>
              <TcidButton type="submit" variant="secondary">
                Mark pending
              </TcidButton>
            </form>
          ) : null}
          <TcidButtonLink href="/guest-applications" variant="secondary">
            Back
          </TcidButtonLink>
        </div>
      </TcidCard>
    </>
  );
}

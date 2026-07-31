import { TcidCard } from "@/components/ui/tcid-card";
import pageStyles from "@/components/ui/page.module.css";
import {
  GuestApplicationList,
  GuestFilterBar,
} from "@/components/features/guests/guest-application-list";
import type { AdminGuestApplication } from "@/lib/guests/types";
import { listGuestApplications, parseGuestListFilter } from "@/lib/guests/queries";

type GuestApplicationsPageProps = {
  searchParams: Promise<{ status?: string; error?: string }>;
};

const ERROR_MESSAGES: Record<string, string> = {
  approve: "Could not approve that application.",
  decline: "Could not decline that application.",
  reset: "Could not reset that application.",
};

export default async function GuestApplicationsPage({ searchParams }: GuestApplicationsPageProps) {
  const params = await searchParams;
  const filter = parseGuestListFilter(params);
  let applications: AdminGuestApplication[] = [];
  let loadError: string | null = null;

  try {
    applications = await listGuestApplications(filter);
  } catch {
    loadError =
      "Could not load guest applications. Check APPWRITE_API_KEY and guest_applications collection.";
  }

  return (
    <>
      <header className={pageStyles.pageHeader}>
        <h1 className={pageStyles.pageTitle}>Guest applications</h1>
        <p className={pageStyles.pageSubtitle}>Review Be a Guest submissions from listeners.</p>
      </header>

      {params.error ? <p className={pageStyles.error}>{ERROR_MESSAGES[params.error]}</p> : null}
      {loadError ? <p className={pageStyles.error}>{loadError}</p> : null}

      <GuestFilterBar status={filter.status ?? "all"} />

      <TcidCard>
        <GuestApplicationList applications={applications} />
      </TcidCard>
    </>
  );
}

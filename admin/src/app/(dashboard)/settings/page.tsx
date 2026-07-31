import { getAppwriteConfig } from "@/lib/appwrite/config";
import { TcidCard } from "@/components/ui/tcid-card";
import pageStyles from "@/components/ui/page.module.css";

export default function SettingsPage() {
  const { endpoint, projectId, databaseId } = getAppwriteConfig();
  const adminEmails = process.env.ADMIN_ALLOWED_EMAILS ?? "—";

  return (
    <>
      <header className={pageStyles.pageHeader}>
        <h1 className={pageStyles.pageTitle}>Settings</h1>
        <p className={pageStyles.pageSubtitle}>Admin connection and access control.</p>
      </header>

      <TcidCard>
        <dl className={pageStyles.stack}>
          <div>
            <dt className={pageStyles.muted}>Appwrite endpoint</dt>
            <dd>{endpoint}</dd>
          </div>
          <div>
            <dt className={pageStyles.muted}>Project ID</dt>
            <dd>{projectId}</dd>
          </div>
          <div>
            <dt className={pageStyles.muted}>Database ID</dt>
            <dd>{databaseId}</dd>
          </div>
          <div>
            <dt className={pageStyles.muted}>Allowed admin emails</dt>
            <dd>{adminEmails}</dd>
          </div>
        </dl>
      </TcidCard>
    </>
  );
}

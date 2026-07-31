import Image from "next/image";
import { TcidCard } from "@/components/ui/tcid-card";
import pageStyles from "@/components/ui/page.module.css";
import type { AdminMember } from "@/lib/members/queries";
import { listMembers } from "@/lib/members/queries";
import styles from "@/components/features/episodes/episodes.module.css";

export default async function MembersPage() {
  let members: AdminMember[] = [];
  let loadError: string | null = null;

  try {
    members = await listMembers();
  } catch {
    loadError = "Could not load members. Check APPWRITE_API_KEY and profiles collection.";
  }

  return (
    <>
      <header className={pageStyles.pageHeader}>
        <h1 className={pageStyles.pageTitle}>Members</h1>
        <p className={pageStyles.pageSubtitle}>View community members and profile roles.</p>
      </header>

      {loadError ? <p className={pageStyles.error}>{loadError}</p> : null}

      <TcidCard>
        {members.length === 0 ? (
          <p className={styles.empty}>No member profiles found yet.</p>
        ) : (
          <table className={styles.table}>
            <tbody>
              {members.map((member) => (
                <tr key={member.id} className={styles.row}>
                  <td className={styles.cell}>
                    {member.avatarUrl ? (
                      <Image
                        src={member.avatarUrl}
                        alt=""
                        width={40}
                        height={40}
                        className={styles.artwork}
                        style={{ borderRadius: "999px" }}
                      />
                    ) : (
                      <div
                        className={styles.artworkPlaceholder}
                        style={{ borderRadius: "999px" }}
                        aria-hidden
                      />
                    )}
                  </td>
                  <td className={styles.cellTitle}>
                    <strong>{member.displayName}</strong>
                    {member.username ? (
                      <div className={styles.meta}>@{member.username}</div>
                    ) : null}
                  </td>
                  <td className={styles.cell}>
                    <span className={[styles.badge, styles.rss].join(" ")}>{member.role}</span>
                  </td>
                  <td className={styles.cell}>
                    <span className={[styles.badge, styles.draft].join(" ")}>
                      {member.accountStatus}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </TcidCard>
    </>
  );
}

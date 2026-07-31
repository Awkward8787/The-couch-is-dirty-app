import Link from "next/link";
import styles from "./tcid-section-header.module.css";

type TcidSectionHeaderProps = {
  title: string;
  actionHref?: string;
  actionLabel?: string;
};

export function TcidSectionHeader({ title, actionHref, actionLabel }: TcidSectionHeaderProps) {
  return (
    <div className={styles.header}>
      <h2 className={styles.title}>{title}</h2>
      {actionHref && actionLabel ? (
        <Link className={styles.action} href={actionHref}>
          {actionLabel} →
        </Link>
      ) : null}
    </div>
  );
}

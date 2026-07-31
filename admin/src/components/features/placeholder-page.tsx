import { TcidCard } from "@/components/ui/tcid-card";
import pageStyles from "@/components/ui/page.module.css";

type PlaceholderPageProps = {
  title: string;
  description: string;
};

export function PlaceholderPage({ title, description }: PlaceholderPageProps) {
  return (
    <>
      <header className={pageStyles.pageHeader}>
        <h1 className={pageStyles.pageTitle}>{title}</h1>
        <p className={pageStyles.pageSubtitle}>{description}</p>
      </header>
      <TcidCard>
        <p className={pageStyles.muted}>
          This section is scaffolded. Data wiring ships in the next Phase 7 tasks.
        </p>
      </TcidCard>
    </>
  );
}

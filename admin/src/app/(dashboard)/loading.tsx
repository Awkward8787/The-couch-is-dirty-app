import { TcidCard } from "@/components/ui/tcid-card";
import pageStyles from "@/components/ui/page.module.css";

export default function DashboardLoading() {
  return (
    <div className={pageStyles.stack}>
      <div className={pageStyles.pageHeader}>
        <div className={pageStyles.skeleton} style={{ height: 32, width: 240 }} />
        <div className={pageStyles.skeleton} style={{ height: 18, width: 320, marginTop: 8 }} />
      </div>
      <div className={pageStyles.kpiGrid}>
        {Array.from({ length: 4 }).map((_, index) => (
          <TcidCard key={index}>
            <div className={pageStyles.skeleton} style={{ height: 64 }} />
          </TcidCard>
        ))}
      </div>
      <TcidCard>
        <div className={pageStyles.skeleton} style={{ height: 160 }} />
      </TcidCard>
    </div>
  );
}

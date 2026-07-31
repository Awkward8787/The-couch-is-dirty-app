import { TcidCard } from "@/components/ui/tcid-card";
import pageStyles from "@/components/ui/page.module.css";

export default function EpisodesLoading() {
  return (
    <div className={pageStyles.stack}>
      <div className={pageStyles.pageHeader}>
        <div className={pageStyles.skeleton} style={{ height: 32, width: 180 }} />
        <div className={pageStyles.skeleton} style={{ height: 18, width: 320, marginTop: 8 }} />
      </div>
      <div className={pageStyles.skeleton} style={{ height: 36, width: "100%", maxWidth: 640 }} />
      <TcidCard>
        <div className={pageStyles.skeleton} style={{ height: 280 }} />
      </TcidCard>
    </div>
  );
}

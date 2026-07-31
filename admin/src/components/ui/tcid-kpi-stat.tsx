import styles from "./tcid-kpi-stat.module.css";

type TcidKpiStatProps = {
  label: string;
  value: string | number;
};

export function TcidKpiStat({ label, value }: TcidKpiStatProps) {
  return (
    <div className={styles.stat}>
      <div className={styles.value}>{value}</div>
      <div className={styles.label}>{label}</div>
    </div>
  );
}

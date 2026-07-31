import styles from "./tcid-card.module.css";

type TcidCardProps = React.ComponentProps<"div"> & {
  elevated?: boolean;
};

export function TcidCard({ elevated = false, className, ...props }: TcidCardProps) {
  const classes = [styles.card, elevated ? styles.elevated : "", className ?? ""]
    .filter(Boolean)
    .join(" ");

  return <div className={classes} {...props} />;
}

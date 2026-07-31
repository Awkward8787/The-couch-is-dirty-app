import styles from "./tcid-input.module.css";

type TcidInputProps = React.ComponentProps<"input"> & {
  label: string;
};

export function TcidInput({ label, id, className, ...props }: TcidInputProps) {
  const inputId = id ?? label.toLowerCase().replace(/\s+/g, "-");

  return (
    <label className={styles.field} htmlFor={inputId}>
      <span className={styles.label}>{label}</span>
      <input id={inputId} className={[styles.input, className ?? ""].join(" ")} {...props} />
    </label>
  );
}

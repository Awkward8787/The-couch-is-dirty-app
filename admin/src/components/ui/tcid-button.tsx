import Link from "next/link";
import styles from "./tcid-button.module.css";

type TcidButtonProps = React.ComponentProps<"button"> & {
  variant?: "primary" | "secondary" | "destructive";
  fullWidth?: boolean;
};

function buttonClassName(
  variant: TcidButtonProps["variant"],
  fullWidth: boolean,
  className?: string,
) {
  return [styles.button, styles[variant ?? "primary"], fullWidth ? styles.fullWidth : "", className ?? ""]
    .filter(Boolean)
    .join(" ");
}

export function TcidButton({
  variant = "primary",
  fullWidth = false,
  className,
  type = "button",
  ...props
}: TcidButtonProps) {
  return (
    <button type={type} className={buttonClassName(variant, fullWidth, className)} {...props} />
  );
}

type TcidButtonLinkProps = {
  href: string;
  variant?: TcidButtonProps["variant"];
  fullWidth?: boolean;
  className?: string;
  children: React.ReactNode;
};

export function TcidButtonLink({
  href,
  variant = "primary",
  fullWidth = false,
  className,
  children,
}: TcidButtonLinkProps) {
  return (
    <Link href={href} className={buttonClassName(variant, fullWidth, className)}>
      {children}
    </Link>
  );
}

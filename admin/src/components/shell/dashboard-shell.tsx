"use client";

import { useState } from "react";
import Image from "next/image";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { logoutAction } from "@/lib/auth/actions";
import { TcidButton } from "@/components/ui/tcid-button";
import styles from "./dashboard-shell.module.css";

const NAV_ITEMS = [
  { href: "/", label: "Overview" },
  { href: "/episodes", label: "Episodes" },
  { href: "/feed", label: "Feed" },
  { href: "/guest-applications", label: "Guest apps" },
  { href: "/members", label: "Members" },
  { href: "/rss-sync", label: "RSS sync" },
  { href: "/settings", label: "Settings" },
] as const;

type DashboardShellProps = {
  userEmail: string;
  children: React.ReactNode;
};

export function DashboardShell({ userEmail, children }: DashboardShellProps) {
  const pathname = usePathname();
  const [sidebarOpen, setSidebarOpen] = useState(false);

  const activeItem = NAV_ITEMS.find((item) =>
    item.href === "/" ? pathname === "/" : pathname.startsWith(item.href),
  );

  return (
    <div className={styles.shell}>
      <button
        type="button"
        className={sidebarOpen ? `${styles.overlay} ${styles.overlayVisible}` : styles.overlay}
        aria-label="Close navigation"
        onClick={() => setSidebarOpen(false)}
      />

      <aside
        className={[styles.sidebar, sidebarOpen ? styles.sidebarOpen : ""].filter(Boolean).join(" ")}
      >
        <div className={styles.brand}>
          <Image
            src="/podcast-logo.png"
            alt="The Couch Is Dirty Podcast"
            width={140}
            height={36}
            className={styles.logo}
            priority
          />
          <span className={styles.brandLabel}>TCID Admin</span>
        </div>

        <nav className={styles.nav} aria-label="Main">
          {NAV_ITEMS.map((item) => {
            const isActive =
              item.href === "/"
                ? pathname === "/"
                : pathname === item.href || pathname.startsWith(`${item.href}/`);

            return (
              <Link
                key={item.href}
                href={item.href}
                className={[styles.navLink, isActive ? styles.navLinkActive : ""]
                  .filter(Boolean)
                  .join(" ")}
                onClick={() => setSidebarOpen(false)}
              >
                {item.label}
              </Link>
            );
          })}
        </nav>
      </aside>

      <div className={styles.main}>
        <header className={styles.topbar}>
          <div style={{ display: "flex", alignItems: "center", gap: "12px" }}>
            <button
              type="button"
              className={styles.mobileToggle}
              aria-label="Open navigation"
              onClick={() => setSidebarOpen(true)}
            >
              Menu
            </button>
            <span className={styles.breadcrumb}>{activeItem?.label ?? "Dashboard"}</span>
          </div>

          <div className={styles.userBlock}>
            <span className={styles.userEmail}>{userEmail}</span>
            <form action={logoutAction}>
              <TcidButton type="submit" variant="secondary">
                Sign out
              </TcidButton>
            </form>
          </div>
        </header>

        <main className={styles.content}>{children}</main>
      </div>
    </div>
  );
}

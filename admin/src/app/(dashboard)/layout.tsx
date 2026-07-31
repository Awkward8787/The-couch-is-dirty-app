import { DashboardShell } from "@/components/shell/dashboard-shell";
import { requireSessionUser } from "@/lib/auth/session";

export default async function DashboardLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  const user = await requireSessionUser();

  return <DashboardShell userEmail={user.email}>{children}</DashboardShell>;
}

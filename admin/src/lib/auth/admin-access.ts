/** Admin allowlist — Appwrite auth email must match (Phase 7 dashboard). */
export function isAdminEmail(email: string | undefined): boolean {
  if (!email) return false;
  const allowed = (process.env.ADMIN_ALLOWED_EMAILS ?? "")
    .split(",")
    .map((entry) => entry.trim().toLowerCase())
    .filter(Boolean);
  return allowed.includes(email.toLowerCase());
}

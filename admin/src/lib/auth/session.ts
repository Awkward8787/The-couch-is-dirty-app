import { cookies } from "next/headers";
import { redirect } from "next/navigation";
import { sessionCookieName } from "@/lib/appwrite/config";
import { isAdminEmail } from "./admin-access";
import { getAdminUserById } from "./admin-user";
import {
  ADMIN_SESSION_ID_COOKIE,
  ADMIN_USER_ID_COOKIE,
} from "./constants";

export type AdminSessionUser = {
  id: string;
  email: string;
  name: string;
};

export async function getSessionSecret() {
  const cookieStore = await cookies();
  return cookieStore.get(sessionCookieName())?.value ?? null;
}

export async function getSessionUser(): Promise<AdminSessionUser | null> {
  const cookieStore = await cookies();
  const userId = cookieStore.get(ADMIN_USER_ID_COOKIE)?.value;
  const secret = cookieStore.get(sessionCookieName())?.value;

  if (!userId || !secret) return null;

  const user = await getAdminUserById(userId);
  if (!user || !isAdminEmail(user.email)) return null;

  return user;
}

export async function requireSessionUser(): Promise<AdminSessionUser> {
  const user = await getSessionUser();
  if (!user) redirect("/login");
  return user;
}

export async function setSessionCookie(
  secret: string,
  expire: string,
  userId: string,
  sessionId: string,
) {
  const cookieStore = await cookies();
  const expires = new Date(expire);
  const options = {
    httpOnly: true,
    secure: process.env.NODE_ENV === "production",
    sameSite: "lax" as const,
    path: "/",
    expires,
  };

  cookieStore.set(sessionCookieName(), secret, options);
  cookieStore.set(ADMIN_USER_ID_COOKIE, userId, options);
  cookieStore.set(ADMIN_SESSION_ID_COOKIE, sessionId, options);
}

export async function clearSessionCookie() {
  const cookieStore = await cookies();
  cookieStore.delete(sessionCookieName());
  cookieStore.delete(ADMIN_USER_ID_COOKIE);
  cookieStore.delete(ADMIN_SESSION_ID_COOKIE);
}

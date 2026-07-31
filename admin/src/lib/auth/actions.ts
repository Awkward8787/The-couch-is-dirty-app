"use server";

import { redirect } from "next/navigation";
import { cookies } from "next/headers";
import { getAppwriteConfig } from "@/lib/appwrite/config";
import { isAdminEmail } from "./admin-access";
import {
  AppwriteAuthError,
  createEmailPasswordSession,
} from "./appwrite-session";
import { deleteUserSession } from "./admin-user";
import {
  ADMIN_SESSION_ID_COOKIE,
  ADMIN_USER_ID_COOKIE,
} from "./constants";
import { clearSessionCookie, setSessionCookie } from "./session";

export async function loginAction(formData: FormData) {
  const email = String(formData.get("email") ?? "").trim().toLowerCase();
  const password = String(formData.get("password") ?? "");

  if (!email || !password) {
    redirect("/login?error=missing");
  }

  if (!isAdminEmail(email)) {
    redirect("/login?error=not-allowed");
  }

  const { endpoint, projectId } = getAppwriteConfig();

  let session;
  try {
    session = await createEmailPasswordSession(endpoint, projectId, email, password);
  } catch (error) {
    if (error instanceof AppwriteAuthError) {
      redirect("/login?error=invalid");
    }
    redirect("/login?error=server");
  }

  await setSessionCookie(session.secret, session.expire, session.userId, session.sessionId);
  redirect("/");
}

export async function logoutAction() {
  const cookieStore = await cookies();
  const userId = cookieStore.get(ADMIN_USER_ID_COOKIE)?.value;
  const sessionId = cookieStore.get(ADMIN_SESSION_ID_COOKIE)?.value;

  if (userId && sessionId) {
    try {
      await deleteUserSession(userId, sessionId);
    } catch {
      // Session may already be expired.
    }
  }

  await clearSessionCookie();
  redirect("/login");
}

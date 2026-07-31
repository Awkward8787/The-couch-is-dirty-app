import { sessionCookieName } from "@/lib/appwrite/config";

export class AppwriteAuthError extends Error {
  type: string;
  code: number;

  constructor(message: string, type: string, code: number) {
    super(message);
    this.name = "AppwriteAuthError";
    this.type = type;
    this.code = code;
  }
}

export type EmailPasswordSessionResult = {
  sessionId: string;
  userId: string;
  expire: string;
  secret: string;
};

type SessionCookiePayload = {
  id?: string;
  secret?: string;
};

/** Appwrite 1.9+ omits `secret` from JSON; it is only in Set-Cookie / X-Fallback-Cookies. */
export async function createEmailPasswordSession(
  endpoint: string,
  projectId: string,
  email: string,
  password: string,
): Promise<EmailPasswordSessionResult> {
  const response = await fetch(`${endpoint.replace(/\/$/, "")}/account/sessions/email`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "X-Appwrite-Project": projectId,
    },
    body: JSON.stringify({ email, password }),
  });

  const data = (await response.json()) as Record<string, string>;

  if (!response.ok) {
    throw new AppwriteAuthError(
      data.message ?? "Authentication failed.",
      data.type ?? "unknown",
      response.status,
    );
  }

  const secret = extractSessionSecret(response, projectId);
  if (!secret) {
    throw new Error("Appwrite did not return a session secret.");
  }

  return {
    sessionId: data.$id,
    userId: data.userId,
    expire: data.expire,
    secret,
  };
}

function extractSessionSecret(response: Response, projectId: string): string | null {
  const cookieName = sessionCookieName();

  const fallback = response.headers.get("x-fallback-cookies");
  if (fallback) {
    try {
      const parsed = JSON.parse(fallback) as Record<string, string>;
      const secret = decodeSessionCookieValue(parsed[cookieName]);
      if (secret) return secret;
    } catch {
      // Fall through to Set-Cookie parsing.
    }
  }

  const setCookies =
    typeof response.headers.getSetCookie === "function"
      ? response.headers.getSetCookie()
      : [];

  for (const cookie of setCookies) {
    if (!cookie.startsWith(`${cookieName}=`)) continue;
    const value = cookie.slice(cookieName.length + 1).split(";")[0];
    const secret = decodeSessionCookieValue(value);
    if (secret) return secret;
  }

  return null;
}

function decodeSessionCookieValue(value: string | undefined): string | null {
  if (!value) return null;

  try {
    const payload = JSON.parse(
      Buffer.from(value, "base64").toString("utf8"),
    ) as SessionCookiePayload;
    return payload.secret ?? null;
  } catch {
    return null;
  }
}

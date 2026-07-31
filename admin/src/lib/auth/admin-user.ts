import { Users } from "node-appwrite";
import { createAdminClient } from "@/lib/appwrite/server";
import type { AdminSessionUser } from "./session";

export async function getAdminUserById(userId: string): Promise<AdminSessionUser | null> {
  try {
    const users = new Users(createAdminClient());
    const user = await users.get(userId);

    return {
      id: user.$id,
      email: user.email,
      name: user.name ?? user.email.split("@")[0] ?? "Admin",
    };
  } catch {
    return null;
  }
}

export async function deleteUserSession(userId: string, sessionId: string): Promise<void> {
  const users = new Users(createAdminClient());
  await users.deleteSession(userId, sessionId);
}

import type { Models } from "node-appwrite";
import { Databases, Query } from "node-appwrite";
import { APPWRITE_COLLECTIONS } from "@/lib/appwrite/collections";
import { createAdminClient } from "@/lib/appwrite/server";
import { getAppwriteConfig } from "@/lib/appwrite/config";

import { avatarViewUrl } from "@/lib/appwrite/storage";

export type AdminMember = {
  id: string;
  displayName: string;
  username: string | null;
  role: string;
  accountStatus: string;
  avatarUrl: string | null;
};

function readString(data: Record<string, unknown>, key: string): string | null {
  const value = data[key];
  if (typeof value === "string" && value.trim()) return value.trim();
  return null;
}

function mapProfile(document: Models.Document): AdminMember {
  const data = document as Models.Document & Record<string, unknown>;
  const avatarFileId = readString(data, "avatar_url");

  return {
    id: document.$id,
    displayName:
      readString(data, "display_name") ??
      readString(data, "username") ??
      document.$id.slice(0, 8),
    username: readString(data, "username"),
    role: readString(data, "role") ?? "user",
    accountStatus: readString(data, "account_status") ?? "active",
    avatarUrl: avatarFileId ? avatarViewUrl(avatarFileId) : null,
  };
}

export async function listMembers(): Promise<AdminMember[]> {
  const { databaseId } = getAppwriteConfig();
  const databases = new Databases(createAdminClient());
  const result = await databases.listDocuments(databaseId, APPWRITE_COLLECTIONS.profiles, [
    Query.orderDesc("$createdAt"),
    Query.limit(50),
  ]);

  return result.documents.map(mapProfile);
}

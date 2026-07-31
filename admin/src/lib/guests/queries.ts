import { Databases, Query } from "node-appwrite";
import { APPWRITE_COLLECTIONS } from "@/lib/appwrite/collections";
import { createAdminClient } from "@/lib/appwrite/server";
import { getAppwriteConfig } from "@/lib/appwrite/config";
import { mapGuestApplication } from "./mapping";
import type {
  AdminGuestApplication,
  GuestApplicationStatus,
  GuestListFilter,
} from "./types";

export async function listGuestApplications(
  filter: GuestListFilter = {},
): Promise<AdminGuestApplication[]> {
  const { databaseId } = getAppwriteConfig();
  const databases = new Databases(createAdminClient());
  const queries = [Query.orderDesc("$createdAt"), Query.limit(50)];

  if (filter.status && filter.status !== "all") {
    queries.push(Query.equal("status", filter.status));
  }

  const result = await databases.listDocuments(
    databaseId,
    APPWRITE_COLLECTIONS.guestApplications,
    queries,
  );

  return result.documents.map(mapGuestApplication);
}

export async function getGuestApplication(documentId: string): Promise<AdminGuestApplication | null> {
  const { databaseId } = getAppwriteConfig();
  const databases = new Databases(createAdminClient());

  try {
    const document = await databases.getDocument(
      databaseId,
      APPWRITE_COLLECTIONS.guestApplications,
      documentId,
    );
    return mapGuestApplication(document);
  } catch {
    return null;
  }
}

export function parseGuestListFilter(searchParams: {
  status?: string;
}): GuestListFilter {
  const valid: Array<GuestApplicationStatus | "all"> = [
    "all",
    "pending",
    "approved",
    "declined",
  ];
  const status = searchParams.status;

  return {
    status: valid.includes(status as GuestApplicationStatus | "all")
      ? (status as GuestApplicationStatus | "all")
      : "all",
  };
}

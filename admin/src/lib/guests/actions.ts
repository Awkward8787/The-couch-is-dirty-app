"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { Databases } from "node-appwrite";
import { APPWRITE_COLLECTIONS } from "@/lib/appwrite/collections";
import { createAdminClient } from "@/lib/appwrite/server";
import { getAppwriteConfig } from "@/lib/appwrite/config";
import { requireSessionUser } from "@/lib/auth/session";

async function updateGuestStatus(documentId: string, status: string) {
  await requireSessionUser();
  const { databaseId } = getAppwriteConfig();
  const databases = new Databases(createAdminClient());

  await databases.updateDocument(
    databaseId,
    APPWRITE_COLLECTIONS.guestApplications,
    documentId,
    { status },
  );
}

export async function approveGuestApplicationAction(documentId: string) {
  try {
    await updateGuestStatus(documentId, "approved");
  } catch {
    redirect("/guest-applications?error=approve");
  }

  revalidatePath("/guest-applications");
  revalidatePath(`/guest-applications/${documentId}`);
  redirect(`/guest-applications/${documentId}?saved=1`);
}

export async function declineGuestApplicationAction(documentId: string) {
  try {
    await updateGuestStatus(documentId, "declined");
  } catch {
    redirect("/guest-applications?error=decline");
  }

  revalidatePath("/guest-applications");
  revalidatePath(`/guest-applications/${documentId}`);
  redirect(`/guest-applications/${documentId}?saved=1`);
}

export async function resetGuestApplicationAction(documentId: string) {
  try {
    await updateGuestStatus(documentId, "pending");
  } catch {
    redirect("/guest-applications?error=reset");
  }

  revalidatePath("/guest-applications");
  revalidatePath(`/guest-applications/${documentId}`);
  redirect(`/guest-applications/${documentId}?saved=1`);
}

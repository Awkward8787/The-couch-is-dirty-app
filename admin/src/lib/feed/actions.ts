"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { Databases } from "node-appwrite";
import { APPWRITE_COLLECTIONS } from "@/lib/appwrite/collections";
import { createAdminClient } from "@/lib/appwrite/server";
import { getAppwriteConfig } from "@/lib/appwrite/config";
import { requireSessionUser } from "@/lib/auth/session";

async function updatePostModeration(documentId: string, moderationStatus: string) {
  await requireSessionUser();
  const { databaseId } = getAppwriteConfig();
  const databases = new Databases(createAdminClient());

  await databases.updateDocument(databaseId, APPWRITE_COLLECTIONS.posts, documentId, {
    moderation_status: moderationStatus,
  });
}

export async function hidePostAction(documentId: string) {
  try {
    await updatePostModeration(documentId, "hidden");
  } catch {
    redirect("/feed?error=hide");
  }

  revalidatePath("/feed");
  revalidatePath(`/feed/${documentId}`);
  redirect(`/feed/${documentId}?saved=1`);
}

export async function restorePostAction(documentId: string) {
  try {
    await updatePostModeration(documentId, "visible");
  } catch {
    redirect("/feed?error=restore");
  }

  revalidatePath("/feed");
  revalidatePath(`/feed/${documentId}`);
  redirect(`/feed/${documentId}?saved=1`);
}

export async function removePostAction(documentId: string) {
  try {
    await updatePostModeration(documentId, "removed");
  } catch {
    redirect("/feed?error=remove");
  }

  revalidatePath("/feed");
  revalidatePath(`/feed/${documentId}`);
  redirect(`/feed/${documentId}?saved=1`);
}

export async function deleteCommentAction(commentId: string, postId: string) {
  await requireSessionUser();
  const { databaseId } = getAppwriteConfig();
  const databases = new Databases(createAdminClient());

  try {
    await databases.deleteDocument(databaseId, APPWRITE_COLLECTIONS.postComments, commentId);
  } catch {
    redirect(`/feed/${postId}?error=comment-delete`);
  }

  revalidatePath("/feed");
  revalidatePath(`/feed/${postId}`);
  redirect(`/feed/${postId}?saved=1`);
}

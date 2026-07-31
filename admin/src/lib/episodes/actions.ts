"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { Databases } from "node-appwrite";
import { z } from "zod";
import { APPWRITE_COLLECTIONS } from "@/lib/appwrite/collections";
import { createAdminClient } from "@/lib/appwrite/server";
import { getAppwriteConfig } from "@/lib/appwrite/config";
import { requireSessionUser } from "@/lib/auth/session";
import { EPISODE_STATUSES } from "./types";

const updateEpisodeSchema = z.object({
  title: z.string().trim().min(1, "Title is required.").max(300),
  description: z.string().trim().max(10000).optional(),
  status: z.enum(EPISODE_STATUSES),
});

async function updateEpisodeDocument(
  documentId: string,
  data: Record<string, string | number | boolean | null>,
) {
  await requireSessionUser();
  const { databaseId } = getAppwriteConfig();
  const databases = new Databases(createAdminClient());

  await databases.updateDocument(databaseId, APPWRITE_COLLECTIONS.episodes, documentId, data);
}

export async function updateEpisodeAction(documentId: string, formData: FormData) {
  await requireSessionUser();

  const parsed = updateEpisodeSchema.safeParse({
    title: formData.get("title"),
    description: formData.get("description") ?? "",
    status: formData.get("status"),
  });

  if (!parsed.success) {
    redirect(`/episodes/${documentId}?error=validation`);
  }

  const payload: Record<string, string> = {
    title: parsed.data.title,
    status: parsed.data.status,
  };

  if (parsed.data.description) {
    payload.description = parsed.data.description;
  }

  if (parsed.data.status === "published" && !formData.get("published_at")) {
    payload.published_at = new Date().toISOString();
  }

  try {
    await updateEpisodeDocument(documentId, payload);
  } catch {
    redirect(`/episodes/${documentId}?error=save`);
  }

  revalidatePath("/episodes");
  revalidatePath(`/episodes/${documentId}`);
  revalidatePath("/");
  redirect(`/episodes/${documentId}?saved=1`);
}

export async function publishEpisodeAction(documentId: string) {
  await requireSessionUser();

  try {
    await updateEpisodeDocument(documentId, {
      status: "published",
      published_at: new Date().toISOString(),
    });
  } catch {
    redirect(`/episodes?error=publish`);
  }

  revalidatePath("/episodes");
  revalidatePath(`/episodes/${documentId}`);
  revalidatePath("/");
  redirect(`/episodes/${documentId}?saved=1`);
}

export async function unpublishEpisodeAction(documentId: string) {
  await requireSessionUser();

  try {
    await updateEpisodeDocument(documentId, {
      status: "draft",
    });
  } catch {
    redirect(`/episodes?error=unpublish`);
  }

  revalidatePath("/episodes");
  revalidatePath(`/episodes/${documentId}`);
  revalidatePath("/");
  redirect(`/episodes/${documentId}?saved=1`);
}

export async function archiveEpisodeAction(documentId: string) {
  await requireSessionUser();

  try {
    await updateEpisodeDocument(documentId, {
      status: "archived",
    });
  } catch {
    redirect(`/episodes?error=archive`);
  }

  revalidatePath("/episodes");
  revalidatePath(`/episodes/${documentId}`);
  revalidatePath("/");
  redirect(`/episodes/${documentId}?saved=1`);
}

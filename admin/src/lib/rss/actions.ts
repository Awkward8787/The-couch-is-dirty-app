"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { requireSessionUser } from "@/lib/auth/session";
import { syncEpisodesFromRss } from "./sync";

export async function syncRssAction() {
  await requireSessionUser();

  let result;
  try {
    result = await syncEpisodesFromRss();
    revalidatePath("/");
    revalidatePath("/episodes");
    revalidatePath("/rss-sync");
  } catch {
    redirect("/rss-sync?error=sync");
  }

  const params = new URLSearchParams({
    total: String(result.total),
    created: String(result.created),
    updated: String(result.updated),
    skipped: String(result.skipped),
  });
  redirect(`/rss-sync?${params.toString()}`);
}

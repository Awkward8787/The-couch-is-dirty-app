import { APPWRITE_COLLECTIONS } from "@/lib/appwrite/collections";
import { listDocumentTotal } from "@/lib/appwrite/server";

export type DashboardStats = {
  episodes: number;
  posts: number;
  guestApplications: number;
};

export async function getDashboardStats(): Promise<DashboardStats | null> {
  if (!process.env.APPWRITE_API_KEY) return null;

  try {
    const [episodes, posts, guestApplications] = await Promise.all([
      listDocumentTotal(APPWRITE_COLLECTIONS.episodes),
      listDocumentTotal(APPWRITE_COLLECTIONS.posts),
      listDocumentTotal(APPWRITE_COLLECTIONS.guestApplications),
    ]);

    return { episodes, posts, guestApplications };
  } catch {
    return null;
  }
}

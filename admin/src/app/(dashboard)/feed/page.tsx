import { TcidCard } from "@/components/ui/tcid-card";
import pageStyles from "@/components/ui/page.module.css";
import { FeedFilterBar } from "@/components/features/feed/feed-filter-bar";
import { FeedPostList } from "@/components/features/feed/feed-post-list";
import type { AdminFeedPost } from "@/lib/feed/types";
import { listFeedPosts, parseFeedListFilter } from "@/lib/feed/queries";

type FeedPageProps = {
  searchParams: Promise<{ status?: string; error?: string }>;
};

const ERROR_MESSAGES: Record<string, string> = {
  hide: "Could not hide that post.",
  restore: "Could not restore that post.",
  remove: "Could not remove that post.",
};

export default async function FeedPage({ searchParams }: FeedPageProps) {
  const params = await searchParams;
  const filter = parseFeedListFilter(params);
  let posts: AdminFeedPost[] = [];
  let loadError: string | null = null;

  try {
    posts = await listFeedPosts(filter);
  } catch {
    loadError = "Could not load feed posts. Check APPWRITE_API_KEY and posts collection.";
  }

  return (
    <>
      <header className={pageStyles.pageHeader}>
        <h1 className={pageStyles.pageTitle}>Home feed</h1>
        <p className={pageStyles.pageSubtitle}>Moderate posts and comments from the community feed.</p>
      </header>

      {params.error ? <p className={pageStyles.error}>{ERROR_MESSAGES[params.error]}</p> : null}
      {loadError ? <p className={pageStyles.error}>{loadError}</p> : null}

      <FeedFilterBar status={filter.status ?? "all"} />

      <TcidCard>
        <FeedPostList posts={posts} />
      </TcidCard>
    </>
  );
}

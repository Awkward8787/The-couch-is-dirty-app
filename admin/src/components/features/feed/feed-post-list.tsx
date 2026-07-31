import Image from "next/image";
import { formatFeedDate } from "@/lib/feed/mapping";
import type { AdminFeedPost } from "@/lib/feed/types";
import { hidePostAction, removePostAction, restorePostAction } from "@/lib/feed/actions";
import { TcidButton, TcidButtonLink } from "@/components/ui/tcid-button";
import { FeedStatusBadge } from "./feed-filter-bar";
import styles from "@/components/features/episodes/episodes.module.css";

type FeedPostListProps = {
  posts: AdminFeedPost[];
};

export function FeedPostList({ posts }: FeedPostListProps) {
  if (posts.length === 0) {
    return <p className={styles.empty}>No posts match these filters.</p>;
  }

  return (
    <div className={styles.stack}>
      {posts.map((post) => (
        <article key={post.id} className={styles.row} style={{ padding: "16px 0" }}>
          <div style={{ display: "flex", justifyContent: "space-between", gap: 16 }}>
            <div style={{ flex: 1 }}>
              <div style={{ display: "flex", gap: 8, alignItems: "center", flexWrap: "wrap" }}>
                <strong>{post.authorName}</strong>
                <span className={styles.meta}>@{post.authorRole}</span>
                <FeedStatusBadge status={post.moderationStatus} />
              </div>
              <p style={{ margin: "8px 0" }}>{post.body || "(No text)"}</p>
              {post.linkUrl ? (
                <p className={styles.meta}>
                  <a href={post.linkUrl} target="_blank" rel="noopener noreferrer">
                    {post.linkUrl}
                  </a>
                </p>
              ) : null}
              {post.imageUrl ? (
                <Image
                  src={post.imageUrl}
                  alt=""
                  width={320}
                  height={180}
                  style={{ borderRadius: 8, marginTop: 8, maxWidth: "100%", height: "auto" }}
                />
              ) : null}
              <p className={styles.meta}>
                {formatFeedDate(post.createdAt)} · {post.likeCount} likes · {post.commentCount}{" "}
                comments
              </p>
            </div>
          </div>
          <div className={styles.actions} style={{ marginTop: 12 }}>
            <TcidButtonLink href={`/feed/${post.id}`} variant="secondary">
              Open
            </TcidButtonLink>
            {post.moderationStatus === "visible" || post.moderationStatus === "reported" ? (
              <form action={hidePostAction.bind(null, post.id)}>
                <TcidButton type="submit" variant="secondary">
                  Hide
                </TcidButton>
              </form>
            ) : (
              <form action={restorePostAction.bind(null, post.id)}>
                <TcidButton type="submit">Restore</TcidButton>
              </form>
            )}
            <form action={removePostAction.bind(null, post.id)}>
              <TcidButton type="submit" variant="destructive">
                Remove
              </TcidButton>
            </form>
          </div>
        </article>
      ))}
    </div>
  );
}

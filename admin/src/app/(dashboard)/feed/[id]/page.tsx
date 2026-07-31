import Image from "next/image";
import Link from "next/link";
import { notFound } from "next/navigation";
import {
  deleteCommentAction,
  hidePostAction,
  removePostAction,
  restorePostAction,
} from "@/lib/feed/actions";
import { formatFeedDate } from "@/lib/feed/mapping";
import { getFeedPost, listPostComments } from "@/lib/feed/queries";
import { TcidButton, TcidButtonLink } from "@/components/ui/tcid-button";
import { TcidCard } from "@/components/ui/tcid-card";
import pageStyles from "@/components/ui/page.module.css";
import { FeedStatusBadge } from "@/components/features/feed/feed-filter-bar";
import styles from "@/components/features/episodes/episodes.module.css";

type FeedDetailPageProps = {
  params: Promise<{ id: string }>;
  searchParams: Promise<{ saved?: string; error?: string }>;
};

export default async function FeedDetailPage({ params, searchParams }: FeedDetailPageProps) {
  const { id } = await params;
  const query = await searchParams;
  const post = await getFeedPost(id);
  if (!post) notFound();

  const comments = await listPostComments(id);

  return (
    <>
      <header className={pageStyles.pageHeader}>
        <p className={pageStyles.muted}>
          <Link href="/feed">Feed</Link> / Post
        </p>
        <h1 className={pageStyles.pageTitle}>{post.authorName}</h1>
        <FeedStatusBadge status={post.moderationStatus} />
      </header>

      {query.saved ? <p className={styles.success}>Changes saved.</p> : null}
      {query.error === "comment-delete" ? (
        <p className={pageStyles.error}>Could not delete that comment.</p>
      ) : null}

      <TcidCard className={pageStyles.stack}>
        <p>{post.body || "(No text)"}</p>
        {post.linkUrl ? (
          <a href={post.linkUrl} target="_blank" rel="noopener noreferrer">
            {post.linkUrl}
          </a>
        ) : null}
        {post.imageUrl ? (
          <Image src={post.imageUrl} alt="" width={480} height={270} style={{ maxWidth: "100%", height: "auto" }} />
        ) : null}
        <p className={pageStyles.muted}>
          {formatFeedDate(post.createdAt)} · {post.likeCount} likes · {post.commentCount} comments
        </p>
        <div className={styles.actions}>
          {post.moderationStatus === "visible" || post.moderationStatus === "reported" ? (
            <form action={hidePostAction.bind(null, id)}>
              <TcidButton type="submit" variant="secondary">
                Hide
              </TcidButton>
            </form>
          ) : (
            <form action={restorePostAction.bind(null, id)}>
              <TcidButton type="submit">Restore</TcidButton>
            </form>
          )}
          <form action={removePostAction.bind(null, id)}>
            <TcidButton type="submit" variant="destructive">
              Remove
            </TcidButton>
          </form>
          <TcidButtonLink href="/feed" variant="secondary">
            Back
          </TcidButtonLink>
        </div>
      </TcidCard>

      <TcidCard className={pageStyles.stack} style={{ marginTop: 16 }}>
        <h2 className={pageStyles.pageTitle} style={{ fontSize: 20 }}>
          Comments ({comments.length})
        </h2>
        {comments.length === 0 ? (
          <p className={pageStyles.muted}>No comments on this post.</p>
        ) : (
          comments.map((comment) => (
            <div key={comment.id} className={styles.row} style={{ padding: "12px 0" }}>
              <strong>{comment.authorName}</strong>
              <p style={{ margin: "6px 0" }}>{comment.body}</p>
              <p className={styles.meta}>{formatFeedDate(comment.createdAt)}</p>
              <form action={deleteCommentAction.bind(null, comment.id, id)}>
                <TcidButton type="submit" variant="destructive">
                  Delete comment
                </TcidButton>
              </form>
            </div>
          ))
        )}
      </TcidCard>
    </>
  );
}

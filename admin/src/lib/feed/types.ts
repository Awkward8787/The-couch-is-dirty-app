export const MODERATION_STATUSES = ["visible", "hidden", "removed", "reported"] as const;

export type ModerationStatus = (typeof MODERATION_STATUSES)[number];

export type AdminFeedPost = {
  id: string;
  authorId: string;
  authorName: string;
  authorRole: string;
  body: string;
  linkUrl: string | null;
  imageUrl: string | null;
  likeCount: number;
  commentCount: number;
  moderationStatus: ModerationStatus;
  createdAt: string;
};

export type AdminFeedComment = {
  id: string;
  postId: string;
  authorId: string;
  authorName: string;
  body: string;
  createdAt: string;
};

export type FeedListFilter = {
  status?: ModerationStatus | "all";
};

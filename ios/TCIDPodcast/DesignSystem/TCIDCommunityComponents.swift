import SwiftUI

struct CommunityDiscussionCard: View {
    let discussion: CommunityDiscussion

    var body: some View {
        TCIDCard {
            HStack(alignment: .top, spacing: TCIDSpacing.md) {
                discussionIcon
                    .frame(width: 44, height: 44)
                    .background(TCIDColors.cardElevated)
                    .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.sm))

                VStack(alignment: .leading, spacing: TCIDSpacing.xs) {
                    if discussion.isPinned {
                        Text("Pinned")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(TCIDColors.accent)
                    }

                    Text(discussion.title)
                        .font(TCIDTypography.headline)
                        .foregroundStyle(TCIDColors.textPrimary)
                        .lineLimit(2)

                    Text(discussion.subtitle)
                        .font(TCIDTypography.caption)
                        .foregroundStyle(TCIDColors.textSecondary)
                        .lineLimit(2)

                    HStack(spacing: TCIDSpacing.md) {
                        Label("+\(discussion.participantCount)", systemImage: "person.2")
                        Label("\(discussion.replyCount) replies", systemImage: "bubble.left")
                    }
                    .font(TCIDTypography.caption)
                    .foregroundStyle(TCIDColors.textSecondary)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(TCIDColors.textSecondary)
            }
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var discussionIcon: some View {
        switch discussion.icon {
        case .flame:
            Image(systemName: "flame.fill")
                .foregroundStyle(TCIDColors.accent)
        case .couch:
            Image(systemName: "sofa.fill")
                .foregroundStyle(TCIDColors.textPrimary)
        case .microphone:
            Image(systemName: "mic.fill")
                .foregroundStyle(TCIDColors.textPrimary)
        }
    }
}

struct FanCommentCard: View {
    let comment: FanComment

    var body: some View {
        TCIDCard {
            VStack(alignment: .leading, spacing: TCIDSpacing.sm) {
                HStack {
                    Circle()
                        .fill(TCIDColors.cardElevated)
                        .frame(width: 36, height: 36)
                        .overlay {
                            Text(String(comment.authorName.prefix(1)))
                                .font(TCIDTypography.caption.weight(.bold))
                        }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(comment.authorName)
                            .font(TCIDTypography.caption.weight(.semibold))
                        Text("\(comment.timeAgo) · \(comment.episodeTitle)")
                            .font(.caption2)
                            .foregroundStyle(TCIDColors.textSecondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    Button { } label: {
                        Image(systemName: "ellipsis")
                            .foregroundStyle(TCIDColors.textSecondary)
                    }
                    .accessibilityLabel("Comment options")
                }

                Text(comment.body)
                    .font(TCIDTypography.body)
                    .foregroundStyle(TCIDColors.textPrimary)

                HStack {
                    Button("Reply") {}
                        .font(TCIDTypography.caption)
                        .foregroundStyle(TCIDColors.textSecondary)
                    Button("Like") {}
                        .font(TCIDTypography.caption)
                        .foregroundStyle(TCIDColors.textSecondary)
                    Spacer()
                    Label("\(comment.likeCount)", systemImage: "heart.fill")
                        .font(TCIDTypography.caption)
                        .foregroundStyle(TCIDColors.accent)
                }
            }
        }
    }
}

struct TrendingQuestionRow: View {
    let question: String
    var participantCount: Int = 63

    var body: some View {
        HStack(spacing: TCIDSpacing.md) {
            Circle()
                .fill(TCIDColors.cardElevated)
                .frame(width: 36, height: 36)
                .overlay {
                    Image(systemName: "questionmark")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(TCIDColors.textSecondary)
                }

            Text(question)
                .font(TCIDTypography.caption.weight(.medium))
                .foregroundStyle(TCIDColors.textPrimary)
                .lineLimit(2)

            Spacer()

            Text("+\(participantCount)")
                .font(TCIDTypography.caption)
                .foregroundStyle(TCIDColors.textSecondary)
        }
        .padding(.vertical, TCIDSpacing.sm)
        .accessibilityElement(children: .combine)
    }
}

struct ComposeDiscussionPrompt: View {
    var body: some View {
        HStack(spacing: TCIDSpacing.md) {
            Circle()
                .fill(TCIDColors.cardElevated)
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: "person.fill")
                        .foregroundStyle(TCIDColors.textSecondary)
                }

            Text("What are you thinking? Start a discussion…")
                .font(TCIDTypography.caption)
                .foregroundStyle(TCIDColors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "square.and.pencil")
                .foregroundStyle(TCIDColors.textPrimary)
        }
        .padding(TCIDSpacing.md)
        .background(TCIDColors.card)
        .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.lg))
        .accessibilityLabel("Start a discussion")
    }
}

import SwiftUI

struct FeedPostCard: View {
    let post: FeedPost

    var body: some View {
        VStack(alignment: .leading, spacing: TCIDSpacing.md) {
            HStack(spacing: TCIDSpacing.sm) {
                Circle()
                    .fill(TCIDColors.cardElevated)
                    .frame(width: 40, height: 40)
                    .overlay {
                        Text(String(post.authorName.prefix(1)).uppercased())
                            .font(TCIDTypography.caption.weight(.bold))
                            .foregroundStyle(TCIDColors.textPrimary)
                    }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: TCIDSpacing.xs) {
                        Text(post.authorName)
                            .font(TCIDTypography.caption.weight(.semibold))
                            .foregroundStyle(TCIDColors.textPrimary)

                        if post.authorRole != .guest {
                            Text(post.authorRole.badgeTitle.uppercased())
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(TCIDColors.accent)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(TCIDColors.accentMuted)
                                .clipShape(Capsule())
                        }
                    }

                    Text(post.createdAt, style: .relative)
                        .font(.caption2)
                        .foregroundStyle(TCIDColors.textSecondary)
                }

                Spacer()
            }

            if !post.body.isEmpty {
                Text(post.body)
                    .font(TCIDTypography.body)
                    .foregroundStyle(TCIDColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let imageURL = post.imageURL {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        Color.black.overlay {
                            Image(systemName: "photo")
                                .foregroundStyle(TCIDColors.textSecondary)
                        }
                    default:
                        TCIDColors.card.overlay { ProgressView().tint(TCIDColors.accent) }
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 220)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.md))
            }

            if let linkURL = post.linkURL {
                if post.hasPlayableVideoLink {
                    InAppVideoPlayer(url: linkURL)
                } else {
                    Link(destination: linkURL) {
                        HStack {
                            Image(systemName: "link")
                            Text(linkURL.host ?? linkURL.absoluteString)
                                .lineLimit(1)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                        }
                        .font(TCIDTypography.caption)
                        .foregroundStyle(TCIDColors.accent)
                        .padding(TCIDSpacing.md)
                        .background(TCIDColors.cardElevated)
                        .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.md))
                    }
                }
            }
        }
        .padding(TCIDSpacing.md)
        .background(TCIDColors.card)
        .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.lg))
        .accessibilityElement(children: .contain)
    }
}

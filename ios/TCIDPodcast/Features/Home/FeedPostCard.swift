import SwiftUI

struct FeedPostCard: View {
    @Environment(AuthService.self) private var auth
    @Environment(FeedStore.self) private var feed
    @Environment(PlaybackState.self) private var playback

    let post: FeedPost

    @State private var showsAbsoluteTime = false
    @State private var showsComments = false
    @State private var showsEdit = false
    @State private var showsLogin = false
    @State private var actionError: String?

    private var canManage: Bool {
        guard let userId = auth.currentUser?.id else { return false }
        return post.authorId == userId || auth.communityRole.canModerate
    }

    private var canEdit: Bool {
        guard let userId = auth.currentUser?.id else { return false }
        return post.authorId == userId
    }

    var body: some View {
        VStack(alignment: .leading, spacing: TCIDSpacing.md) {
            header

            if !post.body.isEmpty {
                Text(post.body)
                    .font(TCIDTypography.body)
                    .foregroundStyle(TCIDColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            media

            actionBar

            if let actionError {
                Text(actionError)
                    .font(.caption2)
                    .foregroundStyle(TCIDColors.destructive)
            }
        }
        .padding(TCIDSpacing.md)
        .background(TCIDColors.card)
        .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.lg))
        .sheet(isPresented: $showsComments) {
            FeedCommentsView(post: post)
        }
        .sheet(isPresented: $showsEdit) {
            EditPostView(post: post)
        }
        .sheet(isPresented: $showsLogin) {
            LoginView()
        }
        .accessibilityElement(children: .contain)
    }

    private var header: some View {
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

                    if post.isEdited {
                        Text("Edited")
                            .font(.caption2)
                            .foregroundStyle(TCIDColors.textSecondary)
                    }
                }

                Button {
                    showsAbsoluteTime.toggle()
                } label: {
                    Group {
                        if showsAbsoluteTime {
                            Text(post.createdAt.formatted(date: .abbreviated, time: .shortened))
                        } else {
                            Text(post.createdAt, style: .relative)
                        }
                    }
                    .font(.caption2)
                    .foregroundStyle(TCIDColors.textSecondary)
                }
                .buttonStyle(.plain)
            }

            Spacer()

            Menu {
                Button("Report") {
                    actionError = "Thanks — report received. Moderators will review."
                }
                if canEdit {
                    Button("Edit") { showsEdit = true }
                }
                if canManage {
                    Button("Delete", role: .destructive) {
                        Task { await deletePost() }
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundStyle(TCIDColors.textSecondary)
                    .frame(width: TCIDSpacing.touchTarget, height: TCIDSpacing.touchTarget)
            }
            .accessibilityLabel("More options")
        }
    }

    @ViewBuilder
    private var media: some View {
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
                    .onAppear {
                        // Pause podcast audio when feed video appears / is about to play.
                        if playback.isPlaying {
                            playback.toggleCurrentPlayback()
                        }
                    }
            } else if FeedService.isSafeURL(linkURL) {
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

    private var actionBar: some View {
        HStack(spacing: TCIDSpacing.lg) {
            Button {
                Task { await toggleLike() }
            } label: {
                Label(
                    "\(post.likeCount)",
                    systemImage: feed.likedPostIds.contains(post.id) ? "heart.fill" : "heart"
                )
                .font(TCIDTypography.caption)
                .foregroundStyle(feed.likedPostIds.contains(post.id) ? TCIDColors.accent : TCIDColors.textSecondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Like")

            Button {
                if auth.isAuthenticated {
                    showsComments = true
                } else {
                    showsLogin = true
                }
            } label: {
                Label("\(post.commentCount)", systemImage: "bubble.right")
                    .font(TCIDTypography.caption)
                    .foregroundStyle(TCIDColors.textSecondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Comments")

            ShareLink(item: shareText) {
                Label("Share", systemImage: "square.and.arrow.up")
                    .font(TCIDTypography.caption)
                    .foregroundStyle(TCIDColors.textSecondary)
                    .labelStyle(.iconOnly)
            }
            .accessibilityLabel("Share")

            Spacer()
        }
    }

    private var shareText: String {
        var parts = [post.authorName]
        if !post.body.isEmpty { parts.append(post.body) }
        if let link = post.linkURL?.absoluteString { parts.append(link) }
        return parts.joined(separator: " — ")
    }

    private func toggleLike() async {
        actionError = nil
        guard auth.isAuthenticated else {
            showsLogin = true
            return
        }
        do {
            try await feed.toggleLike(post: post, isAuthenticated: true)
        } catch {
            actionError = error.localizedDescription
        }
    }

    private func deletePost() async {
        actionError = nil
        guard let userId = auth.currentUser?.id else {
            showsLogin = true
            return
        }
        do {
            try await feed.deletePost(post, currentUserId: userId, role: auth.communityRole)
        } catch {
            actionError = error.localizedDescription
        }
    }
}

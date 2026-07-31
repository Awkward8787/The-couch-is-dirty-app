import SwiftUI

/// Home tab = Be a Guest + composer + social feed only. No episodes.
struct HomeView: View {
    @Environment(AuthService.self) private var auth
    @Environment(FeedStore.self) private var feed
    @Environment(BlockedUsersStore.self) private var blockedUsers

    @State private var showsComposer = false
    @State private var showsLogin = false

    var body: some View {
        NavigationStack {
            TCIDScreenContainer {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: TCIDSpacing.lg) {
                        TCIDAppHeader()

                        VStack(alignment: .leading, spacing: TCIDSpacing.xs) {
                            Text("Feed")
                                .font(TCIDTypography.display)
                                .foregroundStyle(TCIDColors.textPrimary)
                            Text("Community conversations from the couch.")
                                .font(TCIDTypography.caption)
                                .foregroundStyle(TCIDColors.textTertiary)
                        }
                        .padding(.horizontal, TCIDSpacing.md)

                        BeAGuestHomeBanner()
                            .padding(.horizontal, TCIDSpacing.md)

                        composerPrompt
                            .padding(.horizontal, TCIDSpacing.md)

                        feedContent
                            .padding(.horizontal, TCIDSpacing.md)
                            .padding(.bottom, TCIDSpacing.xl)
                    }
                }
                .refreshable {
                    await feed.load(reset: true)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showsComposer) {
                ComposePostView()
            }
            .sheet(isPresented: $showsLogin) {
                LoginView()
            }
            .task {
                await feed.load(reset: true)
                feed.startRealtime()
            }
            .onDisappear {
                feed.stopRealtime()
            }
        }
    }

    @ViewBuilder
    private var feedContent: some View {
        if feed.isLoading && feed.posts.isEmpty {
            ProgressView("Loading feed…")
                .tint(TCIDColors.accent)
                .font(TCIDTypography.caption)
                .foregroundStyle(TCIDColors.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, TCIDSpacing.xl)
        } else if let loadError = feed.loadError, feed.posts.isEmpty {
            VStack(alignment: .leading, spacing: TCIDSpacing.sm) {
                Text("Feed unavailable")
                    .font(TCIDTypography.headline)
                    .foregroundStyle(TCIDColors.textPrimary)
                Text(loadError)
                    .font(TCIDTypography.caption)
                    .foregroundStyle(TCIDColors.destructive)
                Button("Retry") {
                    Task { await feed.load(reset: true) }
                }
                .font(TCIDTypography.caption.weight(.semibold))
                .foregroundStyle(TCIDColors.accent)
            }
            .padding(TCIDSpacing.md)
            .background(TCIDColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: TCIDRadius.lg)
                    .stroke(TCIDColors.border, lineWidth: 1)
            )
        } else if feed.posts.isEmpty {
            VStack(spacing: TCIDSpacing.sm) {
                Text("No posts yet")
                    .font(TCIDTypography.headline)
                    .foregroundStyle(TCIDColors.textPrimary)
                Text("The feed stays empty until someone posts. Be the first.")
                    .font(TCIDTypography.caption)
                    .foregroundStyle(TCIDColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, TCIDSpacing.xl)
        } else {
            ForEach(visiblePosts) { post in
                FeedPostCard(post: post)
                    .onAppear {
                        Task { await feed.loadMoreIfNeeded(currentItem: post) }
                    }
            }

            if feed.isLoadingMore {
                ProgressView()
                    .tint(TCIDColors.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, TCIDSpacing.sm)
            }
        }
    }

    private var composerPrompt: some View {
        Button {
            if auth.isAuthenticated, auth.communityRole.canPost {
                showsComposer = true
            } else {
                showsLogin = true
            }
        } label: {
            HStack(spacing: TCIDSpacing.md) {
                TCIDAvatarView(
                    imageURL: auth.isAuthenticated ? auth.avatarURL : nil,
                    name: auth.isAuthenticated ? auth.displayName : "?",
                    size: 36
                )

                Text(auth.communityRole.canPost ? "What's on your mind?" : "Sign in to post")
                    .font(TCIDTypography.body)
                    .foregroundStyle(TCIDColors.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "square.and.pencil")
                    .foregroundStyle(TCIDColors.accent)
            }
            .padding(TCIDSpacing.md)
            .background(TCIDColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: TCIDRadius.lg)
                    .stroke(TCIDColors.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var visiblePosts: [FeedPost] {
        feed.visiblePosts(blockedAuthorIds: blockedUsers.blockedAuthorIds)
    }
}

#Preview {
    HomeView()
        .environment(AuthService())
        .environment(FeedStore())
        .environment(PlaybackState())
}

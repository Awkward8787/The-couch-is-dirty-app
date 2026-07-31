import SwiftUI

/// Home tab = Be a Guest + composer + social feed only. No episodes.
struct HomeView: View {
    @Environment(AuthService.self) private var auth
    @Environment(FeedStore.self) private var feed

    @State private var showsComposer = false
    @State private var showsLogin = false

    var body: some View {
        NavigationStack {
            TCIDScreenContainer {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: TCIDSpacing.md) {
                        TCIDAppHeader(showsNotificationBadge: false)

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
            .background(TCIDColors.card)
            .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.lg))
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
            ForEach(feed.posts) { post in
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
                Circle()
                    .fill(TCIDColors.cardElevated)
                    .frame(width: 40, height: 40)
                    .overlay {
                        Image(systemName: "person.fill")
                            .foregroundStyle(TCIDColors.textSecondary)
                    }

                Text(auth.communityRole.canPost ? "What’s on your mind?" : "Sign in to post")
                    .font(TCIDTypography.caption)
                    .foregroundStyle(TCIDColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "square.and.pencil")
                    .foregroundStyle(TCIDColors.textPrimary)
            }
            .padding(TCIDSpacing.md)
            .background(TCIDColors.card)
            .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.lg))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView()
        .environment(AuthService())
        .environment(FeedStore())
        .environment(PlaybackState())
}

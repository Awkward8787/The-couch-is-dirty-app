import SwiftUI

/// Home tab = community feed only. Episodes live on the Episodes tab.
struct HomeView: View {
    @Environment(AuthService.self) private var auth
    @Environment(FeedStore.self) private var feed

    @State private var showsComposer = false
    @State private var showsLogin = false

    var body: some View {
        NavigationStack {
            TCIDScreenContainer {
                ScrollView {
                    VStack(alignment: .leading, spacing: TCIDSpacing.md) {
                        TCIDAppHeader(showsNotificationBadge: false)

                        VStack(alignment: .leading, spacing: TCIDSpacing.xs) {
                            Text("Feed")
                                .font(TCIDTypography.largeTitle)
                                .foregroundStyle(TCIDColors.textPrimary)
                            Text("Community posts only — updated as people share. Episodes are on the Episodes tab.")
                                .font(TCIDTypography.caption)
                                .foregroundStyle(TCIDColors.textSecondary)
                        }
                        .padding(.horizontal, TCIDSpacing.md)

                        composerPrompt
                            .padding(.horizontal, TCIDSpacing.md)

                        feedContent
                            .padding(.horizontal, TCIDSpacing.md)
                            .padding(.bottom, TCIDSpacing.xl)
                    }
                }
                .refreshable {
                    await feed.load()
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
                await feed.load()
            }
            .onAppear {
                Task { await feed.load() }
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
                Text("Pull to refresh after Appwrite `posts` is set up.")
                    .font(TCIDTypography.caption)
                    .foregroundStyle(TCIDColors.textSecondary)
            }
            .padding(TCIDSpacing.md)
            .background(TCIDColors.card)
            .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.lg))
        } else if feed.posts.isEmpty {
            VStack(spacing: TCIDSpacing.sm) {
                Text("No posts yet today")
                    .font(TCIDTypography.headline)
                    .foregroundStyle(TCIDColors.textPrimary)
                Text("This feed stays empty until someone posts. Be the first.")
                    .font(TCIDTypography.caption)
                    .foregroundStyle(TCIDColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, TCIDSpacing.xl)
        } else {
            LazyVStack(spacing: TCIDSpacing.md) {
                ForEach(feed.posts) { post in
                    FeedPostCard(post: post)
                }
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
}

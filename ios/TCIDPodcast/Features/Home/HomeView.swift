import SwiftUI

struct HomeView: View {
    @Environment(AuthService.self) private var auth
    @Environment(FeedStore.self) private var feed

    @State private var showsComposer = false
    @State private var showsLogin = false

    var body: some View {
        NavigationStack {
            TCIDScreenContainer {
                ScrollView {
                    VStack(alignment: .leading, spacing: TCIDSpacing.lg) {
                        TCIDAppHeader(showsNotificationBadge: false)

                        VStack(alignment: .leading, spacing: TCIDSpacing.xs) {
                            Text("Couch Feed")
                                .font(TCIDTypography.largeTitle)
                                .foregroundStyle(TCIDColors.textPrimary)
                            Text("Share thoughts, photos, and video links. Keep it light on the server.")
                                .font(TCIDTypography.caption)
                                .foregroundStyle(TCIDColors.textSecondary)
                        }
                        .padding(.horizontal, TCIDSpacing.md)

                        composerPrompt
                            .padding(.horizontal, TCIDSpacing.md)

                        if feed.isLoading && feed.posts.isEmpty {
                            ProgressView("Loading the couch…")
                                .tint(TCIDColors.accent)
                                .font(TCIDTypography.caption)
                                .foregroundStyle(TCIDColors.textSecondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, TCIDSpacing.lg)
                        }

                        if let loadError = feed.loadError, feed.posts.isEmpty {
                            Text(loadError)
                                .font(TCIDTypography.caption)
                                .foregroundStyle(TCIDColors.destructive)
                                .padding(.horizontal, TCIDSpacing.md)
                        }

                        LazyVStack(spacing: TCIDSpacing.md) {
                            ForEach(feed.posts) { post in
                                FeedPostCard(post: post)
                            }
                        }
                        .padding(.horizontal, TCIDSpacing.md)
                        .padding(.bottom, TCIDSpacing.xl)
                    }
                }
                .refreshable {
                    await feed.load()
                }
            }
            .sheet(isPresented: $showsComposer) {
                ComposePostView()
            }
            .sheet(isPresented: $showsLogin) {
                LoginView()
            }
            .task {
                if feed.posts.isEmpty {
                    await feed.load()
                }
            }
        }
    }

    private var composerPrompt: some View {
        Button {
            if auth.isAuthenticated {
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

                Text(auth.isAuthenticated ? "What’s on your mind?" : "Sign in to post on the couch")
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
        .accessibilityLabel(auth.isAuthenticated ? "Create a post" : "Sign in to post")
    }
}

#Preview {
    HomeView()
        .environment(AuthService())
        .environment(FeedStore())
}

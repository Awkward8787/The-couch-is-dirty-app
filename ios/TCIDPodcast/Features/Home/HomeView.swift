import SwiftUI

struct HomeView: View {
    @Environment(PlaybackState.self) private var playback
    private let episodes = MockDataService.episodes

    var body: some View {
        NavigationStack {
            TCIDScreenContainer {
                ScrollView {
                    VStack(alignment: .leading, spacing: TCIDSpacing.lg) {
                        TCIDAppHeader()

                        VStack(alignment: .leading, spacing: TCIDSpacing.xs) {
                            Text("Welcome back, Couch Fam.")
                                .font(TCIDTypography.title)
                                .foregroundStyle(TCIDColors.textPrimary)
                            Text("Real talk. No filter. All on the couch.")
                                .font(TCIDTypography.body)
                                .foregroundStyle(TCIDColors.textSecondary)
                        }
                        .padding(.horizontal, TCIDSpacing.md)

                        BeAGuestPromoCard()
                            .padding(.horizontal, TCIDSpacing.md)

                        NowPlayingCard(
                            episode: MockDataService.featuredEpisode,
                            progress: playback.progress,
                            elapsedSeconds: playback.elapsedSeconds
                        ) {
                            playback.togglePlayback(for: MockDataService.featuredEpisode)
                        }
                        .padding(.horizontal, TCIDSpacing.md)

                        VStack(alignment: .leading, spacing: TCIDSpacing.md) {
                            TCIDSectionHeader(title: "Continue Listening", actionTitle: nil)
                            ContinueListeningRow(episode: episodes[1], progress: 0.65)
                        }
                        .padding(.horizontal, TCIDSpacing.md)

                        VStack(alignment: .leading, spacing: TCIDSpacing.md) {
                            TCIDSectionHeader(title: "Latest Episodes", actionTitle: "See All") {}
                            ForEach(episodes) { episode in
                                EpisodeRowView(episode: episode, showsNewBadge: episode.episodeNumber == 87) {
                                    playback.togglePlayback(for: episode)
                                }
                            }
                        }
                        .padding(.horizontal, TCIDSpacing.md)

                        VStack(alignment: .leading, spacing: TCIDSpacing.md) {
                            TCIDSectionHeader(title: "Trending in Community", actionTitle: "See All") {}
                            CommunityDiscussionCard(discussion: MockDataService.communityDiscussions[0])
                        }
                        .padding(.horizontal, TCIDSpacing.md)
                        .padding(.bottom, TCIDSpacing.xl)
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environment(PlaybackState())
}

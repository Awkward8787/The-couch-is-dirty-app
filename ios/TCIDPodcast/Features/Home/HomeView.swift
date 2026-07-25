import SwiftUI

struct HomeView: View {
    @Environment(PlaybackState.self) private var playback
    @Environment(EpisodeCatalog.self) private var catalog

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

                        if let nowPlayingEpisode {
                            NowPlayingCard(
                                episode: nowPlayingEpisode,
                                progress: nowPlayingProgress,
                                elapsedSeconds: nowPlayingElapsedSeconds,
                                isPlaying: isNowPlayingActive
                            ) {
                                playback.togglePlayback(for: nowPlayingEpisode)
                            }
                            .padding(.horizontal, TCIDSpacing.md)
                        }

                        if let continueEpisode {
                            VStack(alignment: .leading, spacing: TCIDSpacing.md) {
                                TCIDSectionHeader(title: "Continue Listening", actionTitle: nil)
                                ContinueListeningRow(
                                    episode: continueEpisode,
                                    progress: continueProgress
                                ) {
                                    playback.togglePlayback(for: continueEpisode)
                                }
                            }
                            .padding(.horizontal, TCIDSpacing.md)
                        }

                        VStack(alignment: .leading, spacing: TCIDSpacing.md) {
                            TCIDSectionHeader(title: "Latest Episodes", actionTitle: "See All") {}
                            ForEach(catalog.episodes) { episode in
                                EpisodeRowView(
                                    episode: episode,
                                    showsNewBadge: episode.id == catalog.featuredEpisode?.id,
                                    isPlaying: playback.currentEpisode?.id == episode.id && playback.isPlaying
                                ) {
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

    private var nowPlayingEpisode: Episode? {
        playback.currentEpisode ?? catalog.featuredEpisode
    }

    private var isNowPlayingActive: Bool {
        guard
            let nowPlayingEpisode,
            let currentEpisode = playback.currentEpisode
        else { return false }

        return currentEpisode.id == nowPlayingEpisode.id && playback.isPlaying
    }

    private var nowPlayingProgress: Double {
        guard
            let nowPlayingEpisode,
            let currentEpisode = playback.currentEpisode,
            currentEpisode.id == nowPlayingEpisode.id
        else { return 0 }

        return playback.progress
    }

    private var nowPlayingElapsedSeconds: Int {
        guard
            let nowPlayingEpisode,
            let currentEpisode = playback.currentEpisode,
            currentEpisode.id == nowPlayingEpisode.id
        else { return 0 }

        return playback.elapsedSeconds
    }

    private var continueEpisode: Episode? {
        if
            let currentEpisode = playback.currentEpisode,
            playback.progress > 0,
            playback.progress < 1
        {
            return currentEpisode
        }

        return catalog.episodes.dropFirst().first
    }

    private var continueProgress: Double {
        guard
            let continueEpisode,
            let currentEpisode = playback.currentEpisode,
            continueEpisode.id == currentEpisode.id
        else { return 0.35 }

        return playback.progress
    }
}

#Preview {
    HomeView()
        .environment(PlaybackState())
        .environment(EpisodeCatalog())
}

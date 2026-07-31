import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) private var appState
    @Environment(PlaybackState.self) private var playback
    @Environment(EpisodeCatalog.self) private var catalog

    var body: some View {
        NavigationStack {
            TCIDScreenContainer {
                ScrollView {
                    VStack(alignment: .leading, spacing: TCIDSpacing.xl) {
                        TCIDAppHeader(showsNotificationBadge: false)

                        hero
                            .padding(.horizontal, TCIDSpacing.md)

                        if let featured = catalog.featuredEpisode {
                            featuredSection(featured)
                                .padding(.horizontal, TCIDSpacing.md)
                        } else if catalog.isLoading {
                            ProgressView()
                                .tint(TCIDColors.accent)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, TCIDSpacing.lg)
                        }

                        if let continueEpisode, shouldShowContinue(for: continueEpisode) {
                            continueSection(continueEpisode)
                                .padding(.horizontal, TCIDSpacing.md)
                        }

                        BeAGuestPromoCard()
                            .padding(.horizontal, TCIDSpacing.md)

                        browseEpisodesButton
                            .padding(.horizontal, TCIDSpacing.md)
                            .padding(.bottom, TCIDSpacing.xl)
                    }
                }
            }
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: TCIDSpacing.md) {
            Text("The Couch Is Dirty")
                .font(TCIDTypography.largeTitle)
                .foregroundStyle(TCIDColors.textPrimary)
                .accessibilityAddTraits(.isHeader)

            Rectangle()
                .fill(TCIDColors.accent)
                .frame(width: 40, height: 3)
                .accessibilityHidden(true)

            Text("Real talk. No filter.")
                .font(TCIDTypography.body)
                .foregroundStyle(TCIDColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, TCIDSpacing.sm)
    }

    private func featuredSection(_ episode: Episode) -> some View {
        VStack(alignment: .leading, spacing: TCIDSpacing.md) {
            TCIDSectionHeader(title: "Now on the Couch", actionTitle: nil)

            NavigationLink {
                EpisodeDetailView(episode: episode)
            } label: {
                NowPlayingCard(
                    episode: episode,
                    progress: featuredProgress(for: episode),
                    elapsedSeconds: featuredElapsed(for: episode),
                    isPlaying: playback.currentEpisode?.id == episode.id && playback.isPlaying
                ) {
                    playback.togglePlayback(for: episode)
                }
            }
            .buttonStyle(.plain)
        }
    }

    private func continueSection(_ episode: Episode) -> some View {
        VStack(alignment: .leading, spacing: TCIDSpacing.md) {
            TCIDSectionHeader(title: "Continue", actionTitle: nil)
            ContinueListeningRow(
                episode: episode,
                progress: playback.progress
            ) {
                playback.togglePlayback(for: episode)
            }
        }
    }

    private var browseEpisodesButton: some View {
        Button {
            appState.selectedTab = .episodes
        } label: {
            HStack {
                Text("Browse all episodes")
                    .font(TCIDTypography.headline)
                    .foregroundStyle(TCIDColors.textPrimary)
                Spacer()
                Image(systemName: "arrow.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(TCIDColors.accent)
            }
            .padding(TCIDSpacing.md)
            .frame(minHeight: TCIDSpacing.touchTarget)
            .overlay(
                RoundedRectangle(cornerRadius: TCIDRadius.md)
                    .stroke(TCIDColors.border, lineWidth: 1)
            )
        }
        .accessibilityHint("Opens the Episodes tab")
    }

    private var continueEpisode: Episode? {
        guard
            let currentEpisode = playback.currentEpisode,
            playback.progress > 0.02,
            playback.progress < 0.98
        else { return nil }
        return currentEpisode
    }

    private func shouldShowContinue(for episode: Episode) -> Bool {
        episode.id != catalog.featuredEpisode?.id || !playback.isPlaying
    }

    private func featuredProgress(for episode: Episode) -> Double {
        guard playback.currentEpisode?.id == episode.id else { return 0 }
        return playback.progress
    }

    private func featuredElapsed(for episode: Episode) -> Int {
        guard playback.currentEpisode?.id == episode.id else { return 0 }
        return playback.elapsedSeconds
    }
}

#Preview {
    HomeView()
        .environment(AppState(hasCompletedOnboarding: true))
        .environment(PlaybackState())
        .environment(EpisodeCatalog())
}

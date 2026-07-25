import SwiftUI

struct EpisodesView: View {
    @Environment(PlaybackState.self) private var playback
    @Environment(EpisodeCatalog.self) private var catalog
    @State private var selectedFilter: EpisodeFilter = .all

    var body: some View {
        TCIDScreenContainer {
            ScrollView {
                VStack(alignment: .leading, spacing: TCIDSpacing.lg) {
                    TCIDAppHeader()

                    Text("Episodes")
                        .font(TCIDTypography.largeTitle)
                        .foregroundStyle(TCIDColors.textPrimary)
                        .padding(.horizontal, TCIDSpacing.md)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: TCIDSpacing.sm) {
                            ForEach(EpisodeFilter.allCases) { filter in
                                TCIDFilterChip(
                                    title: filter.rawValue,
                                    isSelected: selectedFilter == filter
                                ) {
                                    selectedFilter = filter
                                }
                            }
                        }
                        .padding(.horizontal, TCIDSpacing.md)
                    }

                    if catalog.isLoading {
                        ProgressView("Loading episodes from RSS…")
                            .font(TCIDTypography.caption)
                            .foregroundStyle(TCIDColors.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, TCIDSpacing.lg)
                    } else {
                        VStack(spacing: TCIDSpacing.md) {
                            ForEach(filteredEpisodes) { episode in
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
                    }

                    if let loadError = catalog.loadError {
                        Text(loadError)
                            .font(TCIDTypography.caption)
                            .foregroundStyle(TCIDColors.destructive)
                            .padding(.horizontal, TCIDSpacing.md)
                    }

                    Spacer(minLength: TCIDSpacing.xl)
                }
            }
        }
    }

    private var filteredEpisodes: [Episode] {
        switch selectedFilter {
        case .all, .newest:
            return catalog.episodes
        case .popular:
            return catalog.episodes.sorted { $0.playCount > $1.playCount }
        case .saved:
            return []
        }
    }
}

#Preview {
    EpisodesView()
        .environment(PlaybackState())
        .environment(EpisodeCatalog())
}

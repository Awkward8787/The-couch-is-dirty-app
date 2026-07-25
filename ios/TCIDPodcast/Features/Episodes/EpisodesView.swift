import SwiftUI

struct EpisodesView: View {
    @Environment(PlaybackState.self) private var playback
    @State private var selectedFilter: EpisodeFilter = .all
    private let episodes = MockDataService.episodes

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

                    VStack(spacing: TCIDSpacing.md) {
                        ForEach(filteredEpisodes) { episode in
                            EpisodeRowView(
                                episode: episode,
                                showsNewBadge: episode.episodeNumber == 87
                            ) {
                                playback.togglePlayback(for: episode)
                            }
                        }
                    }
                    .padding(.horizontal, TCIDSpacing.md)
                    .padding(.bottom, TCIDSpacing.xl)
                }
            }
        }
    }

    private var filteredEpisodes: [Episode] {
        switch selectedFilter {
        case .all, .newest:
            return episodes
        case .popular:
            return episodes.sorted { $0.playCount > $1.playCount }
        case .saved:
            return []
        }
    }
}

#Preview {
    EpisodesView()
        .environment(PlaybackState())
}

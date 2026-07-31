import SwiftUI

struct EpisodesView: View {
    @Environment(PlaybackState.self) private var playback
    @Environment(EpisodeCatalog.self) private var catalog
    @Environment(UserLibraryStore.self) private var library
    @State private var selectedFilter: EpisodeFilter = .all

    var body: some View {
        NavigationStack {
            TCIDScreenContainer {
                ScrollView {
                    VStack(alignment: .leading, spacing: TCIDSpacing.lg) {
                        TCIDAppHeader()

                        VStack(alignment: .leading, spacing: TCIDSpacing.xs) {
                            Text("Episodes")
                                .font(TCIDTypography.display)
                                .foregroundStyle(TCIDColors.textPrimary)
                            Text("Listen to the latest from the couch.")
                                .font(TCIDTypography.caption)
                                .foregroundStyle(TCIDColors.textTertiary)
                        }
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
                            ProgressView("Loading episodes…")
                                .tint(TCIDColors.accent)
                                .font(TCIDTypography.caption)
                                .foregroundStyle(TCIDColors.textSecondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, TCIDSpacing.lg)
                        } else {
                            VStack(alignment: .leading, spacing: TCIDSpacing.md) {
                                if selectedFilter == .all || selectedFilter == .newest,
                                   let featured = catalog.featuredEpisode ?? catalog.episodes.first {
                                    NavigationLink {
                                        EpisodeDetailView(episode: featured)
                                    } label: {
                                        FeaturedEpisodeCard(
                                            episode: featured,
                                            isPlaying: playback.currentEpisode?.id == featured.id && playback.isPlaying
                                        ) {
                                            playback.togglePlayback(for: featured)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.horizontal, TCIDSpacing.md)
                                }

                                if listEpisodes.isEmpty {
                                    emptyFilterState
                                } else {
                                    VStack(spacing: 0) {
                                        ForEach(Array(listEpisodes.enumerated()), id: \.element.id) { index, episode in
                                            if index > 0 {
                                                Divider()
                                                    .background(TCIDColors.separator)
                                                    .padding(.leading, 72)
                                            }
                                            NavigationLink {
                                                EpisodeDetailView(episode: episode)
                                            } label: {
                                                EpisodeRowView(
                                                    episode: episode,
                                                    showsNewBadge: false,
                                                    isPlaying: playback.currentEpisode?.id == episode.id && playback.isPlaying
                                                ) {
                                                    playback.togglePlayback(for: episode)
                                                }
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                    .padding(.horizontal, TCIDSpacing.md)
                                }
                            }
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
                .refreshable {
                    await catalog.loadFromAppwrite()
                }
            }
        }
    }

    private var listEpisodes: [Episode] {
        let filtered = filteredEpisodes
        guard selectedFilter == .all || selectedFilter == .newest else { return filtered }
        guard let featured = catalog.featuredEpisode ?? catalog.episodes.first else { return filtered }
        return filtered.filter { $0.id != featured.id }
    }

    private var filteredEpisodes: [Episode] {
        switch selectedFilter {
        case .all, .newest:
            return catalog.episodes
        case .popular:
            return catalog.episodes.sorted { $0.playCount > $1.playCount }
        case .saved:
            return library.savedEpisodes(from: catalog.episodes)
        }
    }

    @ViewBuilder
    private var emptyFilterState: some View {
        VStack(spacing: TCIDSpacing.sm) {
            Text("No episodes here yet")
                .font(TCIDTypography.headline)
                .foregroundStyle(TCIDColors.textPrimary)
            Text("Try another filter or pull to refresh.")
                .font(TCIDTypography.caption)
                .foregroundStyle(TCIDColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, TCIDSpacing.xl)
    }
}

#Preview {
    EpisodesView()
        .environment(PlaybackState())
        .environment(EpisodeCatalog())
        .environment(UserLibraryStore())
}

import SwiftUI

struct ListeningHistoryView: View {
    @Environment(EpisodeCatalog.self) private var catalog
    @Environment(UserLibraryStore.self) private var library
    @Environment(PlaybackState.self) private var playback

    var body: some View {
        TCIDScreenContainer {
            ScrollView {
                VStack(alignment: .leading, spacing: TCIDSpacing.md) {
                    if historyItems.isEmpty {
                        emptyState
                    } else {
                        ForEach(historyItems, id: \.episode.id) { item in
                            NavigationLink {
                                EpisodeDetailView(episode: item.episode)
                            } label: {
                                VStack(alignment: .leading, spacing: TCIDSpacing.xs) {
                                    EpisodeRowView(
                                        episode: item.episode,
                                        showsNewBadge: false,
                                        isPlaying: playback.currentEpisode?.id == item.episode.id && playback.isPlaying
                                    ) {
                                        playback.togglePlayback(for: item.episode)
                                    }

                                    if item.entry.positionSeconds > 0 {
                                        Text("Last position: \(DurationFormatter.formatLong(seconds: item.entry.positionSeconds))")
                                            .font(TCIDTypography.caption)
                                            .foregroundStyle(TCIDColors.textSecondary)
                                            .padding(.leading, TCIDSpacing.sm)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(TCIDSpacing.md)
            }
        }
        .navigationTitle("Listening History")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var historyItems: [(episode: Episode, entry: ListeningHistoryEntry)] {
        library.historyEpisodes(from: catalog.episodes)
    }

    private var emptyState: some View {
        VStack(spacing: TCIDSpacing.sm) {
            Image(systemName: "clock")
                .font(.system(size: 36))
                .foregroundStyle(TCIDColors.textSecondary)
            Text("No listening history yet")
                .font(TCIDTypography.headline)
                .foregroundStyle(TCIDColors.textPrimary)
            Text("Episodes you play will appear here with your last position.")
                .font(TCIDTypography.body)
                .foregroundStyle(TCIDColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, TCIDSpacing.xl)
    }
}

#Preview {
    NavigationStack {
        ListeningHistoryView()
            .environment(EpisodeCatalog())
            .environment(UserLibraryStore())
            .environment(PlaybackState())
    }
}

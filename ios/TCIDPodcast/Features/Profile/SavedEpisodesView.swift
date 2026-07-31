import SwiftUI

struct SavedEpisodesView: View {
    @Environment(EpisodeCatalog.self) private var catalog
    @Environment(UserLibraryStore.self) private var library
    @Environment(PlaybackState.self) private var playback

    var body: some View {
        TCIDScreenContainer {
            ScrollView {
                VStack(alignment: .leading, spacing: TCIDSpacing.md) {
                    if savedEpisodes.isEmpty {
                        emptyState
                    } else {
                        ForEach(savedEpisodes) { episode in
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
                }
                .padding(TCIDSpacing.md)
            }
        }
        .navigationTitle("Saved Episodes")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var savedEpisodes: [Episode] {
        library.savedEpisodes(from: catalog.episodes)
    }

    private var emptyState: some View {
        VStack(spacing: TCIDSpacing.sm) {
            Image(systemName: "bookmark")
                .font(.system(size: 36))
                .foregroundStyle(TCIDColors.textSecondary)
            Text("No saved episodes yet")
                .font(TCIDTypography.headline)
                .foregroundStyle(TCIDColors.textPrimary)
            Text("Tap Save on an episode to bookmark it here.")
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
        SavedEpisodesView()
            .environment(EpisodeCatalog())
            .environment(UserLibraryStore())
            .environment(PlaybackState())
    }
}

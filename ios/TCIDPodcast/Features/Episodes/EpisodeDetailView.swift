import SwiftUI

struct EpisodeDetailView: View {
    @Environment(PlaybackState.self) private var playback

    let episode: Episode

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: TCIDSpacing.lg) {
                EpisodeArtworkView(coverArtURL: episode.coverArtURL, size: 220)
                    .frame(maxWidth: .infinity)

                VStack(alignment: .leading, spacing: TCIDSpacing.sm) {
                    Text(episode.title)
                        .font(TCIDTypography.title)
                        .foregroundStyle(TCIDColors.textPrimary)

                    HStack(spacing: TCIDSpacing.xs) {
                        if let publishedAt = episode.publishedAt {
                            Text(DurationFormatter.formatDate(publishedAt))
                        }
                        if let duration = episode.durationSeconds {
                            Text("•")
                            Text(DurationFormatter.formatLong(seconds: duration))
                        }
                        if episode.isExplicit {
                            Text("•")
                            Text("Explicit")
                        }
                    }
                    .font(TCIDTypography.caption)
                    .foregroundStyle(TCIDColors.textSecondary)
                }

                TCIDPrimaryButton(
                    title: playback.currentEpisode?.id == episode.id && playback.isPlaying ? "Pause" : "Play Episode"
                ) {
                    playback.togglePlayback(for: episode)
                }
                .disabled(episode.audioURL == nil)

                if episode.audioURL == nil {
                    Text("Audio is not available for this episode yet.")
                        .font(TCIDTypography.caption)
                        .foregroundStyle(TCIDColors.textSecondary)
                }

                if let description = episode.description, !description.isEmpty {
                    VStack(alignment: .leading, spacing: TCIDSpacing.sm) {
                        Text("About")
                            .font(TCIDTypography.headline)
                            .foregroundStyle(TCIDColors.textPrimary)
                        Text(description)
                            .font(TCIDTypography.body)
                            .foregroundStyle(TCIDColors.textSecondary)
                    }
                }

                if let showNotes = episode.showNotes, !showNotes.isEmpty {
                    VStack(alignment: .leading, spacing: TCIDSpacing.sm) {
                        Text("Show Notes")
                            .font(TCIDTypography.headline)
                            .foregroundStyle(TCIDColors.textPrimary)
                        Text(showNotes)
                            .font(TCIDTypography.body)
                            .foregroundStyle(TCIDColors.textSecondary)
                    }
                }
            }
            .padding(TCIDSpacing.md)
        }
        .background(TCIDColors.background.ignoresSafeArea())
        .navigationTitle("Episode")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        EpisodeDetailView(episode: MockDataService.episodes[0])
            .environment(PlaybackState())
    }
}

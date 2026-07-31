import SwiftUI

struct EpisodeDetailView: View {
    @Environment(PlaybackState.self) private var playback
    @Environment(UserLibraryStore.self) private var library

    let episode: Episode

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: TCIDSpacing.lg) {
                EpisodeArtworkView(coverArtURL: episode.coverArtURL, size: 280)
                    .frame(maxWidth: .infinity)
                    .shadow(color: Color.black.opacity(0.35), radius: 24, y: 12)

                VStack(alignment: .leading, spacing: TCIDSpacing.sm) {
                    Text(episode.title)
                        .font(TCIDTypography.display)
                        .foregroundStyle(TCIDColors.textPrimary)

                    HStack(spacing: TCIDSpacing.xs) {
                        if let publishedAt = episode.publishedAt {
                            Text(DurationFormatter.formatDate(publishedAt))
                        }
                        if let duration = episode.durationSeconds {
                            Text("·")
                            Text(DurationFormatter.formatLong(seconds: duration))
                        }
                        if episode.isExplicit {
                            Text("·")
                            Text("Explicit")
                        }
                    }
                    .font(TCIDTypography.caption)
                    .foregroundStyle(TCIDColors.textTertiary)
                }

                TCIDPrimaryButton(
                    title: playback.currentEpisode?.id == episode.id && playback.isPlaying ? "Pause" : "Play Episode",
                    systemImage: playback.currentEpisode?.id == episode.id && playback.isPlaying ? "pause.fill" : "play.fill"
                ) {
                    playback.togglePlayback(for: episode)
                }
                .disabled(episode.audioURL == nil)

                TCIDGhostButton(
                    title: library.isSaved(episode.id) ? "Saved" : "Save Episode",
                    systemImage: library.isSaved(episode.id) ? "bookmark.fill" : "bookmark",
                    isActive: library.isSaved(episode.id)
                ) {
                    library.toggleSaved(episode)
                }

                if episode.audioURL == nil {
                    Text("Audio is not available for this episode yet.")
                        .font(TCIDTypography.caption)
                        .foregroundStyle(TCIDColors.textSecondary)
                }

                if let description = episode.description, !description.isEmpty {
                    detailSection(title: "About", body: description)
                }

                if let showNotes = episode.showNotes, !showNotes.isEmpty {
                    detailSection(title: "Show Notes", body: showNotes)
                }
            }
            .padding(TCIDSpacing.md)
        }
        .background(TCIDColors.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }

    private func detailSection(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: TCIDSpacing.sm) {
            Text(title)
                .font(TCIDTypography.headline)
                .foregroundStyle(TCIDColors.textPrimary)
            Text(body)
                .font(TCIDTypography.body)
                .foregroundStyle(TCIDColors.textSecondary)
                .lineSpacing(4)
        }
        .padding(TCIDSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(TCIDColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: TCIDRadius.lg)
                .stroke(TCIDColors.border, lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        EpisodeDetailView(episode: MockDataService.episodes[0])
            .environment(PlaybackState())
            .environment(UserLibraryStore())
    }
}

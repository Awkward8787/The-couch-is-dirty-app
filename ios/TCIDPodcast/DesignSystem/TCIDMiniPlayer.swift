import SwiftUI

@Observable
@MainActor
final class PlaybackState {
    var currentEpisode: Episode?
    var isPlaying = false
    var progress: Double = 0.4
    var elapsedSeconds: Int = 1723

    func togglePlayback(for episode: Episode) {
        if currentEpisode?.id == episode.id {
            isPlaying.toggle()
        } else {
            currentEpisode = episode
            isPlaying = true
            progress = 0
            elapsedSeconds = 0
        }
    }
}

struct MiniPlayerBar: View {
    @Environment(PlaybackState.self) private var playback

    var body: some View {
        if let episode = playback.currentEpisode {
            VStack(spacing: 0) {
                TCIDProgressBar(progress: playback.progress)
                    .frame(height: 2)

                HStack(spacing: TCIDSpacing.md) {
                    EpisodeArtworkView(size: 40)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(episode.title)
                            .font(TCIDTypography.caption.weight(.semibold))
                            .foregroundStyle(TCIDColors.textPrimary)
                            .lineLimit(1)
                        Text(AppConfig.showName)
                            .font(.caption2)
                            .foregroundStyle(TCIDColors.textSecondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    Button { } label: {
                        Image(systemName: "gobackward.30")
                            .foregroundStyle(TCIDColors.textPrimary)
                    }
                    .accessibilityLabel("Rewind 30 seconds")

                    TCIDPlayButton(size: 40, isPlaying: playback.isPlaying) {
                        playback.isPlaying.toggle()
                    }

                    Button { } label: {
                        Image(systemName: "goforward.30")
                            .foregroundStyle(TCIDColors.textPrimary)
                    }
                    .accessibilityLabel("Forward 30 seconds")
                }
                .padding(.horizontal, TCIDSpacing.md)
                .padding(.vertical, TCIDSpacing.sm)
                .background(TCIDColors.card)
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Mini player, \(episode.title)")
        }
    }
}

struct TCIDScreenContainer<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(TCIDColors.background)
    }
}

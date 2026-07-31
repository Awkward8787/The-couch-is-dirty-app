import SwiftUI

@Observable
@MainActor
final class PlaybackState {
    private let player = AudioPlayerService()
    private weak var libraryStore: UserLibraryStore?

    var currentEpisode: Episode?
    var isPlaying = false
    var progress: Double = 0
    var elapsedSeconds: Int = 0

    init() {
        player.onTimeUpdate = { [weak self] elapsed, duration in
            guard let self else { return }
            self.elapsedSeconds = Int(elapsed)
            if duration > 0 {
                self.progress = min(max(elapsed / duration, 0), 1)
            }
            if let episode = self.currentEpisode {
                self.libraryStore?.recordProgress(
                    episodeId: episode.id,
                    positionSeconds: Int(elapsed)
                )
            }
        }

        player.onPlaybackStateChange = { [weak self] isPlaying in
            self?.isPlaying = isPlaying
        }

        player.onPlaybackFinished = { [weak self] in
            self?.isPlaying = false
            self?.progress = 1
        }
    }

    func configureAudioSession() {
        player.configureSession()
    }

    func bindLibraryStore(_ store: UserLibraryStore) {
        libraryStore = store
    }

    func togglePlayback(for episode: Episode) {
        guard episode.audioURL != nil else { return }

        if currentEpisode?.id == episode.id {
            if isPlaying {
                player.pause()
            } else {
                player.resume()
            }
            return
        }

        currentEpisode = episode
        progress = 0
        elapsedSeconds = 0
        player.play(episode: episode)
    }

    func toggleCurrentPlayback() {
        guard currentEpisode != nil else { return }
        if isPlaying {
            player.pause()
        } else {
            player.resume()
        }
    }

    func skipBackward() {
        player.seek(by: -30)
    }

    func skipForward() {
        player.seek(by: 30)
    }
}

struct MiniPlayerBar: View {
    @Environment(PlaybackState.self) private var playback

    var body: some View {
        if let episode = playback.currentEpisode {
            VStack(spacing: 0) {
                Rectangle()
                    .fill(TCIDColors.separator)
                    .frame(height: 1)

                TCIDProgressBar(progress: playback.progress)
                    .frame(height: 2)

                HStack(spacing: TCIDSpacing.md) {
                    EpisodeArtworkView(coverArtURL: episode.coverArtURL, size: 44)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(episode.title)
                            .font(TCIDTypography.caption.weight(.semibold))
                            .foregroundStyle(TCIDColors.textPrimary)
                            .lineLimit(1)
                        Text(AppConfig.showName)
                            .font(TCIDTypography.micro)
                            .foregroundStyle(TCIDColors.textTertiary)
                            .lineLimit(1)
                    }

                    Spacer()

                    Button {
                        playback.skipBackward()
                    } label: {
                        Image(systemName: "gobackward.30")
                            .font(.body.weight(.medium))
                            .foregroundStyle(TCIDColors.textSecondary)
                    }
                    .accessibilityLabel("Rewind 30 seconds")

                    TCIDPlayButton(size: 40, isPlaying: playback.isPlaying) {
                        playback.toggleCurrentPlayback()
                    }

                    Button {
                        playback.skipForward()
                    } label: {
                        Image(systemName: "goforward.30")
                            .font(.body.weight(.medium))
                            .foregroundStyle(TCIDColors.textSecondary)
                    }
                    .accessibilityLabel("Forward 30 seconds")
                }
                .padding(.horizontal, TCIDSpacing.md)
                .padding(.vertical, TCIDSpacing.sm)
                .background(TCIDColors.surfaceElevated)
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

import AVFoundation
import Foundation
import MediaPlayer
import UIKit

@MainActor
final class AudioPlayerService {
    private var player: AVPlayer?
    private var currentEpisode: Episode?
    private var timeObserver: Any?
    private var endObserver: NSObjectProtocol?

    var onTimeUpdate: ((TimeInterval, TimeInterval) -> Void)?
    var onPlaybackStateChange: ((Bool) -> Void)?
    var onPlaybackFinished: (() -> Void)?

    init() {
        configureRemoteCommands()
    }

    func configureSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .spokenAudio)
            try session.setActive(true)
        } catch {
            // Playback still works in foreground if session setup fails.
        }
    }

    func play(episode: Episode) {
        guard let audioURL = episode.audioURL else { return }

        removeObservers()
        player?.pause()
        player = nil

        let item = AVPlayerItem(url: audioURL)
        player = AVPlayer(playerItem: item)
        currentEpisode = episode

        addObservers(for: item)
        updateNowPlayingInfo(for: episode, elapsed: 0, isPlaying: true)
        player?.play()
        onPlaybackStateChange?(true)
    }

    func resume() {
        player?.play()
        updateNowPlayingPlaybackState(isPlaying: true)
        onPlaybackStateChange?(true)
    }

    func pause() {
        player?.pause()
        updateNowPlayingPlaybackState(isPlaying: false)
        onPlaybackStateChange?(false)
    }

    func seek(by seconds: TimeInterval) {
        guard let player else { return }
        let current = player.currentTime().seconds
        let duration = player.currentItem?.duration.seconds ?? 0
        let target = max(0, min(current + seconds, duration.isFinite ? duration : current + seconds))
        player.seek(to: CMTime(seconds: target, preferredTimescale: 600))
    }

    func seek(to progress: Double) {
        guard
            let player,
            let duration = player.currentItem?.duration.seconds,
            duration.isFinite,
            duration > 0
        else { return }

        let target = duration * min(max(progress, 0), 1)
        player.seek(to: CMTime(seconds: target, preferredTimescale: 600))
    }

    private func addObservers(for item: AVPlayerItem) {
        guard let player else { return }

        timeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.5, preferredTimescale: 600),
            queue: .main
        ) { [weak self] time in
            Task { @MainActor in
                self?.handleTimeUpdate(current: time)
            }
        }

        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.handlePlaybackFinished()
            }
        }
    }

    private func handleTimeUpdate(current: CMTime) {
        guard let player, let episode = currentEpisode else { return }
        let elapsed = max(0, current.seconds)
        let duration = player.currentItem?.duration.seconds ?? Double(episode.durationSeconds ?? 0)
        onTimeUpdate?(elapsed, duration.isFinite ? duration : 0)
        updateNowPlayingInfo(for: episode, elapsed: elapsed, isPlaying: player.rate > 0)
    }

    private func handlePlaybackFinished() {
        pause()
        onPlaybackFinished?()
    }

    private func removeObservers() {
        if let timeObserver, let player {
            player.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
            self.endObserver = nil
        }
    }

    private func configureRemoteCommands() {
        let center = MPRemoteCommandCenter.shared()

        center.playCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.resume() }
            return .success
        }

        center.pauseCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.pause() }
            return .success
        }

        center.togglePlayPauseCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                if self.player?.rate ?? 0 > 0 {
                    self.pause()
                } else {
                    self.resume()
                }
            }
            return .success
        }

        center.skipForwardCommand.preferredIntervals = [30]
        center.skipForwardCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.seek(by: 30) }
            return .success
        }

        center.skipBackwardCommand.preferredIntervals = [30]
        center.skipBackwardCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.seek(by: -30) }
            return .success
        }
    }

    private func updateNowPlayingInfo(for episode: Episode, elapsed: TimeInterval, isPlaying: Bool) {
        var info: [String: Any] = [
            MPMediaItemPropertyTitle: episode.title,
            MPMediaItemPropertyArtist: AppConfig.showName,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: elapsed,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1 : 0,
        ]

        if let duration = episode.durationSeconds, duration > 0 {
            info[MPMediaItemPropertyPlaybackDuration] = TimeInterval(duration)
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info

        if let coverArtURL = episode.coverArtURL ?? Optional(AppConfig.podcastArtworkURL) {
            Task {
                if let artwork = await loadArtwork(from: coverArtURL) {
                    await MainActor.run {
                        var updated = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? info
                        updated[MPMediaItemPropertyArtwork] = artwork
                        MPNowPlayingInfoCenter.default().nowPlayingInfo = updated
                    }
                }
            }
        }
    }

    private func updateNowPlayingPlaybackState(isPlaying: Bool) {
        guard var info = MPNowPlayingInfoCenter.default().nowPlayingInfo else { return }
        info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1 : 0
        if let elapsed = player?.currentTime().seconds {
            info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsed
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    private func loadArtwork(from url: URL) async -> MPMediaItemArtwork? {
        guard
            let (data, _) = try? await URLSession.shared.data(from: url),
            let image = UIImage(data: data)
        else { return nil }

        return MPMediaItemArtwork(boundsSize: image.size) { _ in image }
    }
}

private extension CMTime {
    var seconds: TimeInterval {
        CMTimeGetSeconds(self)
    }
}

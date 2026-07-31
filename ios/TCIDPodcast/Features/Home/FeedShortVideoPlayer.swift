import AVKit
import SwiftUI

/// Vertical short-form player for uploaded feed clips (TikTok-style 9:16 frame).
struct FeedShortVideoPlayer: View {
    let url: URL
    var onPlaybackStart: () -> Void = {}

    @State private var player: AVPlayer?
    @State private var hasStarted = false

    var body: some View {
        ZStack {
            if let player, hasStarted {
                VideoPlayer(player: player)
            } else {
                TCIDColors.surfaceOverlay
                    .overlay {
                        Button {
                            startPlayback()
                        } label: {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 56))
                                .foregroundStyle(.white)
                                .shadow(color: .black.opacity(0.35), radius: 8, y: 2)
                        }
                        .accessibilityLabel("Play video")
                    }
            }
        }
        .aspectRatio(9 / 16, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: TCIDRadius.md)
                .stroke(TCIDColors.border, lineWidth: 1)
        )
        .onDisappear {
            player?.pause()
        }
    }

    private func startPlayback() {
        if player == nil {
            player = AVPlayer(url: url)
        }
        hasStarted = true
        onPlaybackStart()
        player?.play()
    }
}

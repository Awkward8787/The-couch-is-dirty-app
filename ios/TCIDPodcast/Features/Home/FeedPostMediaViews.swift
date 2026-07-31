import AVKit
import SwiftUI

/// Full-width 9:16 frame for feed photos — TikTok-style vertical display.
struct FeedPostImageView: View {
    let url: URL

    var body: some View {
        Color.clear
            .aspectRatio(FeedMediaFormat.aspectRatio, contentMode: .fit)
            .frame(maxWidth: .infinity)
            .overlay {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        FeedMediaPlaceholder(systemName: "photo", message: "Image unavailable")
                    case .empty:
                        FeedMediaPlaceholder(showsProgress: true)
                    @unknown default:
                        FeedMediaPlaceholder(showsProgress: true)
                    }
                }
            }
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: TCIDRadius.md)
                    .stroke(TCIDColors.border, lineWidth: 1)
            )
            .accessibilityLabel("Post image")
    }
}

/// Full-width 9:16 frame for uploaded feed video clips.
struct FeedPostVideoView: View {
    let url: URL
    var onPlaybackStart: () -> Void = {}

    @State private var player: AVPlayer?
    @State private var hasStarted = false

    var body: some View {
        Color.clear
            .aspectRatio(FeedMediaFormat.aspectRatio, contentMode: .fit)
            .frame(maxWidth: .infinity)
            .overlay {
                ZStack {
                    if let player, hasStarted {
                        VideoPlayer(player: player)
                    } else {
                        FeedMediaPlaceholder(systemName: "play.circle.fill", showsProgress: false)
                            .overlay {
                                Button(action: startPlayback) {
                                    Image(systemName: "play.circle.fill")
                                        .font(.system(size: 56))
                                        .foregroundStyle(.white)
                                        .shadow(color: .black.opacity(0.35), radius: 8, y: 2)
                                }
                                .accessibilityLabel("Play video")
                            }
                    }
                }
            }
            .clipped()
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

struct FeedMediaPlaceholder: View {
    var systemName: String = "photo"
    var message: String? = nil
    var showsProgress: Bool = false

    var body: some View {
        ZStack {
            TCIDColors.surfaceOverlay
            if showsProgress {
                ProgressView()
                    .tint(TCIDColors.accent)
            } else {
                VStack(spacing: TCIDSpacing.sm) {
                    Image(systemName: systemName)
                        .font(.title)
                        .foregroundStyle(TCIDColors.textSecondary)
                    if let message {
                        Text(message)
                            .font(TCIDTypography.caption)
                            .foregroundStyle(TCIDColors.textSecondary)
                    }
                }
            }
        }
    }
}

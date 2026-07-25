import SwiftUI

struct EpisodeArtworkView: View {
    var coverArtURL: URL? = nil
    var size: CGFloat = 56

    var body: some View {
        Group {
            if let coverArtURL {
                AsyncImage(url: coverArtURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.sm))
        .accessibilityHidden(true)
    }

    private var placeholder: some View {
        Image("PodcastLogo")
            .resizable()
            .scaledToFill()
    }
}

struct NowPlayingCard: View {
    let episode: Episode
    var progress: Double = 0.4
    var elapsedSeconds: Int = 1723
    var isPlaying = false
    var onPlay: () -> Void = {}

    var body: some View {
        TCIDCard {
            VStack(alignment: .leading, spacing: TCIDSpacing.md) {
                HStack(alignment: .top, spacing: TCIDSpacing.md) {
                    EpisodeArtworkView(coverArtURL: episode.coverArtURL, size: 72)

                    VStack(alignment: .leading, spacing: TCIDSpacing.xs) {
                        HStack(spacing: TCIDSpacing.xs) {
                            Circle()
                                .fill(TCIDColors.accent)
                                .frame(width: 6, height: 6)
                            Text("NOW PLAYING")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(TCIDColors.accent)
                        }

                        Text(episode.title)
                            .font(TCIDTypography.headline)
                            .foregroundStyle(TCIDColors.textPrimary)
                            .lineLimit(2)

                        if let description = episode.description {
                            Text(description)
                                .font(TCIDTypography.caption)
                                .foregroundStyle(TCIDColors.textSecondary)
                                .lineLimit(2)
                        }
                    }

                    Spacer(minLength: 0)

                    VStack(spacing: TCIDSpacing.sm) {
                        Button { } label: {
                            Image(systemName: "ellipsis")
                                .foregroundStyle(TCIDColors.textSecondary)
                                .frame(width: TCIDSpacing.touchTarget, height: 28)
                        }
                        .accessibilityLabel("More options")

                        TCIDPlayButton(size: 52, isPlaying: isPlaying, action: onPlay)
                    }
                }

                VStack(spacing: TCIDSpacing.xs) {
                    TCIDProgressBar(progress: progress)
                    HStack {
                        Text(DurationFormatter.format(seconds: elapsedSeconds))
                        Spacer()
                        if let duration = episode.durationSeconds {
                            Text(DurationFormatter.format(seconds: duration))
                        }
                    }
                    .font(TCIDTypography.caption)
                    .foregroundStyle(TCIDColors.textSecondary)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Now playing, \(episode.title)")
    }
}

struct EpisodeRowView: View {
    let episode: Episode
    var showsNewBadge = false
    var isPlaying = false
    var onPlay: () -> Void = {}

    var body: some View {
        TCIDCard {
            HStack(alignment: .top, spacing: TCIDSpacing.md) {
                EpisodeArtworkView(coverArtURL: episode.coverArtURL)

                VStack(alignment: .leading, spacing: TCIDSpacing.xs) {
                    if showsNewBadge {
                        HStack(spacing: TCIDSpacing.xs) {
                            Circle().fill(TCIDColors.accent).frame(width: 6, height: 6)
                            Text("NEW")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(TCIDColors.accent)
                        }
                    }

                    Text(episode.title)
                        .font(TCIDTypography.headline)
                        .foregroundStyle(TCIDColors.textPrimary)
                        .lineLimit(2)

                    if let description = episode.description {
                        Text(description)
                            .font(TCIDTypography.caption)
                            .foregroundStyle(TCIDColors.textSecondary)
                            .lineLimit(2)
                    }

                    HStack(spacing: TCIDSpacing.xs) {
                        Text(DurationFormatter.formatDate(episode.publishedAt))
                        if let duration = episode.durationSeconds {
                            Text("•")
                            Text(DurationFormatter.formatLong(seconds: duration))
                        }
                    }
                    .font(TCIDTypography.caption)
                    .foregroundStyle(TCIDColors.textSecondary)
                }

                Spacer(minLength: 0)

                VStack(spacing: TCIDSpacing.md) {
                    Button { } label: {
                        Image(systemName: "ellipsis")
                            .foregroundStyle(TCIDColors.textSecondary)
                    }
                    .accessibilityLabel("More options")

                    TCIDPlayButton(isPlaying: isPlaying, action: onPlay)
                }
            }
        }
    }
}

struct ContinueListeningRow: View {
    let episode: Episode
    var progress: Double
    var onPlay: () -> Void = {}

    var body: some View {
        HStack(spacing: TCIDSpacing.md) {
            EpisodeArtworkView(coverArtURL: episode.coverArtURL, size: 48)
            VStack(alignment: .leading, spacing: TCIDSpacing.xs) {
                Text(episode.title)
                    .font(TCIDTypography.caption.weight(.semibold))
                    .foregroundStyle(TCIDColors.textPrimary)
                    .lineLimit(1)
                TCIDProgressBar(progress: progress)
            }
            TCIDPlayButton(size: 36, action: onPlay)
        }
        .padding(TCIDSpacing.md)
        .background(TCIDColors.card)
        .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.lg))
    }
}

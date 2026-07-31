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
        .overlay(
            RoundedRectangle(cornerRadius: TCIDRadius.sm)
                .stroke(TCIDColors.border, lineWidth: 1)
        )
        .accessibilityHidden(true)
    }

    private var placeholder: some View {
        ZStack {
            TCIDColors.surfaceElevated
            Image("PodcastLogoDark")
                .resizable()
                .scaledToFit()
                .padding(size * 0.18)
        }
    }
}

struct FeaturedEpisodeCard: View {
    let episode: Episode
    var isPlaying: Bool = false
    var onPlay: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: TCIDSpacing.md) {
            HStack(alignment: .top, spacing: TCIDSpacing.md) {
                EpisodeArtworkView(coverArtURL: episode.coverArtURL, size: 88)

                VStack(alignment: .leading, spacing: TCIDSpacing.xs) {
                    HStack(spacing: TCIDSpacing.xs) {
                        Circle()
                            .fill(TCIDColors.accent)
                            .frame(width: 6, height: 6)
                        Text("LATEST")
                            .font(TCIDTypography.micro.weight(.bold))
                            .foregroundStyle(TCIDColors.accent)
                            .tracking(0.6)
                    }

                    Text(episode.title)
                        .font(TCIDTypography.title)
                        .foregroundStyle(TCIDColors.textPrimary)
                        .lineLimit(3)

                    if let description = episode.description {
                        Text(description)
                            .font(TCIDTypography.caption)
                            .foregroundStyle(TCIDColors.textSecondary)
                            .lineLimit(2)
                    }
                }
            }

            HStack {
                if let duration = episode.durationSeconds {
                    Text(DurationFormatter.formatLong(seconds: duration))
                        .font(TCIDTypography.caption)
                        .foregroundStyle(TCIDColors.textTertiary)
                }
                Spacer()
                TCIDPlayButton(size: 48, isPlaying: isPlaying, action: onPlay)
            }
        }
        .padding(TCIDSpacing.md)
        .background(TCIDColors.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: TCIDRadius.lg)
                .stroke(TCIDColors.border, lineWidth: 1)
        )
    }
}

struct EpisodeRowView: View {
    let episode: Episode
    var showsNewBadge = false
    var isPlaying = false
    var onPlay: () -> Void = {}

    var body: some View {
        HStack(alignment: .center, spacing: TCIDSpacing.md) {
            EpisodeArtworkView(coverArtURL: episode.coverArtURL, size: 56)

            VStack(alignment: .leading, spacing: TCIDSpacing.xs) {
                if showsNewBadge {
                    Text("NEW")
                        .font(TCIDTypography.micro.weight(.bold))
                        .foregroundStyle(TCIDColors.accent)
                        .tracking(0.5)
                }

                Text(episode.title)
                    .font(TCIDTypography.headline)
                    .foregroundStyle(TCIDColors.textPrimary)
                    .lineLimit(2)

                HStack(spacing: TCIDSpacing.xs) {
                    Text(DurationFormatter.formatDate(episode.publishedAt))
                    if let duration = episode.durationSeconds {
                        Text("·")
                        Text(DurationFormatter.formatLong(seconds: duration))
                    }
                }
                .font(TCIDTypography.caption)
                .foregroundStyle(TCIDColors.textTertiary)
            }

            Spacer(minLength: 0)

            TCIDPlayButton(size: 40, isPlaying: isPlaying, action: onPlay)
        }
        .padding(.vertical, TCIDSpacing.sm)
    }
}

struct NowPlayingCard: View {
    let episode: Episode
    var progress: Double = 0.4
    var elapsedSeconds: Int = 1723
    var isPlaying = false
    var onPlay: () -> Void = {}

    var body: some View {
        FeaturedEpisodeCard(episode: episode, isPlaying: isPlaying, onPlay: onPlay)
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
        .background(TCIDColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: TCIDRadius.lg)
                .stroke(TCIDColors.border, lineWidth: 1)
        )
    }
}

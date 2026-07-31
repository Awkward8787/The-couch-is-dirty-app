import SwiftUI

struct TCIDAppHeader: View {
    var showsNotificationBadge = true

    var body: some View {
        HStack {
            Button {
                // Phase 3+
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(TCIDColors.textPrimary)
                        .frame(width: TCIDSpacing.touchTarget, height: TCIDSpacing.touchTarget)

                    if showsNotificationBadge {
                        Circle()
                            .fill(TCIDColors.accent)
                            .frame(width: 8, height: 8)
                            .offset(x: 2, y: 6)
                            .accessibilityLabel("Unread notifications")
                    }
                }
            }
            .accessibilityLabel("Notifications")

            Spacer()

            Image("PodcastLogoDark")
                .resizable()
                .scaledToFit()
                .frame(height: 36)
                .accessibilityLabel("The Couch Is Dirty Podcast")

            Spacer()

            Button {
                // Phase 4 search
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(TCIDColors.textPrimary)
                    .frame(width: TCIDSpacing.touchTarget, height: TCIDSpacing.touchTarget)
            }
            .accessibilityLabel("Search")
        }
        .padding(.horizontal, TCIDSpacing.md)
        .padding(.vertical, TCIDSpacing.sm)
    }
}

struct TCIDSectionHeader: View {
    let title: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        HStack {
            Text(title)
                .font(TCIDTypography.headline)
                .foregroundStyle(TCIDColors.textPrimary)

            Spacer()

            if let actionTitle, let action {
                Button(action: action) {
                    HStack(spacing: 2) {
                        Text(actionTitle)
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                    }
                    .font(TCIDTypography.caption.weight(.semibold))
                    .foregroundStyle(TCIDColors.accent)
                }
                .accessibilityLabel("\(actionTitle) for \(title)")
            }
        }
    }
}

struct TCIDFilterChip: View {
    let title: String
    let isSelected: Bool
    var systemImage: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: TCIDSpacing.xs) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.caption.weight(.semibold))
                }
                Text(title)
                    .font(TCIDTypography.caption.weight(.semibold))
            }
            .foregroundStyle(isSelected ? TCIDColors.textPrimary : TCIDColors.textSecondary)
            .padding(.horizontal, TCIDSpacing.md)
            .frame(minHeight: 36)
            .background(isSelected ? TCIDColors.accent : TCIDColors.card)
            .clipShape(Capsule())
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

struct TCIDProgressBar: View {
    let progress: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(TCIDColors.cardElevated)
                Capsule()
                    .fill(TCIDColors.accent)
                    .frame(width: max(0, geo.size.width * min(1, max(0, progress))))
            }
        }
        .frame(height: 4)
        .accessibilityValue("\(Int(progress * 100)) percent played")
    }
}

struct TCIDPlayButton: View {
    var size: CGFloat = 44
    var isPlaying = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(TCIDColors.textPrimary)
                    .frame(width: size, height: size)
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: size * 0.35, weight: .bold))
                    .foregroundStyle(TCIDColors.accent)
                    .offset(x: isPlaying ? 0 : 2)
            }
        }
        .frame(minWidth: TCIDSpacing.touchTarget, minHeight: TCIDSpacing.touchTarget)
        .accessibilityLabel(isPlaying ? "Pause" : "Play")
    }
}

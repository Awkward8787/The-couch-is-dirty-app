import SwiftUI

/// Warm vignette backdrop for launch, onboarding, and hero moments.
struct TCIDStudioBackground: View {
    var body: some View {
        ZStack {
            TCIDColors.background.ignoresSafeArea()

            RadialGradient(
                colors: [
                    TCIDColors.accent.opacity(0.07),
                    Color.clear,
                ],
                center: .top,
                startRadius: 8,
                endRadius: 420
            )
            .ignoresSafeArea()

            LinearGradient(
                colors: [
                    Color.clear,
                    TCIDColors.background.opacity(0.4),
                ],
                startPoint: .center,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }
}

struct TCIDWordmark: View {
    var logoSize: CGFloat = 40
    var showsTagline: Bool = true
    var alignment: HorizontalAlignment = .center

    var body: some View {
        VStack(alignment: alignment, spacing: TCIDSpacing.sm) {
            Image("PodcastLogoDark")
                .resizable()
                .scaledToFit()
                .frame(width: logoSize, height: logoSize)
                .accessibilityHidden(true)

            VStack(alignment: alignment, spacing: TCIDSpacing.xs) {
                Text("The Couch Is Dirty")
                    .font(TCIDTypography.headline)
                    .foregroundStyle(TCIDColors.textPrimary)

                if showsTagline {
                    Text("Podcast")
                        .font(TCIDTypography.caption)
                        .foregroundStyle(TCIDColors.textTertiary)
                        .tracking(1.2)
                        .textCase(.uppercase)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("The Couch Is Dirty Podcast")
    }
}

struct TCIDSectionGroup<Content: View>: View {
    let title: String?
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: TCIDSpacing.sm) {
            if let title {
                Text(title)
                    .font(TCIDTypography.caption.weight(.semibold))
                    .foregroundStyle(TCIDColors.textTertiary)
                    .textCase(.uppercase)
                    .tracking(0.8)
                    .padding(.horizontal, TCIDSpacing.xs)
            }

            VStack(spacing: 0) {
                content()
            }
            .background(TCIDColors.surfaceOverlay)
            .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: TCIDRadius.lg)
                    .stroke(TCIDColors.border, lineWidth: 1)
            )
        }
    }
}

struct TCIDGroupedRowDivider: View {
    var body: some View {
        Divider()
            .background(TCIDColors.separator)
            .padding(.leading, TCIDSpacing.md)
    }
}

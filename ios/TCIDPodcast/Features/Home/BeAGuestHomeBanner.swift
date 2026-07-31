import SwiftUI

/// Compact Be a Guest promo permanently pinned above the Home composer.
struct BeAGuestHomeBanner: View {
    var body: some View {
        NavigationLink {
            BeAGuestView()
        } label: {
            HStack(spacing: TCIDSpacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: TCIDRadius.sm)
                        .fill(TCIDColors.accentMuted)
                        .frame(width: 44, height: 44)
                    Image(systemName: "mic.fill")
                        .foregroundStyle(TCIDColors.accent)
                }

                VStack(alignment: .leading, spacing: TCIDSpacing.xs) {
                    Text("Be a Guest")
                        .font(TCIDTypography.headline)
                        .foregroundStyle(TCIDColors.textPrimary)
                    Text("Apply to join the couch in person or by phone.")
                        .font(TCIDTypography.caption)
                        .foregroundStyle(TCIDColors.textSecondary)
                        .lineLimit(2)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(TCIDColors.textTertiary)
            }
            .padding(TCIDSpacing.md)
            .background(TCIDColors.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: TCIDRadius.lg)
                    .stroke(TCIDColors.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityHint("Opens the Be a Guest application")
    }
}

#Preview {
    NavigationStack {
        BeAGuestHomeBanner()
            .padding()
            .background(TCIDColors.background)
    }
}

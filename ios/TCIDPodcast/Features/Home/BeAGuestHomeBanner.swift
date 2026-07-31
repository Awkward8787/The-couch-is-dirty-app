import SwiftUI

/// Compact Be a Guest promo permanently pinned above the Home composer.
struct BeAGuestHomeBanner: View {
    var body: some View {
        NavigationLink {
            BeAGuestView()
        } label: {
            VStack(alignment: .leading, spacing: TCIDSpacing.sm) {
                Text("Be a Guest")
                    .font(TCIDTypography.headline)
                    .foregroundStyle(TCIDColors.textPrimary)

                Text("Got a story for the couch? Apply to appear in person or by phone.")
                    .font(TCIDTypography.caption)
                    .foregroundStyle(TCIDColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack {
                    Text("Apply now")
                        .font(TCIDTypography.caption.weight(.semibold))
                        .foregroundStyle(Color.black)
                        .padding(.horizontal, TCIDSpacing.md)
                        .padding(.vertical, TCIDSpacing.sm)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.sm))

                    Spacer(minLength: 0)

                    Text(AppConfig.guestEmail)
                        .font(.caption2)
                        .foregroundStyle(TCIDColors.accent)
                        .lineLimit(1)
                }
            }
            .padding(TCIDSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(TCIDColors.card)
            .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.lg))
        }
        .buttonStyle(.plain)
        .accessibilityHint("Opens the Be a Guest application")
    }
}

#Preview {
    NavigationStack {
        BeAGuestHomeBanner()
            .padding()
            .background(Color.black)
    }
}

import SwiftUI

struct BeAGuestPromoCard: View {
    var body: some View {
        NavigationLink {
            BeAGuestView()
        } label: {
            TCIDCard {
                HStack(spacing: TCIDSpacing.md) {
                    Image(systemName: "mic.fill")
                        .font(.title2)
                        .foregroundStyle(TCIDColors.accent)
                        .frame(width: 44, height: 44)
                        .background(TCIDColors.accentMuted)
                        .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.sm))

                    VStack(alignment: .leading, spacing: TCIDSpacing.xs) {
                        Text("Be a Guest")
                            .font(TCIDTypography.headline)
                            .foregroundStyle(TCIDColors.textPrimary)
                        Text("Join us in person or over the phone.")
                            .font(TCIDTypography.caption)
                            .foregroundStyle(TCIDColors.textSecondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(TCIDColors.textSecondary)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Be a Guest. Join us in person or over the phone.")
    }
}

#Preview {
    NavigationStack {
        BeAGuestPromoCard()
            .padding()
            .background(TCIDColors.background)
    }
}

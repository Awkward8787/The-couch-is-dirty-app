import SwiftUI

struct TCIDPrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(TCIDTypography.headline)
                .foregroundStyle(Color.black)
                .frame(maxWidth: .infinity)
                .frame(minHeight: TCIDSpacing.touchTarget)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.md))
        }
        .accessibilityHint("Double tap to activate")
    }
}

struct TCIDSecondaryButton: View {
    let title: String
    let systemImage: String?
    let action: () -> Void

    init(_ title: String, systemImage: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: TCIDSpacing.sm) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .foregroundStyle(TCIDColors.accent)
                }
                Text(title)
                    .font(TCIDTypography.headline)
                    .foregroundStyle(TCIDColors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: TCIDSpacing.touchTarget)
            .overlay(
                RoundedRectangle(cornerRadius: TCIDRadius.md)
                    .stroke(TCIDColors.border, lineWidth: 1)
            )
        }
        .accessibilityHint("Double tap to activate")
    }
}

struct TCIDCard<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(TCIDSpacing.md)
            .background(TCIDColors.card)
            .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.lg))
    }
}

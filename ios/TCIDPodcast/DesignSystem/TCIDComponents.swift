import SwiftUI

struct TCIDPrimaryButton: View {
    let title: String
    var systemImage: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: TCIDSpacing.sm) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
            }
            .font(TCIDTypography.headline)
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity)
            .frame(minHeight: TCIDSpacing.touchTarget)
            .background(TCIDColors.accent)
            .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.md))
        }
        .accessibilityHint("Double tap to activate")
    }
}

struct TCIDSecondaryButton: View {
    let title: String
    var systemImage: String? = nil
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
                        .foregroundStyle(TCIDColors.textSecondary)
                }
                Text(title)
                    .font(TCIDTypography.headline)
                    .foregroundStyle(TCIDColors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: TCIDSpacing.touchTarget)
            .background(TCIDColors.surface)
            .overlay(
                RoundedRectangle(cornerRadius: TCIDRadius.md)
                    .stroke(TCIDColors.border, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.md))
        }
        .accessibilityHint("Double tap to activate")
    }
}

struct TCIDGhostButton: View {
    let title: String
    var systemImage: String? = nil
    var isActive: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: TCIDSpacing.sm) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
            }
            .font(TCIDTypography.headline)
            .foregroundStyle(isActive ? TCIDColors.accent : TCIDColors.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(minHeight: TCIDSpacing.touchTarget)
            .overlay(
                RoundedRectangle(cornerRadius: TCIDRadius.md)
                    .stroke(isActive ? TCIDColors.accent.opacity(0.5) : TCIDColors.border, lineWidth: 1)
            )
        }
    }
}

struct TCIDCard<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(TCIDSpacing.md)
            .background(TCIDColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: TCIDRadius.lg)
                    .stroke(TCIDColors.border, lineWidth: 1)
            )
    }
}

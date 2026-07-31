import SwiftUI

/// Opens the web creator dashboard in Safari — no in-app sign-in required.
struct CreatorDashboardLink: View {
    @Environment(\.openURL) private var openURL

    var style: Style = .profileRow
    var showsDescription: Bool = true

    enum Style {
        case profileRow
        case compact
    }

    var body: some View {
        switch style {
        case .profileRow:
            profileRow
        case .compact:
            compactLink
        }
    }

    private var profileRow: some View {
        Button {
            openURL(AppConfig.adminDashboardURL)
        } label: {
            HStack(spacing: TCIDSpacing.md) {
                Image(systemName: "macbook.and.iphone")
                    .frame(width: 24)
                    .foregroundStyle(TCIDColors.accent)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Creator Dashboard")
                        .font(TCIDTypography.body)
                        .foregroundStyle(TCIDColors.textPrimary)

                    if showsDescription {
                        Text(creatorDescription)
                            .font(TCIDTypography.caption)
                            .foregroundStyle(TCIDColors.textSecondary)
                            .multilineTextAlignment(.leading)
                    }
                }

                Spacer(minLength: TCIDSpacing.sm)

                Image(systemName: "arrow.up.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(TCIDColors.textSecondary)
            }
            .padding(TCIDSpacing.md)
            .frame(minHeight: TCIDSpacing.touchTarget)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Creator Dashboard")
        .accessibilityHint("Opens the web dashboard in Safari")
    }

    private var compactLink: some View {
        VStack(alignment: .leading, spacing: TCIDSpacing.sm) {
            if showsDescription {
                Text(creatorDescription)
                    .font(TCIDTypography.caption)
                    .foregroundStyle(TCIDColors.textSecondary)
            }

            Button {
                openURL(AppConfig.adminDashboardURL)
            } label: {
                HStack(spacing: 6) {
                    Text("Open Creator Dashboard")
                    Image(systemName: "arrow.up.right")
                        .font(.caption.weight(.semibold))
                }
                .font(TCIDTypography.body.weight(.medium))
                .foregroundStyle(TCIDColors.accent)
            }
            .accessibilityLabel("Open creator dashboard in Safari")
        }
    }

    private var creatorDescription: String {
        "Manage episodes, moderate posts, ban users, sync RSS, and go live from your computer."
    }
}

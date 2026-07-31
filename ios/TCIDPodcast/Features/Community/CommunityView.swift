import SwiftUI

struct CommunityView: View {
    @Environment(AuthService.self) private var auth
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationStack {
            TCIDScreenContainer {
                ScrollView {
                    VStack(alignment: .leading, spacing: TCIDSpacing.lg) {
                        TCIDAppHeader()

                        VStack(alignment: .leading, spacing: TCIDSpacing.xs) {
                            Text("Community")
                                .font(TCIDTypography.display)
                                .foregroundStyle(TCIDColors.textPrimary)
                            Text("Your role, the live feed, and ways to join the show.")
                                .font(TCIDTypography.caption)
                                .foregroundStyle(TCIDColors.textTertiary)
                        }
                        .padding(.horizontal, TCIDSpacing.md)

                        roleCard
                            .padding(.horizontal, TCIDSpacing.md)

                        TCIDSectionGroup(title: "Explore") {
                            hubRow(
                                title: "Open live Feed",
                                subtitle: "See posts and join the conversation",
                                icon: "rectangle.stack.fill"
                            ) {
                                appState.selectedTab = .home
                            }

                            TCIDGroupedRowDivider()

                            NavigationLink {
                                BeAGuestView()
                            } label: {
                                hubRowLabel(
                                    title: "Be a Guest",
                                    subtitle: "Apply to join the couch",
                                    icon: "mic.fill"
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, TCIDSpacing.md)
                        .padding(.bottom, TCIDSpacing.xl)
                    }
                }
            }
        }
    }

    private var roleCard: some View {
        VStack(alignment: .leading, spacing: TCIDSpacing.sm) {
            Text("Your membership")
                .font(TCIDTypography.caption)
                .foregroundStyle(TCIDColors.textTertiary)
                .textCase(.uppercase)
                .tracking(0.6)

            HStack(spacing: TCIDSpacing.sm) {
                TCIDAvatarView(
                    imageURL: auth.avatarURL,
                    name: auth.isAuthenticated ? auth.displayName : "Guest",
                    size: 44
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text(auth.isAuthenticated ? auth.displayName : "Not signed in")
                        .font(TCIDTypography.headline)
                        .foregroundStyle(TCIDColors.textPrimary)

                    Text(auth.communityRole.badgeTitle)
                        .font(TCIDTypography.caption)
                        .foregroundStyle(TCIDColors.textSecondary)
                }

                Spacer()

                Text(auth.communityRole.badgeTitle.uppercased())
                    .font(TCIDTypography.micro.weight(.bold))
                    .foregroundStyle(TCIDColors.accent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(TCIDColors.accentMuted)
                    .clipShape(Capsule())
            }

            Text(
                auth.communityRole.canPost
                    ? "You can post on the Feed."
                    : "Sign in on Profile to post as a Fan, Member, Mod, or Admin."
            )
            .font(TCIDTypography.caption)
            .foregroundStyle(TCIDColors.textSecondary)
        }
        .padding(TCIDSpacing.md)
        .background(TCIDColors.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: TCIDRadius.lg)
                .stroke(TCIDColors.border, lineWidth: 1)
        )
    }

    private func hubRow(
        title: String,
        subtitle: String,
        icon: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            hubRowLabel(title: title, subtitle: subtitle, icon: icon)
        }
        .buttonStyle(.plain)
    }

    private func hubRowLabel(title: String, subtitle: String, icon: String) -> some View {
        HStack(spacing: TCIDSpacing.md) {
            Image(systemName: icon)
                .frame(width: 28)
                .foregroundStyle(TCIDColors.accent)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(TCIDTypography.body.weight(.semibold))
                    .foregroundStyle(TCIDColors.textPrimary)
                Text(subtitle)
                    .font(TCIDTypography.caption)
                    .foregroundStyle(TCIDColors.textTertiary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(TCIDColors.textTertiary)
        }
        .padding(TCIDSpacing.md)
        .frame(minHeight: TCIDSpacing.touchTarget)
    }
}

#Preview {
    CommunityView()
        .environment(AuthService())
        .environment(AppState(hasCompletedOnboarding: true))
}

import SwiftUI

struct CommunityView: View {
    @Environment(AuthService.self) private var auth
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationStack {
            TCIDScreenContainer {
                ScrollView {
                    VStack(alignment: .leading, spacing: TCIDSpacing.lg) {
                        TCIDAppHeader(showsNotificationBadge: false)

                        VStack(alignment: .leading, spacing: TCIDSpacing.xs) {
                            Text("Community")
                                .font(TCIDTypography.largeTitle)
                                .foregroundStyle(TCIDColors.textPrimary)
                            Text("Roles come from Appwrite Teams. Posts live on the Feed tab.")
                                .font(TCIDTypography.body)
                                .foregroundStyle(TCIDColors.textSecondary)
                        }
                        .padding(.horizontal, TCIDSpacing.md)

                        roleCard
                            .padding(.horizontal, TCIDSpacing.md)

                        Button {
                            appState.selectedTab = .home
                        } label: {
                            HStack {
                                Image(systemName: "rectangle.stack.fill")
                                Text("Open live Feed")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .font(TCIDTypography.headline)
                            .foregroundStyle(TCIDColors.textPrimary)
                            .padding(TCIDSpacing.md)
                            .background(TCIDColors.card)
                            .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.lg))
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, TCIDSpacing.md)

                        NavigationLink {
                            BeAGuestView()
                        } label: {
                            HStack {
                                Image(systemName: "mic.fill")
                                Text("Be a Guest")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .font(TCIDTypography.headline)
                            .foregroundStyle(TCIDColors.textPrimary)
                            .padding(TCIDSpacing.md)
                            .background(TCIDColors.card)
                            .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.lg))
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, TCIDSpacing.md)
                        .padding(.bottom, TCIDSpacing.xl)
                    }
                }
            }
        }
    }

    private var roleCard: some View {
        VStack(alignment: .leading, spacing: TCIDSpacing.sm) {
            Text("Your role")
                .font(TCIDTypography.caption)
                .foregroundStyle(TCIDColors.textSecondary)

            HStack(spacing: TCIDSpacing.sm) {
                Text(auth.isAuthenticated ? auth.displayName : "Not signed in")
                    .font(TCIDTypography.headline)
                    .foregroundStyle(TCIDColors.textPrimary)

                Text(auth.communityRole.badgeTitle.uppercased())
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(TCIDColors.accent)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(TCIDSpacing.md)
        .background(TCIDColors.card)
        .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.lg))
    }
}

#Preview {
    CommunityView()
        .environment(AuthService())
        .environment(AppState(hasCompletedOnboarding: true))
}

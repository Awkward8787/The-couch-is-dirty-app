import SwiftUI

struct ProfileView: View {
    var body: some View {
        TCIDScreenContainer {
            ScrollView {
                VStack(spacing: TCIDSpacing.lg) {
                    TCIDAppHeader(showsNotificationBadge: false)

                    VStack(spacing: TCIDSpacing.md) {
                        Circle()
                            .fill(TCIDColors.card)
                            .frame(width: 88, height: 88)
                            .overlay {
                                Image(systemName: "person.fill")
                                    .font(.largeTitle)
                                    .foregroundStyle(TCIDColors.textSecondary)
                            }
                            .accessibilityLabel("Profile photo placeholder")

                        Text("Guest Listener")
                            .font(TCIDTypography.title)
                            .foregroundStyle(TCIDColors.textPrimary)

                        Text("Sign in to join the community, save episodes, and sync progress.")
                            .font(TCIDTypography.body)
                            .foregroundStyle(TCIDColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, TCIDSpacing.lg)
                    }
                    .padding(.top, TCIDSpacing.md)

                    TCIDPrimaryButton(title: "Sign In") {}
                        .padding(.horizontal, TCIDSpacing.lg)

                    VStack(spacing: 0) {
                        profileRow("Saved Episodes", icon: "bookmark")
                        Divider().background(TCIDColors.border)
                        profileRow("Listening History", icon: "clock")
                        Divider().background(TCIDColors.border)
                        profileRow("Notification Preferences", icon: "bell")
                        Divider().background(TCIDColors.border)
                        profileRow("Community Guidelines", icon: "doc.text")
                        Divider().background(TCIDColors.border)
                        profileRow("Privacy Policy", icon: "hand.raised")
                        Divider().background(TCIDColors.border)
                        profileRow("Terms of Use", icon: "doc.plaintext")
                        Divider().background(TCIDColors.border)
                        profileRow("Support", icon: "questionmark.circle")
                    }
                    .background(TCIDColors.card)
                    .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.lg))
                    .padding(.horizontal, TCIDSpacing.md)
                    .padding(.bottom, TCIDSpacing.xl)
                }
            }
        }
    }

    private func profileRow(_ title: String, icon: String) -> some View {
        Button { } label: {
            HStack(spacing: TCIDSpacing.md) {
                Image(systemName: icon)
                    .frame(width: 24)
                    .foregroundStyle(TCIDColors.textSecondary)
                Text(title)
                    .font(TCIDTypography.body)
                    .foregroundStyle(TCIDColors.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(TCIDColors.textSecondary)
            }
            .padding(TCIDSpacing.md)
            .frame(minHeight: TCIDSpacing.touchTarget)
        }
        .accessibilityLabel(title)
    }
}

#Preview {
    ProfileView()
}

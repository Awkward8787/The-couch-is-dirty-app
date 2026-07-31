import SwiftUI

struct ProfileView: View {
    @Environment(AuthService.self) private var auth
    @State private var showsLogin = false

    var body: some View {
        NavigationStack {
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

                            Text(auth.isAuthenticated ? auth.displayName : "Guest Listener")
                                .font(TCIDTypography.title)
                                .foregroundStyle(TCIDColors.textPrimary)

                            if auth.isAuthenticated {
                                Text(auth.currentUser?.email ?? "")
                                    .font(TCIDTypography.caption)
                                    .foregroundStyle(TCIDColors.textSecondary)
                            } else {
                                Text("Sign in to post on the feed, save episodes, and sync progress.")
                                    .font(TCIDTypography.body)
                                    .foregroundStyle(TCIDColors.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, TCIDSpacing.lg)
                            }
                        }
                        .padding(.top, TCIDSpacing.md)

                        if auth.isRestoringSession {
                            ProgressView("Restoring session…")
                                .tint(TCIDColors.accent)
                        } else if auth.isAuthenticated {
                            Button {
                                Task { await auth.signOut() }
                            } label: {
                                Text("Sign Out")
                                    .font(TCIDTypography.headline)
                                    .foregroundStyle(TCIDColors.textPrimary)
                                    .frame(maxWidth: .infinity)
                                    .frame(minHeight: TCIDSpacing.touchTarget)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: TCIDRadius.md)
                                            .stroke(TCIDColors.border, lineWidth: 1)
                                    )
                            }
                            .padding(.horizontal, TCIDSpacing.lg)
                        } else {
                            Button {
                                showsLogin = true
                            } label: {
                                Text("Sign In")
                                    .font(TCIDTypography.headline)
                                    .foregroundStyle(Color.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(minHeight: TCIDSpacing.touchTarget)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.md))
                            }
                            .padding(.horizontal, TCIDSpacing.lg)
                        }

                        VStack(spacing: 0) {
                            NavigationLink {
                                BeAGuestView()
                            } label: {
                                profileRowLabel("Be a Guest", icon: "mic.fill", accent: true)
                            }
                            .buttonStyle(.plain)

                            Divider().background(TCIDColors.border)
                            profileRow("Saved Episodes", icon: "bookmark")
                            Divider().background(TCIDColors.border)
                            profileRow("Listening History", icon: "clock")
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
            .sheet(isPresented: $showsLogin) {
                LoginView()
            }
        }
    }

    private func profileRowLabel(_ title: String, icon: String, accent: Bool = false) -> some View {
        HStack(spacing: TCIDSpacing.md) {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundStyle(accent ? TCIDColors.accent : TCIDColors.textSecondary)
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
        .accessibilityLabel(title)
    }

    private func profileRow(_ title: String, icon: String) -> some View {
        Button { } label: {
            profileRowLabel(title, icon: icon)
        }
    }
}

#Preview {
    ProfileView()
        .environment(AuthService())
}

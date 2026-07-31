import PhotosUI
import SwiftUI
import UIKit

struct ProfileView: View {
    @Environment(AuthService.self) private var auth
    @Environment(UserLibraryStore.self) private var library
    @Environment(BlockedUsersStore.self) private var blockedUsers

    @State private var showsLogin = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var avatarError: String?
    @State private var showsDeleteConfirmation = false
    @State private var deleteError: String?

    var body: some View {
        NavigationStack {
            TCIDScreenContainer {
                ScrollView {
                    VStack(spacing: TCIDSpacing.lg) {
                        TCIDAppHeader()

                        profileHeaderCard
                            .padding(.horizontal, TCIDSpacing.md)

                        if auth.isRestoringSession {
                            ProgressView("Restoring session…")
                                .tint(TCIDColors.accent)
                        } else if auth.isAuthenticated {
                            VStack(spacing: TCIDSpacing.sm) {
                                TCIDSecondaryButton("Sign Out") {
                                    Task { await auth.signOut() }
                                }

                                Button {
                                    showsDeleteConfirmation = true
                                } label: {
                                    Text("Delete Account")
                                        .font(TCIDTypography.caption.weight(.medium))
                                        .foregroundStyle(TCIDColors.destructive)
                                }
                                .frame(minHeight: TCIDSpacing.touchTarget)
                                .accessibilityLabel("Delete account permanently")
                            }
                            .padding(.horizontal, TCIDSpacing.md)
                        } else {
                            TCIDPrimaryButton(title: "Sign In") {
                                showsLogin = true
                            }
                            .padding(.horizontal, TCIDSpacing.md)
                        }

                        TCIDSectionGroup(title: "Listening") {
                            profileLink("Saved Episodes", icon: "bookmark") { SavedEpisodesView() }
                            TCIDGroupedRowDivider()
                            profileLink("Listening History", icon: "clock") { ListeningHistoryView() }
                        }
                        .padding(.horizontal, TCIDSpacing.md)

                        TCIDSectionGroup(title: "Community") {
                            profileLink("Be a Guest", icon: "mic.fill", accent: true) { BeAGuestView() }
                        }
                        .padding(.horizontal, TCIDSpacing.md)

                        TCIDSectionGroup(title: "Support & Legal") {
                            profileLink("Community Guidelines", icon: "doc.text") {
                                LegalDocumentView(document: LegalContent.communityGuidelines)
                            }
                            TCIDGroupedRowDivider()
                            profileLink("Privacy Policy", icon: "hand.raised") {
                                LegalDocumentView(document: LegalContent.privacyPolicy)
                            }
                            TCIDGroupedRowDivider()
                            profileLink("Terms of Service", icon: "doc.plaintext") {
                                LegalDocumentView(document: LegalContent.termsOfService)
                            }
                            TCIDGroupedRowDivider()
                            profileLink("Support", icon: "questionmark.circle") { SupportView() }
                        }
                        .padding(.horizontal, TCIDSpacing.md)
                        .padding(.bottom, TCIDSpacing.xl)
                    }
                }
            }
            .sheet(isPresented: $showsLogin) {
                LoginView()
            }
            .confirmationDialog(
                "Delete your account?",
                isPresented: $showsDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete Account", role: .destructive) {
                    Task { await performAccountDeletion() }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This permanently deletes your account and profile. Your posts may remain until moderated. This cannot be undone.")
            }
            .onChange(of: selectedPhoto) { _, newItem in
                guard let newItem else { return }
                Task { await loadSelectedPhoto(newItem) }
            }
        }
    }

    @ViewBuilder
    private var profileHeaderCard: some View {
        VStack(spacing: TCIDSpacing.md) {
            avatarSection

            VStack(spacing: TCIDSpacing.xs) {
                Text(auth.isAuthenticated ? auth.displayName : "Guest Listener")
                    .font(TCIDTypography.title)
                    .foregroundStyle(TCIDColors.textPrimary)

                if auth.isAuthenticated {
                    Text(auth.currentUser?.email ?? "")
                        .font(TCIDTypography.caption)
                        .foregroundStyle(TCIDColors.textSecondary)

                    #if DEBUG
                    if auth.communityRole == .admin {
                        Link(destination: AppConfig.adminDashboardURL) {
                            HStack(spacing: 4) {
                                Text("Admin Dashboard")
                                Image(systemName: "arrow.up.right")
                                    .font(.caption2.weight(.semibold))
                            }
                            .font(TCIDTypography.caption.weight(.medium))
                            .foregroundStyle(TCIDColors.accent)
                        }
                    }
                    #endif
                } else {
                    Text("Sign in to post, save episodes, and sync progress.")
                        .font(TCIDTypography.body)
                        .foregroundStyle(TCIDColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }

            if let avatarError {
                Text(avatarError)
                    .font(TCIDTypography.caption)
                    .foregroundStyle(TCIDColors.destructive)
            }

            if let deleteError {
                Text(deleteError)
                    .font(TCIDTypography.caption)
                    .foregroundStyle(TCIDColors.destructive)
            }
        }
        .padding(TCIDSpacing.lg)
        .frame(maxWidth: .infinity)
        .background(TCIDColors.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: TCIDRadius.lg)
                .stroke(TCIDColors.border, lineWidth: 1)
        )
    }

    private func profileLink<Destination: View>(
        _ title: String,
        icon: String,
        accent: Bool = false,
        @ViewBuilder destination: () -> Destination
    ) -> some View {
        NavigationLink {
            destination()
        } label: {
            profileRowLabel(title, icon: icon, accent: accent)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var avatarSection: some View {
        if auth.isAuthenticated {
            PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared()) {
                ZStack(alignment: .bottomTrailing) {
                    TCIDAvatarView(
                        imageURL: auth.avatarURL,
                        name: auth.displayName,
                        size: 88
                    )
                    .overlay {
                        if auth.isSubmitting {
                            Circle()
                                .fill(TCIDColors.surfaceOverlay)
                            ProgressView()
                                .tint(TCIDColors.accent)
                        }
                    }

                    Image(systemName: "camera.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(TCIDColors.textPrimary)
                        .padding(6)
                        .background(TCIDColors.surfaceElevated)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(TCIDColors.border, lineWidth: 1))
                        .offset(x: 2, y: 2)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Change profile photo")
            .accessibilityHint("Opens photo picker to choose a profile picture")
        } else {
            TCIDAvatarView(imageURL: nil, name: "Guest", size: 88)
        }
    }

    private func loadSelectedPhoto(_ item: PhotosPickerItem) async {
        avatarError = nil
        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else {
                avatarError = "Could not load that photo."
                return
            }
            try await auth.uploadAvatar(image: image)
            selectedPhoto = nil
        } catch {
            avatarError = error.localizedDescription
        }
    }

    private func performAccountDeletion() async {
        deleteError = nil
        do {
            try await auth.deleteAccount()
            library.clearAll()
            blockedUsers.clearAll()
        } catch {
            deleteError = auth.lastError ?? error.localizedDescription
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
}

#Preview {
    ProfileView()
        .environment(AuthService())
        .environment(UserLibraryStore())
        .environment(BlockedUsersStore())
}

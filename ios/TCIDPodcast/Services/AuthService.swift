import Appwrite
import Foundation
import Observation
import UIKit

struct AuthUser: Sendable, Equatable {
    let id: String
    let email: String
    let name: String?
}

enum CommunityRole: String, Codable, Sendable, CaseIterable {
    case guest
    case user
    case member
    case moderator
    case admin

    var badgeTitle: String {
        switch self {
        case .guest: "Guest"
        case .user: "Fan"
        case .member: "Member"
        case .moderator: "Mod"
        case .admin: "Admin"
        }
    }

    var canPost: Bool {
        switch self {
        case .guest: false
        case .user, .member, .moderator, .admin: true
        }
    }

    var canModerate: Bool {
        switch self {
        case .moderator, .admin: true
        case .guest, .user, .member: false
        }
    }
}

@Observable
@MainActor
final class AuthService {
    private(set) var currentUser: AuthUser?
    private(set) var userProfile: UserProfile?
    private(set) var communityRole: CommunityRole = .guest
    private(set) var teamIds: Set<String> = []
    private(set) var isRestoringSession = true
    private(set) var isSubmitting = false
    private(set) var lastError: String?

    var isAuthenticated: Bool { currentUser != nil }

    var avatarURL: URL? { userProfile?.avatarURL }

    var displayName: String {
        if let name = currentUser?.name, !name.isEmpty { return name }
        if let email = currentUser?.email {
            return email.split(separator: "@").first.map(String.init) ?? "Couch Fam"
        }
        return "Guest Listener"
    }

    func restoreSession() async {
        isRestoringSession = true
        lastError = nil
        defer { isRestoringSession = false }

        do {
            let user = try await AppwriteClient.account.get()
            currentUser = AuthUser(id: user.id, email: user.email, name: user.name)
            await refreshRole()
            await refreshProfile()
        } catch {
            currentUser = nil
            userProfile = nil
            communityRole = .guest
            teamIds = []
        }
    }

    func signIn(email: String, password: String) async throws {
        isSubmitting = true
        lastError = nil
        defer { isSubmitting = false }

        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !password.isEmpty else {
            lastError = "Email and password are required."
            throw FeedServiceError.signInRequired
        }

        do {
            _ = try await AppwriteClient.account.createEmailPasswordSession(
                email: trimmed,
                password: password
            )
            let user = try await AppwriteClient.account.get()
            currentUser = AuthUser(id: user.id, email: user.email, name: user.name)
            await refreshRole()
            await refreshProfile()
        } catch {
            lastError = error.localizedDescription
            throw error
        }
    }

    func uploadAvatar(image: UIImage) async throws {
        guard let user = currentUser else {
            throw ProfileServiceError.signInRequired
        }

        isSubmitting = true
        lastError = nil
        defer { isSubmitting = false }

        do {
            userProfile = try await ProfileService.uploadAvatar(
                userId: user.id,
                image: image,
                previousFileId: userProfile?.avatarFileId,
                displayName: displayName
            )
        } catch {
            lastError = error.localizedDescription
            throw error
        }
    }

    func refreshProfile() async {
        guard let userId = currentUser?.id else {
            userProfile = nil
            return
        }

        userProfile = try? await ProfileService.fetchProfile(userId: userId)
    }

    func signOut() async {
        isSubmitting = true
        defer { isSubmitting = false }
        _ = try? await AppwriteClient.account.deleteSession(sessionId: "current")
        currentUser = nil
        userProfile = nil
        communityRole = .guest
        teamIds = []
    }

    /// Permanently deletes the signed-in Appwrite account and local profile data (Guideline 5.1.1(v)).
    func deleteAccount() async throws {
        guard currentUser != nil else {
            lastError = "Sign in to delete your account."
            throw FeedServiceError.signInRequired
        }

        isSubmitting = true
        lastError = nil
        defer { isSubmitting = false }

        do {
            try await AccountDeletionService.deleteCurrentAccount()
            currentUser = nil
            userProfile = nil
            communityRole = .guest
            teamIds = []
        } catch let error as AccountDeletionError {
            lastError = error.localizedDescription
            throw error
        } catch {
            lastError = error.localizedDescription
            throw error
        }
    }

    func sendPasswordRecovery(email: String) async throws {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            lastError = "Enter your email address."
            throw FeedServiceError.signInRequired
        }

        isSubmitting = true
        lastError = nil
        defer { isSubmitting = false }

        do {
            let recoveryURL = AppConfig.passwordRecoveryURL.absoluteString
            _ = try await AppwriteClient.account.createRecovery(
                email: trimmed,
                url: recoveryURL
            )
        } catch {
            lastError = error.localizedDescription
            throw error
        }
    }

    private func refreshRole() async {
        guard let user = currentUser else {
            communityRole = .guest
            teamIds = []
            return
        }

        let isSoleAdministrator = user.email.lowercased()
            == AppConfig.administratorAccountEmail.lowercased()

        do {
            let teams = try await AppwriteClient.teams.list()
            teamIds = Set(teams.teams.map(\.id))
            if isSoleAdministrator, teamIds.contains(AppwriteCollections.Team.admins) {
                communityRole = .admin
            } else if teamIds.contains(AppwriteCollections.Team.moderators) {
                communityRole = .moderator
            } else if teamIds.contains(AppwriteCollections.Team.members) {
                communityRole = .member
            } else {
                communityRole = .user
            }
        } catch {
            communityRole = .user
            teamIds = []
        }
    }
}

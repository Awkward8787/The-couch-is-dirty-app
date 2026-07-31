import Appwrite
import Foundation
import Observation

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
}

@Observable
@MainActor
final class AuthService {
    private(set) var currentUser: AuthUser?
    private(set) var communityRole: CommunityRole = .guest
    private(set) var teamIds: Set<String> = []
    private(set) var isRestoringSession = true
    private(set) var isSubmitting = false
    private(set) var lastError: String?

    var isAuthenticated: Bool { currentUser != nil }

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
        } catch {
            currentUser = nil
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
        } catch {
            lastError = error.localizedDescription
            throw error
        }
    }

    func signOut() async {
        isSubmitting = true
        defer { isSubmitting = false }
        _ = try? await AppwriteClient.account.deleteSession(sessionId: "current")
        currentUser = nil
        communityRole = .guest
        teamIds = []
    }

    private func refreshRole() async {
        guard currentUser != nil else {
            communityRole = .guest
            teamIds = []
            return
        }

        do {
            let teams = try await AppwriteClient.teams.list()
            teamIds = Set(teams.teams.map(\.id))
            if teamIds.contains(AppwriteCollections.Team.admins) {
                communityRole = .admin
            } else if teamIds.contains(AppwriteCollections.Team.moderators) {
                communityRole = .moderator
            } else if teamIds.contains(AppwriteCollections.Team.members) {
                communityRole = .member
            } else {
                communityRole = .user
            }
        } catch {
            // Signed in, but teams unavailable — still a community user.
            communityRole = .user
            teamIds = []
        }
    }
}

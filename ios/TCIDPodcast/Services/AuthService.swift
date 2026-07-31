import Appwrite
import Foundation
import Observation

struct AuthUser: Sendable, Equatable {
    let id: String
    let email: String
    let name: String?
}

@Observable
@MainActor
final class AuthService {
    private(set) var currentUser: AuthUser?
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
        } catch {
            currentUser = nil
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
    }
}

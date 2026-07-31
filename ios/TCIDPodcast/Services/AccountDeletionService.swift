import Appwrite
import AppwriteModels
import Foundation

enum AccountDeletionService {
    static func deleteCurrentAccount() async throws {
        let jwt: AppwriteModels.Jwt
        do {
            jwt = try await AppwriteClient.account.createJWT()
        } catch {
            throw AccountDeletionError.notAuthenticated
        }

        var request = URLRequest(url: AppConfig.accountDeletionURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(jwt.jwt)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw AccountDeletionError.serverError
        }

        guard (200 ... 299).contains(http.statusCode) else {
            if let payload = try? JSONDecoder().decode(DeletionErrorResponse.self, from: data),
               !payload.error.isEmpty {
                throw AccountDeletionError.message(payload.error)
            }
            throw AccountDeletionError.serverError
        }

        _ = try? await AppwriteClient.account.deleteSessions()
    }
}

private struct DeletionErrorResponse: Decodable {
    let error: String
}

enum AccountDeletionError: LocalizedError {
    case notAuthenticated
    case serverError
    case message(String)

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            "Sign in again, then try deleting your account."
        case .serverError:
            "Could not delete your account. Try again or contact support."
        case .message(let text):
            text
        }
    }
}

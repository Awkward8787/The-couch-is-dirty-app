import Appwrite
import AppwriteModels
import Foundation

enum EpisodeService {
    static func fetchPublishedEpisodes(limit: Int = 50) async throws -> [Episode] {
        let response = try await AppwriteClient.databases.listDocuments(
            databaseId: AppConfig.appwriteDatabaseId,
            collectionId: AppwriteCollections.Collection.episodes,
            queries: [
                Query.equal("status", value: EpisodeStatus.published.rawValue),
                Query.orderDesc("published_at"),
                Query.limit(limit),
            ]
        )

        return response.documents.compactMap { document in
            AppwriteDocumentMapping.episode(from: document)
        }
    }

    static func fetchEpisode(documentId: String) async throws -> Episode? {
        let document = try await AppwriteClient.databases.getDocument(
            databaseId: AppConfig.appwriteDatabaseId,
            collectionId: AppwriteCollections.Collection.episodes,
            documentId: documentId
        )
        return AppwriteDocumentMapping.episode(from: document)
    }
}

enum ProfileService {
    static func fetchProfile(userId: String) async throws -> UserProfile? {
        do {
            let document = try await AppwriteClient.databases.getDocument(
                databaseId: AppConfig.appwriteDatabaseId,
                collectionId: AppwriteCollections.Collection.profiles,
                documentId: userId
            )
            return AppwriteDocumentMapping.profile(from: document, userId: userId)
        } catch {
            let message = error.localizedDescription.lowercased()
            if message.contains("not found") {
                return fallbackProfile(userId: userId)
            }
            throw error
        }
    }

    private static func fallbackProfile(userId: String) -> UserProfile {
        UserProfile(
            id: AppwriteDocumentMapping.documentUUID(userId),
            documentId: userId,
            username: nil,
            displayName: nil,
            bio: nil,
            avatarURL: nil,
            role: .user,
            accountStatus: .active
        )
    }
}

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

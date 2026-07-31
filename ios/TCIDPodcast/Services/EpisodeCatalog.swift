import Foundation

@Observable
@MainActor
final class EpisodeCatalog {
    private(set) var episodes: [Episode] = []
    private(set) var isLoading = false
    private(set) var loadError: String?

    var featuredEpisode: Episode? {
        episodes.first
    }

    func loadFromAppwrite() async {
        isLoading = true
        loadError = nil

        do {
            let fetched = try await EpisodeService.fetchPublishedEpisodes()
            episodes = fetched
            if fetched.isEmpty {
                loadError = "No published episodes found in Appwrite yet."
            }
        } catch {
            // Do not fall back to mock titles like "Ep. 87" — that hides real data issues.
            episodes = []
            loadError = "Could not load episodes from Appwrite: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func episode(withID id: UUID) -> Episode? {
        episodes.first { $0.id == id }
    }

    func episode(withDocumentId documentId: String) -> Episode? {
        episodes.first { $0.documentId == documentId }
    }
}

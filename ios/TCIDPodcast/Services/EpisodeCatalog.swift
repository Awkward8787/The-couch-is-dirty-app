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
        guard !isLoading else { return }
        isLoading = true
        loadError = nil

        do {
            let fetched = try await EpisodeService.fetchPublishedEpisodes()
            if fetched.isEmpty {
                episodes = MockDataService.episodes
                loadError = "No published episodes in Appwrite yet. Showing offline preview data."
            } else {
                episodes = fetched
            }
        } catch {
            episodes = MockDataService.episodes
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

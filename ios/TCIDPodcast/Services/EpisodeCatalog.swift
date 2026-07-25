import Foundation

@Observable
@MainActor
final class EpisodeCatalog {
    private(set) var episodes: [Episode] = MockDataService.episodes
    private(set) var isLoading = false
    private(set) var loadError: String?

    var featuredEpisode: Episode? {
        episodes.first
    }

    func loadFromRSS() async {
        isLoading = true
        loadError = nil

        do {
            let fetched = try await RSSFeedService.fetchEpisodes()
            episodes = fetched
        } catch {
            loadError = error.localizedDescription
        }

        isLoading = false
    }

    func episode(withID id: UUID) -> Episode? {
        episodes.first { $0.id == id }
    }
}

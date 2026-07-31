import Foundation
import Observation

struct ListeningHistoryEntry: Identifiable, Codable, Hashable, Sendable {
    var episodeId: UUID
    var positionSeconds: Int
    var lastListenedAt: Date

    var id: UUID { episodeId }
}

@Observable
@MainActor
final class UserLibraryStore {
    private(set) var savedEpisodeIds: Set<UUID> = []
    private(set) var history: [ListeningHistoryEntry] = []

    private var storageScope = "guest"
    private var lastProgressWrite: [UUID: Date] = [:]

    func configure(userId: String?) {
        let scope = userId ?? "guest"
        guard scope != storageScope else { return }
        storageScope = scope
        load()
    }

    func isSaved(_ episodeId: UUID) -> Bool {
        savedEpisodeIds.contains(episodeId)
    }

    func toggleSaved(_ episode: Episode) {
        if savedEpisodeIds.contains(episode.id) {
            savedEpisodeIds.remove(episode.id)
        } else {
            savedEpisodeIds.insert(episode.id)
        }
        persist()
    }

    func recordProgress(episodeId: UUID, positionSeconds: Int) {
        let now = Date()
        if let last = lastProgressWrite[episodeId], now.timeIntervalSince(last) < 5 {
            return
        }
        lastProgressWrite[episodeId] = now

        if let index = history.firstIndex(where: { $0.episodeId == episodeId }) {
            history[index].positionSeconds = max(0, positionSeconds)
            history[index].lastListenedAt = now
        } else {
            history.append(
                ListeningHistoryEntry(
                    episodeId: episodeId,
                    positionSeconds: max(0, positionSeconds),
                    lastListenedAt: now
                )
            )
        }
        history.sort { $0.lastListenedAt > $1.lastListenedAt }
        if history.count > 100 {
            history = Array(history.prefix(100))
        }
        persist()
    }

    func clearAll() {
        savedEpisodeIds = []
        history = []
        lastProgressWrite = [:]
        persist()
    }

    func savedEpisodes(from catalog: [Episode]) -> [Episode] {
        catalog.filter { savedEpisodeIds.contains($0.id) }
            .sorted { lhs, rhs in
                (lhs.publishedAt ?? .distantPast) > (rhs.publishedAt ?? .distantPast)
            }
    }

    func historyEpisodes(from catalog: [Episode]) -> [(episode: Episode, entry: ListeningHistoryEntry)] {
        history.compactMap { entry in
            guard let episode = catalog.first(where: { $0.id == entry.episodeId }) else { return nil }
            return (episode, entry)
        }
    }

    private func load() {
        let defaults = UserDefaults.standard
        if let saved = defaults.stringArray(forKey: savedKey) {
            savedEpisodeIds = Set(saved.compactMap { UUID(uuidString: $0) })
        } else {
            savedEpisodeIds = []
        }
        if let data = defaults.data(forKey: historyKey),
           let decoded = try? JSONDecoder().decode([ListeningHistoryEntry].self, from: data) {
            history = decoded.sorted { $0.lastListenedAt > $1.lastListenedAt }
        } else {
            history = []
        }
        lastProgressWrite = [:]
    }

    private func persist() {
        let defaults = UserDefaults.standard
        defaults.set(savedEpisodeIds.map(\.uuidString), forKey: savedKey)
        if let data = try? JSONEncoder().encode(history) {
            defaults.set(data, forKey: historyKey)
        }
    }

    private var savedKey: String { "tcid.library.saved.\(storageScope)" }
    private var historyKey: String { "tcid.library.history.\(storageScope)" }
}

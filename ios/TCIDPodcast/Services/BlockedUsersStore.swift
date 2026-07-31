import Foundation
import Observation

@Observable
@MainActor
final class BlockedUsersStore {
    private(set) var blockedAuthorIds: Set<String> = []

    private var storageScope = "guest"

    func configure(userId: String?) {
        let scope = userId ?? "guest"
        guard scope != storageScope else { return }
        storageScope = scope
        load()
    }

    func isBlocked(_ authorId: String) -> Bool {
        blockedAuthorIds.contains(authorId)
    }

    func block(authorId: String) {
        blockedAuthorIds.insert(authorId)
        persist()
    }

    func unblock(authorId: String) {
        blockedAuthorIds.remove(authorId)
        persist()
    }

    func clearAll() {
        blockedAuthorIds = []
        persist()
    }

    private func load() {
        let stored = UserDefaults.standard.stringArray(forKey: storageKey) ?? []
        blockedAuthorIds = Set(stored)
    }

    private func persist() {
        UserDefaults.standard.set(Array(blockedAuthorIds), forKey: storageKey)
    }

    private var storageKey: String { "tcid.blocked.\(storageScope)" }
}

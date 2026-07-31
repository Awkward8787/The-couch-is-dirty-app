import SwiftUI
import UIKit

@main
struct TCIDPodcastApp: App {
    @State private var appState = AppState()
    @State private var catalog = EpisodeCatalog()
    @State private var auth = AuthService()
    @State private var feed = FeedStore()
    @State private var library = UserLibraryStore()
    @State private var blockedUsers = BlockedUsersStore()

    init() {
        UIWindow.appearance().backgroundColor = UIColor(
            red: 0.039,
            green: 0.039,
            blue: 0.043,
            alpha: 1
        )
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .environment(catalog)
                .environment(auth)
                .environment(feed)
                .environment(library)
                .environment(blockedUsers)
                .preferredColorScheme(.dark)
                .background(TCIDColors.background.ignoresSafeArea())
                .task {
                    async let session: Void = auth.restoreSession()
                    async let episodes: Void = catalog.loadFromAppwrite()
                    _ = await (session, episodes)
                    syncUserScopedStores()
                }
                .onChange(of: auth.currentUser?.id) { _, _ in
                    syncUserScopedStores()
                }
        }
    }

    private func syncUserScopedStores() {
        library.configure(userId: auth.currentUser?.id)
        blockedUsers.configure(userId: auth.currentUser?.id)
    }
}

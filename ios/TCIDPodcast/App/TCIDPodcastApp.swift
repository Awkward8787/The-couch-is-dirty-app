import SwiftUI
import UIKit

@main
struct TCIDPodcastApp: App {
    @State private var appState = AppState()
    @State private var catalog = EpisodeCatalog()
    @State private var auth = AuthService()
    @State private var feed = FeedStore()

    init() {
        UIWindow.appearance().backgroundColor = .black
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .environment(catalog)
                .environment(auth)
                .environment(feed)
                .preferredColorScheme(.dark)
                .background(TCIDColors.background.ignoresSafeArea())
                .task {
                    await auth.restoreSession()
                }
        }
    }
}

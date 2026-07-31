import SwiftUI
import UIKit

@main
struct TCIDPodcastApp: App {
    @State private var appState = AppState()
    @State private var catalog = EpisodeCatalog()

    init() {
        // Prevent the system window from flashing white before SwiftUI paints.
        UIWindow.appearance().backgroundColor = .black
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .environment(catalog)
                .preferredColorScheme(.dark)
                .background(TCIDColors.background.ignoresSafeArea())
        }
    }
}

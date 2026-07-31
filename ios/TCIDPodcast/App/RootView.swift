import SwiftUI

struct RootView: View {
    @Environment(AppState.self) private var appState
    @Environment(EpisodeCatalog.self) private var catalog
    @State private var showsLaunchSplash = false
    @State private var minimumSplashElapsed = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            Group {
                if !appState.hasCompletedOnboarding {
                    // First launch: only black + logo + Enter — no second splash on top.
                    OnboardingView()
                } else {
                    MainTabView()
                }
            }

            if showsLaunchSplash {
                LaunchScreenView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .background(Color.black.ignoresSafeArea())
        .task {
            // Loading splash only after onboarding, while episodes load.
            guard appState.hasCompletedOnboarding else { return }

            showsLaunchSplash = true
            async let splashTimer: Void = waitForMinimumSplash()
            async let catalogLoad: Void = loadCatalogIfNeeded()
            _ = await (splashTimer, catalogLoad)
            dismissSplashIfReady()
        }
        .onChange(of: catalog.isLoading) { _, isLoading in
            if !isLoading {
                dismissSplashIfReady()
            }
        }
        .onChange(of: minimumSplashElapsed) { _, elapsed in
            if elapsed {
                dismissSplashIfReady()
            }
        }
        .onChange(of: appState.hasCompletedOnboarding) { _, completed in
            guard completed else { return }
            Task {
                showsLaunchSplash = true
                minimumSplashElapsed = false
                async let splashTimer: Void = waitForMinimumSplash()
                async let catalogLoad: Void = loadCatalogIfNeeded()
                _ = await (splashTimer, catalogLoad)
                dismissSplashIfReady()
            }
        }
    }

    private func waitForMinimumSplash() async {
        try? await Task.sleep(for: .milliseconds(1200))
        minimumSplashElapsed = true
    }

    private func loadCatalogIfNeeded() async {
        if catalog.episodes.isEmpty && !catalog.isLoading {
            await catalog.loadFromAppwrite()
        }
    }

    private func dismissSplashIfReady() {
        guard showsLaunchSplash else { return }
        guard minimumSplashElapsed else { return }
        guard !catalog.isLoading else { return }

        withAnimation(.easeOut(duration: 0.3)) {
            showsLaunchSplash = false
        }
    }
}

#Preview {
    RootView()
        .environment(AppState(hasCompletedOnboarding: false))
        .environment(EpisodeCatalog())
}

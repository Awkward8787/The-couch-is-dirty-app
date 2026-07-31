import SwiftUI

struct RootView: View {
    @Environment(AppState.self) private var appState
    @Environment(EpisodeCatalog.self) private var catalog
    @State private var showsLaunchSplash = true
    @State private var minimumSplashElapsed = false

    var body: some View {
        ZStack {
            TCIDColors.background.ignoresSafeArea()

            Group {
                if !appState.hasCompletedOnboarding {
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
        .background(TCIDColors.background.ignoresSafeArea())
        .task {
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
    }

    private func waitForMinimumSplash() async {
        try? await Task.sleep(for: .milliseconds(1600))
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

        withAnimation(.easeOut(duration: 0.35)) {
            showsLaunchSplash = false
        }
    }
}

#Preview {
    RootView()
        .environment(AppState(hasCompletedOnboarding: true))
        .environment(EpisodeCatalog())
}

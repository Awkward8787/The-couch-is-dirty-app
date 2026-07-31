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
            async let minimumHold: Void = {
                try? await Task.sleep(for: .milliseconds(1600))
                minimumSplashElapsed = true
            }()

            if catalog.episodes.isEmpty && !catalog.isLoading {
                await catalog.loadFromAppwrite()
            }

            _ = await minimumHold
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

    private func dismissSplashIfReady() {
        guard showsLaunchSplash else { return }
        guard minimumSplashElapsed else { return }
        // Keep splash up until the first catalog attempt finishes (success or error).
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

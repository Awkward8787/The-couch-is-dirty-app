import SwiftUI

struct RootView: View {
    @Environment(AppState.self) private var appState
    @Environment(EpisodeCatalog.self) private var catalog
    @Environment(AuthService.self) private var auth

    @State private var showsLaunchSplash = false
    @State private var minimumSplashElapsed = false
    @State private var launchProgress: Double = 0.05

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
                LaunchScreenView(progress: launchProgress)
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .background(TCIDColors.background.ignoresSafeArea())
        .task {
            guard appState.hasCompletedOnboarding else { return }
            await runLaunchSequence()
        }
        .onChange(of: catalog.isLoading) { _, _ in
            refreshLaunchProgress()
            dismissSplashIfReady()
        }
        .onChange(of: auth.isRestoringSession) { _, _ in
            refreshLaunchProgress()
        }
        .onChange(of: minimumSplashElapsed) { _, elapsed in
            if elapsed {
                refreshLaunchProgress()
                dismissSplashIfReady()
            }
        }
        .onChange(of: appState.hasCompletedOnboarding) { _, completed in
            guard completed else { return }
            Task { await runLaunchSequence() }
        }
    }

    private func runLaunchSequence() async {
        showsLaunchSplash = true
        minimumSplashElapsed = false
        launchProgress = 0.05
        refreshLaunchProgress()

        async let splashTimer: Void = waitForMinimumSplash()
        async let catalogLoad: Void = loadCatalogIfNeeded()
        async let progressTicker: Void = creepProgressWhileLoading()

        _ = await (splashTimer, catalogLoad, progressTicker)
        refreshLaunchProgress()
        dismissSplashIfReady()
    }

    private func waitForMinimumSplash() async {
        try? await Task.sleep(for: .milliseconds(650))
        minimumSplashElapsed = true
    }

    private func loadCatalogIfNeeded() async {
        if catalog.episodes.isEmpty && !catalog.isLoading {
            await catalog.loadFromAppwrite()
        }
    }

    private func creepProgressWhileLoading() async {
        while showsLaunchSplash && launchProgress < 0.92 {
            try? await Task.sleep(for: .milliseconds(80))
            guard showsLaunchSplash else { return }
            let target = bootstrapTargetProgress()
            if launchProgress < target {
                launchProgress = min(target, launchProgress + 0.04)
            } else if launchProgress < 0.88 {
                launchProgress = min(0.88, launchProgress + 0.008)
            }
        }
    }

    private func bootstrapTargetProgress() -> Double {
        var value = 0.1
        if !auth.isRestoringSession { value += 0.3 }
        if !catalog.isLoading { value += 0.55 }
        else if !catalog.episodes.isEmpty { value += 0.35 }
        if minimumSplashElapsed { value += 0.05 }
        return min(value, 1)
    }

    private func refreshLaunchProgress() {
        let target = bootstrapTargetProgress()
        withAnimation(.easeOut(duration: 0.25)) {
            launchProgress = max(launchProgress, target)
        }
    }

    private func dismissSplashIfReady() {
        guard showsLaunchSplash else { return }
        guard minimumSplashElapsed else { return }
        guard !catalog.isLoading else { return }

        withAnimation(.easeOut(duration: 0.2)) {
            launchProgress = 1
        }

        Task {
            try? await Task.sleep(for: .milliseconds(180))
            withAnimation(.easeOut(duration: 0.28)) {
                showsLaunchSplash = false
            }
        }
    }
}

#Preview {
    RootView()
        .environment(AppState(hasCompletedOnboarding: false))
        .environment(EpisodeCatalog())
        .environment(AuthService())
}

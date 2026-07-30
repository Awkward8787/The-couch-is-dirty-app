import SwiftUI

struct RootView: View {
    @Environment(AppState.self) private var appState
    @State private var showsLaunchSplash = true

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
            // Brief branded splash so the system launch screen never lands on white content.
            try? await Task.sleep(for: .milliseconds(450))
            withAnimation(.easeOut(duration: 0.25)) {
                showsLaunchSplash = false
            }
        }
    }
}

#Preview {
    RootView()
        .environment(AppState(hasCompletedOnboarding: true))
}

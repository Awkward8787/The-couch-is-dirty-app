import SwiftUI

struct RootView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        Group {
            if !appState.hasCompletedOnboarding {
                OnboardingView()
            } else {
                MainTabView()
            }
        }
        .background(TCIDColors.background.ignoresSafeArea())
    }
}

#Preview {
    RootView()
        .environment(AppState(hasCompletedOnboarding: true))
}

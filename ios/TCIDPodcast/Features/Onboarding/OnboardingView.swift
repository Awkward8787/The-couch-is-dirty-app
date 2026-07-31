import SwiftUI

struct OnboardingView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: TCIDSpacing.xl) {
                Spacer()

                Image("PodcastLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 240)
                    .accessibilityLabel("The Couch Is Dirty Podcast")

                Spacer()

                TCIDPrimaryButton(title: "Enter") {
                    appState.completeOnboarding()
                }
                .padding(.horizontal, TCIDSpacing.lg)
                .padding(.bottom, TCIDSpacing.xl)
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environment(AppState())
}

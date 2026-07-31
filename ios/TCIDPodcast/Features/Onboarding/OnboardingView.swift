import SwiftUI

struct OnboardingView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ZStack {
            TCIDColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: TCIDSpacing.xl)

                Image("PodcastLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 260)
                    .accessibilityLabel("The Couch Is Dirty Podcast")

                Spacer(minLength: TCIDSpacing.lg)

                VStack(spacing: TCIDSpacing.sm) {
                    Text("Real talk. No filter.")
                        .font(TCIDTypography.title)
                        .foregroundStyle(TCIDColors.textPrimary)
                        .multilineTextAlignment(.center)

                    Rectangle()
                        .fill(TCIDColors.accent)
                        .frame(width: 40, height: 3)
                        .accessibilityHidden(true)
                }

                Spacer()

                VStack(spacing: TCIDSpacing.md) {
                    TCIDPrimaryButton(title: "Enter App") {
                        appState.completeOnboarding()
                    }

                    TCIDSecondaryButton("Join Community", systemImage: "person.2.fill") {
                        appState.completeOnboarding()
                        appState.selectedTab = .community
                    }
                }
                .padding(.horizontal, TCIDSpacing.lg)
                .padding(.bottom, TCIDSpacing.xl)
            }
            .padding(.horizontal, TCIDSpacing.md)
        }
    }
}

#Preview {
    OnboardingView()
        .environment(AppState())
}

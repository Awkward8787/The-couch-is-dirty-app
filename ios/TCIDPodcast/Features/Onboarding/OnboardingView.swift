import SwiftUI

struct OnboardingView: View {
    @Environment(AppState.self) private var appState
    @State private var currentPage = 0

    private let tagline = "Real talk. No filter."

    var body: some View {
        ZStack {
            TCIDColors.background.ignoresSafeArea()

            VStack(spacing: TCIDSpacing.lg) {
                Spacer()

                Image("PodcastLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 280)
                    .shadow(color: TCIDColors.accent.opacity(0.3), radius: 40)
                    .accessibilityLabel("The Couch Is Dirty Podcast")

                Text(tagline)
                    .font(TCIDTypography.title)
                    .foregroundStyle(TCIDColors.textPrimary)

                Rectangle()
                    .fill(TCIDColors.accent)
                    .frame(width: 48, height: 3)
                    .accessibilityHidden(true)

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

                HStack(spacing: TCIDSpacing.sm) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? TCIDColors.accent : TCIDColors.textSecondary.opacity(0.4))
                            .frame(width: 8, height: 8)
                            .accessibilityLabel(index == currentPage ? "Page \(index + 1), current" : "Page \(index + 1)")
                    }
                }
                .padding(.bottom, TCIDSpacing.lg)
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environment(AppState())
}

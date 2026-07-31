import SwiftUI

struct OnboardingView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                Image("PodcastLogoDark")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 260)
                    .padding(.horizontal, 32)
                    .accessibilityLabel("The Couch Is Dirty Podcast")

                Spacer()

                Button {
                    appState.completeOnboarding()
                } label: {
                    Text("Enter the site")
                        .font(TCIDTypography.headline)
                        .foregroundStyle(Color.black)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: TCIDSpacing.touchTarget)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.md))
                }
                .padding(.horizontal, TCIDSpacing.lg)
                .padding(.bottom, 48)
                .accessibilityHint("Opens the app")
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    OnboardingView()
        .environment(AppState())
}

import SwiftUI

struct OnboardingView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var didAppear = false

    var body: some View {
        ZStack {
            TCIDStudioBackground()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: TCIDSpacing.lg) {
                    TCIDWordmark(logoSize: 52, showsTagline: true)
                        .opacity(didAppear ? 1 : 0)
                        .offset(y: didAppear ? 0 : 8)

                    Text("Real talk. Unfiltered conversations from the couch.")
                        .font(TCIDTypography.body)
                        .foregroundStyle(TCIDColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, TCIDSpacing.xl)
                        .opacity(didAppear ? 1 : 0)
                }

                Spacer()

                VStack(spacing: TCIDSpacing.sm) {
                    TCIDPrimaryButton(title: "Get Started") {
                        appState.completeOnboarding()
                    }

                    Text("Listen free · Sign in to join the feed")
                        .font(TCIDTypography.caption)
                        .foregroundStyle(TCIDColors.textTertiary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, TCIDSpacing.lg)
                .padding(.bottom, 48)
                .opacity(didAppear ? 1 : 0)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            guard !reduceMotion else {
                didAppear = true
                return
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.08)) {
                didAppear = true
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environment(AppState())
}

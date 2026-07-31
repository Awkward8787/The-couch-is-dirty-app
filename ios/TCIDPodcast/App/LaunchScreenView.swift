import SwiftUI

struct LaunchScreenView: View {
    @State private var jokeIndex = 0
    @State private var contentOpacity: Double = 0

    private let jokes = [
        "Fluffing the cushions…",
        "Convincing the couch this is a good idea…",
        "Digging for the remote under the cushions…",
        "Warming up the dirty couch…",
        "Adjusting the cushions for maximum honesty…",
        "Asking the couch not to spill tea… yet.",
    ]

    var body: some View {
        ZStack {
            TCIDColors.background.ignoresSafeArea()

            VStack(spacing: TCIDSpacing.lg) {
                Spacer()

                Image("PodcastLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 220)
                    .accessibilityLabel("The Couch Is Dirty Podcast")

                Spacer()

                VStack(spacing: TCIDSpacing.md) {
                    ProgressView()
                        .tint(TCIDColors.accent)
                        .scaleEffect(1.1)
                        .accessibilityLabel("Loading")

                    Text(jokes[jokeIndex])
                        .font(TCIDTypography.caption)
                        .foregroundStyle(TCIDColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, TCIDSpacing.xl)
                        .animation(.easeInOut(duration: 0.35), value: jokeIndex)
                }
                .padding(.bottom, TCIDSpacing.xl)
            }
            .opacity(contentOpacity)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.35)) {
                contentOpacity = 1
            }
        }
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(2.2))
                guard !Task.isCancelled else { return }
                jokeIndex = (jokeIndex + 1) % jokes.count
            }
        }
    }
}

#Preview {
    LaunchScreenView()
}

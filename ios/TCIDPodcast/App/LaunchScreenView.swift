import SwiftUI

struct LaunchScreenView: View {
    @State private var jokeIndex = 0

    private let jokes = [
        "Fluffing the cushions…",
        "Convincing the couch this is a good idea…",
        "Digging for the remote under the cushions…",
        "Warming up the dirty couch…",
        "Adjusting the cushions for maximum honesty…",
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: TCIDSpacing.lg) {
                Spacer()

                Image("PodcastLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 220)
                    .padding(.horizontal, 32)
                    .accessibilityLabel("The Couch Is Dirty Podcast")

                Spacer()

                VStack(spacing: TCIDSpacing.md) {
                    ProgressView()
                        .tint(TCIDColors.accent)
                        .accessibilityLabel("Loading")

                    Text(jokes[jokeIndex])
                        .font(TCIDTypography.caption)
                        .foregroundStyle(TCIDColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, TCIDSpacing.xl)
                }
                .padding(.bottom, TCIDSpacing.xl)
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

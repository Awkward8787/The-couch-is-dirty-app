import SwiftUI

struct LaunchScreenView: View {
    var progress: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var didAppear = false

    private let barWidth: CGFloat = 120

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                TCIDStudioBackground()

                VStack(spacing: TCIDSpacing.md) {
                    Spacer()
                        .frame(height: topInset(for: proxy))

                    TCIDWordmark(logoSize: 36, showsTagline: true)
                        .opacity(didAppear ? 1 : 0)
                        .scaleEffect(didAppear ? 1 : 0.96)

                    LaunchProgressBar(progress: progress, width: barWidth)
                        .padding(.top, TCIDSpacing.sm)

                    Text(statusLine)
                        .font(TCIDTypography.micro)
                        .foregroundStyle(TCIDColors.textTertiary)
                        .multilineTextAlignment(.center)
                        .accessibilityLabel(statusLine)

                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear {
            guard !reduceMotion else {
                didAppear = true
                return
            }
            withAnimation(.easeOut(duration: 0.45)) {
                didAppear = true
            }
        }
    }

    private var statusLine: String {
        if progress >= 1 { return "Welcome back" }
        if progress >= 0.55 { return "Almost ready" }
        if progress >= 0.2 { return "Loading episodes" }
        return "Starting up"
    }

    private func topInset(for proxy: GeometryProxy) -> CGFloat {
        proxy.safeAreaInsets.top + proxy.size.height * 0.16
    }
}

private struct LaunchProgressBar: View {
    let progress: Double
    let width: CGFloat

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(TCIDColors.border)

            Capsule()
                .fill(TCIDColors.accent)
                .frame(width: width * clampedProgress)
        }
        .frame(width: width, height: 2)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.28), value: clampedProgress)
        .accessibilityLabel("Loading progress")
        .accessibilityValue("\(Int(clampedProgress * 100)) percent")
    }

    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }
}

#Preview("Mid load") {
    LaunchScreenView(progress: 0.42)
}

#Preview("Complete") {
    LaunchScreenView(progress: 1)
}

import SwiftUI

struct LaunchScreenView: View {
    var body: some View {
        ZStack {
            TCIDColors.background.ignoresSafeArea()
            Image("PodcastLogo")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 240)
                .accessibilityLabel("The Couch Is Dirty Podcast")
        }
    }
}

#Preview {
    LaunchScreenView()
}

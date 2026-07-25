import SwiftUI

struct MainTabView: View {
    @Environment(AppState.self) private var appState
    @State private var playback = PlaybackState()
    @State private var catalog = EpisodeCatalog()

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: Binding(
                get: { appState.selectedTab },
                set: { appState.selectedTab = $0 }
            )) {
                HomeView()
                    .tag(AppTab.home)
                    .tabItem { tabLabel(for: .home) }

                EpisodesView()
                    .tag(AppTab.episodes)
                    .tabItem { tabLabel(for: .episodes) }

                CommunityView()
                    .tag(AppTab.community)
                    .tabItem { tabLabel(for: .community) }

                ProfileView()
                    .tag(AppTab.profile)
                    .tabItem { tabLabel(for: .profile) }
            }
            .tint(TCIDColors.accent)

            MiniPlayerBar()
        }
        .environment(playback)
        .environment(catalog)
        .onAppear {
            playback.configureAudioSession()
            configureTabBarAppearance()
        }
        .task {
            await catalog.loadFromRSS()
        }
    }

    @ViewBuilder
    private func tabLabel(for tab: AppTab) -> some View {
        Label {
            Text(tab.title)
        } icon: {
            ZStack(alignment: .topTrailing) {
                Image(systemName: tab.systemImage)
                if tab == .community {
                    Circle()
                        .fill(TCIDColors.accent)
                        .frame(width: 8, height: 8)
                        .offset(x: 4, y: -4)
                        .accessibilityHidden(true)
                }
            }
        }
    }

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    MainTabView()
        .environment(AppState(hasCompletedOnboarding: true))
}

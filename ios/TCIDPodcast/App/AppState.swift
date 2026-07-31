import Foundation
import Observation

@Observable
@MainActor
final class AppState {
    var hasCompletedOnboarding: Bool
    var selectedTab: AppTab = .home

    init(
        hasCompletedOnboarding: Bool = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    ) {
        self.hasCompletedOnboarding = hasCompletedOnboarding
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
}

enum AppTab: String, CaseIterable, Identifiable {
    case home
    case episodes
    case community
    case profile

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: "Feed"
        case .episodes: "Episodes"
        case .community: "Community"
        case .profile: "Profile"
        }
    }

    var systemImage: String {
        switch self {
        case .home: "rectangle.stack.fill"
        case .episodes: "mic.fill"
        case .community: "person.3.fill"
        case .profile: "person.fill"
        }
    }
}

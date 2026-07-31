import Foundation

enum AppConfig {
    private static let secrets: [String: Any] = {
        guard
            let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any]
        else {
            return [:]
        }
        return plist
    }()

    /// Self-hosted Appwrite API endpoint (no trailing slash).
    static var appwriteEndpoint: String {
        secrets["APPWRITE_ENDPOINT"] as? String ?? "https://api.tcidpodcast.com/v1"
    }

    static var appwriteProjectId: String {
        secrets["APPWRITE_PROJECT_ID"] as? String ?? "tcidpodcast"
    }

    static var appwriteDatabaseId: String {
        secrets["APPWRITE_DATABASE_ID"] as? String ?? AppwriteCollections.databaseId
    }

    static let supportEmail = "info@tcidpodcast.com"
    static let guestEmail = "info@tcidpodcast.com"
    static let websiteURL = URL(string: "https://tcidpodcast.com")!
    static let privacyURL = URL(string: "https://tcidpodcast.com/privacy")!
    static let termsURL = URL(string: "https://tcidpodcast.com/terms")!
    static let communityGuidelinesURL = URL(string: "https://tcidpodcast.com/community-guidelines")!
    static let minimumAge = 13
    static let bundleIdentifier = "com.tcidpodcast.app"
    static let showName = "The Couch Is Dirty Podcast"
    static let rssFeedURL = URL(string: "https://media.rss.com/the-couch-is-dirty-podcast/feed.xml")!
    static let podcastArtworkURL = URL(string: "https://media.rss.com/the-couch-is-dirty-podcast/20260203_060212_32f38b82552f042abcdb98d0b9254e8b.png")!
}

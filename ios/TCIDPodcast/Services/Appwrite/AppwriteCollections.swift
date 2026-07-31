import Foundation

/// Appwrite database, collection, bucket, and team identifiers.
enum AppwriteCollections {
    /// Matches the Database ID created in Appwrite Console.
    static let databaseId = "episodes"

    enum Collection {
        static let episodes = "episodes"
        static let profiles = "profiles"
        static let submissions = "submissions"
        static let guestApplications = "guest_applications"
        static let posts = "posts"
        static let postComments = "post_comments"
        static let opinions = "opinions"
        static let streams = "streams"
        static let favoriteEpisodes = "favorite_episodes"
        static let orders = "orders"
    }

    enum Bucket {
        static let avatars = "avatars"
        static let episodeImages = "episode-images"
        static let postImages = "post-images"
        static let guestUploads = "guest-uploads"
    }

    enum Team {
        static let members = "members"
        static let moderators = "moderators"
        static let admins = "admins"
    }
}

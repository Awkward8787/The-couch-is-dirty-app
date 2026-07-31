import Foundation

struct Episode: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    /// Appwrite document ID (used for API lookups).
    var documentId: String?
    var rssGuid: String?
    var source: EpisodeSource
    var status: EpisodeStatus
    var title: String
    var slug: String?
    var description: String?
    var showNotes: String?
    var audioURL: URL?
    var coverArtURL: URL?
    var durationSeconds: Int?
    var seasonNumber: Int?
    var episodeNumber: Int?
    var isExplicit: Bool
    var publishedAt: Date?
    var playCount: Int
    var chapters: [EpisodeChapter]

    enum CodingKeys: String, CodingKey {
        case id
        case documentId = "document_id"
        case rssGuid = "rss_guid"
        case source, status, title, slug, description
        case showNotes = "show_notes"
        case audioURL = "audio_url"
        case coverArtURL = "cover_art_url"
        case durationSeconds = "duration_seconds"
        case seasonNumber = "season_number"
        case episodeNumber = "episode_number"
        case isExplicit = "is_explicit"
        case publishedAt = "published_at"
        case playCount = "play_count"
        case chapters
    }
}

enum EpisodeSource: String, Codable, Sendable {
    case rss
    case manual
}

enum EpisodeStatus: String, Codable, Sendable {
    case draft
    case scheduled
    case published
    case archived
}

struct EpisodeChapter: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var title: String
    var startSeconds: Int
    var sortOrder: Int

    enum CodingKeys: String, CodingKey {
        case id, title
        case startSeconds = "start_seconds"
        case sortOrder = "sort_order"
    }
}

struct UserProfile: Identifiable, Sendable {
    let id: UUID
    var documentId: String?
    var username: String?
    var displayName: String?
    var bio: String?
    var avatarFileId: String?
    var avatarURL: URL?
    var role: UserRole
    var accountStatus: AccountStatus
}

enum UserRole: String, Codable, Sendable {
    case user
    case moderator
    case admin
}

enum AccountStatus: String, Codable, Sendable {
    case active
    case warned
    case suspended
    case banned
}

struct CommunityPost: Identifiable, Codable, Sendable {
    let id: UUID
    var authorId: UUID
    var episodeId: UUID?
    var postType: PostType
    var title: String?
    var body: String
    var isPinned: Bool
    var isFeatured: Bool
    var replyCount: Int
    var reactionCount: Int
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, title, body
        case authorId = "author_id"
        case episodeId = "episode_id"
        case postType = "post_type"
        case isPinned = "is_pinned"
        case isFeatured = "is_featured"
        case replyCount = "reply_count"
        case reactionCount = "reaction_count"
        case createdAt = "created_at"
    }
}

enum PostType: String, Codable, Sendable {
    case discussion
    case question
    case comment
    case episodeDiscussion = "episode_discussion"
}

struct ListeningProgress: Codable, Sendable {
    var episodeId: UUID
    var positionSeconds: Int
    var completed: Bool
    var lastListenedAt: Date

    enum CodingKeys: String, CodingKey {
        case episodeId = "episode_id"
        case positionSeconds = "position_seconds"
        case completed
        case lastListenedAt = "last_listened_at"
    }
}

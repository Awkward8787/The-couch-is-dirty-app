import Foundation

enum FeedPostKind: String, Codable, Sendable {
    case text
    case link
    case image
    case video
}

enum FeedModerationStatus: String, Codable, Sendable {
    case visible
    case hidden
    case removed
    case reported
}

struct FeedPost: Identifiable, Hashable, Sendable {
    let id: String
    var authorId: String
    var authorName: String
    var authorRole: CommunityRole
    var authorAvatarURL: URL?
    var body: String
    var linkURL: URL?
    var imageFileId: String?
    var imageURL: URL?
    var videoFileId: String?
    var videoURL: URL?
    var videoDurationSeconds: Int?
    var kind: FeedPostKind
    let createdAt: Date
    var updatedAt: Date?
    var likeCount: Int
    var commentCount: Int
    var isEdited: Bool
    var moderationStatus: FeedModerationStatus

    var hasPlayableVideoLink: Bool {
        guard let linkURL else { return false }
        return VideoLinkParser.classify(linkURL) != .unsupported
    }

    var isVisibleInFeed: Bool {
        switch moderationStatus {
        case .visible, .reported: true
        case .hidden, .removed: false
        }
    }
}

struct FeedComment: Identifiable, Hashable, Sendable {
    let id: String
    let postId: String
    var authorId: String
    var authorName: String
    var body: String
    let createdAt: Date
}

enum VideoLinkKind: Equatable, Sendable {
    case youtube(videoId: String)
    case directVideo(url: URL)
    case unsupported
}

enum VideoLinkParser {
    static func classify(_ url: URL) -> VideoLinkKind {
        let scheme = (url.scheme ?? "").lowercased()
        guard scheme == "http" || scheme == "https" else {
            return .unsupported
        }

        let host = (url.host ?? "").lowercased()
        let path = url.path
        let absolute = url.absoluteString

        if host.contains("youtube.com") || host.contains("youtu.be") || host.contains("youtube-nocookie.com") {
            if let id = youtubeID(from: url) {
                return .youtube(videoId: id)
            }
        }

        let videoExtensions = [".mp4", ".m3u8", ".mov", ".m4v"]
        if videoExtensions.contains(where: { path.lowercased().hasSuffix($0) || absolute.lowercased().contains($0) }) {
            return .directVideo(url: url)
        }

        if host.contains("vimeo.com"), let id = vimeoID(from: url) {
            if let embed = URL(string: "https://player.vimeo.com/video/\(id)") {
                return .directVideo(url: embed)
            }
        }

        return .unsupported
    }

    static func youtubeID(from url: URL) -> String? {
        let host = (url.host ?? "").lowercased()
        if host.contains("youtu.be") {
            let id = url.path.split(separator: "/").first.map(String.init)
            return sanitizedYouTubeID(id)
        }

        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            if let v = components.queryItems?.first(where: { $0.name == "v" })?.value {
                return sanitizedYouTubeID(v)
            }
            let parts = url.path.split(separator: "/")
            if let embedIndex = parts.firstIndex(of: "embed"), parts.count > embedIndex + 1 {
                return sanitizedYouTubeID(String(parts[embedIndex + 1]))
            }
            if let shortsIndex = parts.firstIndex(of: "shorts"), parts.count > shortsIndex + 1 {
                return sanitizedYouTubeID(String(parts[shortsIndex + 1]))
            }
        }
        return nil
    }

    private static func vimeoID(from url: URL) -> String? {
        url.path.split(separator: "/").last.map(String.init)?.filter(\.isNumber)
    }

    private static func sanitizedYouTubeID(_ raw: String?) -> String? {
        guard let raw else { return nil }
        let cleaned = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard cleaned.count >= 8, cleaned.count <= 20 else { return nil }
        return cleaned
    }
}

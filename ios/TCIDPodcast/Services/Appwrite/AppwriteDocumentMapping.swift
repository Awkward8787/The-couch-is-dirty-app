import AppwriteModels
import Foundation
import JSONCodable

enum AppwriteDocumentMapping {
    static func string(from data: [String: AnyCodable], key: String) -> String? {
        guard let value = data[key]?.value else { return nil }
        if let string = value as? String { return string.isEmpty ? nil : string }
        if let int = value as? Int { return String(int) }
        if let double = value as? Double { return String(double) }
        return nil
    }

    static func int(from data: [String: AnyCodable], key: String) -> Int? {
        guard let value = data[key]?.value else { return nil }
        if let int = value as? Int { return int }
        if let double = value as? Double { return Int(double) }
        if let string = value as? String { return Int(string) }
        return nil
    }

    static func bool(from data: [String: AnyCodable], key: String, default defaultValue: Bool = false) -> Bool {
        guard let value = data[key]?.value else { return defaultValue }
        if let bool = value as? Bool { return bool }
        if let int = value as? Int { return int != 0 }
        if let string = value as? String {
            return ["true", "1", "yes"].contains(string.lowercased())
        }
        return defaultValue
    }

    static func date(from data: [String: AnyCodable], key: String) -> Date? {
        guard let raw = string(from: data, key: key) else { return nil }
        return AppwriteDateParser.parse(raw)
    }

    static func url(from data: [String: AnyCodable], key: String, bucketId: String? = nil) -> URL? {
        guard let raw = string(from: data, key: key) else { return nil }
        if raw.hasPrefix("http://") || raw.hasPrefix("https://") {
            return URL(string: raw)
        }
        if let bucketId {
            return AppwriteStorageURL.viewURL(bucketId: bucketId, fileId: raw)
        }
        return URL(string: raw)
    }

    static func documentUUID(_ documentId: String) -> UUID {
        if let uuid = UUID(uuidString: documentId) {
            return uuid
        }
        return StableIdentifier.uuid(from: documentId)
    }

    static func episode(from document: Document<[String: AnyCodable]>) -> Episode? {
        let data = document.data
        guard let title = string(from: data, key: "title"), !title.isEmpty else { return nil }

        let sourceRaw = string(from: data, key: "source") ?? EpisodeSource.rss.rawValue
        let statusRaw = string(from: data, key: "status") ?? EpisodeStatus.published.rawValue

        return Episode(
            id: documentUUID(document.id),
            documentId: document.id,
            rssGuid: string(from: data, key: "rss_guid"),
            source: EpisodeSource(rawValue: sourceRaw) ?? .rss,
            status: EpisodeStatus(rawValue: statusRaw) ?? .draft,
            title: title,
            slug: string(from: data, key: "slug"),
            description: string(from: data, key: "description"),
            showNotes: string(from: data, key: "show_notes"),
            audioURL: url(from: data, key: "audio_url"),
            coverArtURL: url(from: data, key: "cover_art_url", bucketId: AppwriteCollections.Bucket.episodeImages),
            durationSeconds: int(from: data, key: "duration_seconds"),
            seasonNumber: int(from: data, key: "season_number"),
            episodeNumber: int(from: data, key: "episode_number"),
            isExplicit: bool(from: data, key: "is_explicit"),
            publishedAt: date(from: data, key: "published_at"),
            playCount: int(from: data, key: "play_count") ?? 0,
            chapters: []
        )
    }

    static func profile(from document: Document<[String: AnyCodable]>, userId: String) -> UserProfile {
        let data = document.data
        let roleRaw = string(from: data, key: "role") ?? UserRole.user.rawValue
        let statusRaw = string(from: data, key: "account_status") ?? AccountStatus.active.rawValue

        return UserProfile(
            id: documentUUID(userId),
            documentId: userId,
            username: string(from: data, key: "username"),
            displayName: string(from: data, key: "display_name"),
            bio: string(from: data, key: "bio"),
            avatarURL: url(from: data, key: "avatar_url", bucketId: AppwriteCollections.Bucket.avatars),
            role: UserRole(rawValue: roleRaw) ?? .user,
            accountStatus: AccountStatus(rawValue: statusRaw) ?? .active
        )
    }
}

enum AppwriteStorageURL {
    static func viewURL(bucketId: String, fileId: String) -> URL? {
        var components = URLComponents(
            string: "\(AppConfig.appwriteEndpoint)/storage/buckets/\(bucketId)/files/\(fileId)/view"
        )
        components?.queryItems = [URLQueryItem(name: "project", value: AppConfig.appwriteProjectId)]
        return components?.url
    }
}

enum AppwriteDateParser {
    private static let formatters: [ISO8601DateFormatter] = {
        let withFraction = ISO8601DateFormatter()
        withFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let standard = ISO8601DateFormatter()
        standard.formatOptions = [.withInternetDateTime]

        return [withFraction, standard]
    }()

    static func parse(_ value: String) -> Date? {
        for formatter in formatters {
            if let date = formatter.date(from: value) {
                return date
            }
        }
        return nil
    }
}

enum StableIdentifier {
    static func uuid(from string: String) -> UUID {
        var bytes = [UInt8](repeating: 0, count: 16)
        let hash = string.utf8.reduce(into: UInt64(0xcbf29ce484222325)) { partial, byte in
            partial = (partial ^ UInt64(byte)) &* 0x100000001b3
        }
        bytes.withUnsafeMutableBytes { buffer in
            buffer.storeBytes(of: hash, toByteOffset: 0, as: UInt64.self)
            buffer.storeBytes(of: hash.byteSwapped, toByteOffset: 8, as: UInt64.self)
        }
        bytes[6] = (bytes[6] & 0x0F) | 0x40
        bytes[8] = (bytes[8] & 0x3F) | 0x80
        return UUID(uuid: (
            bytes[0], bytes[1], bytes[2], bytes[3],
            bytes[4], bytes[5], bytes[6], bytes[7],
            bytes[8], bytes[9], bytes[10], bytes[11],
            bytes[12], bytes[13], bytes[14], bytes[15]
        ))
    }
}

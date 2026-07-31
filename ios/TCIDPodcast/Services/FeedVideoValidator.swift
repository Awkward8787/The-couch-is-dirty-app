import AVFoundation
import Foundation
import UniformTypeIdentifiers

/// TikTok-style short video limits for the Home feed.
enum FeedVideoValidator {
    static let maxDurationSeconds: TimeInterval = 60
    static let maxFileBytes = 30_000_000
    static let allowedExtensions: Set<String> = ["mp4", "mov", "m4v"]

    struct ValidatedVideo: Sendable {
        let data: Data
        let mimeType: String
        let durationSeconds: Int
        let filename: String
    }

    static func validate(fileURL: URL) async throws -> ValidatedVideo {
        let ext = fileURL.pathExtension.lowercased()
        guard allowedExtensions.contains(ext) else {
            throw FeedServiceError.invalidVideoFormat
        }

        let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
        let byteCount = attributes[.size] as? Int ?? 0
        guard byteCount > 0 else {
            throw FeedServiceError.invalidVideo
        }
        guard byteCount <= maxFileBytes else {
            throw FeedServiceError.videoTooLarge
        }

        let asset = AVURLAsset(url: fileURL)
        let duration = try await asset.load(.duration)
        let seconds = CMTimeGetSeconds(duration)
        guard seconds.isFinite, seconds > 0 else {
            throw FeedServiceError.invalidVideo
        }
        guard seconds <= maxDurationSeconds else {
            throw FeedServiceError.videoTooLong
        }

        let data = try Data(contentsOf: fileURL)
        guard data.count <= maxFileBytes else {
            throw FeedServiceError.videoTooLarge
        }

        let mimeType = mimeType(for: ext)
        let filename = "post-\(Int(Date().timeIntervalSince1970)).\(ext)"

        return ValidatedVideo(
            data: data,
            mimeType: mimeType,
            durationSeconds: max(1, Int(seconds.rounded())),
            filename: filename
        )
    }

    private static func mimeType(for ext: String) -> String {
        switch ext {
        case "mp4", "m4v":
            "video/mp4"
        default:
            "video/quicktime"
        }
    }
}

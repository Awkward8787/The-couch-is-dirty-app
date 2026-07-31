import CoreGraphics
import UIKit

/// TikTok-style vertical feed media — 9:16 at iPhone-native resolution.
enum FeedMediaFormat {
    /// Width : height (portrait).
    static let aspectRatio: CGFloat = 9 / 16

    /// Longest edge cap — 1920px matches full-quality vertical iPhone capture.
    static let maxLongEdge: CGFloat = 1920

    static let maxImageBytes = 5_000_000
    static let maxVideoBytes = 30_000_000
    static let maxVideoDurationSeconds: TimeInterval = 60

    static let allowedVideoExtensions: Set<String> = ["mp4", "mov", "m4v"]

    /// Resize and compress a photo for feed upload while preserving aspect ratio.
    static func prepareImageForUpload(_ image: UIImage) -> Data? {
        let oriented = image.normalizedOrientation()
        let resized = resize(oriented, maxLongEdge: maxLongEdge)

        var quality: CGFloat = 0.82
        var data = resized.jpegData(compressionQuality: quality)
        while let current = data, current.count > maxImageBytes, quality > 0.4 {
            quality -= 0.08
            data = resized.jpegData(compressionQuality: quality)
        }
        guard let data, data.count <= maxImageBytes else { return nil }
        return data
    }

    private static func resize(_ image: UIImage, maxLongEdge: CGFloat) -> UIImage {
        let size = image.size
        guard size.width > 0, size.height > 0 else { return image }

        let longEdge = max(size.width, size.height)
        guard longEdge > maxLongEdge else { return image }

        let scale = maxLongEdge / longEdge
        let target = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: target)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: target))
        }
    }
}

private extension UIImage {
    func normalizedOrientation() -> UIImage {
        guard imageOrientation != .up else { return self }
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

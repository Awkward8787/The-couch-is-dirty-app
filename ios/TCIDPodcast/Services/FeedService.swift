import Appwrite
import AppwriteModels
import Foundation
import JSONCodable
import UIKit

enum FeedService {
    /// Soft caps to protect limited Appwrite storage.
    static let maxImageBytes = 1_200_000
    static let maxImageDimension: CGFloat = 1280
    static let maxBodyLength = 1200

    static func fetchPosts(limit: Int = 40) async throws -> [FeedPost] {
        let response = try await AppwriteClient.databases.listDocuments(
            databaseId: AppConfig.appwriteDatabaseId,
            collectionId: AppwriteCollections.Collection.posts,
            queries: [
                Query.orderDesc("$createdAt"),
                Query.limit(limit),
            ]
        )
        return response.documents.compactMap(mapPost(from:))
    }

    static func createPost(
        authorId: String,
        authorName: String,
        body: String,
        linkURL: URL?,
        imageJPEGData: Data?
    ) async throws -> FeedPost {
        let trimmed = body.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty || linkURL != nil || imageJPEGData != nil else {
            throw FeedServiceError.emptyPost
        }
        guard trimmed.count <= maxBodyLength else {
            throw FeedServiceError.bodyTooLong
        }

        var imageFileId: String?
        if let imageJPEGData {
            guard imageJPEGData.count <= maxImageBytes else {
                throw FeedServiceError.imageTooLarge
            }
            let file = InputFile.fromData(
                imageJPEGData,
                filename: "post-\(Int(Date().timeIntervalSince1970)).jpg",
                mimeType: "image/jpeg"
            )
            let uploaded = try await AppwriteClient.storage.createFile(
                bucketId: AppwriteCollections.Bucket.postImages,
                fileId: ID.unique(),
                file: file,
                permissions: [
                    Permission.read(Role.any()),
                    Permission.update(Role.user(authorId)),
                    Permission.delete(Role.user(authorId)),
                ]
            )
            imageFileId = uploaded.id
        }

        let kind: FeedPostKind
        if imageFileId != nil {
            kind = .image
        } else if linkURL != nil {
            kind = .link
        } else {
            kind = .text
        }

        var data: [String: Any] = [
            "author_id": authorId,
            "author_name": authorName,
            "body": trimmed,
            "post_kind": kind.rawValue,
            "like_count": 0,
        ]
        if let linkURL {
            data["link_url"] = linkURL.absoluteString
        }
        if let imageFileId {
            data["image_file_id"] = imageFileId
        }

        let document = try await AppwriteClient.databases.createDocument(
            databaseId: AppConfig.appwriteDatabaseId,
            collectionId: AppwriteCollections.Collection.posts,
            documentId: ID.unique(),
            data: data,
            permissions: [
                Permission.read(Role.any()),
                Permission.update(Role.user(authorId)),
                Permission.delete(Role.user(authorId)),
            ]
        )

        guard let post = mapPost(from: document) else {
            throw FeedServiceError.mappingFailed
        }
        return post
    }

    static func compressImageForUpload(_ image: UIImage) -> Data? {
        let longest = max(image.size.width, image.size.height)
        let scale = longest > maxImageDimension ? maxImageDimension / longest : 1
        let targetSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let resized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }

        var quality: CGFloat = 0.72
        var data = resized.jpegData(compressionQuality: quality)
        while let current = data, current.count > maxImageBytes, quality > 0.35 {
            quality -= 0.1
            data = resized.jpegData(compressionQuality: quality)
        }
        guard let data, data.count <= maxImageBytes else { return nil }
        return data
    }

    private static func mapPost(from document: Document<[String: AnyCodable]>) -> FeedPost? {
        let data = document.data
        let body = AppwriteDocumentMapping.string(from: data, key: "body") ?? ""
        let authorId = AppwriteDocumentMapping.string(from: data, key: "author_id") ?? "unknown"
        let authorName = AppwriteDocumentMapping.string(from: data, key: "author_name") ?? "Couch Fam"
        let kindRaw = AppwriteDocumentMapping.string(from: data, key: "post_kind") ?? FeedPostKind.text.rawValue
        let imageFileId = AppwriteDocumentMapping.string(from: data, key: "image_file_id")
        let link = AppwriteDocumentMapping.url(from: data, key: "link_url")
        let createdAt = AppwriteDateParser.parse(document.createdAt) ?? Date()

        return FeedPost(
            id: document.id,
            authorId: authorId,
            authorName: authorName,
            body: body,
            linkURL: link,
            imageFileId: imageFileId,
            imageURL: imageFileId.flatMap {
                AppwriteStorageURL.viewURL(
                    bucketId: AppwriteCollections.Bucket.postImages,
                    fileId: $0
                )
            },
            kind: FeedPostKind(rawValue: kindRaw) ?? .text,
            createdAt: createdAt,
            likeCount: AppwriteDocumentMapping.int(from: data, key: "like_count") ?? 0
        )
    }
}

enum FeedServiceError: LocalizedError {
    case emptyPost
    case bodyTooLong
    case imageTooLarge
    case mappingFailed
    case signInRequired

    var errorDescription: String? {
        switch self {
        case .emptyPost:
            "Write something, add a link, or attach a photo."
        case .bodyTooLong:
            "Keep it under \(FeedService.maxBodyLength) characters."
        case .imageTooLarge:
            "That photo is too large. Try a smaller image."
        case .mappingFailed:
            "Could not read the post after creating it."
        case .signInRequired:
            "Sign in to post on the couch."
        }
    }
}

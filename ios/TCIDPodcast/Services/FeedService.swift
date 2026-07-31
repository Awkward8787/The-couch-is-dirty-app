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
    static let pageSize = 20

    static func fetchPosts(limit: Int = pageSize, cursorAfter: String? = nil) async throws -> [FeedPost] {
        var queries: [String] = [
            Query.orderDesc("$createdAt"),
            Query.limit(limit),
        ]
        if let cursorAfter {
            queries.append(Query.cursorAfter(cursorAfter))
        }

        let response = try await AppwriteClient.databases.listDocuments(
            databaseId: AppConfig.appwriteDatabaseId,
            collectionId: AppwriteCollections.Collection.posts,
            queries: queries
        )
        return response.documents.compactMap(mapPost(from:)).filter(\.isVisibleInFeed)
    }

    static func createPost(
        authorId: String,
        authorName: String,
        authorRole: CommunityRole,
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
        guard authorRole.canPost else {
            throw FeedServiceError.signInRequired
        }
        if let linkURL, !isSafeURL(linkURL) {
            throw FeedServiceError.unsafeLink
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
            "author_role": authorRole.rawValue,
            "body": trimmed,
            "post_kind": kind.rawValue,
            "like_count": 0,
        ]
        // Optional schema fields (added by scripts/setup_appwrite_feed.py). Safe to omit if missing.
        data["comment_count"] = 0
        data["is_edited"] = false
        data["moderation_status"] = FeedModerationStatus.visible.rawValue
        if let linkURL {
            data["link_url"] = linkURL.absoluteString
        }
        if let imageFileId {
            data["image_file_id"] = imageFileId
        }

        do {
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
        } catch {
            // Retry without optional attrs if the schema hasn’t been upgraded yet.
            data.removeValue(forKey: "comment_count")
            data.removeValue(forKey: "is_edited")
            data.removeValue(forKey: "moderation_status")
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
    }

    static func updatePost(
        postId: String,
        authorId: String,
        body: String,
        linkURL: URL?
    ) async throws -> FeedPost {
        let trimmed = body.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty || linkURL != nil else {
            throw FeedServiceError.emptyPost
        }
        if let linkURL, !isSafeURL(linkURL) {
            throw FeedServiceError.unsafeLink
        }

        var data: [String: Any] = [
            "body": trimmed,
            "is_edited": true,
        ]
        if let linkURL {
            data["link_url"] = linkURL.absoluteString
        } else {
            data["link_url"] = ""
        }

        do {
            let document = try await AppwriteClient.databases.updateDocument(
                databaseId: AppConfig.appwriteDatabaseId,
                collectionId: AppwriteCollections.Collection.posts,
                documentId: postId,
                data: data
            )
            guard let post = mapPost(from: document) else {
                throw FeedServiceError.mappingFailed
            }
            return post
        } catch {
            data.removeValue(forKey: "is_edited")
            let document = try await AppwriteClient.databases.updateDocument(
                databaseId: AppConfig.appwriteDatabaseId,
                collectionId: AppwriteCollections.Collection.posts,
                documentId: postId,
                data: data
            )
            guard var post = mapPost(from: document) else {
                throw FeedServiceError.mappingFailed
            }
            post.isEdited = true
            return post
        }
    }

    static func deletePost(postId: String) async throws {
        try await AppwriteClient.databases.deleteDocument(
            databaseId: AppConfig.appwriteDatabaseId,
            collectionId: AppwriteCollections.Collection.posts,
            documentId: postId
        )
    }

    static func setLikeCount(postId: String, likeCount: Int) async throws -> FeedPost {
        let document = try await AppwriteClient.databases.updateDocument(
            databaseId: AppConfig.appwriteDatabaseId,
            collectionId: AppwriteCollections.Collection.posts,
            documentId: postId,
            data: ["like_count": max(0, likeCount)]
        )
        guard let post = mapPost(from: document) else {
            throw FeedServiceError.mappingFailed
        }
        return post
    }

    static func fetchComments(postId: String, limit: Int = 40) async throws -> [FeedComment] {
        let response = try await AppwriteClient.databases.listDocuments(
            databaseId: AppConfig.appwriteDatabaseId,
            collectionId: AppwriteCollections.Collection.postComments,
            queries: [
                Query.equal("post_id", value: postId),
                Query.orderDesc("$createdAt"),
                Query.limit(limit),
            ]
        )
        return response.documents.compactMap(mapComment(from:))
    }

    static func createComment(
        postId: String,
        authorId: String,
        authorName: String,
        body: String
    ) async throws -> FeedComment {
        let trimmed = body.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw FeedServiceError.emptyPost }

        let document = try await AppwriteClient.databases.createDocument(
            databaseId: AppConfig.appwriteDatabaseId,
            collectionId: AppwriteCollections.Collection.postComments,
            documentId: ID.unique(),
            data: [
                "post_id": postId,
                "author_id": authorId,
                "author_name": authorName,
                "body": trimmed,
            ],
            permissions: [
                Permission.read(Role.any()),
                Permission.update(Role.user(authorId)),
                Permission.delete(Role.user(authorId)),
            ]
        )

        guard let comment = mapComment(from: document) else {
            throw FeedServiceError.mappingFailed
        }

        if let existing = try? await AppwriteClient.databases.getDocument(
            databaseId: AppConfig.appwriteDatabaseId,
            collectionId: AppwriteCollections.Collection.posts,
            documentId: postId
        ), let mapped = mapPost(from: existing) {
            _ = try? await AppwriteClient.databases.updateDocument(
                databaseId: AppConfig.appwriteDatabaseId,
                collectionId: AppwriteCollections.Collection.posts,
                documentId: postId,
                data: ["comment_count": mapped.commentCount + 1]
            )
        }

        return comment
    }

    static func deleteComment(commentId: String) async throws {
        try await AppwriteClient.databases.deleteDocument(
            databaseId: AppConfig.appwriteDatabaseId,
            collectionId: AppwriteCollections.Collection.postComments,
            documentId: commentId
        )
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

    static func isSafeURL(_ url: URL) -> Bool {
        let scheme = (url.scheme ?? "").lowercased()
        return scheme == "http" || scheme == "https"
    }

    static func mapPost(from document: Document<[String: AnyCodable]>) -> FeedPost? {
        let data = document.data
        let body = AppwriteDocumentMapping.string(from: data, key: "body") ?? ""
        let authorId = AppwriteDocumentMapping.string(from: data, key: "author_id") ?? "unknown"
        let authorName = AppwriteDocumentMapping.string(from: data, key: "author_name") ?? "Couch Fam"
        let kindRaw = AppwriteDocumentMapping.string(from: data, key: "post_kind") ?? FeedPostKind.text.rawValue
        let roleRaw = AppwriteDocumentMapping.string(from: data, key: "author_role") ?? CommunityRole.user.rawValue
        let statusRaw = AppwriteDocumentMapping.string(from: data, key: "moderation_status")
            ?? FeedModerationStatus.visible.rawValue
        let imageFileId = AppwriteDocumentMapping.string(from: data, key: "image_file_id")
        let link = AppwriteDocumentMapping.url(from: data, key: "link_url")
        let createdAt = AppwriteDateParser.parse(document.createdAt) ?? Date()
        let updatedAt = AppwriteDateParser.parse(document.updatedAt)

        return FeedPost(
            id: document.id,
            authorId: authorId,
            authorName: authorName,
            authorRole: CommunityRole(rawValue: roleRaw) ?? .user,
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
            updatedAt: updatedAt,
            likeCount: AppwriteDocumentMapping.int(from: data, key: "like_count") ?? 0,
            commentCount: AppwriteDocumentMapping.int(from: data, key: "comment_count") ?? 0,
            isEdited: AppwriteDocumentMapping.bool(from: data, key: "is_edited"),
            moderationStatus: FeedModerationStatus(rawValue: statusRaw) ?? .visible
        )
    }

    private static func mapComment(from document: Document<[String: AnyCodable]>) -> FeedComment? {
        let data = document.data
        guard let postId = AppwriteDocumentMapping.string(from: data, key: "post_id") else { return nil }
        let body = AppwriteDocumentMapping.string(from: data, key: "body") ?? ""
        return FeedComment(
            id: document.id,
            postId: postId,
            authorId: AppwriteDocumentMapping.string(from: data, key: "author_id") ?? "unknown",
            authorName: AppwriteDocumentMapping.string(from: data, key: "author_name") ?? "Couch Fam",
            body: body,
            createdAt: AppwriteDateParser.parse(document.createdAt) ?? Date()
        )
    }
}

enum FeedServiceError: LocalizedError {
    case emptyPost
    case bodyTooLong
    case imageTooLarge
    case mappingFailed
    case signInRequired
    case unsafeLink
    case notAuthorized

    var errorDescription: String? {
        switch self {
        case .emptyPost:
            "Write something, add a link, or attach a photo."
        case .bodyTooLong:
            "Keep it under \(FeedService.maxBodyLength) characters."
        case .imageTooLarge:
            "That photo is too large. Try a smaller image."
        case .mappingFailed:
            "Could not read the post after saving it."
        case .signInRequired:
            "Sign in to post on the couch."
        case .unsafeLink:
            "Only http/https links are allowed."
        case .notAuthorized:
            "You don’t have permission to do that."
        }
    }
}

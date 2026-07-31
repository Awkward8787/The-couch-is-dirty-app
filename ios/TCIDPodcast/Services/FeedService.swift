import Appwrite
import AppwriteModels
import Foundation
import JSONCodable
import UIKit

enum FeedService {
    static let maxBodyLength = 1200
    static let pageSize = 20

    static func fetchPosts(limit: Int = 20, cursorAfter: String? = nil) async throws -> [FeedPost] {
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
        authorAvatarFileId: String?,
        body: String,
        linkURL: URL?,
        imageJPEGData: Data?,
        videoUpload: FeedVideoValidator.ValidatedVideo? = nil
    ) async throws -> FeedPost {
        let trimmed = body.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty || linkURL != nil || imageJPEGData != nil || videoUpload != nil else {
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
        if videoUpload != nil, imageJPEGData != nil {
            throw FeedServiceError.singleMediaOnly
        }

        var videoFileId: String?
        if let videoUpload {
            let file = InputFile.fromData(
                videoUpload.data,
                filename: videoUpload.filename,
                mimeType: videoUpload.mimeType
            )
            let uploaded = try await AppwriteClient.storage.createFile(
                bucketId: AppwriteCollections.Bucket.postVideos,
                fileId: ID.unique(),
                file: file,
                permissions: [
                    Permission.read(Role.any()),
                    Permission.update(Role.user(authorId)),
                    Permission.delete(Role.user(authorId)),
                ]
            )
            videoFileId = uploaded.id
        }

        var imageFileId: String?
        if let imageJPEGData, videoFileId == nil {
            guard imageJPEGData.count <= FeedMediaFormat.maxImageBytes else {
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
        if videoFileId != nil {
            kind = .video
        } else if imageFileId != nil {
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
        if let videoFileId {
            data[AppwriteCollections.Posts.videoFileId] = videoFileId
        }
        if let videoUpload {
            data[AppwriteCollections.Posts.videoDurationSeconds] = videoUpload.durationSeconds
        }
        if let authorAvatarFileId, !authorAvatarFileId.isEmpty {
            data[AppwriteCollections.Posts.authorAvatarUrl] = authorAvatarFileId
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
            data.removeValue(forKey: AppwriteCollections.Posts.videoFileId)
            data.removeValue(forKey: AppwriteCollections.Posts.videoDurationSeconds)
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

    static func reportPost(postId: String) async throws -> FeedPost {
        let document = try await AppwriteClient.databases.updateDocument(
            databaseId: AppConfig.appwriteDatabaseId,
            collectionId: AppwriteCollections.Collection.posts,
            documentId: postId,
            data: [
                AppwriteCollections.Posts.moderationStatus: FeedModerationStatus.reported.rawValue,
            ]
        )
        guard let post = mapPost(from: document) else {
            throw FeedServiceError.mappingFailed
        }
        return post
    }

    static func reportComment(commentId: String) async throws {
        _ = try await AppwriteClient.databases.updateDocument(
            databaseId: AppConfig.appwriteDatabaseId,
            collectionId: AppwriteCollections.Collection.postComments,
            documentId: commentId,
            data: ["is_reported": true]
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
        FeedMediaFormat.prepareImageForUpload(image)
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
        let videoFileId = AppwriteDocumentMapping.string(
            from: data,
            key: AppwriteCollections.Posts.videoFileId
        )
        let authorAvatarFileId = AppwriteDocumentMapping.string(
            from: data,
            key: AppwriteCollections.Posts.authorAvatarUrl
        )
        let link = AppwriteDocumentMapping.url(from: data, key: "link_url")
        let createdAt = AppwriteDateParser.parse(document.createdAt) ?? Date()
        let updatedAt = AppwriteDateParser.parse(document.updatedAt)

        return FeedPost(
            id: document.id,
            authorId: authorId,
            authorName: authorName,
            authorRole: CommunityRole(rawValue: roleRaw) ?? .user,
            authorAvatarURL: authorAvatarFileId.flatMap {
                AppwriteStorageURL.viewURL(
                    bucketId: AppwriteCollections.Bucket.avatars,
                    fileId: $0
                )
            },
            body: body,
            linkURL: link,
            imageFileId: imageFileId,
            imageURL: imageFileId.flatMap {
                AppwriteStorageURL.viewURL(
                    bucketId: AppwriteCollections.Bucket.postImages,
                    fileId: $0
                )
            },
            videoFileId: videoFileId,
            videoURL: videoFileId.flatMap {
                AppwriteStorageURL.viewURL(
                    bucketId: AppwriteCollections.Bucket.postVideos,
                    fileId: $0
                )
            },
            videoDurationSeconds: AppwriteDocumentMapping.int(
                from: data,
                key: AppwriteCollections.Posts.videoDurationSeconds
            ),
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
    case videoTooLong
    case videoTooLarge
    case invalidVideo
    case invalidVideoFormat
    case singleMediaOnly
    case mappingFailed
    case signInRequired
    case unsafeLink
    case notAuthorized

    var errorDescription: String? {
        switch self {
        case .emptyPost:
            "Write something, add a link, or attach a photo or short video."
        case .bodyTooLong:
            "Keep it under \(FeedService.maxBodyLength) characters."
        case .imageTooLarge:
            "That photo is too large. Try a smaller image."
        case .videoTooLong:
            "Videos must be \(Int(FeedVideoValidator.maxDurationSeconds)) seconds or less."
        case .videoTooLarge:
            "That video is too large. Trim or export a smaller clip (max 30 MB)."
        case .invalidVideo:
            "Couldn’t read that video. Try another clip."
        case .invalidVideoFormat:
            "Use MP4 or MOV for feed videos."
        case .singleMediaOnly:
            "Choose a photo or a video — not both."
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

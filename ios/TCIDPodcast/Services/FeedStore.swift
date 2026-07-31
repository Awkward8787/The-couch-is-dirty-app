import Appwrite
import AppwriteModels
import Foundation
import JSONCodable
import Observation

@Observable
@MainActor
final class FeedStore {
    private(set) var posts: [FeedPost] = []
    private(set) var isLoading = false
    private(set) var isLoadingMore = false
    private(set) var isPosting = false
    private(set) var loadError: String?
    private(set) var postError: String?
    private(set) var hasMore = true
    private(set) var isRealtimeConnected = false

    /// Local optimistic like toggles: postId → user has liked in this session.
    private(set) var likedPostIds: Set<String> = []

    private var realtimeSubscription: RealtimeSubscription?
    private var isSubscribing = false

    func load(reset: Bool = true) async {
        if reset {
            isLoading = true
            hasMore = true
        } else {
            isLoadingMore = true
        }
        loadError = nil
        defer {
            isLoading = false
            isLoadingMore = false
        }

        do {
            let cursor = reset ? nil : posts.last?.id
            let page = try await FeedService.fetchPosts(
                limit: FeedService.pageSize,
                cursorAfter: cursor
            )
            if reset {
                posts = dedupe(page)
            } else {
                posts = dedupe(posts + page)
            }
            hasMore = page.count >= FeedService.pageSize
        } catch {
            if reset && posts.isEmpty {
                loadError = friendlyMessage(for: error)
            }
        }
    }

    func loadMoreIfNeeded(currentItem: FeedPost) async {
        guard hasMore, !isLoading, !isLoadingMore else { return }
        guard posts.last?.id == currentItem.id else { return }
        await load(reset: false)
    }

    func startRealtime() {
        guard !isSubscribing, realtimeSubscription == nil else { return }
        isSubscribing = true

        let databaseId = AppConfig.appwriteDatabaseId
        let collectionId = AppwriteCollections.Collection.posts
        // Legacy Databases channel + TablesDB channel for self-hosted / cloud variance.
        let channels: [String] = [
            "databases.\(databaseId).collections.\(collectionId).documents",
            "databases.\(databaseId).tables.\(collectionId).rows",
        ]

        Task {
            defer { isSubscribing = false }
            do {
                let subscription = try await AppwriteClient.realtime.subscribe(channels: channels) { [weak self] message in
                    guard let events = message.events, let payload = message.payload else { return }
                    Task { @MainActor in
                        self?.handleRealtime(events: events, payload: payload)
                    }
                }
                self.realtimeSubscription = subscription
                self.isRealtimeConnected = true
            } catch {
                // Fall back to pull-to-refresh; don't block the feed.
                self.isRealtimeConnected = false
            }
        }
    }

    func stopRealtime() {
        let subscription = realtimeSubscription
        realtimeSubscription = nil
        isRealtimeConnected = false
        isSubscribing = false
        Task {
            try? await subscription?.close()
        }
    }

    func createPost(
        authorId: String,
        authorName: String,
        authorRole: CommunityRole,
        authorAvatarFileId: String?,
        body: String,
        linkText: String,
        imageJPEGData: Data?,
        videoUpload: FeedVideoValidator.ValidatedVideo? = nil
    ) async throws {
        guard !isPosting else { return }
        isPosting = true
        postError = nil
        defer { isPosting = false }

        let linkURL = normalizedLink(from: linkText)
        do {
            let created = try await FeedService.createPost(
                authorId: authorId,
                authorName: authorName,
                authorRole: authorRole,
                authorAvatarFileId: authorAvatarFileId,
                body: body,
                linkURL: linkURL,
                imageJPEGData: imageJPEGData,
                videoUpload: videoUpload
            )
            upsert(created, preferFront: true)
        } catch {
            postError = friendlyMessage(for: error)
            throw error
        }
    }

    func editPost(post: FeedPost, body: String, linkText: String, currentUserId: String) async throws {
        guard post.authorId == currentUserId else {
            throw FeedServiceError.notAuthorized
        }
        let linkURL = normalizedLink(from: linkText)
        let updated = try await FeedService.updatePost(
            postId: post.id,
            authorId: currentUserId,
            body: body,
            linkURL: linkURL
        )
        upsert(updated, preferFront: false)
    }

    func deletePost(_ post: FeedPost, currentUserId: String, role: CommunityRole) async throws {
        guard post.authorId == currentUserId || role.canModerate else {
            throw FeedServiceError.notAuthorized
        }
        try await FeedService.deletePost(postId: post.id)
        posts.removeAll { $0.id == post.id }
    }

    func reportPost(_ post: FeedPost) async throws {
        let updated = try await FeedService.reportPost(postId: post.id)
        upsert(updated, preferFront: false)
    }

    func visiblePosts(blockedAuthorIds: Set<String>) -> [FeedPost] {
        posts.filter { !blockedAuthorIds.contains($0.authorId) }
    }

    func toggleLike(post: FeedPost, isAuthenticated: Bool) async throws {
        guard isAuthenticated else { throw FeedServiceError.signInRequired }
        let currentlyLiked = likedPostIds.contains(post.id)
        let nextCount = currentlyLiked ? max(0, post.likeCount - 1) : post.likeCount + 1
        if currentlyLiked {
            likedPostIds.remove(post.id)
        } else {
            likedPostIds.insert(post.id)
        }
        // Optimistic UI
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            posts[index].likeCount = nextCount
        }
        do {
            let updated = try await FeedService.setLikeCount(postId: post.id, likeCount: nextCount)
            upsert(updated, preferFront: false)
        } catch {
            // Revert optimistic toggle
            if currentlyLiked {
                likedPostIds.insert(post.id)
            } else {
                likedPostIds.remove(post.id)
            }
            if let index = posts.firstIndex(where: { $0.id == post.id }) {
                posts[index].likeCount = post.likeCount
            }
            throw error
        }
    }

    private func handleRealtime(events: [String], payload: [String: Any]) {
        let isDelete = events.contains { $0.contains(".delete") }

        if isDelete {
            if let id = payload["$id"] as? String {
                posts.removeAll { $0.id == id }
            }
            return
        }

        if let post = mapRealtimePayload(payload) {
            guard post.isVisibleInFeed else {
                posts.removeAll { $0.id == post.id }
                return
            }
            let isCreate = events.contains { $0.contains(".create") }
            upsert(post, preferFront: isCreate)
        }
    }

    private func mapRealtimePayload(_ payload: [String: Any]) -> FeedPost? {
        // Realtime payloads aren't typed Documents; map common keys directly.
        guard let id = payload["$id"] as? String else { return nil }
        let createdRaw = payload["$createdAt"] as? String
        let updatedRaw = payload["$updatedAt"] as? String
        let authorId = payload["author_id"] as? String ?? "unknown"
        let authorName = payload["author_name"] as? String ?? "Couch Fam"
        let roleRaw = payload["author_role"] as? String ?? CommunityRole.user.rawValue
        let body = payload["body"] as? String ?? ""
        let kindRaw = payload["post_kind"] as? String ?? FeedPostKind.text.rawValue
        let statusRaw = payload["moderation_status"] as? String ?? FeedModerationStatus.visible.rawValue
        let imageFileId = payload["image_file_id"] as? String
        let videoFileId = payload[AppwriteCollections.Posts.videoFileId] as? String
        let authorAvatarFileId = payload[AppwriteCollections.Posts.authorAvatarUrl] as? String
        let linkRaw = payload["link_url"] as? String
        let link = linkRaw.flatMap { URL(string: $0) }

        return FeedPost(
            id: id,
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
            videoDurationSeconds: (payload[AppwriteCollections.Posts.videoDurationSeconds] as? Int)
                ?? (payload[AppwriteCollections.Posts.videoDurationSeconds] as? Double).map(Int.init),
            kind: FeedPostKind(rawValue: kindRaw) ?? .text,
            createdAt: AppwriteDateParser.parse(createdRaw ?? "") ?? Date(),
            updatedAt: updatedRaw.flatMap { AppwriteDateParser.parse($0) },
            likeCount: (payload["like_count"] as? Int)
                ?? (payload["like_count"] as? Double).map(Int.init)
                ?? 0,
            commentCount: (payload["comment_count"] as? Int)
                ?? (payload["comment_count"] as? Double).map(Int.init)
                ?? 0,
            isEdited: (payload["is_edited"] as? Bool) ?? false,
            moderationStatus: FeedModerationStatus(rawValue: statusRaw) ?? .visible
        )
    }

    private func upsert(_ post: FeedPost, preferFront: Bool) {
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            posts[index] = post
            if preferFront && index != 0 {
                posts.remove(at: index)
                posts.insert(post, at: 0)
            }
        } else if preferFront {
            posts.insert(post, at: 0)
        } else {
            posts.append(post)
            posts.sort { $0.createdAt > $1.createdAt }
        }
        posts = dedupe(posts)
    }

    private func dedupe(_ input: [FeedPost]) -> [FeedPost] {
        var seen = Set<String>()
        var result: [FeedPost] = []
        for post in input {
            if seen.insert(post.id).inserted {
                result.append(post)
            }
        }
        return result.sorted { $0.createdAt > $1.createdAt }
    }

    private func normalizedLink(from text: String) -> URL? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        if let url = URL(string: trimmed), url.scheme != nil {
            return FeedService.isSafeURL(url) ? url : nil
        }
        guard let url = URL(string: "https://\(trimmed)"), FeedService.isSafeURL(url) else {
            return nil
        }
        return url
    }

    private func friendlyMessage(for error: Error) -> String {
        let message = error.localizedDescription
        if message.lowercased().contains("collection") && message.lowercased().contains("not found") {
            return "Feed isn’t set up in Appwrite yet. Create the posts table (see docs/ios/FEED_SETUP.md)."
        }
        if message.lowercased().contains("bucket") {
            return "Photo or video bucket missing. Run docs/ios/FEED_SETUP.md (post-images / post-videos)."
        }
        return message
    }
}

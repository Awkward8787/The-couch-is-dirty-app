import Foundation
import Observation

@Observable
@MainActor
final class FeedStore {
    private(set) var posts: [FeedPost] = []
    private(set) var isLoading = false
    private(set) var isPosting = false
    private(set) var loadError: String?
    private(set) var postError: String?

    func load() async {
        isLoading = true
        loadError = nil
        defer { isLoading = false }

        do {
            posts = try await FeedService.fetchPosts()
        } catch {
            posts = []
            loadError = friendlyMessage(for: error)
        }
    }

    func createPost(
        authorId: String,
        authorName: String,
        authorRole: CommunityRole,
        body: String,
        linkText: String,
        imageJPEGData: Data?
    ) async throws {
        isPosting = true
        postError = nil
        defer { isPosting = false }

        let linkURL = normalizedLink(from: linkText)
        do {
            let created = try await FeedService.createPost(
                authorId: authorId,
                authorName: authorName,
                authorRole: authorRole,
                body: body,
                linkURL: linkURL,
                imageJPEGData: imageJPEGData
            )
            posts.insert(created, at: 0)
        } catch {
            postError = friendlyMessage(for: error)
            throw error
        }
    }

    private func normalizedLink(from text: String) -> URL? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        if let url = URL(string: trimmed), url.scheme != nil {
            return url
        }
        return URL(string: "https://\(trimmed)")
    }

    private func friendlyMessage(for error: Error) -> String {
        let message = error.localizedDescription
        if message.lowercased().contains("collection") && message.lowercased().contains("not found") {
            return "Feed isn’t set up in Appwrite yet. Create the posts table (see docs/ios/FEED_SETUP.md)."
        }
        if message.lowercased().contains("bucket") {
            return "Photo bucket missing. Create the post-images bucket in Appwrite."
        }
        return message
    }
}

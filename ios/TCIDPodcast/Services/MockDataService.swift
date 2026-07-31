import Foundation

/// Seeded mock data for UI development — replaced by Appwrite when offline fallback is not needed.
enum MockDataService {
    static let featuredEpisode = episodes[0]

    static let episodes: [Episode] = [
        Episode(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000087")!,
            rssGuid: "ep-87",
            source: .rss,
            status: .published,
            title: "Ep. 87: No Filter, All Facts",
            slug: "ep-87-no-filter-all-facts",
            description: "We get real about boundaries, loyalty, and protecting your peace — no filter, all facts.",
            showNotes: nil,
            audioURL: nil,
            coverArtURL: nil,
            durationSeconds: 4328,
            seasonNumber: 1,
            episodeNumber: 87,
            isExplicit: true,
            publishedAt: date(year: 2025, month: 5, day: 29),
            playCount: 12_300,
            chapters: [
                EpisodeChapter(id: UUID(), title: "Intro — What's on the table today", startSeconds: 0, sortOrder: 0),
                EpisodeChapter(id: UUID(), title: "The hard truths we don't talk about", startSeconds: 222, sortOrder: 1),
            ]
        ),
        Episode(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000086")!,
            rssGuid: "ep-86",
            source: .rss,
            status: .published,
            title: "Ep. 86: Protecting Your Peace",
            slug: "ep-86-protecting-your-peace",
            description: "When to walk away, how to set boundaries, and why peace isn't selfish.",
            showNotes: nil,
            audioURL: nil,
            coverArtURL: nil,
            durationSeconds: 3840,
            seasonNumber: 1,
            episodeNumber: 86,
            isExplicit: false,
            publishedAt: date(year: 2025, month: 5, day: 22),
            playCount: 9_800,
            chapters: []
        ),
        Episode(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000085")!,
            rssGuid: "ep-85",
            source: .rss,
            status: .published,
            title: "Ep. 85: Loyalty vs. Self-Respect",
            slug: "ep-85-loyalty-vs-self-respect",
            description: "Unpacking toxic loyalty and what real support looks like on the couch.",
            showNotes: nil,
            audioURL: nil,
            coverArtURL: nil,
            durationSeconds: 4100,
            seasonNumber: 1,
            episodeNumber: 85,
            isExplicit: false,
            publishedAt: date(year: 2025, month: 5, day: 15),
            playCount: 8_200,
            chapters: []
        ),
    ]

    static let communityDiscussions: [CommunityDiscussion] = [
        CommunityDiscussion(
            id: UUID(),
            title: "Who's episode hit you the hardest?",
            subtitle: "Join the conversation and drop your pick.",
            replyCount: 142,
            participantCount: 127,
            isPinned: true,
            icon: .flame
        ),
        CommunityDiscussion(
            id: UUID(),
            title: "Episode 87 hit hard…",
            subtitle: "That boundaries segment changed how I show up.",
            replyCount: 86,
            participantCount: 64,
            isPinned: false,
            icon: .couch
        ),
    ]

    static let fanComment = FanComment(
        id: UUID(),
        authorName: "Jasmine T.",
        body: "That message about protecting your peace hit different. Needed that today. 💯",
        episodeTitle: "Ep. 87: No Filter, All Facts",
        timeAgo: "10m ago",
        likeCount: 24
    )

    static let trendingQuestions: [String] = [
        "What's the most toxic \"loyalty\" you've experienced?",
        "How do you set boundaries without feeling guilty?",
        "What episode made you rethink a relationship?",
    ]

    static let homeFeedPosts: [HomeFeedPost] = [
        HomeFeedPost(
            id: UUID(uuidString: "10000000-0000-0000-0000-000000000001")!,
            authorName: "Marcus R.",
            body: "Just finished my morning walk listening to the latest — needed that reminder to protect my peace today.",
            timeAgo: "12m ago",
            reactionCount: 18,
            commentCount: 4
        ),
        HomeFeedPost(
            id: UUID(uuidString: "10000000-0000-0000-0000-000000000002")!,
            authorName: "Keisha L.",
            body: "Who else is pulling up to the live recording next month? Couch fam let's go! 🔥",
            timeAgo: "1h ago",
            reactionCount: 42,
            commentCount: 11
        ),
        HomeFeedPost(
            id: UUID(uuidString: "10000000-0000-0000-0000-000000000003")!,
            authorName: "Devon P.",
            body: "Real talk: setting boundaries isn't selfish. Wish I'd heard that ten years ago.",
            timeAgo: "3h ago",
            reactionCount: 67,
            commentCount: 9
        ),
    ]

    private static func date(year: Int, month: Int, day: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day)) ?? .now
    }
}

struct CommunityDiscussion: Identifiable, Hashable {
    let id: UUID
    let title: String
    let subtitle: String
    let replyCount: Int
    let participantCount: Int
    let isPinned: Bool
    let icon: DiscussionIcon

    enum DiscussionIcon: Hashable {
        case flame
        case couch
        case microphone
    }
}

struct FanComment: Identifiable, Hashable {
    let id: UUID
    let authorName: String
    let body: String
    let episodeTitle: String
    let timeAgo: String
    let likeCount: Int
}

struct HomeFeedPost: Identifiable, Hashable {
    let id: UUID
    let authorName: String
    let body: String
    let timeAgo: String
    let reactionCount: Int
    let commentCount: Int
}

enum EpisodeFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case newest = "Newest"
    case popular = "Popular"
    case saved = "Saved"

    var id: String { rawValue }
}

enum CommunityFilter: String, CaseIterable, Identifiable {
    case hot = "Hot"
    case latest = "Latest"
    case questions = "Questions"
    case clips = "Clips"

    var id: String { rawValue }

    var systemImage: String? {
        switch self {
        case .hot: "flame.fill"
        default: nil
        }
    }
}

import Foundation

enum MailHelper {
    static let guestEmail = "info@tcidpodcast.com"

    static func guestApplicationURL(format: GuestAppearanceType?) -> URL? {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = guestEmail
        components.queryItems = [
            URLQueryItem(name: "subject", value: "Guest Application — The Couch Is Dirty Podcast"),
            URLQueryItem(
                name: "body",
                value: guestApplicationBody(format: format)
            ),
        ]
        return components.url
    }

    static func generalInquiryURL() -> URL? {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = guestEmail
        components.queryItems = [
            URLQueryItem(name: "subject", value: "Inquiry — The Couch Is Dirty Podcast"),
        ]
        return components.url
    }

    private static func guestApplicationBody(format: GuestAppearanceType?) -> String {
        let formatLine = format.map { "Preferred appearance: \($0.rawValue)\n" } ?? ""
        return """
        Hi Couch Crew,

        I'd like to apply to be a guest on the show.

        \(formatLine)Name:
        Topic / story idea:
        Best contact number:
        Availability:

        Thanks!
        """
    }
}

enum GuestAppearanceType: String, Hashable, Identifiable {
    case inPerson = "In Person"
    case overThePhone = "Over the Phone"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .inPerson: "sofa.fill"
        case .overThePhone: "phone.fill"
        }
    }

    var headline: String {
        switch self {
        case .inPerson: "Come sit on the couch and record live with us."
        case .overThePhone: "Join remotely and be part of the conversation from anywhere."
        }
    }

    var detailTitle: String {
        switch self {
        case .inPerson: "In Person"
        case .overThePhone: "Over the Phone"
        }
    }

    var detailDescription: String {
        switch self {
        case .inPerson: "Come through and record with us in the studio."
        case .overThePhone: "Join the conversation from anywhere."
        }
    }

    var expectations: [String] {
        switch self {
        case .inPerson:
            [
                "Professional recording setup",
                "Video and audio capture",
                "Promotion across our platforms",
                "Real, unfiltered conversations",
            ]
        case .overThePhone:
            [
                "Easy call-in process",
                "High-quality audio",
                "Real, unfiltered conversations",
                "Promotion across our platforms",
            ]
        }
    }

    var footerNote: String {
        switch self {
        case .inPerson: "We'll contact you to confirm your date and time."
        case .overThePhone: "We'll send you call-in details after you apply."
        }
    }
}

struct GuestExpectation: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
}

enum GuestContent {
    static let expectations: [GuestExpectation] = [
        GuestExpectation(
            icon: "bubble.left.and.bubble.right.fill",
            title: "Real Conversation",
            subtitle: "Unfiltered, honest, and unscripted discussions."
        ),
        GuestExpectation(
            icon: "shield.fill",
            title: "Respectful Discussion",
            subtitle: "All guests are expected to engage with respect."
        ),
        GuestExpectation(
            icon: "calendar",
            title: "Episode Scheduling",
            subtitle: "We'll work with you to find the best time to record."
        ),
        GuestExpectation(
            icon: "pencil",
            title: "Topic Prep",
            subtitle: "Share your topic ideas so we can prep together."
        ),
    ]

    static let guidelines: [String] = [
        "Be respectful to hosts and listeners",
        "Stay on topic and come prepared",
        "No hate speech or discrimination",
        "Keep it real — authenticity over perfection",
        "Promote your mission when it fits naturally",
        "Have fun on the couch",
    ]
}

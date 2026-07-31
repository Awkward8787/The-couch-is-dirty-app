import Foundation

struct LegalSection: Identifiable {
    let id = UUID()
    let title: String
    let body: String
}

struct LegalDocument {
    let title: String
    let subtitle: String
    let icon: String
    let lastUpdated: String
    let scaffoldNotice: String
    let sections: [LegalSection]
    let webURL: URL
}

enum LegalContent {
    private static let scaffoldPreamble = """
    This is a general summary for in-app reference. A complete, legally reviewed version \
    will be published on our website. Contact us if you need the full document before then.
    """

    static let privacyPolicy = LegalDocument(
        title: "Privacy Policy",
        subtitle: "General information about how we handle your data.",
        icon: "hand.raised.fill",
        lastUpdated: "July 31, 2026",
        scaffoldNotice: scaffoldPreamble,
        sections: [
            LegalSection(
                title: "Introduction",
                body: """
                \(AppConfig.showName) (“we,” “us,” “our”) provides a mobile app for listening to the podcast \
                and participating in community features. This summary explains, in general terms, \
                what information we may collect and why.
                """
            ),
            LegalSection(
                title: "Information We May Collect",
                body: """
                • Information you provide — such as name, email, profile details, and messages you send us. \
                • Usage information — such as how you use the app, features you access, and general device or log data. \
                • Content you submit — such as posts, comments, or media shared in community areas. \
                • Optional preferences — such as saved content or settings tied to your account when you sign in.
                """
            ),
            LegalSection(
                title: "How We May Use Information",
                body: """
                We generally use information to operate and improve the app, authenticate users, \
                deliver podcast content, support community features, respond to inquiries, \
                maintain security, and comply with applicable law. \
                We do not sell personal information.
                """
            ),
            LegalSection(
                title: "Sharing & Service Providers",
                body: """
                We may share information with trusted service providers who help us run the app \
                (for example, hosting, authentication, or analytics), when you ask us to, \
                to protect rights and safety, or when required by law.
                """
            ),
            LegalSection(
                title: "Retention & Security",
                body: """
                We keep information only as long as needed for the purposes described above \
                or as required by law. We use reasonable measures to protect data, \
                but no system is completely secure.
                """
            ),
            LegalSection(
                title: "Your Choices",
                body: """
                You may be able to update profile information, sign out, or request account changes \
                by contacting \(AppConfig.supportEmail). Some features may work without an account; \
                others may require sign-in. Users must meet the minimum age required in their region \
                (typically \(AppConfig.minimumAge)+).
                """
            ),
            LegalSection(
                title: "Changes & Contact",
                body: """
                We may update this policy from time to time. Material changes will be reflected \
                on our website and, where appropriate, in the app. \
                Questions: \(AppConfig.supportEmail).
                """
            ),
        ],
        webURL: AppConfig.privacyURL
    )

    static let termsOfService = LegalDocument(
        title: "Terms of Service",
        subtitle: "General rules for using the app and our services.",
        icon: "doc.plaintext.fill",
        lastUpdated: "July 31, 2026",
        scaffoldNotice: scaffoldPreamble,
        sections: [
            LegalSection(
                title: "Agreement",
                body: """
                By accessing or using \(AppConfig.showName), you agree to these Terms of Service \
                and our Community Guidelines. If you do not agree, do not use the app.
                """
            ),
            LegalSection(
                title: "The Service",
                body: """
                We provide access to podcast episodes, related content, and optional community features. \
                Features may change, be added, or be removed over time. \
                We try to keep the service available but do not guarantee uninterrupted access.
                """
            ),
            LegalSection(
                title: "Accounts & Eligibility",
                body: """
                Some features require an account. You agree to provide accurate information \
                and keep your credentials secure. You are responsible for activity under your account. \
                You must meet the minimum age required to use the service in your region.
                """
            ),
            LegalSection(
                title: "Acceptable Use",
                body: """
                Use the app lawfully and respectfully. Do not abuse, disrupt, or attempt to gain \
                unauthorized access to the service, other users, or our systems. \
                Do not use the app for spam, harassment, or illegal activity.
                """
            ),
            LegalSection(
                title: "Your Content",
                body: """
                You may submit content in community areas. You retain ownership of what you create, \
                but grant us a license to host, display, and moderate that content as needed \
                to operate the app and promote the podcast. You must have the rights to what you share.
                """
            ),
            LegalSection(
                title: "Intellectual Property",
                body: """
                The app, branding, and podcast materials are owned by us or our licensors. \
                You may not copy, modify, or redistribute them except as allowed by these terms \
                or applicable law.
                """
            ),
            LegalSection(
                title: "Disclaimers & Liability",
                body: """
                The app and podcast content are provided “as is.” Views expressed on the show \
                are those of participants and are not professional advice. \
                To the fullest extent permitted by law, we disclaim warranties and limit liability \
                for indirect or consequential damages.
                """
            ),
            LegalSection(
                title: "Termination & Changes",
                body: """
                We may suspend or terminate access for violations of these terms or our guidelines. \
                You may stop using the app at any time. We may update these terms; continued use \
                after changes means you accept the updated terms. Questions: \(AppConfig.supportEmail).
                """
            ),
        ],
        webURL: AppConfig.termsURL
    )

    static let communityGuidelines = LegalDocument(
        title: "Community Guidelines",
        subtitle: "General standards for participating in our community spaces.",
        icon: "doc.text.fill",
        lastUpdated: "July 31, 2026",
        scaffoldNotice: scaffoldPreamble,
        sections: [
            LegalSection(
                title: "Purpose",
                body: """
                Our community exists to discuss the podcast, episodes, and related topics \
                in a welcoming way. These guidelines apply to posts, comments, and other interactions \
                in app community features.
                """
            ),
            LegalSection(
                title: "Be Respectful",
                body: """
                Treat others with respect. Healthy disagreement is welcome; personal attacks, \
                hate speech, slurs, threats, bullying, and harassment are not.
                """
            ),
            LegalSection(
                title: "Be Honest",
                body: """
                Share authentically. Do not impersonate others, spread misinformation deliberately, \
                or post misleading or deceptive content.
                """
            ),
            LegalSection(
                title: "Keep It Appropriate",
                body: """
                Do not post illegal content, content that exploits minors, non-consensual imagery, \
                doxxing, or material that puts others at risk. Follow applicable laws and platform rules.
                """
            ),
            LegalSection(
                title: "Stay On Topic",
                body: """
                Keep discussions relevant to the show and community. \
                Excessive spam, unrelated promotion, or repetitive off-topic posts may be removed.
                """
            ),
            LegalSection(
                title: "Moderation",
                body: """
                Moderators and administrators may remove content or restrict accounts that violate \
                these guidelines. Enforcement decisions are made to protect the community. \
                Repeated or serious violations may result in permanent removal.
                """
            ),
            LegalSection(
                title: "Reporting & Updates",
                body: """
                If you see content that breaks these rules, report it in the app where available \
                or contact \(AppConfig.supportEmail). We may update these guidelines over time; \
                the latest version will be posted on our website.
                """
            ),
        ],
        webURL: AppConfig.communityGuidelinesURL
    )
}

struct SupportTopic: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}

enum SupportContent {
    static let intro = """
    Need help with the app, your account, or the community? \
    Start here—we’ll point you in the right direction.
    """

    static let topics: [SupportTopic] = [
        SupportTopic(
            question: "I can't sign in",
            answer: """
            Check your email and password, then try again. On the sign-in screen, tap Forgot password? \
            to receive a reset link by email. Still stuck? Contact us with the address on your account.
            """
        ),
        SupportTopic(
            question: "Playback or episodes not loading",
            answer: """
            Confirm you have a stable internet connection and try pulling to refresh the Episodes tab. \
            If a specific episode fails, note the title and contact us.
            """
        ),
        SupportTopic(
            question: "Community posts or comments",
            answer: """
            Read our Community Guidelines in Profile. To report content, use report actions where available \
            or email us with a link or screenshot.
            """
        ),
        SupportTopic(
            question: "Be a guest on the show",
            answer: """
            Open Be a Guest in Profile to review formats and apply. Guest questions go to \(AppConfig.guestEmail).
            """
        ),
        SupportTopic(
            question: "Account deletion or privacy",
            answer: """
            Email \(AppConfig.supportEmail) from the address on your account and ask for deletion or a data request. \
            See Privacy Policy for details.
            """
        ),
    ]
}

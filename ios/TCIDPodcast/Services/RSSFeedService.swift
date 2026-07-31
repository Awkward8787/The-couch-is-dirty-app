import CryptoKit
import Foundation

enum RSSFeedService {
    enum FeedError: LocalizedError {
        case invalidResponse
        case emptyFeed

        var errorDescription: String? {
            switch self {
            case .invalidResponse: "Unable to load the podcast feed."
            case .emptyFeed: "The podcast feed has no episodes yet."
            }
        }
    }

    static func fetchEpisodes(from feedURL: URL = AppConfig.rssFeedURL) async throws -> [Episode] {
        let (data, response) = try await URLSession.shared.data(from: feedURL)
        guard let http = response as? HTTPURLResponse, (200 ... 299).contains(http.statusCode) else {
            throw FeedError.invalidResponse
        }

        let parser = RSSFeedParser()
        let parsedItems = parser.parse(data: data)
        guard !parsedItems.isEmpty else { throw FeedError.emptyFeed }

        return parsedItems.map(makeEpisode(from:))
    }

    private static func makeEpisode(from item: RSSFeedItem) -> Episode {
        Episode(
            id: stableUUID(from: item.guid),
            rssGuid: item.guid,
            source: .rss,
            status: .published,
            title: item.title,
            slug: slugify(item.title),
            description: item.description,
            showNotes: nil,
            audioURL: item.audioURL,
            coverArtURL: item.coverArtURL,
            durationSeconds: item.durationSeconds,
            seasonNumber: item.seasonNumber,
            episodeNumber: item.episodeNumber,
            isExplicit: item.isExplicit,
            publishedAt: item.publishedAt,
            playCount: 0,
            chapters: []
        )
    }

    private static func stableUUID(from guid: String) -> UUID {
        let hash = SHA256.hash(data: Data("tcid.episode.\(guid)".utf8))
        let bytes = Array(hash.prefix(16))
        return UUID(uuid: (
            bytes[0], bytes[1], bytes[2], bytes[3],
            bytes[4], bytes[5], bytes[6], bytes[7],
            bytes[8], bytes[9], bytes[10], bytes[11],
            bytes[12], bytes[13], bytes[14], bytes[15]
        ))
    }

    private static func slugify(_ title: String) -> String {
        let lowered = title.lowercased()
        let allowed = lowered.map { character -> Character in
            character.isLetter || character.isNumber ? character : "-"
        }
        return String(allowed)
            .replacingOccurrences(of: "-+", with: "-", options: .regularExpression)
            .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    }
}

private struct RSSFeedItem {
    let guid: String
    let title: String
    let description: String?
    let audioURL: URL?
    let coverArtURL: URL?
    let durationSeconds: Int?
    let seasonNumber: Int?
    let episodeNumber: Int?
    let isExplicit: Bool
    let publishedAt: Date?
}

private final class RSSFeedParser: NSObject, XMLParserDelegate {
    private var items: [RSSFeedItem] = []
    private var currentFields: [String: String] = [:]
    private var currentEnclosureURL: String?
    private var currentCoverArtURL: String?
    private var isInsideItem = false
    private var currentText = ""

    func parse(data: Data) -> [RSSFeedItem] {
        items = []
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return items
    }

    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        currentText = ""
        let name = normalizedElementName(elementName)

        if name == "item" {
            isInsideItem = true
            currentFields = [:]
            currentEnclosureURL = nil
            currentCoverArtURL = nil
            return
        }

        guard isInsideItem else { return }

        if name == "enclosure", let url = attributeDict["url"] {
            currentEnclosureURL = url
        }

        if name == "image", let href = attributeDict["href"] {
            currentCoverArtURL = href
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentText += string
    }

    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        let name = normalizedElementName(elementName)

        if isInsideItem, name != "item" {
            let value = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
            if !value.isEmpty {
                currentFields[name] = stripHTML(from: value)
            }
        }

        if name == "item" {
            if let item = buildItem() {
                items.append(item)
            }
            isInsideItem = false
        }

        currentText = ""
    }

    private func buildItem() -> RSSFeedItem? {
        let guid = currentFields["guid"] ?? currentFields["link"] ?? ""
        let title = currentFields["title"] ?? ""
        guard !guid.isEmpty, !title.isEmpty else { return nil }

        return RSSFeedItem(
            guid: guid,
            title: title,
            description: currentFields["description"],
            audioURL: currentEnclosureURL.flatMap(URL.init(string:)),
            coverArtURL: currentCoverArtURL.flatMap(URL.init(string:)),
            durationSeconds: parseDuration(currentFields["duration"]),
            seasonNumber: Int(currentFields["season"] ?? ""),
            episodeNumber: Int(currentFields["episode"] ?? ""),
            isExplicit: parseExplicit(currentFields["explicit"]),
            publishedAt: parseDate(currentFields["pubDate"])
        )
    }

    private func normalizedElementName(_ elementName: String) -> String {
        if elementName.contains(":") {
            return String(elementName.split(separator: ":").last ?? Substring(elementName))
        }
        return elementName
    }

    private func stripHTML(from value: String) -> String {
        value
            .replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func parseDuration(_ value: String?) -> Int? {
        guard let value, !value.isEmpty else { return nil }
        if let seconds = Int(value) { return seconds }

        let parts = value.split(separator: ":").compactMap { Int($0) }
        guard !parts.isEmpty else { return nil }

        switch parts.count {
        case 3: return parts[0] * 3600 + parts[1] * 60 + parts[2]
        case 2: return parts[0] * 60 + parts[1]
        default: return nil
        }
    }

    private func parseExplicit(_ value: String?) -> Bool {
        guard let value else { return false }
        let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return normalized == "yes" || normalized == "true"
    }

    private func parseDate(_ value: String?) -> Date? {
        guard let value else { return nil }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        return formatter.date(from: value)
    }
}

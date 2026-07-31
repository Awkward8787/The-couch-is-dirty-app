import Foundation

enum EpisodeTextSanitizer {
    /// Strips RSS/XML CDATA wrappers, HTML tags, and common entities for display.
    static func sanitize(_ value: String?) -> String? {
        guard var text = value?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else {
            return nil
        }

        text = decodeBasicEntities(text)
        text = stripCDataMarkers(text)
        text = stripHTMLTags(text)
        text = decodeBasicEntities(text)
        text = collapseWhitespace(text)

        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private static func stripCDataMarkers(_ value: String) -> String {
        var result = value
        let markers = [
            "<![CDATA[",
            "<!{CDATA{",
            "CDATA[",
            "]]>",
        ]
        for marker in markers {
            result = result.replacingOccurrences(of: marker, with: "", options: .caseInsensitive)
        }
        return result
    }

    private static func stripHTMLTags(_ value: String) -> String {
        value.replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
    }

    private static func decodeBasicEntities(_ value: String) -> String {
        value
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
    }

    private static func collapseWhitespace(_ value: String) -> String {
        value.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }
}

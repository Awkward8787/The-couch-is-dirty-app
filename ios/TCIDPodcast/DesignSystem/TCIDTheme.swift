import SwiftUI

enum TCIDColors {
    static let background = Color.black
    static let card = Color(red: 0.11, green: 0.11, blue: 0.12)
    static let cardElevated = Color(red: 0.15, green: 0.15, blue: 0.16)
    static let textPrimary = Color.white
    static let textSecondary = Color(red: 0.56, green: 0.56, blue: 0.58)
    static let accent = Color(red: 0.92, green: 0.11, blue: 0.14)
    static let accentMuted = Color(red: 0.92, green: 0.11, blue: 0.14).opacity(0.2)
    static let border = Color.white.opacity(0.12)
    static let destructive = Color.red
}

enum TCIDSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let touchTarget: CGFloat = 44
}

enum TCIDTypography {
    static let largeTitle = Font.system(.largeTitle, design: .default).weight(.bold)
    static let title = Font.system(.title2, design: .default).weight(.bold)
    static let headline = Font.system(.headline, design: .default).weight(.semibold)
    static let body = Font.system(.body, design: .default)
    static let caption = Font.system(.caption, design: .default)
    static let footnote = Font.system(.footnote, design: .default)
}

enum TCIDRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let pill: CGFloat = 999
}

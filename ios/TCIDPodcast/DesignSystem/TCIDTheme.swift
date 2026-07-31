import SwiftUI

enum TCIDColors {
    /// Warm charcoal studio base — not pure OLED black.
    static let background = Color(red: 0.039, green: 0.039, blue: 0.043)

    static let surface = Color(red: 0.082, green: 0.082, blue: 0.086)
    static let surfaceElevated = Color(red: 0.11, green: 0.11, blue: 0.118)
    static let surfaceOverlay = Color(red: 0.125, green: 0.125, blue: 0.133)

    /// Legacy aliases
    static let card = surface
    static let cardElevated = surfaceElevated

    static let textPrimary = Color.white
    static let textSecondary = Color(red: 0.62, green: 0.62, blue: 0.64)
    static let textTertiary = Color(red: 0.45, green: 0.45, blue: 0.47)

    static let accent = Color(red: 0.92, green: 0.11, blue: 0.14)
    static let accentMuted = accent.opacity(0.18)

    static let border = Color.white.opacity(0.08)
    static let separator = Color.white.opacity(0.06)
    static let destructive = Color(red: 1, green: 0.35, blue: 0.35)
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
    static let display = Font.system(.largeTitle, design: .default).weight(.semibold)
    static let largeTitle = Font.system(.largeTitle, design: .default).weight(.bold)
    static let title = Font.system(.title2, design: .default).weight(.bold)
    static let headline = Font.system(.headline, design: .default).weight(.semibold)
    static let body = Font.system(.body, design: .default)
    static let caption = Font.system(.caption, design: .default)
    static let footnote = Font.system(.footnote, design: .default)
    static let micro = Font.system(size: 11, weight: .regular, design: .default)
}

enum TCIDRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let pill: CGFloat = 999
}

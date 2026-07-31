import SwiftUI

struct LegalDocumentView: View {
    let document: LegalDocument
    @Environment(\.openURL) private var openURL

    var body: some View {
        TCIDScreenContainer {
            ScrollView {
                VStack(spacing: TCIDSpacing.lg) {
                    header
                    scaffoldBanner

                    VStack(spacing: TCIDSpacing.md) {
                        ForEach(document.sections) { section in
                            sectionCard(section)
                        }
                    }

                    footer
                }
                .padding(.horizontal, TCIDSpacing.md)
                .padding(.bottom, TCIDSpacing.xl)
            }
        }
        .navigationTitle(document.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(spacing: TCIDSpacing.sm) {
            Image(systemName: document.icon)
                .font(.system(size: 44))
                .foregroundStyle(TCIDColors.accent)
                .padding(.top, TCIDSpacing.lg)
                .accessibilityHidden(true)

            Text(document.title)
                .font(TCIDTypography.title)
                .foregroundStyle(TCIDColors.textPrimary)
                .multilineTextAlignment(.center)

            Text(document.subtitle)
                .font(TCIDTypography.body)
                .foregroundStyle(TCIDColors.textSecondary)
                .multilineTextAlignment(.center)

            Text("Last updated \(document.lastUpdated)")
                .font(TCIDTypography.caption)
                .foregroundStyle(TCIDColors.textSecondary)
        }
    }

    private var scaffoldBanner: some View {
        HStack(alignment: .top, spacing: TCIDSpacing.sm) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(TCIDColors.accent)
                .accessibilityHidden(true)

            Text(document.scaffoldNotice)
                .font(TCIDTypography.caption)
                .foregroundStyle(TCIDColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(TCIDSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(TCIDColors.card.opacity(0.85))
        .overlay(
            RoundedRectangle(cornerRadius: TCIDRadius.lg)
                .stroke(TCIDColors.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.lg))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Summary notice: \(document.scaffoldNotice)")
    }

    private func sectionCard(_ section: LegalSection) -> some View {
        VStack(alignment: .leading, spacing: TCIDSpacing.sm) {
            Text(section.title)
                .font(TCIDTypography.headline)
                .foregroundStyle(TCIDColors.textPrimary)

            Text(section.body)
                .font(TCIDTypography.body)
                .foregroundStyle(TCIDColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(TCIDSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(TCIDColors.card)
        .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.lg))
    }

    private var footer: some View {
        VStack(spacing: TCIDSpacing.md) {
            Text("Full version online")
                .font(TCIDTypography.caption)
                .foregroundStyle(TCIDColors.textSecondary)

            Button {
                openURL(document.webURL)
            } label: {
                HStack(spacing: TCIDSpacing.sm) {
                    Text(document.webURL.absoluteString)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Image(systemName: "arrow.up.right")
                        .font(.caption.weight(.semibold))
                }
                .font(TCIDTypography.caption.weight(.medium))
                .foregroundStyle(TCIDColors.accent)
            }
            .accessibilityLabel("Open full \(document.title) on the web")
        }
        .padding(.top, TCIDSpacing.sm)
    }
}

#Preview {
    NavigationStack {
        LegalDocumentView(document: LegalContent.privacyPolicy)
    }
}

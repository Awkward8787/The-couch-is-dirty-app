import SwiftUI

struct SupportView: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        TCIDScreenContainer {
            ScrollView {
                VStack(spacing: TCIDSpacing.lg) {
                    header
                    contactCard
                    faqSection
                    websiteLink
                }
                .padding(.horizontal, TCIDSpacing.md)
                .padding(.bottom, TCIDSpacing.xl)
            }
        }
        .navigationTitle("Support")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(spacing: TCIDSpacing.sm) {
            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: 44))
                .foregroundStyle(TCIDColors.accent)
                .padding(.top, TCIDSpacing.lg)
                .accessibilityHidden(true)

            Text("How can we help?")
                .font(TCIDTypography.title)
                .foregroundStyle(TCIDColors.textPrimary)

            Text(SupportContent.intro)
                .font(TCIDTypography.body)
                .foregroundStyle(TCIDColors.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    private var contactCard: some View {
        VStack(alignment: .leading, spacing: TCIDSpacing.md) {
            Text("Contact us")
                .font(TCIDTypography.headline)
                .foregroundStyle(TCIDColors.textPrimary)

            Text("We typically respond within a few business days.")
                .font(TCIDTypography.body)
                .foregroundStyle(TCIDColors.textSecondary)

            Button {
                openSupportEmail()
            } label: {
                HStack(spacing: TCIDSpacing.sm) {
                    Image(systemName: "envelope.fill")
                        .foregroundStyle(TCIDColors.accent)
                    Text(AppConfig.supportEmail)
                        .font(TCIDTypography.body.weight(.medium))
                        .foregroundStyle(TCIDColors.textPrimary)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(TCIDColors.textSecondary)
                }
                .frame(minHeight: TCIDSpacing.touchTarget)
            }
            .accessibilityLabel("Email support at \(AppConfig.supportEmail)")
        }
        .padding(TCIDSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(TCIDColors.card)
        .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.lg))
    }

    private var faqSection: some View {
        VStack(alignment: .leading, spacing: TCIDSpacing.md) {
            Text("Common questions")
                .font(TCIDTypography.headline)
                .foregroundStyle(TCIDColors.textPrimary)
                .padding(.horizontal, TCIDSpacing.xs)

            ForEach(SupportContent.topics) { topic in
                VStack(alignment: .leading, spacing: TCIDSpacing.sm) {
                    Text(topic.question)
                        .font(TCIDTypography.body.weight(.semibold))
                        .foregroundStyle(TCIDColors.textPrimary)

                    Text(topic.answer)
                        .font(TCIDTypography.body)
                        .foregroundStyle(TCIDColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(TCIDSpacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(TCIDColors.card)
                .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.lg))
            }
        }
    }

    private var websiteLink: some View {
        Button {
            openURL(AppConfig.websiteURL)
        } label: {
            HStack(spacing: TCIDSpacing.sm) {
                Text("Visit \(AppConfig.websiteURL.host ?? "tcidpodcast.com")")
                Image(systemName: "arrow.up.right")
                    .font(.caption.weight(.semibold))
            }
            .font(TCIDTypography.caption.weight(.medium))
            .foregroundStyle(TCIDColors.accent)
        }
        .accessibilityLabel("Open TCID website")
        .padding(.top, TCIDSpacing.sm)
    }

    private func openSupportEmail() {
        guard let url = MailHelper.supportURL() else { return }
        openURL(url)
    }
}

#Preview {
    NavigationStack {
        SupportView()
    }
}

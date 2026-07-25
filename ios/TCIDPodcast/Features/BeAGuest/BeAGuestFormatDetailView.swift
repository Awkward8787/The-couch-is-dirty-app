import SwiftUI

struct BeAGuestFormatDetailView: View {
    @Environment(\.openURL) private var openURL

    let format: GuestAppearanceType

    var body: some View {
        TCIDScreenContainer {
            ScrollView {
                VStack(spacing: TCIDSpacing.lg) {
                    Image(systemName: format.icon)
                        .font(.system(size: 44))
                        .foregroundStyle(TCIDColors.accent)
                        .padding(.top, TCIDSpacing.lg)
                        .accessibilityHidden(true)

                    Text(format.detailTitle)
                        .font(TCIDTypography.title)
                        .foregroundStyle(TCIDColors.textPrimary)

                    Text(format.detailDescription)
                        .font(TCIDTypography.body)
                        .foregroundStyle(TCIDColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, TCIDSpacing.md)

                    VStack(alignment: .leading, spacing: TCIDSpacing.md) {
                        Text("What to Expect")
                            .font(TCIDTypography.headline)
                            .foregroundStyle(TCIDColors.textPrimary)

                        VStack(alignment: .leading, spacing: TCIDSpacing.sm) {
                            ForEach(format.expectations, id: \.self) { item in
                                HStack(alignment: .top, spacing: TCIDSpacing.sm) {
                                    Circle()
                                        .fill(TCIDColors.accent)
                                        .frame(width: 6, height: 6)
                                        .padding(.top, 6)
                                    Text(item)
                                        .font(TCIDTypography.body)
                                        .foregroundStyle(TCIDColors.textPrimary)
                                }
                            }
                        }
                        .padding(TCIDSpacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(TCIDColors.card)
                        .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.lg))
                    }

                    Button {
                        applyNow()
                    } label: {
                        Text("Apply Now")
                            .font(TCIDTypography.headline)
                            .foregroundStyle(TCIDColors.textPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: TCIDSpacing.touchTarget)
                            .background(TCIDColors.accent)
                            .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.md))
                    }
                    .accessibilityHint("Opens email to submit your guest application")

                    Text(format.footerNote)
                        .font(TCIDTypography.caption)
                        .foregroundStyle(TCIDColors.textSecondary)
                        .multilineTextAlignment(.center)

                    Button {
                        openGeneralEmail()
                    } label: {
                        Text("Questions? \(MailHelper.guestEmail)")
                            .font(TCIDTypography.caption)
                            .foregroundStyle(TCIDColors.accent)
                            .multilineTextAlignment(.center)
                    }
                    .accessibilityLabel("Email \(MailHelper.guestEmail) with questions")
                    .padding(.bottom, TCIDSpacing.xl)
                }
                .padding(.horizontal, TCIDSpacing.md)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func applyNow() {
        guard let url = MailHelper.guestApplicationURL(format: format) else { return }
        openURL(url)
    }

    private func openGeneralEmail() {
        guard let url = MailHelper.generalInquiryURL() else { return }
        openURL(url)
    }
}

#Preview {
    NavigationStack {
        BeAGuestFormatDetailView(format: .inPerson)
    }
}

import SwiftUI

struct GuestGuidelinesView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        TCIDScreenContainer {
            ScrollView {
                VStack(spacing: TCIDSpacing.lg) {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(TCIDColors.accent)
                        .padding(.top, TCIDSpacing.lg)
                        .accessibilityHidden(true)

                    Text("Guest Guidelines")
                        .font(TCIDTypography.title)
                        .foregroundStyle(TCIDColors.textPrimary)

                    Text("What to expect when you join us on the couch.")
                        .font(TCIDTypography.body)
                        .foregroundStyle(TCIDColors.textSecondary)
                        .multilineTextAlignment(.center)

                    VStack(alignment: .leading, spacing: TCIDSpacing.md) {
                        ForEach(GuestContent.guidelines, id: \.self) { rule in
                            HStack(alignment: .top, spacing: TCIDSpacing.sm) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(TCIDColors.accent)
                                Text(rule)
                                    .font(TCIDTypography.body)
                                    .foregroundStyle(TCIDColors.textPrimary)
                            }
                        }
                    }
                    .padding(TCIDSpacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(TCIDColors.card)
                    .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.lg))

                    Button {
                        dismiss()
                    } label: {
                        Text("I Understand")
                            .font(TCIDTypography.headline)
                            .foregroundStyle(TCIDColors.textPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: TCIDSpacing.touchTarget)
                            .background(TCIDColors.accent)
                            .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.md))
                    }
                    .accessibilityHint("Dismisses guest guidelines")

                    Button {
                        openContactEmail()
                    } label: {
                        Text("Contact: \(MailHelper.guestEmail)")
                            .font(TCIDTypography.caption)
                            .foregroundStyle(TCIDColors.accent)
                    }
                    .accessibilityLabel("Email \(MailHelper.guestEmail)")
                    .padding(.bottom, TCIDSpacing.xl)
                }
                .padding(.horizontal, TCIDSpacing.md)
            }
        }
        .navigationTitle("Guidelines")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func openContactEmail() {
        guard let url = MailHelper.generalInquiryURL() else { return }
        openURL(url)
    }
}

#Preview {
    NavigationStack {
        GuestGuidelinesView()
    }
}

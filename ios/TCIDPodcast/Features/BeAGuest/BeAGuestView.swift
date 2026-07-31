import SwiftUI

struct BeAGuestView: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        TCIDScreenContainer {
            ScrollView {
                VStack(alignment: .leading, spacing: TCIDSpacing.lg) {
                    header

                    formatOptions

                    expectationsSection

                    connectCard

                    actionButtons

                    Text("We'll follow up to confirm availability and format.")
                        .font(TCIDTypography.caption)
                        .foregroundStyle(TCIDColors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, TCIDSpacing.xl)
                }
                .padding(.horizontal, TCIDSpacing.md)
            }
        }
        .navigationTitle("Be a Guest")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    GuestGuidelinesView()
                } label: {
                    Image(systemName: "info.circle")
                        .foregroundStyle(TCIDColors.textPrimary)
                }
                .accessibilityLabel("Guest guidelines")
            }
        }
    }

    private var header: some View {
        VStack(spacing: TCIDSpacing.md) {
            Image("PodcastLogoDark")
                .resizable()
                .scaledToFit()
                .frame(height: 48)
                .accessibilityLabel("The Couch Is Dirty Podcast")

            Text("Be a Guest")
                .font(TCIDTypography.largeTitle)
                .foregroundStyle(TCIDColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("Join the conversation! Be a guest on the show either in person or over the phone.")
                .font(TCIDTypography.body)
                .foregroundStyle(TCIDColors.textSecondary)
        }
        .padding(.top, TCIDSpacing.sm)
    }

    private var formatOptions: some View {
        HStack(spacing: TCIDSpacing.md) {
            NavigationLink {
                BeAGuestFormatDetailView(format: .inPerson)
            } label: {
                GuestFormatCard(format: .inPerson)
            }
            .buttonStyle(.plain)

            NavigationLink {
                BeAGuestFormatDetailView(format: .overThePhone)
            } label: {
                GuestFormatCard(format: .overThePhone)
            }
            .buttonStyle(.plain)
        }
    }

    private var expectationsSection: some View {
        VStack(alignment: .leading, spacing: TCIDSpacing.md) {
            Text("What to Expect")
                .font(TCIDTypography.headline)
                .foregroundStyle(TCIDColors.textPrimary)

            VStack(spacing: TCIDSpacing.sm) {
                ForEach(GuestContent.expectations) { item in
                    GuestExpectationRow(expectation: item)
                }
            }
        }
    }

    private var connectCard: some View {
        TCIDCard {
            HStack(alignment: .top, spacing: TCIDSpacing.md) {
                Image(systemName: "envelope.fill")
                    .font(.title2)
                    .foregroundStyle(TCIDColors.accent)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: TCIDSpacing.xs) {
                    Text("Let's Connect")
                        .font(TCIDTypography.headline)
                        .foregroundStyle(TCIDColors.textPrimary)

                    Text("Email us your name, topic, and preferred appearance type.")
                        .font(TCIDTypography.caption)
                        .foregroundStyle(TCIDColors.textSecondary)
                }

                Spacer(minLength: 0)

                Button {
                    openGuestEmail(format: nil)
                } label: {
                    Text(MailHelper.guestEmail)
                        .font(TCIDTypography.caption.weight(.semibold))
                        .foregroundStyle(TCIDColors.accent)
                        .multilineTextAlignment(.trailing)
                }
                .accessibilityLabel("Email \(MailHelper.guestEmail)")
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: TCIDSpacing.md) {
            Button {
                openGuestEmail(format: nil)
            } label: {
                HStack(spacing: TCIDSpacing.sm) {
                    Image(systemName: "mic.fill")
                        .foregroundStyle(TCIDColors.accent)
                    Text("Apply to Be a Guest")
                        .font(TCIDTypography.headline)
                        .foregroundStyle(TCIDColors.accent)
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: TCIDSpacing.touchTarget)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.md))
            }
            .accessibilityHint("Opens email to apply as a guest")

            TCIDSecondaryButton("Email Us", systemImage: "envelope.fill") {
                openGeneralEmail()
            }
        }
    }

    private func openGuestEmail(format: GuestAppearanceType?) {
        guard let url = MailHelper.guestApplicationURL(format: format) else { return }
        openURL(url)
    }

    private func openGeneralEmail() {
        guard let url = MailHelper.generalInquiryURL() else { return }
        openURL(url)
    }
}

private struct GuestFormatCard: View {
    let format: GuestAppearanceType

    var body: some View {
        VStack(alignment: .leading, spacing: TCIDSpacing.sm) {
            Image(systemName: format.icon)
                .font(.title2)
                .foregroundStyle(TCIDColors.accent)

            Text(format.rawValue)
                .font(TCIDTypography.headline)
                .foregroundStyle(TCIDColors.textPrimary)

            Text(format.headline)
                .font(TCIDTypography.caption)
                .foregroundStyle(TCIDColors.textSecondary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(TCIDColors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(TCIDSpacing.md)
        .frame(maxWidth: .infinity, minHeight: 160, alignment: .leading)
        .background(TCIDColors.card)
        .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.lg))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(format.rawValue). \(format.headline)")
        .accessibilityHint("Shows guest details for this format")
    }
}

private struct GuestExpectationRow: View {
    let expectation: GuestExpectation

    var body: some View {
        HStack(spacing: TCIDSpacing.md) {
            Image(systemName: expectation.icon)
                .font(.body)
                .foregroundStyle(TCIDColors.accent)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(expectation.title)
                    .font(TCIDTypography.caption.weight(.semibold))
                    .foregroundStyle(TCIDColors.textPrimary)
                Text(expectation.subtitle)
                    .font(.caption2)
                    .foregroundStyle(TCIDColors.textSecondary)
            }

            Spacer(minLength: 0)
        }
        .padding(TCIDSpacing.md)
        .background(TCIDColors.card)
        .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.md))
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack {
        BeAGuestView()
    }
}

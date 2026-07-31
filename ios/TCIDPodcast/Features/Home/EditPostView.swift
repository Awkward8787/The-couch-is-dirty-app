import SwiftUI

struct EditPostView: View {
    @Environment(AuthService.self) private var auth
    @Environment(FeedStore.self) private var feed
    @Environment(\.dismiss) private var dismiss

    let post: FeedPost

    @State private var bodyText: String
    @State private var linkText: String
    @State private var error: String?
    @State private var isSaving = false

    init(post: FeedPost) {
        self.post = post
        _bodyText = State(initialValue: post.body)
        _linkText = State(initialValue: post.linkURL?.absoluteString ?? "")
    }

    var body: some View {
        NavigationStack {
            ZStack {
                TCIDColors.background.ignoresSafeArea()
                VStack(alignment: .leading, spacing: TCIDSpacing.md) {
                    TextField("What’s on your mind?", text: $bodyText, axis: .vertical)
                        .lineLimit(4...10)
                        .padding(TCIDSpacing.md)
                        .background(TCIDColors.card)
                        .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.md))

                    TextField("Link (optional)", text: $linkText)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.URL)
                        .padding(TCIDSpacing.md)
                        .background(TCIDColors.card)
                        .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.md))

                    if let error {
                        Text(error)
                            .font(TCIDTypography.caption)
                            .foregroundStyle(TCIDColors.destructive)
                    }

                    TCIDPrimaryButton(title: isSaving ? "Saving…" : "Save") {
                        Task { await save() }
                    }
                    .disabled(isSaving)
                    .opacity(isSaving ? 0.5 : 1)

                    Spacer()
                }
                .padding(TCIDSpacing.lg)
            }
            .navigationTitle("Edit post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func save() async {
        error = nil
        guard let userId = auth.currentUser?.id else {
            error = FeedServiceError.signInRequired.localizedDescription
            return
        }
        isSaving = true
        defer { isSaving = false }
        do {
            try await feed.editPost(
                post: post,
                body: bodyText,
                linkText: linkText,
                currentUserId: userId
            )
            dismiss()
        } catch {
            self.error = error.localizedDescription
        }
    }
}

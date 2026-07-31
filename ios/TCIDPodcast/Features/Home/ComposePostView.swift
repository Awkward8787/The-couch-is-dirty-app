import PhotosUI
import SwiftUI
import UIKit

struct ComposePostView: View {
    @Environment(AuthService.self) private var auth
    @Environment(FeedStore.self) private var feed
    @Environment(\.dismiss) private var dismiss

    @State private var bodyText = ""
    @State private var linkText = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var previewImage: UIImage?
    @State private var imageData: Data?
    @State private var localError: String?
    @State private var successMessage: String?
    @FocusState private var focused: Field?

    private enum Field {
        case body
        case link
    }

    private var canSubmit: Bool {
        let hasBody = !bodyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasLink = !linkText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasImage = imageData != nil
        return (hasBody || hasLink || hasImage) && !feed.isPosting
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: TCIDSpacing.lg) {
                        Text("What’s on your mind?")
                            .font(TCIDTypography.title)
                            .foregroundStyle(TCIDColors.textPrimary)

                        Text("Text, a website/video link, or one photo. Video files stay off our server — paste a YouTube/mp4 link instead.")
                            .font(TCIDTypography.caption)
                            .foregroundStyle(TCIDColors.textSecondary)

                        TextField("What’s on your mind?", text: $bodyText, axis: .vertical)
                            .lineLimit(4...8)
                            .padding(TCIDSpacing.md)
                            .background(TCIDColors.card)
                            .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.md))
                            .focused($focused, equals: .body)

                        HStack {
                            TextField("Website or video link (optional)", text: $linkText)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .keyboardType(.URL)
                                .focused($focused, equals: .link)

                            if !linkText.isEmpty {
                                Button {
                                    linkText = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(TCIDColors.textSecondary)
                                }
                                .accessibilityLabel("Remove link")
                            }
                        }
                        .padding(TCIDSpacing.md)
                        .background(TCIDColors.card)
                        .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.md))

                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            Label(
                                previewImage == nil ? "Add photo (optional)" : "Change photo",
                                systemImage: "photo"
                            )
                            .font(TCIDTypography.headline)
                            .foregroundStyle(TCIDColors.textPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: TCIDSpacing.touchTarget)
                            .overlay(
                                RoundedRectangle(cornerRadius: TCIDRadius.md)
                                    .stroke(TCIDColors.border, lineWidth: 1)
                            )
                        }
                        .onChange(of: selectedPhoto) { _, item in
                            Task { await loadPhoto(item) }
                        }

                        if let previewImage {
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: previewImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 180)
                                    .clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.md))

                                Button {
                                    clearPhoto()
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title2)
                                        .foregroundStyle(.white)
                                        .padding(8)
                                }
                                .accessibilityLabel("Remove photo")
                            }
                        }

                        if let error = localError ?? feed.postError {
                            Text(error)
                                .font(TCIDTypography.caption)
                                .foregroundStyle(TCIDColors.destructive)
                        }

                        if let successMessage {
                            Text(successMessage)
                                .font(TCIDTypography.caption)
                                .foregroundStyle(TCIDColors.accent)
                        }

                        if feed.isPosting {
                            ProgressView("Publishing…")
                                .tint(TCIDColors.accent)
                                .font(TCIDTypography.caption)
                                .foregroundStyle(TCIDColors.textSecondary)
                        }

                        Button {
                            Task { await submit() }
                        } label: {
                            Text(feed.isPosting ? "Posting…" : "Post")
                                .font(TCIDTypography.headline)
                                .foregroundStyle(Color.black)
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: TCIDSpacing.touchTarget)
                                .background(canSubmit ? Color.white : Color.white.opacity(0.4))
                                .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.md))
                        }
                        .disabled(!canSubmit)
                    }
                    .padding(TCIDSpacing.lg)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .disabled(feed.isPosting)
                }
            }
        }
    }

    private func clearPhoto() {
        selectedPhoto = nil
        previewImage = nil
        imageData = nil
    }

    private func loadPhoto(_ item: PhotosPickerItem?) async {
        localError = nil
        guard let item else { return }
        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data)
            else {
                localError = "Couldn’t read that photo."
                return
            }
            guard let compressed = FeedService.compressImageForUpload(image) else {
                localError = "Photo is too large after compression. Try another."
                clearPhoto()
                return
            }
            previewImage = image
            imageData = compressed
        } catch {
            localError = error.localizedDescription
        }
    }

    private func submit() async {
        localError = nil
        successMessage = nil
        guard let user = auth.currentUser else {
            localError = FeedServiceError.signInRequired.localizedDescription
            return
        }
        guard canSubmit else {
            localError = FeedServiceError.emptyPost.localizedDescription
            return
        }

        do {
            try await feed.createPost(
                authorId: user.id,
                authorName: auth.displayName,
                authorRole: auth.communityRole,
                body: bodyText,
                linkText: linkText,
                imageJPEGData: imageData
            )
            successMessage = "Posted."
            dismiss()
        } catch {
            // feed.postError already set
        }
    }
}

#Preview {
    ComposePostView()
        .environment(AuthService())
        .environment(FeedStore())
}

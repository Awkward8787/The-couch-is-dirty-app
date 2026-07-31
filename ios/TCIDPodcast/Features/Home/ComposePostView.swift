import AVFoundation
import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

private struct PickedFeedVideo: Transferable {
    let url: URL

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { video in
            SentTransferredFile(video.url)
        } importing: { received in
            let destination = FileManager.default.temporaryDirectory
                .appendingPathComponent("feed-video-\(UUID().uuidString).mov")
            if FileManager.default.fileExists(atPath: destination.path) {
                try FileManager.default.removeItem(at: destination)
            }
            try FileManager.default.copyItem(at: received.file, to: destination)
            return Self(url: destination)
        }
    }
}

struct ComposePostView: View {
    @Environment(AuthService.self) private var auth
    @Environment(FeedStore.self) private var feed
    @Environment(\.dismiss) private var dismiss

    @State private var bodyText = ""
    @State private var linkText = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedVideo: PhotosPickerItem?
    @State private var previewImage: UIImage?
    @State private var imageData: Data?
    @State private var videoPreviewImage: UIImage?
    @State private var videoUpload: FeedVideoValidator.ValidatedVideo?
    @State private var localError: String?
    @State private var successMessage: String?
    @State private var isProcessingVideo = false
    @FocusState private var focused: Field?

    private enum Field {
        case body
        case link
    }

    private var canSubmit: Bool {
        let hasBody = !bodyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasLink = !linkText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasImage = imageData != nil
        let hasVideo = videoUpload != nil
        return (hasBody || hasLink || hasImage || hasVideo) && !feed.isPosting && !isProcessingVideo
    }

    var body: some View {
        NavigationStack {
            ZStack {
                TCIDColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: TCIDSpacing.lg) {
                        Text("What’s on your mind?")
                            .font(TCIDTypography.title)
                            .foregroundStyle(TCIDColors.textPrimary)

                        Text("Share text, a link, a photo, or a short vertical clip — up to 60 seconds (MP4/MOV, max 30 MB).")
                            .font(TCIDTypography.caption)
                            .foregroundStyle(TCIDColors.textSecondary)

                        TextField("What’s on your mind?", text: $bodyText, axis: .vertical)
                            .lineLimit(4...8)
                            .padding(TCIDSpacing.md)
                            .background(TCIDColors.surfaceElevated)
                            .overlay(
                                RoundedRectangle(cornerRadius: TCIDRadius.md)
                                    .stroke(TCIDColors.border, lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.md))
                            .focused($focused, equals: .body)

                        HStack {
                            TextField("Website or YouTube link (optional)", text: $linkText)
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
                        .background(TCIDColors.surfaceElevated)
                        .overlay(
                            RoundedRectangle(cornerRadius: TCIDRadius.md)
                                .stroke(TCIDColors.border, lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.md))

                        mediaPickers

                        if let previewImage {
                            photoPreview(previewImage)
                        }

                        if let videoPreviewImage, let videoUpload {
                            videoPreview(videoPreviewImage, duration: videoUpload.durationSeconds)
                        }

                        if isProcessingVideo {
                            ProgressView("Checking video…")
                                .tint(TCIDColors.accent)
                                .font(TCIDTypography.caption)
                                .foregroundStyle(TCIDColors.textSecondary)
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

                        TCIDPrimaryButton(title: feed.isPosting ? "Posting…" : "Post") {
                            Task { await submit() }
                        }
                        .disabled(!canSubmit)
                        .opacity(canSubmit ? 1 : 0.5)
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

    private var mediaPickers: some View {
        VStack(spacing: TCIDSpacing.sm) {
            PhotosPicker(selection: $selectedVideo, matching: .videos) {
                Label(
                    videoUpload == nil ? "Add short video (≤60 sec)" : "Change video",
                    systemImage: "video.fill"
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
            .disabled(videoUpload != nil && isProcessingVideo)
            .onChange(of: selectedVideo) { _, item in
                Task { await loadVideo(item) }
            }

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
            .disabled(videoUpload != nil)
            .onChange(of: selectedPhoto) { _, item in
                Task { await loadPhoto(item) }
            }
        }
    }

    @ViewBuilder
    private func photoPreview(_ image: UIImage) -> some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
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

    @ViewBuilder
    private func videoPreview(_ image: UIImage, duration: Int) -> some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .aspectRatio(9 / 16, contentMode: .fit)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.md))
                .overlay(alignment: .bottomLeading) {
                    Text(formatDuration(duration))
                        .font(TCIDTypography.micro.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.black.opacity(0.55))
                        .clipShape(Capsule())
                        .padding(TCIDSpacing.sm)
                }

            Button {
                clearVideo()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .padding(8)
            }
            .accessibilityLabel("Remove video")
        }
    }

    private func clearPhoto() {
        selectedPhoto = nil
        previewImage = nil
        imageData = nil
    }

    private func clearVideo() {
        selectedVideo = nil
        videoPreviewImage = nil
        videoUpload = nil
    }

    private func loadPhoto(_ item: PhotosPickerItem?) async {
        localError = nil
        guard let item else { return }
        clearVideo()
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

    private func loadVideo(_ item: PhotosPickerItem?) async {
        localError = nil
        guard let item else { return }
        clearPhoto()
        isProcessingVideo = true
        defer { isProcessingVideo = false }

        do {
            guard let picked = try await item.loadTransferable(type: PickedFeedVideo.self) else {
                localError = FeedServiceError.invalidVideo.localizedDescription
                return
            }
            let validated = try await FeedVideoValidator.validate(fileURL: picked.url)
            videoUpload = validated
            videoPreviewImage = try await generateThumbnail(for: picked.url)
        } catch let error as FeedServiceError {
            localError = error.localizedDescription
            clearVideo()
        } catch {
            localError = error.localizedDescription
            clearVideo()
        }
    }

    private func generateThumbnail(for url: URL) async throws -> UIImage {
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 0.5, preferredTimescale: 600)
        let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
        return UIImage(cgImage: cgImage)
    }

    private func formatDuration(_ seconds: Int) -> String {
        String(format: "0:%02d", min(seconds, 60))
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
                authorAvatarFileId: auth.userProfile?.avatarFileId,
                body: bodyText,
                linkText: linkText,
                imageJPEGData: imageData,
                videoUpload: videoUpload
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

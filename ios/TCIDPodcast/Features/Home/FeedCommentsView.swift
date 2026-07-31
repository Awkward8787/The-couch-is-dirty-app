import SwiftUI

struct FeedCommentsView: View {
    @Environment(AuthService.self) private var auth
    @Environment(\.dismiss) private var dismiss

    let post: FeedPost

    @State private var comments: [FeedComment] = []
    @State private var draft = ""
    @State private var isLoading = false
    @State private var isSending = false
    @State private var error: String?
    @State private var showsLogin = false
    @State private var actionMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                TCIDColors.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    if isLoading && comments.isEmpty {
                        ProgressView()
                            .tint(TCIDColors.accent)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let error, comments.isEmpty {
                        Text(error)
                            .font(TCIDTypography.caption)
                            .foregroundStyle(TCIDColors.destructive)
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if comments.isEmpty {
                        Text("No comments yet. Start the conversation.")
                            .font(TCIDTypography.caption)
                            .foregroundStyle(TCIDColors.textSecondary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(comments) { comment in
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(comment.authorName)
                                            .font(TCIDTypography.caption.weight(.semibold))
                                            .foregroundStyle(TCIDColors.textPrimary)
                                        Spacer()
                                        Text(comment.createdAt, style: .relative)
                                            .font(.caption2)
                                            .foregroundStyle(TCIDColors.textSecondary)
                                    }
                                    Text(comment.body)
                                        .font(TCIDTypography.body)
                                        .foregroundStyle(TCIDColors.textPrimary)
                                }
                                .listRowBackground(TCIDColors.card)
                                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                    if comment.authorId != auth.currentUser?.id {
                                        Button {
                                            Task { await report(comment) }
                                        } label: {
                                            Label("Report", systemImage: "flag")
                                        }
                                        .tint(.orange)
                                    }
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    if comment.authorId == auth.currentUser?.id || auth.communityRole.canModerate {
                                        Button(role: .destructive) {
                                            Task { await delete(comment) }
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        }
                        .scrollContentBackground(.hidden)
                    }

                    composer

                    if let actionMessage {
                        Text(actionMessage)
                            .font(TCIDTypography.caption)
                            .foregroundStyle(TCIDColors.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, TCIDSpacing.md)
                            .padding(.bottom, TCIDSpacing.sm)
                    }
                }
            }
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showsLogin) {
                LoginView()
            }
            .task {
                await load()
            }
        }
    }

    private var composer: some View {
        HStack(spacing: TCIDSpacing.sm) {
            TextField("Write a comment…", text: $draft, axis: .vertical)
                .lineLimit(1...4)
                .padding(TCIDSpacing.sm)
                .background(TCIDColors.card)
                .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.md))

            Button {
                Task { await send() }
            } label: {
                if isSending {
                    ProgressView().tint(TCIDColors.accent)
                } else {
                    Image(systemName: "paperplane.fill")
                        .foregroundStyle(TCIDColors.accent)
                }
            }
            .disabled(isSending || draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .frame(width: TCIDSpacing.touchTarget, height: TCIDSpacing.touchTarget)
        }
        .padding(TCIDSpacing.md)
        .background(TCIDColors.surfaceElevated)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(TCIDColors.separator)
                .frame(height: 1)
        }
    }

    private func load() async {
        isLoading = true
        error = nil
        defer { isLoading = false }
        do {
            comments = try await FeedService.fetchComments(postId: post.id)
        } catch {
            self.error = error.localizedDescription
        }
    }

    private func send() async {
        guard auth.isAuthenticated, let user = auth.currentUser else {
            showsLogin = true
            return
        }
        isSending = true
        defer { isSending = false }
        do {
            let created = try await FeedService.createComment(
                postId: post.id,
                authorId: user.id,
                authorName: auth.displayName,
                body: draft
            )
            comments.insert(created, at: 0)
            draft = ""
        } catch {
            self.error = error.localizedDescription
        }
    }

    private func delete(_ comment: FeedComment) async {
        do {
            try await FeedService.deleteComment(commentId: comment.id)
            comments.removeAll { $0.id == comment.id }
        } catch {
            self.error = error.localizedDescription
        }
    }

    private func report(_ comment: FeedComment) async {
        guard auth.isAuthenticated else {
            showsLogin = true
            return
        }
        do {
            try await FeedService.reportComment(commentId: comment.id)
            actionMessage = "Report received. Moderators will review."
        } catch {
            actionMessage = error.localizedDescription
        }
    }
}

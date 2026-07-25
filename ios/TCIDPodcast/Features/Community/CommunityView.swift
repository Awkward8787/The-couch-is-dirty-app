import SwiftUI

struct CommunityView: View {
    @State private var selectedFilter: CommunityFilter = .hot

    var body: some View {
        TCIDScreenContainer {
            ScrollView {
                VStack(alignment: .leading, spacing: TCIDSpacing.lg) {
                    TCIDAppHeader()

                    VStack(alignment: .leading, spacing: TCIDSpacing.xs) {
                        Text("Community")
                            .font(TCIDTypography.largeTitle)
                            .foregroundStyle(TCIDColors.textPrimary)
                        Text("Real fans. Real talk. No filter.")
                            .font(TCIDTypography.body)
                            .foregroundStyle(TCIDColors.textSecondary)
                    }
                    .padding(.horizontal, TCIDSpacing.md)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: TCIDSpacing.sm) {
                            ForEach(CommunityFilter.allCases) { filter in
                                TCIDFilterChip(
                                    title: filter.rawValue,
                                    isSelected: selectedFilter == filter,
                                    systemImage: filter.systemImage
                                ) {
                                    selectedFilter = filter
                                }
                            }
                        }
                        .padding(.horizontal, TCIDSpacing.md)
                    }

                    ComposeDiscussionPrompt()
                        .padding(.horizontal, TCIDSpacing.md)

                    VStack(alignment: .leading, spacing: TCIDSpacing.md) {
                        TCIDSectionHeader(title: "Featured Discussions", actionTitle: "See All") {}
                        ForEach(MockDataService.communityDiscussions) { discussion in
                            CommunityDiscussionCard(discussion: discussion)
                        }
                    }
                    .padding(.horizontal, TCIDSpacing.md)

                    VStack(alignment: .leading, spacing: TCIDSpacing.md) {
                        TCIDSectionHeader(title: "Fan Comments", actionTitle: "See All") {}
                        FanCommentCard(comment: MockDataService.fanComment)
                    }
                    .padding(.horizontal, TCIDSpacing.md)

                    VStack(alignment: .leading, spacing: TCIDSpacing.sm) {
                        TCIDSectionHeader(title: "Trending Questions", actionTitle: "See All") {}
                        ForEach(MockDataService.trendingQuestions, id: \.self) { question in
                            TrendingQuestionRow(question: question)
                        }
                    }
                    .padding(.horizontal, TCIDSpacing.md)
                    .padding(.bottom, TCIDSpacing.xl)
                }
            }
        }
    }
}

#Preview {
    CommunityView()
}

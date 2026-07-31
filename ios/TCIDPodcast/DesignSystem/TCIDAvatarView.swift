import SwiftUI

struct TCIDAvatarView: View {
    let imageURL: URL?
    let name: String
    var size: CGFloat = 40

    var body: some View {
        Group {
            if let imageURL {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        initialsView
                    case .empty:
                        ProgressView()
                            .tint(TCIDColors.accent)
                    @unknown default:
                        initialsView
                    }
                }
            } else {
                initialsView
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .accessibilityLabel("\(name) profile photo")
    }

    private var initialsView: some View {
        Circle()
            .fill(TCIDColors.cardElevated)
            .overlay {
                Text(String(name.prefix(1)).uppercased())
                    .font(.system(size: size * 0.38, weight: .bold))
                    .foregroundStyle(TCIDColors.textPrimary)
            }
    }
}

#Preview {
    HStack {
        TCIDAvatarView(imageURL: nil, name: "Anthony")
        TCIDAvatarView(imageURL: nil, name: "Silk", size: 88)
    }
    .padding()
    .background(TCIDColors.background)
}

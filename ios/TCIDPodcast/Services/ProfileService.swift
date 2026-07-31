import Appwrite
import AppwriteModels
import Foundation
import UIKit

enum ProfileService {
    static let maxAvatarBytes = 400_000
    static let maxAvatarDimension: CGFloat = 512

    static func fetchProfile(userId: String) async throws -> UserProfile? {
        do {
            let document = try await AppwriteClient.databases.getDocument(
                databaseId: AppConfig.appwriteDatabaseId,
                collectionId: AppwriteCollections.Collection.profiles,
                documentId: userId
            )
            return AppwriteDocumentMapping.profile(from: document, userId: userId)
        } catch {
            let message = error.localizedDescription.lowercased()
            if message.contains("not found") {
                return fallbackProfile(userId: userId)
            }
            throw error
        }
    }

    static func uploadAvatar(
        userId: String,
        image: UIImage,
        previousFileId: String?,
        displayName: String?
    ) async throws -> UserProfile {
        guard let imageData = compressAvatar(image) else {
            throw ProfileServiceError.imageProcessingFailed
        }

        if let previousFileId, !previousFileId.isEmpty {
            try? await AppwriteClient.storage.deleteFile(
                bucketId: AppwriteCollections.Bucket.avatars,
                fileId: previousFileId
            )
        }

        let file = InputFile.fromData(
            imageData,
            filename: "avatar-\(userId).jpg",
            mimeType: "image/jpeg"
        )

        let uploaded = try await AppwriteClient.storage.createFile(
            bucketId: AppwriteCollections.Bucket.avatars,
            fileId: ID.unique(),
            file: file,
            permissions: [
                Permission.read(Role.any()),
                Permission.update(Role.user(userId)),
                Permission.delete(Role.user(userId)),
            ]
        )

        try await upsertAvatarFileId(
            userId: userId,
            fileId: uploaded.id,
            displayName: displayName
        )

        return try await fetchProfile(userId: userId) ?? fallbackProfile(userId: userId)
    }

    static func compressAvatar(_ image: UIImage) -> Data? {
        let longest = max(image.size.width, image.size.height)
        let scale = longest > maxAvatarDimension ? maxAvatarDimension / longest : 1
        let targetSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let resized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }

        var quality: CGFloat = 0.82
        var data = resized.jpegData(compressionQuality: quality)
        while let current = data, current.count > maxAvatarBytes, quality > 0.4 {
            quality -= 0.08
            data = resized.jpegData(compressionQuality: quality)
        }

        guard let data, data.count <= maxAvatarBytes else { return nil }
        return data
    }

    private static func upsertAvatarFileId(
        userId: String,
        fileId: String,
        displayName: String?
    ) async throws {
        var data: [String: Any] = [
            "avatar_url": fileId,
            "account_status": AccountStatus.active.rawValue,
            "role": UserRole.user.rawValue,
        ]

        if let displayName, !displayName.isEmpty {
            data["display_name"] = displayName
        }

        do {
            _ = try await AppwriteClient.databases.updateDocument(
                databaseId: AppConfig.appwriteDatabaseId,
                collectionId: AppwriteCollections.Collection.profiles,
                documentId: userId,
                data: data
            )
        } catch {
            _ = try await AppwriteClient.databases.createDocument(
                databaseId: AppConfig.appwriteDatabaseId,
                collectionId: AppwriteCollections.Collection.profiles,
                documentId: userId,
                data: data,
                permissions: [
                    Permission.read(Role.any()),
                    Permission.update(Role.user(userId)),
                    Permission.delete(Role.user(userId)),
                ]
            )
        }
    }

    private static func fallbackProfile(userId: String) -> UserProfile {
        UserProfile(
            id: AppwriteDocumentMapping.documentUUID(userId),
            documentId: userId,
            username: nil,
            displayName: nil,
            bio: nil,
            avatarFileId: nil,
            avatarURL: nil,
            role: .user,
            accountStatus: .active
        )
    }
    static func deleteProfileDocument(userId: String) async {
        try? await AppwriteClient.databases.deleteDocument(
            databaseId: AppConfig.appwriteDatabaseId,
            collectionId: AppwriteCollections.Collection.profiles,
            documentId: userId
        )
    }
}

enum ProfileServiceError: LocalizedError {
    case signInRequired
    case imageProcessingFailed

    var errorDescription: String? {
        switch self {
        case .signInRequired:
            "Sign in to update your profile photo."
        case .imageProcessingFailed:
            "Could not process that photo. Try a smaller image."
        }
    }
}

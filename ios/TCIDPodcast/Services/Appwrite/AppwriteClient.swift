import Appwrite
import Foundation

/// Shared Appwrite client — no API keys; session cookies managed by the SDK.
@MainActor
enum AppwriteClient {
    static let shared: Client = {
        Client()
            .setEndpoint(AppConfig.appwriteEndpoint)
            .setProject(AppConfig.appwriteProjectId)
            // Self-hosted Appwrite gzip responses break AsyncHTTPClient/NIO
            // decompression (NIOHTTPDecompression.DecompressionError). Request
            // uncompressed JSON instead.
            .setCompression(false)
    }()

    static let account = Account(shared)
    static let databases = Databases(shared)
    static let storage = Storage(shared)
    static let teams = Teams(shared)
}

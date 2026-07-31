import AVKit
import SwiftUI
import WebKit

struct InAppVideoPlayer: View {
    let url: URL

    var body: some View {
        switch VideoLinkParser.classify(url) {
        case .youtube(let videoId):
            YouTubeEmbedPlayer(videoId: videoId)
                .frame(minHeight: 200)
                .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.md))
        case .directVideo(let videoURL):
            if videoURL.host?.contains("vimeo.com") == true || videoURL.path.contains("/video/") {
                WebEmbedPlayer(url: videoURL)
                    .frame(minHeight: 200)
                    .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.md))
            } else {
                DirectVideoPlayer(url: videoURL)
                    .frame(minHeight: 200)
                    .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.md))
            }
        case .unsupported:
            Link(destination: url) {
                Label(url.host ?? "Open link", systemImage: "link")
                    .font(TCIDTypography.caption)
                    .foregroundStyle(TCIDColors.accent)
            }
        }
    }
}

private struct DirectVideoPlayer: View {
    let url: URL
    @State private var player: AVPlayer?
    @State private var hasStarted = false

    var body: some View {
        ZStack {
            if let player, hasStarted {
                VideoPlayer(player: player)
            } else {
                Color.black
                    .overlay {
                        Button {
                            if player == nil {
                                player = AVPlayer(url: url)
                            }
                            hasStarted = true
                            player?.play()
                        } label: {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 56))
                                .foregroundStyle(.white)
                        }
                        .accessibilityLabel("Play video")
                    }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .onDisappear {
            player?.pause()
        }
    }
}

private struct YouTubeEmbedPlayer: UIViewRepresentable {
    let videoId: String

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = .all
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .black
        webView.scrollView.isScrollEnabled = false
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">
          <style>
            * { margin:0; padding:0; background:#000; }
            html, body { width:100%; height:100%; overflow:hidden; }
            iframe { position:absolute; inset:0; width:100%; height:100%; border:0; }
          </style>
        </head>
        <body>
          <iframe
            src="https://www.youtube-nocookie.com/embed/\(videoId)?playsinline=1&rel=0&modestbranding=1"
            allow="accelerometer; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
            allowfullscreen>
          </iframe>
        </body>
        </html>
        """
        webView.loadHTMLString(html, baseURL: URL(string: "https://www.youtube-nocookie.com"))
    }
}

private struct WebEmbedPlayer: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = .all
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .black
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.load(URLRequest(url: url))
    }
}

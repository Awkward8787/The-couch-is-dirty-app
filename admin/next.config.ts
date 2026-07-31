import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  reactStrictMode: true,
  images: {
    remotePatterns: [
      {
        protocol: "https",
        hostname: "media.rss.com",
      },
      {
        protocol: "https",
        hostname: "**.rss.com",
      },
      {
        protocol: "https",
        hostname: "api.tcidpodcast.com",
      },
    ],
  },
};

export default nextConfig;

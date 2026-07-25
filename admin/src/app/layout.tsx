import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "TCID Admin — The Couch Is Dirty Podcast",
  description: "Creator dashboard for The Couch Is Dirty Podcast",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}

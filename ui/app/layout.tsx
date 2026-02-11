import type { Metadata } from "next";
import {
  Inter as FontSans,
  Noto_Serif_JP as FontSerif,
} from "next/font/google";
import "./globals.css";
import { cn } from "@/lib/utils";

const fontSans = FontSans({
  subsets: ["latin"],
  variable: "--font-sans",
});

const fontSerif = FontSerif({
  subsets: ["latin"],
  weight: ["400", "700", "900"],
  variable: "--font-serif",
});

export const metadata: Metadata = {
  title: "Omikuji - 運命の書",
  description: "日本の伝統的なおみくじアプリ",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body
        className={cn(
          "min-h-screen bg-background font-sans antialiased",
          fontSans.variable,
          fontSerif.variable,
        )}
      >
        {children}
      </body>
    </html>
  );
}

import type { Metadata } from "next";
import {
  Cinzel as FontCinzel,
  Playfair_Display as FontPlayfair,
} from "next/font/google";
import "./globals.css";
import { cn } from "@/lib/utils";

const fontCinzel = FontCinzel({
  subsets: ["latin"],
  variable: "--font-cinzel",
});

const fontPlayfair = FontPlayfair({
  subsets: ["latin", "vietnamese"],
  variable: "--font-playfair",
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
          fontCinzel.variable,
          fontPlayfair.variable,
        )}
      >
        {children}
      </body>
    </html>
  );
}

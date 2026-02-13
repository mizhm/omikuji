"use client";

import { useState } from "react";
import OmikujiBox from "../components/omikuji-box";
import ResultModal from "../components/result-modal";
import { Omikuji } from "../types/omikuji";

export default function Home() {
  const [result, setResult] = useState<Omikuji | null>(null);
  const [isDrawing, setIsDrawing] = useState(false);


  const handleDraw = async () => {
    if (isDrawing) return;
    setIsDrawing(true);
    setResult(null);

    try {
      await new Promise((resolve) => setTimeout(resolve, 1000));

      const res = await fetch(`/api/proxy/api/v1/omikuji/draw`);

      if (!res.ok) throw new Error("API call failed");

      const data = await res.json();
      setResult(data);
    } catch (error) {
      console.error("おみくじエラー:", error);
      alert("神様との接続が切れました！ (APIを確認)");
    } finally {
      setIsDrawing(false);
    }
  };

  return (
    <main className="relative min-h-screen w-full flex flex-col items-center justify-center overflow-hidden px-4 py-12 md:py-16">
      {/* Elegant gradient background - Deep indigo to purple */}
      <div className="absolute inset-0 bg-gradient-to-br from-indigo-900 via-purple-900 to-pink-900" />

      {/* Warm golden light overlay */}
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_30%_50%,_rgba(251,191,36,0.12),transparent_60%)]" />
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_70%_80%,_rgba(236,72,153,0.08),transparent_50%)]" />

      {/* Main Content Container */}
      <div className="relative z-10 flex flex-col items-center gap-10 sm:gap-14 md:gap-16 max-w-5xl mx-auto w-full">
        {/* Header Section */}
        <div className="flex flex-col items-center gap-4 sm:gap-5">
          {/* Main Title */}
          <h1 className="text-6xl sm:text-7xl md:text-8xl lg:text-[7rem] font-serif font-black text-white drop-shadow-[0_4px_20px_rgba(0,0,0,0.3)] tracking-tight leading-none">
            おみくじ
          </h1>

          {/* Subtitle with decorative lines */}
          <div className="flex items-center gap-4 sm:gap-5">
            <div className="h-px w-12 sm:w-16 bg-gradient-to-r from-transparent to-white/40" />
            <p className="text-lg sm:text-xl md:text-2xl font-serif font-light text-white/95 tracking-[0.35em] uppercase">
              運命の書
            </p>
            <div className="h-px w-12 sm:w-16 bg-gradient-to-l from-transparent to-white/40" />
          </div>
        </div>

        {/* Omikuji Box Component */}
        <OmikujiBox onDraw={handleDraw} isDrawing={isDrawing} />

        {/* Instruction Text - Always render to reserve space, just toggle opacity */}
        <p
          className={`text-white/70 text-xs sm:text-sm font-medium tracking-wide transition-opacity duration-300 ${isDrawing ? "opacity-0" : "opacity-100"}`}
        >
          画像をタップして、今日の運勢を占おう
        </p>
      </div>

      {/* Result Modal */}
      {result && (
        <ResultModal
          data={result}
          onClose={() => setResult(null)}
        />
      )}
    </main>
  );
}

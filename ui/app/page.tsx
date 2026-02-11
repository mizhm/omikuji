"use client";

import { useState, useEffect } from "react";
import OmikujiBox from "../components/omikuji-box";
import ResultModal from "../components/result-modal";
import { Omikuji, ServerInfo } from "../types/omikuji";

export default function Home() {
  const [result, setResult] = useState<Omikuji | null>(null);
  const [isDrawing, setIsDrawing] = useState(false);
  const [frontendInfo, setFrontendInfo] = useState<ServerInfo | null>(null);

  useEffect(() => {
    fetch("/api/info")
      .then((res) => res.json())
      .then((data) => setFrontendInfo(data))
      .catch((err) => console.error("Failed to fetch frontend info", err));
  }, []);

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
    <main className="min-h-screen w-full bg-gradient-to-b from-red-950 via-red-900 to-black flex flex-col items-center justify-center relative overflow-hidden font-sans">
      <div className="absolute inset-0 opacity-20 bg-[url('https://www.transparenttextures.com/patterns/asfalt-dark.png')] mix-blend-overlay pointer-events-none"></div>
      <div className="absolute -top-20 -left-20 w-96 h-96 bg-red-600 rounded-full mix-blend-screen filter blur-[100px] opacity-20 animate-pulse"></div>

      <div className="z-10 text-center flex flex-col items-center gap-12">
        <div className="space-y-2">
          <h1 className="text-5xl md:text-7xl font-serif font-black text-[#fcfaf2] drop-shadow-lg tracking-tighter">
            おみくじ
          </h1>
          <p className="text-xl md:text-2xl font-serif font-light text-red-200 tracking-[0.5em] uppercase border-t border-red-800 pt-4 mt-2 inline-block">
            運命の書
          </p>
        </div>

        <OmikujiBox onDraw={handleDraw} isDrawing={isDrawing} />
      </div>

      {result && (
        <ResultModal
          data={result}
          frontendInfo={frontendInfo}
          onClose={() => setResult(null)}
        />
      )}
    </main>
  );
}

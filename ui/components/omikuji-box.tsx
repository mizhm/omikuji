"use client";

import { motion } from "framer-motion";
import Image from "next/image";

interface Props {
  onDraw: () => void;
  isDrawing: boolean;
  language: "ja" | "vi";
}

export default function OmikujiBox({ onDraw, isDrawing, language }: Props) {
  return (
    <div
      className="relative flex flex-col items-center justify-center cursor-pointer group select-none"
      onClick={!isDrawing ? onDraw : undefined}
    >
      {/* Subtle glow effect behind box */}
      <div className="absolute inset-0 bg-secondary/10 rounded-full blur-3xl scale-90 group-hover:scale-100 transition-transform duration-500" />

      {/* Box Image - No frame for realistic look */}
      <motion.div
        className="relative z-10"
        animate={
          isDrawing
            ? {
                x: [-10, 10, -10, 10, -8, 8, -5, 5, 0],
                rotate: [-4, 4, -4, 4, -3, 3, -2, 2, 0],
              }
            : {
                y: [0, -10, 0],
                rotate: [0, 2, -2, 0],
              }
        }
        transition={
          isDrawing
            ? {
                duration: 0.5,
                repeat: Infinity,
                ease: "easeInOut",
              }
            : {
                duration: 4,
                repeat: Infinity,
                ease: "easeInOut",
              }
        }
        whileHover={!isDrawing ? { scale: 1.08, y: -12 } : undefined}
        whileTap={!isDrawing ? { scale: 0.98 } : undefined}
        style={{ willChange: "transform" }}
      >
        <div className="relative w-48 h-48 sm:w-56 sm:h-56 md:w-64 md:h-64 drop-shadow-[0_20px_40px_rgba(0,0,0,0.4)] group-hover:drop-shadow-[0_25px_50px_rgba(0,0,0,0.5)] transition-all duration-300">
          <Image
            src="/images/omikuji.png"
            alt="Omikuji Box"
            fill
            className="object-contain"
            priority
          />
        </div>
      </motion.div>

      {/* Action Text */}
      <motion.div
        className="mt-8 md:mt-10 px-6 py-3 rounded-full bg-white/15 backdrop-blur-lg border border-white/25 shadow-lg"
        animate={{
          opacity: [0.8, 1, 0.8],
        }}
        transition={{ duration: 2.5, repeat: Infinity, ease: "easeInOut" }}
      >
        <p className="text-white font-serif tracking-[0.25em] text-sm sm:text-base md:text-lg uppercase font-semibold">
          {language === "ja"
            ? isDrawing
              ? "振っています..."
              : "タップして引く"
            : isDrawing
              ? "Đang gieo quẻ..."
              : "Chạm để gieo quẻ"}
        </p>
      </motion.div>
    </div>
  );
}

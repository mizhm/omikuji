"use client";

import { motion, Variants } from "framer-motion";
import Image from "next/image";

interface Props {
  onDraw: () => void;
  isDrawing: boolean;
}

export default function OmikujiBox({ onDraw, isDrawing }: Props) {
  // Animation rung lắc dữ dội
  const shakeVariants: Variants = {
    idle: {
      y: [0, -5, 0],
      rotate: [0, 1, -1, 0],
      transition: {
        duration: 3,
        repeat: Infinity,
        ease: "easeInOut",
      },
    },
    shaking: {
      x: [-5, 5, -5, 5, -5, 5, 0],
      rotate: [-2, 2, -2, 2, 0],
      transition: {
        duration: 0.1,
        repeat: Infinity,
      },
    },
  };

  return (
    <div
      className="relative flex flex-col items-center justify-center cursor-pointer group select-none"
      onClick={!isDrawing ? onDraw : undefined}
    >
      {/* Box Image */}
      <motion.div
        className="relative z-10 w-48 md:w-64 drop-shadow-2xl"
        variants={shakeVariants}
        animate={isDrawing ? "shaking" : "idle"}
        whileHover={{ scale: 1.02 }}
        whileTap={{ scale: 0.98 }}
      >
        <Image
          src="/images/omikuji.png"
          alt="Omikuji Box"
          width={300}
          height={400}
          className="object-contain"
          priority
        />
      </motion.div>

      <motion.p
        className="mt-8 text-white/90 font-serif tracking-[0.2em] text-lg uppercase bg-black/20 px-4 py-2 rounded-full backdrop-blur-sm"
        animate={{ opacity: [0.5, 1, 0.5] }}
        transition={{ duration: 2, repeat: Infinity }}
      >
        {isDrawing ? "振っています..." : "おみくじを引く"}
      </motion.p>
    </div>
  );
}

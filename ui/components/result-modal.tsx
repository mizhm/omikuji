"use client";

import { motion, AnimatePresence } from "framer-motion";
import { Omikuji } from "@/types/omikuji";
import { X, Sparkles, Palette, Hash, Compass, Gift } from "lucide-react";
import { Card, CardFooter, CardHeader } from "@/components/ui/card";
import { Separator } from "@/components/ui/separator";
import { Button } from "@/components/ui/button";

interface Props {
  data: Omikuji | null;
  onClose: () => void;
  language: "ja" | "vi";
}

const CATEGORY_MAP: Record<string, { ja: string; vi: string }> = {
  wish: { ja: "願望", vi: "Cầu nguyện" },
  waiting_person: { ja: "待人", vi: "Người đi xa" },
  lost_item: { ja: "失物", vi: "Đồ thất lạc" },
  travel: { ja: "旅行", vi: "Xuất hành" },
  business: { ja: "商売", vi: "Kinh doanh" },
  study: { ja: "学問", vi: "Học hành" },
  market_speculation: { ja: "相場", vi: "Đầu tư" },
  dispute: { ja: "争事", vi: "Tranh chấp" },
  romance: { ja: "恋愛", vi: "Tình duyên" },
  moving: { ja: "転居", vi: "Chuyển nhà" },
  childbirth: { ja: "お産", vi: "Sinh nở" },
  illness: { ja: "病気", vi: "Bệnh tật" },
  marriage_proposal: { ja: "縁談", vi: "Hôn nhân" },
};

const LUCK_TRANSLATION: Record<string, string> = {
  大吉: "Đại Cát",
  中吉: "Trung Cát",
  小吉: "Tiểu Cát",
  吉: "Cát",
  半吉: "Bán Cát",
  末吉: "Mạt Cát",
  末小吉: "Mạt Tiểu Cát",
  凶: "Hung",
  小凶: "Tiểu Hung",
  半凶: "Bán Hung",
  末凶: "Mạt Hung",
  大凶: "Đại Hung",
};

export default function ResultModal({ data, onClose, language }: Props) {
  if (!data) return null;

  return (
    <AnimatePresence>
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4 sm:p-6"
        onClick={onClose}
      >
        <motion.div
          initial={{ scale: 0.95, opacity: 0, y: 20 }}
          animate={{ scale: 1, opacity: 1, y: 0 }}
          exit={{ scale: 0.95, opacity: 0, y: 20 }}
          transition={{
            type: "spring",
            damping: 25,
            stiffness: 300,
          }}
          className="w-full max-w-lg md:max-w-4xl lg:max-w-5xl max-h-[90vh] flex flex-col"
          onClick={(e) => e.stopPropagation()}
        >
          {/* Main Card */}
          <Card className="relative w-full flex flex-col overflow-hidden border-0 shadow-2xl rounded-2xl bg-white">
            {/* Background decorative elements */}
            <div className="absolute top-0 left-0 right-0 h-32 bg-gradient-to-b from-purple-50 to-transparent pointer-events-none" />
            <div className="absolute -top-10 -right-10 w-40 h-40 bg-indigo-100 rounded-full blur-3xl opacity-50 pointer-events-none" />
            <div className="absolute -bottom-10 -left-10 w-40 h-40 bg-pink-100 rounded-full blur-3xl opacity-50 pointer-events-none" />

            {/* Close Button */}
            <div className="absolute right-3 top-3 z-20">
              <Button
                variant="ghost"
                size="icon"
                onClick={onClose}
                className="h-8 w-8 rounded-full bg-white/50 backdrop-blur-md hover:bg-slate-100 text-slate-500 transition-colors"
                aria-label="Close"
              >
                <X className="h-4 w-4" />
              </Button>
            </div>

            {/* Header: Omikuji Number & Luck Level */}
            <CardHeader className="relative text-center pb-2 pt-8 px-6 space-y-3 flex-shrink-0 z-10">
              <div className="inline-flex items-center justify-center px-3 py-1 bg-indigo-50 rounded-full border border-indigo-100 mx-auto">
                <span className="font-serif text-indigo-800/80 text-xs tracking-[0.2em] uppercase font-semibold">
                  {data.omikuji_number}
                </span>
              </div>

              <div className="space-y-1">
                <h2 className="font-serif text-5xl sm:text-6xl font-black bg-gradient-to-br from-indigo-600 via-purple-600 to-pink-500 bg-clip-text text-transparent drop-shadow-sm py-2 leading-none">
                  {data.luck_level}
                </h2>
                {language === "vi" && (
                  <p className="text-sm font-medium text-slate-400 tracking-widest uppercase">
                    {LUCK_TRANSLATION[data.luck_level] || data.luck_level}
                  </p>
                )}
              </div>
            </CardHeader>

            {/* Scrollable Content Area */}
            <div className="flex-1 overflow-y-auto px-6 py-2 z-10 custom-scrollbar">
              <div className="md:grid md:grid-cols-12 md:gap-8 pb-6 space-y-6 md:space-y-0">
                {/* Left Column: Poem & Advice (md:col-span-5) */}
                <div className="md:col-span-5 space-y-6">
                  {/* Poem Section */}
                  <div className="relative bg-gradient-to-br from-indigo-50/50 to-purple-50/30 border border-indigo-100/50 p-6 rounded-xl text-center shadow-sm">
                    <Sparkles className="absolute top-3 left-3 text-indigo-300 w-4 h-4 opacity-60" />
                    <Sparkles className="absolute bottom-3 right-3 text-purple-300 w-4 h-4 opacity-60" />

                    <p className="font-serif text-lg sm:text-xl font-bold text-slate-800 leading-relaxed mb-3">
                      &quot;{data.poem.text[language]}&quot;
                    </p>
                    <p className="text-sm text-slate-500 leading-relaxed">
                      {data.poem.meaning[language]}
                    </p>
                  </div>

                  {/* General Advice */}
                  <div className="text-center px-4 py-3 rounded-lg bg-slate-50/50 border border-slate-100/50">
                    <p className="text-sm font-medium text-slate-600 leading-loose italic">
                      {data.general_advice[language]}
                    </p>
                  </div>

                  {/* Mobile Separator (Hidden on Desktop) */}
                  <Separator className="bg-slate-100 md:hidden" />
                </div>

                {/* Right Column: Categories Grid (md:col-span-7) */}
                <div className="md:col-span-7">
                  <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3 h-full content-start">
                    {Object.entries(data.categories).map(([key, value]) => (
                      <div
                        key={key}
                        className="flex flex-col p-3 rounded-lg bg-slate-50 border border-slate-100 hover:border-indigo-200 transition-colors hover:shadow-sm"
                      >
                        <span className="text-[10px] uppercase font-bold text-indigo-400 tracking-wider mb-1">
                          {CATEGORY_MAP[key]?.[language] || key}
                        </span>
                        <span className="text-sm text-slate-700 font-medium line-clamp-2">
                          {value[language]}
                        </span>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            </div>

            {/* Footer: Lucky Items - Redesigned */}
            <CardFooter className="bg-slate-50/80 backdrop-blur-sm border-t border-slate-100 p-4 z-10">
              <div className="grid grid-cols-2 sm:grid-cols-4 gap-2 w-full">
                {/* Lucky Color */}
                <div className="flex flex-col items-center justify-center p-2 rounded-lg bg-white border border-slate-100 shadow-sm">
                  <div className="flex items-center gap-1.5 mb-1 text-indigo-500">
                    <Palette className="w-3.5 h-3.5" />
                    <span className="text-[10px] font-bold uppercase tracking-wide">
                      {language === "ja" ? "色" : "Màu"}
                    </span>
                  </div>
                  <span className="text-xs font-semibold text-slate-700 text-center line-clamp-1">
                    {data.lucky_data.color[language]}
                  </span>
                </div>

                {/* Lucky Number */}
                <div className="flex flex-col items-center justify-center p-2 rounded-lg bg-white border border-slate-100 shadow-sm">
                  <div className="flex items-center gap-1.5 mb-1 text-purple-500">
                    <Hash className="w-3.5 h-3.5" />
                    <span className="text-[10px] font-bold uppercase tracking-wide">
                      {language === "ja" ? "数" : "Số"}
                    </span>
                  </div>
                  <span className="text-xs font-semibold text-slate-700 text-center">
                    {data.lucky_data.number}
                  </span>
                </div>

                {/* Lucky Direction */}
                <div className="flex flex-col items-center justify-center p-2 rounded-lg bg-white border border-slate-100 shadow-sm">
                  <div className="flex items-center gap-1.5 mb-1 text-pink-500">
                    <Compass className="w-3.5 h-3.5" />
                    <span className="text-[10px] font-bold uppercase tracking-wide">
                      {language === "ja" ? "方角" : "Hướng"}
                    </span>
                  </div>
                  <span className="text-xs font-semibold text-slate-700 text-center line-clamp-1">
                    {data.lucky_data.direction[language]}
                  </span>
                </div>

                {/* Lucky Item */}
                <div className="flex flex-col items-center justify-center p-2 rounded-lg bg-white border border-slate-100 shadow-sm">
                  <div className="flex items-center gap-1.5 mb-1 text-amber-500">
                    <Gift className="w-3.5 h-3.5" />
                    <span className="text-[10px] font-bold uppercase tracking-wide">
                      {language === "ja" ? "物" : "Vật"}
                    </span>
                  </div>
                  <span className="text-xs font-semibold text-slate-700 text-center line-clamp-1">
                    {data.lucky_data.item[language]}
                  </span>
                </div>
              </div>
            </CardFooter>
          </Card>
        </motion.div>
      </motion.div>
    </AnimatePresence>
  );
}

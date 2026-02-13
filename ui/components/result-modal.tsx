"use client";

import { motion, AnimatePresence } from "framer-motion";
import { Omikuji } from "@/types/omikuji";
import { X, Sparkles } from "lucide-react";
import {
  Card,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Separator } from "@/components/ui/separator";
import { ScrollArea } from "@/components/ui/scroll-area";
import { Button } from "@/components/ui/button";

interface Props {
  data: Omikuji | null;
  onClose: () => void;
}

const CATEGORY_MAP: Record<string, string> = {
  wish: "願望",
  waiting_person: "待人",
  lost_item: "失物",
  travel: "旅行",
  business: "商売",
  study: "学問",
  market_speculation: "相場",
  dispute: "争事",
  romance: "恋愛",
  moving: "転居",
  childbirth: "お産",
  illness: "病気",
  marriage_proposal: "縁談",
};

export default function ResultModal({ data, onClose }: Props) {
  if (!data) return null;

  return (
    <AnimatePresence>
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        className="fixed inset-0 z-50 flex items-center justify-center bg-gradient-to-br from-indigo-950/90 via-purple-950/90 to-pink-950/90 backdrop-blur-md p-2 sm:p-4"
        onClick={onClose}
      >
        <motion.div
          initial={{ scale: 0.9, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          exit={{ scale: 0.9, opacity: 0 }}
          transition={{
            type: "spring",
            damping: 30,
            stiffness: 300,
            bounce: 0.2,
          }}
          className="w-full max-w-2xl max-h-[90vh] flex"
          onClick={(e) => e.stopPropagation()}
        >
          {/* Main Card */}
          <Card className="relative w-full flex flex-col overflow-hidden border-0 bg-gradient-to-br from-card via-card to-muted shadow-2xl">
            {/* Decorative gradient overlay on top */}
            {/* <div className="absolute top-0 left-0 right-0 h-32 bg-gradient-to-b from-primary/5 to-transparent pointer-events-none" /> */}

            {/* Close Button */}
            <div className="absolute right-2 top-2 z-10">
              <Button
                variant="ghost"
                size="icon"
                onClick={onClose}
                className="h-8 w-8 rounded-full bg-background/80 backdrop-blur-sm hover:bg-destructive/10 hover:text-destructive border border-border/50"
              >
                <X className="h-4 w-4" />
              </Button>
            </div>

            {/* Header: Omikuji Number & Luck Level */}
            <CardHeader className="text-center pb-3 pt-4 sm:pt-6 space-y-2 flex-shrink-0">
              <CardDescription className="font-serif text-indigo-900/60 text-xs sm:text-sm tracking-[0.3em] uppercase font-semibold">
                {data.omikuji_number}
              </CardDescription>
              <CardTitle className="font-serif text-3xl sm:text-4xl md:text-5xl font-black bg-gradient-to-br from-indigo-600 via-purple-600 to-pink-500 bg-clip-text text-transparent drop-shadow-sm">
                {data.luck_level}
              </CardTitle>
            </CardHeader>

            {/* Scrollable Content Area */}
            <div className="flex-1 overflow-y-auto px-3 sm:px-6">
              <div className="space-y-4 sm:space-y-5 pb-4">
                {/* Poem Section - Premium Highlight */}
                <div className="relative bg-gradient-to-br from-indigo-50 via-purple-50 to-transparent border border-indigo-100 p-4 sm:p-5 rounded-2xl shadow-sm overflow-hidden">
                  {/* Decorative sparkles */}
                  <Sparkles className="absolute top-2 left-2 text-indigo-400 w-4 h-4 opacity-40 animate-pulse" />
                  <Sparkles className="absolute bottom-2 right-2 text-purple-400 w-4 h-4 opacity-40 animate-pulse" />

                  <div className="relative space-y-2">
                    <p className="font-serif text-base sm:text-lg font-bold text-slate-800 leading-relaxed text-center">
                      &quot;{data.poem.text}&quot;
                    </p>
                    <p className="text-xs sm:text-sm text-slate-500 italic font-medium text-center px-2">
                      {data.poem.meaning}
                    </p>
                  </div>
                </div>

                {/* General Advice */}
                <div className="text-center px-2 sm:px-4 py-2.5 sm:py-3 rounded-xl bg-slate-50/80 border border-slate-100">
                  <p className="text-xs sm:text-sm font-medium text-slate-700 leading-relaxed">
                    {data.general_advice}
                  </p>
                </div>

                <Separator className="bg-slate-100" />

                {/* Categories Grid with ScrollArea */}
                <ScrollArea className="max-h-[200px] sm:max-h-[240px] w-full rounded-lg">
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-2.5 sm:gap-3 pr-3">
                    {Object.entries(data.categories).map(([key, value]) => (
                      <div
                        key={key}
                        className="flex flex-col gap-1 p-2.5 sm:p-3 rounded-lg bg-white border border-slate-100 hover:border-indigo-200 hover:shadow-sm transition-all duration-200"
                      >
                        <span className="text-[10px] sm:text-xs font-bold text-indigo-500 uppercase tracking-wider">
                          {CATEGORY_MAP[key] || key}
                        </span>
                        <span className="text-xs sm:text-sm text-slate-600 font-medium leading-snug">
                          {value}
                        </span>
                      </div>
                    ))}
                  </div>
                </ScrollArea>
              </div>
            </div>

            {/* Footer: Lucky Items */}
            <CardFooter className="bg-gradient-to-r from-indigo-500 via-purple-500 to-pink-500 p-4 sm:p-5 flex justify-center items-center flex-shrink-0">
              <div className="flex flex-wrap gap-2 justify-center w-full">
                <Badge
                  variant="outline"
                  className="bg-white/20 backdrop-blur-sm text-white border-white/30 px-3 py-1 font-medium tracking-wide"
                >
                  色: {data.lucky_data.color}
                </Badge>
                <Badge
                  variant="outline"
                  className="bg-white/20 backdrop-blur-sm text-white border-white/30 px-3 py-1 font-medium tracking-wide"
                >
                  数: {data.lucky_data.number}
                </Badge>
                <Badge
                  variant="outline"
                  className="bg-white/20 backdrop-blur-sm text-white border-white/30 px-3 py-1 font-medium tracking-wide"
                >
                  方角: {data.lucky_data.direction}
                </Badge>
                <Badge
                  variant="outline"
                  className="bg-white/20 backdrop-blur-sm text-white border-white/30 px-3 py-1 font-medium tracking-wide"
                >
                  物: {data.lucky_data.item}
                </Badge>
              </div>
            </CardFooter>
          </Card>
        </motion.div>
      </motion.div>
    </AnimatePresence>
  );
}

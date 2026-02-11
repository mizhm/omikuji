"use client";

import { motion, AnimatePresence } from "framer-motion";
import { Omikuji, ServerInfo } from "@/types/omikuji";
import { X, Sparkles, Server, MapPin, ShieldCheck } from "lucide-react";
import {
  Card,
  CardContent,
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
  frontendInfo: ServerInfo | null;
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

export default function ResultModal({ data, frontendInfo, onClose }: Props) {
  if (!data) return null;

  return (
    <AnimatePresence>
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-sm p-4"
        onClick={onClose}
      >
        <motion.div
          initial={{ scale: 0.8, rotateY: 90, opacity: 0 }}
          animate={{ scale: 1, rotateY: 0, opacity: 1 }}
          exit={{ scale: 0.8, opacity: 0 }}
          transition={{ type: "spring", damping: 20, stiffness: 100 }}
          className="w-full max-w-2xl perspective-1000"
          onClick={(e) => e.stopPropagation()}
        >
          {/* SHADCN CARD BẮT ĐẦU TỪ ĐÂY */}
          <Card className="relative w-full overflow-hidden border-4 border-red-800 bg-[#fcfaf2] shadow-2xl">
            {/* Nút đóng */}
            <div className="absolute right-2 top-2 z-10">
              <Button
                variant="ghost"
                size="icon"
                onClick={onClose}
                className="hover:bg-red-100 text-red-900"
              >
                <X className="h-6 w-6" />
              </Button>
            </div>

            {/* Header: Số quẻ & Mức độ may mắn */}
            <CardHeader className="text-center pb-2">
              <CardDescription className="font-serif text-red-700 text-lg tracking-widest uppercase">
                {data.omikuji_number}
              </CardDescription>
              <CardTitle className="font-serif text-5xl md:text-6xl font-black text-red-600 drop-shadow-sm">
                {data.luck_level}
              </CardTitle>
            </CardHeader>

            <CardContent className="space-y-6">
              {/* Bài thơ Waka - Highlight Box */}
              <div className="bg-red-50/50 border border-red-100 p-6 rounded-xl text-center relative overflow-hidden">
                <Sparkles className="absolute top-2 left-2 text-yellow-500 w-4 h-4 opacity-50" />
                <Sparkles className="absolute bottom-2 right-2 text-yellow-500 w-4 h-4 opacity-50" />
                <p className="font-serif text-xl font-bold text-gray-800 mb-2 leading-relaxed">
                  &quot;{data.poem.text}&quot;
                </p>
                <p className="text-sm text-gray-500 italic font-medium">
                  {data.poem.meaning}
                </p>
              </div>

              {/* Lời khuyên chung */}
              <p className="text-center font-medium text-gray-700 px-4">
                {data.general_advice}
              </p>

              <Separator className="bg-red-200" />

              {/* Grid chi tiết - Dùng ScrollArea nếu nội dung quá dài */}
              <ScrollArea className="h-[250px] pr-4 w-full rounded-md border border-red-100 bg-white/50 p-4">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-x-6 gap-y-4">
                  {Object.entries(data.categories).map(([key, value]) => (
                    <div
                      key={key}
                      className="flex flex-col border-b border-dashed border-gray-200 last:border-0 pb-2"
                    >
                      <span className="text-xs font-bold text-red-800 uppercase tracking-wider mb-1">
                        {CATEGORY_MAP[key] || key}
                      </span>
                      <span className="text-sm text-gray-700 font-serif leading-snug">
                        {value}
                      </span>
                    </div>
                  ))}
                </div>
              </ScrollArea>
            </CardContent>

            {/* Footer: Lucky Items */}
            <CardFooter className="bg-red-900 text-[#fcfaf2] p-4 flex justify-between items-center text-sm font-medium">
              <div className="flex flex-wrap gap-2 justify-center w-full">
                <Badge
                  variant="outline"
                  className="border-yellow-400 text-yellow-400 bg-red-950/50"
                >
                  色: {data.lucky_data.color}
                </Badge>
                <Badge
                  variant="outline"
                  className="border-yellow-400 text-yellow-400 bg-red-950/50"
                >
                  数: {data.lucky_data.number}
                </Badge>
                <Badge
                  variant="outline"
                  className="border-yellow-400 text-yellow-400 bg-red-950/50"
                >
                  方角: {data.lucky_data.direction}
                </Badge>
                <Badge
                  variant="outline"
                  className="border-yellow-400 text-yellow-400 bg-red-950/50"
                >
                  物: {data.lucky_data.item}
                </Badge>
              </div>
            </CardFooter>
            <Separator className="bg-red-800" />

            <div className="flex flex-col gap-3 py-2 w-full px-4">
              {/* Backend Info */}
              <div className="flex flex-col items-center gap-1 opacity-70 scale-90">
                <span className="text-[10px] font-bold text-red-900 uppercase tracking-widest opacity-50">
                  バックエンド
                </span>
                <div className="flex flex-wrap gap-2 justify-center">
                  <Badge
                    variant="outline"
                    className="border-red-400/30 text-red-900 bg-black/5"
                  >
                    <Server className="w-3 h-3 mr-1" />{" "}
                    {data.server_info.hostname}
                  </Badge>
                  <Badge
                    variant="outline"
                    className="border-red-400/30 text-red-900 bg-black/5"
                  >
                    <MapPin className="w-3 h-3 mr-1" />{" "}
                    {data.server_info.availability_zone}
                  </Badge>
                  <Badge
                    variant="outline"
                    className="border-red-400/30 text-red-900 bg-black/5"
                  >
                    <ShieldCheck className="w-3 h-3 mr-1" />{" "}
                    {data.server_info.private_ip}
                  </Badge>
                </div>
              </div>

              {/* Frontend Info */}
              {frontendInfo && (
                <div className="flex flex-col items-center gap-1 opacity-70 scale-90">
                  <span className="text-[10px] font-bold text-blue-900 uppercase tracking-widest opacity-50">
                    フロントエンド
                  </span>
                  <div className="flex flex-wrap gap-2 justify-center">
                    <Badge
                      variant="outline"
                      className="border-blue-400/30 text-blue-900 bg-blue-500/10"
                    >
                      <Server className="w-3 h-3 mr-1" />{" "}
                      {frontendInfo.hostname}
                    </Badge>
                    <Badge
                      variant="outline"
                      className="border-blue-400/30 text-blue-900 bg-blue-500/10"
                    >
                      <MapPin className="w-3 h-3 mr-1" />{" "}
                      {frontendInfo.availability_zone}
                    </Badge>
                    <Badge
                      variant="outline"
                      className="border-blue-400/30 text-blue-900 bg-blue-500/10"
                    >
                      <ShieldCheck className="w-3 h-3 mr-1" />{" "}
                      {frontendInfo.private_ip}
                    </Badge>
                  </div>
                </div>
              )}
            </div>
          </Card>
        </motion.div>
      </motion.div>
    </AnimatePresence>
  );
}

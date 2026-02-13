export interface BilingualString {
  ja: string;
  vi: string;
}

export interface Omikuji {
  id: number;
  omikuji_number: string;
  luck_level: string;
  poem: {
    text: BilingualString;
    meaning: BilingualString;
  };
  general_advice: BilingualString;
  categories: {
    wish: BilingualString;
    waiting_person: BilingualString;
    lost_item: BilingualString;
    travel: BilingualString;
    business: BilingualString;
    study: BilingualString;
    market_speculation: BilingualString;
    dispute: BilingualString;
    romance: BilingualString;
    moving: BilingualString;
    childbirth: BilingualString;
    illness: BilingualString;
    marriage_proposal: BilingualString;
  };
  lucky_data: {
    color: BilingualString;
    number: number;
    direction: BilingualString;
    item: BilingualString;
  };
}

export interface Omikuji {
  id: number;
  omikuji_number: string;
  luck_level: string;
  poem: {
    text: string;
    meaning: string;
  };
  general_advice: string;
  categories: {
    wish: string;
    waiting_person: string;
    lost_item: string;
    travel: string;
    business: string;
    study: string;
    market_speculation: string;
    dispute: string;
    romance: string;
    moving: string;
    childbirth: string;
    illness: string;
    marriage_proposal: string;
  };
  lucky_data: {
    color: string;
    number: number;
    direction: string;
    item: string;
  };
}

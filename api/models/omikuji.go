package models

type Omikuji struct {
	ID             int    `json:"id"`
	OmikujiNumber  string `json:"omikuji_number"`
	LuckLevel      string `json:"luck_level"`
	Poem           Poem   `json:"poem"`
	GeneralAdvice  string `json:"general_advice"`
	Categories     Categories `json:"categories"`
	LuckyData     LuckyData `json:"lucky_data"`
}

type Poem struct {
	Text   string `json:"text"`
	Meaning string `json:"meaning"`
}

type Categories struct {
	Wish             string `json:"wish"`
	WaitingPerson    string `json:"waiting_person"`
	LostItem         string `json:"lost_item"`
	Travel           string `json:"travel"`
	Business         string `json:"business"`
	Study            string `json:"study"`
	MarketSpeculation string `json:"market_speculation"`
	Dispute          string `json:"dispute"`
	Romance          string `json:"romance"`
	Moving           string `json:"moving"`
	Childbirth       string `json:"childbirth"`
	Illness          string `json:"illness"`
	MarriageProposal string `json:"marriage_proposal"`
}

type LuckyData struct {
	Color     string `json:"color"`
	Number    int    `json:"number"`
	Direction string `json:"direction"`
	Item      string `json:"item"`
}
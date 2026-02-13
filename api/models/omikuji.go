package models

type BilingualString struct {
	Ja string `json:"ja"`
	Vi string `json:"vi"`
}

type Omikuji struct {
	ID            int             `json:"id"`
	OmikujiNumber string          `json:"omikuji_number"`
	LuckLevel     string          `json:"luck_level"`
	Poem          Poem            `json:"poem"`
	GeneralAdvice BilingualString `json:"general_advice"`
	Categories    Categories      `json:"categories"`
	LuckyData     LuckyData       `json:"lucky_data"`
}

type Poem struct {
	Text    BilingualString `json:"text"`
	Meaning BilingualString `json:"meaning"`
}

type Categories struct {
	Wish              BilingualString `json:"wish"`
	WaitingPerson     BilingualString `json:"waiting_person"`
	LostItem          BilingualString `json:"lost_item"`
	Travel            BilingualString `json:"travel"`
	Business          BilingualString `json:"business"`
	Study             BilingualString `json:"study"`
	MarketSpeculation BilingualString `json:"market_speculation"`
	Dispute           BilingualString `json:"dispute"`
	Romance           BilingualString `json:"romance"`
	Moving            BilingualString `json:"moving"`
	Childbirth        BilingualString `json:"childbirth"`
	Illness           BilingualString `json:"illness"`
	MarriageProposal  BilingualString `json:"marriage_proposal"`
}

type LuckyData struct {
	Color     BilingualString `json:"color"`
	Number    int             `json:"number"`
	Direction BilingualString `json:"direction"`
	Item      BilingualString `json:"item"`
}
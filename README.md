# Omikuji - 運命の書 (おみくじアプリ)

日本のおみくじ体験をデジタルで再現したモダンなWebアプリケーションです。美しくデザインされたUIで、毎日の運勢を占うことができます。

## ✨ 特徴

- **リッチなUIアニメーション**: Framer Motionを使用した滑らかなアニメーション（おみくじ箱の揺れ、結果の表示など）。
- **詳細な運勢結果**: 大吉から凶まで、恋愛、商売、学問などのカテゴリーごとに詳細なアドバイスを提供。
- **ラッキーアイテム**: 毎日のラッキーカラー、ナンバー、方角、アイテムを表示。
- **サーバーメタデータ表示**: フロントエンド（Next.js）とバックエンド（Go）の実行インスタンス情報（ホスト名、IP、AZ）を表示（クラウドネイティブデモ用）。

## 🛠️ 技術スタック

### フロントエンド (UI)

- **Framework**: Next.js 14+ (App Router)
- **Language**: TypeScript
- **Styling**: Tailwind CSS, Shadcn UI
- **Animation**: Framer Motion
- **Icons**: Lucide React

### バックエンド (API)

- **Language**: Go (Golang)
- **Router**: Chi (Lightweight router)
- **Data**: JSON base storage (`data/omikuji.json`)

## 🚀 始め方

前提条件:

- [Node.js](https://nodejs.org/) (v18以上推奨)
- [Bun](https://bun.sh/) (または npm/yarn/pnpm)
- [Go](https://go.dev/) (v1.20以上推奨)

### 1. リポジトリのクローン

```bash
git clone https://github.com/yourusername/omikuji.git
cd omikuji
```

### 2. バックエンドの起動

```bash
cd api
go mod tidy
go run main.go
```

サーバーは `http://localhost:8080` で起動します。

### 3. フロントエンドの起動

別のターミナルを開いて実行してください。

```bash
cd ui
bun install
bun dev
```

ブラウザで `http://localhost:3000` にアクセスしてください。

## 📁 プロジェクト構成

```
.
├── api/          # Go バックエンド
│   ├── data/     # おみくじデータ (JSON)
│   ├── handlers/ # APIハンドラー
│   └── main.go   # エントリーポイント
└── ui/           # Next.js フロントエンド
    ├── app/      # App Router
    └── components/ # UIコンポーネント
```

## 📝 ライセンス

MIT License

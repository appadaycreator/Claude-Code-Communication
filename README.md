# 🤖 Claude Code エージェント通信システム

複数のAIが協力して働く、まるで会社のような開発システムです

## 📌 これは何？

**3行で説明すると：**
1. 複数のAIエージェント（社長・マネージャー・作業者）が協力して開発
2. それぞれ異なるターミナル画面で動作し、メッセージを送り合う
3. 人間の組織のように役割分担して、効率的に開発を進める

**実際の成果：**
- 3時間で完成したアンケートシステム（EmotiFlow）
- 12個の革新的アイデアを生成
- 100%のテストカバレッジ

## 🎬 5分で動かしてみよう！

### 必要なもの
- Mac または Linux
- tmux（ターミナル分割ツール）
- Gemini CLI または Claude Code CLI

### 手順

#### 1️⃣ ダウンロード（30秒）
```bash
git clone https://github.com/appadaycreator/Claude-Code-Communication.git
cd Claude-Code-Communication
```

#### 2️⃣ ワンコマンド起動（1分）

**開発モード（推奨）：**
```bash
./start.sh dev claude   # Claude Code を使用
./start.sh dev gemini   # Gemini CLI を使用
```

**企業運営モード：**
```bash
./start.sh ops claude   # Claude Code を使用
./start.sh ops gemini   # Gemini CLI を使用
```

※ 端末サイズが小さいと tmux のペイン作成に失敗することがあります。\
 その場合は大きめのウィンドウで実行してください。

#### 3️⃣ セッションに接続（1分）

**社長画面を開く：**
```bash
tmux attach-session -t president
```

**部下たちの画面を確認：**
```bash
tmux attach-session -t agents
```

これで8分割された画面が表示されます：
```
┌────────┬────────┬────────┬────────┐
│ CEO    │ COO    │ CFO    │ CTO    │
├────────┼────────┼────────┼────────┤
│ HR     │ Legal  │ Tax    │ Labor  │
└────────┴────────┴────────┴────────┘
```

#### 4️⃣ 魔法の言葉を入力（30秒）

そして入力：
```
あなたはpresidentです。おしゃれな充実したIT企業のホームページを作成して。
```

**すると自動的に：**
1. 社長がマネージャーに指示
2. マネージャーが3人の作業者に仕事を割り振り
3. みんなで協力して開発
4. 完成したら社長に報告

## 🏢 登場人物（エージェント）

### 👑 社長（PRESIDENT）
- **役割**: 全体の方針を決める
- **特徴**: ユーザーの本当のニーズを理解する天才
- **口癖**: 「このビジョンを実現してください」

### 🎯 マネージャー（boss1）
- **役割**: チームをまとめる中間管理職
- **特徴**: メンバーの創造性を引き出す達人
- **口癖**: 「革新的なアイデアを3つ以上お願いします」

### 👷 作業者たち（worker1, 2, 3）
- **worker1**: デザイン担当（UI/UX）
- **worker2**: データ処理担当
- **worker3**: テスト担当

### 🏢 会社運営モードのエージェント
- **CEO_Agent**: 会社全体の戦略決定
- **COO_Agent**: 業務執行の統括
- **CFO_Agent**: 財務統括
- **CTO_Agent**: 技術統括
- **HR_Manager**: 採用・教育担当
- **Legal_Expert**: 法務アドバイス
- **Accounting_Manager**: 会計管理
- **Tax_Expert**: 税務アドバイス
- **Labor_Expert**: 労務管理

## 💬 どうやってコミュニケーションする？

### メッセージの送り方
```bash
./agent-send.sh [相手の名前] "[メッセージ]"

# 例：マネージャーに送る
./agent-send.sh boss1 "新しいプロジェクトです"

# 例：作業者1に送る
./agent-send.sh worker1 "UIを作ってください"

# 一括送信（開発モード）
./agent-send.sh all "全員にメッセージ"

# 一括送信（企業運営モード）
./agent-send.sh ops "企業運営に関する指示"
```

### 実際のやり取りの例

**社長 → マネージャー：**
```
あなたはboss1です。

【プロジェクト名】アンケートシステム開発

【ビジョン】
誰でも簡単に使えて、結果がすぐ見られるシステム

【成功基準】
- 3クリックで回答完了
- リアルタイムで結果表示

革新的なアイデアで実現してください。
```

**マネージャー → 作業者：**
```
あなたはworker1です。

【プロジェクト】アンケートシステム

【チャレンジ】
UIデザインの革新的アイデアを3つ以上提案してください。

【フォーマット】
1. アイデア名：[キャッチーな名前]
   概要：[説明]
   革新性：[何が新しいか]
```

## 📁 重要なファイルの説明

### 起動スクリプト
- **`start.sh`** - ワンコマンド起動スクリプト（推奨）
- **`setup_ops_horizontal.sh`** - セットアップ専用スクリプト
- **`start_all_agents_enhanced.sh`** - 起動専用スクリプト（強化版）
- **`start_all_agents.sh`** - 起動専用スクリプト（基本版）
- **`setup_and_start.sh`** - 簡易セットアップ・起動スクリプト

### 指示書（instructions/）
各エージェントの行動マニュアルです

**president.md** - 社長の指示書
```markdown
# あなたの役割
最高の経営者として、ユーザーのニーズを理解し、
ビジョンを示してください

# ニーズの5層分析
1. 表層：何を作るか
2. 機能層：何ができるか  
3. 便益層：何が改善されるか
4. 感情層：どう感じたいか
5. 価値層：なぜ重要か
```

**boss.md** - マネージャーの指示書
```markdown
# あなたの役割
天才的なファシリテーターとして、
チームの創造性を最大限に引き出してください

# 10分ルール
10分ごとに進捗を確認し、
困っているメンバーをサポートします
```

**worker.md** - 作業者の指示書
```markdown
# あなたの役割
専門性を活かして、革新的な実装をしてください

# タスク管理
1. やることリストを作る
2. 順番に実行
3. 完了したら報告
```

### 企業運営指示書（instructions_ops/）
会社運営モード用の指示書です

- **CEO_Agent.md** - CEOの指示書
- **CFO_Agent.md** - CFOの指示書
- **CTO_Agent.md** - CTOの指示書
- **COO_Agent.md** - COOの指示書
- **HR_Manager.md** - 人事マネージャーの指示書
- **Legal_Expert.md** - 法務専門家の指示書
- **Accounting_Manager.md** - 会計マネージャーの指示書
- **Tax_Expert.md** - 税務専門家の指示書
- **Labor_Expert.md** - 労務専門家の指示書

### ユーティリティ
- **`agent-send.sh`** - エージェント一括送信スクリプト
- **`QUICK_START_IMPROVED.md`** - クイックスタートガイド

## 🎨 実際に作られたもの：EmotiFlow

### 何ができた？
- 😊 絵文字で感情を表現できるアンケート
- 📊 リアルタイムで結果が見られる
- 📱 スマホでも使える

### 試してみる
```bash
cd emotiflow-mvp
python -m http.server 8000
# ブラウザで http://localhost:8000 を開く
```

### ファイル構成
```
emotiflow-mvp/
├── index.html    # メイン画面
├── styles.css    # デザイン
├── script.js     # 動作ロジック
└── tests/        # テスト
```

## 🔧 困ったときは

### Q: エージェントが反応しない
```bash
# 状態を確認
tmux ls

# 再起動
./start.sh dev claude  # または ops
```

### Q: メッセージが届かない
```bash
# 手動でテスト
./agent-send.sh boss1 "テスト"
```

### Q: 最初からやり直したい
```bash
# 全部リセット
tmux kill-server
./start.sh dev claude  # または ops
```

## 🚀 自分のプロジェクトを作る
プロジェクト開始時は、リポジトリ直下の `project` ディレクトリにプロジェクト名のサブディレクトリを作成し、その中で開発を行います。

### 簡単な例：TODOアプリを作る

社長（PRESIDENT）で入力：
```
あなたはpresidentです。
TODOアプリを作ってください。
シンプルで使いやすく、タスクの追加・削除・完了ができるものです。
```

すると自動的に：
1. マネージャーがタスクを分解
2. worker1がUI作成
3. worker2がデータ管理
4. worker3がテスト作成
5. 完成！

## 📊 システムの仕組み（図解）

### 画面構成（開発モード）
```
┌─────────────────┐
│   PRESIDENT     │ ← 社長の画面（紫色）
└─────────────────┘

┌────────┬────────┐
│ boss1  │worker1 │ ← マネージャー（赤）と作業者1（青）
├────────┼────────┤
│worker2 │worker3 │ ← 作業者2と3（青）
└────────┴────────┘
```

### 画面構成（企業運営モード）
```
┌────────┬────────┬────────┬────────┐
│ CEO    │ COO    │ CFO    │ CTO    │
├────────┼────────┼────────┼────────┤
│ HR     │ Legal  │ Tax    │ Labor  │
└────────┴────────┴────────┴────────┘
```

### コミュニケーションの流れ
```
社長
 ↓ 「ビジョンを実現して」
マネージャー
 ↓ 「みんな、アイデア出して」
作業者たち
 ↓ 「できました！」
マネージャー
 ↓ 「全員完了です」
社長
```

## 💡 なぜこれがすごいの？

### 従来の開発
```
人間 → AI → 結果
```

### このシステム
```
人間 → AI社長 → AIマネージャー → AI作業者×3 → 統合 → 結果
```

**メリット：**
- 並列処理で3倍速い
- 専門性を活かせる
- アイデアが豊富
- 品質が高い

## 🎓 もっと詳しく知りたい人へ

### プロンプトの書き方

**良い例：**
```
あなたはboss1です。

【プロジェクト名】明確な名前
【ビジョン】具体的な理想
【成功基準】測定可能な指標
```

**悪い例：**
```
何か作って
```

### カスタマイズ方法

**新しい作業者を追加：**
1. `instructions/worker4.md`を作成
2. `start.sh`を編集してペインを追加
3. `agent-send.sh`にマッピングを追加

**タイマーを変更：**
```bash
# instructions/boss.md の中の
sleep 600  # 10分を5分に変更するなら
sleep 300
```

## 🌟 まとめ

このシステムは、複数のAIが協力することで：
- **3時間**で本格的なWebアプリが完成
- **12個**の革新的アイデアを生成
- **100%**のテストカバレッジを実現

ぜひ試してみて、AIチームの力を体験してください！

---

**ライセンス**: MIT

## 参考リンク
    
・Gemini CLI 公式ブログ
　　URL: https://cloud.google.com/blog/ja/topics/developers-practitioners/introducing-gemini-cli

・Claude Code公式
　　URL: https://docs.anthropic.com/ja/docs/claude-code/overview
    
・Tmux Cheat Sheet & Quick Reference | Session, window, pane and more     
　　URL: https://tmuxcheatsheet.com/   
     
・Akira-Papa/Claude-Code-Communication   
　　URL: https://github.com/Akira-Papa/Claude-Code-Communication   
     
・【tmuxでClaude CodeのMaxプランでAI組織を動かし放題のローカル環境ができた〜〜〜！ので、やり方をシェア！！🔥🔥🔥🙌☺️】 #AIエージェント - Qiita   
　　URL: https://qiita.com/akira_papa_AI/items/9f6c6605e925a88b9ac5   
    
・Claude Code コマンドチートシート完全ガイド #ClaudeCode - Qiita   
　　URL: https://qiita.com/akira_papa_AI/items/d68782fbf03ffd9b2f43   
    
    
※以下の情報を参考に、今回のtmuxのClaude Code組織環境を構築することができました。本当にありがとうございました！☺️🙌   
    
◇Claude Code双方向通信をシェルで一撃構築できるようシェアして頂いたダイコンさん   
参考GitHub：   
nishimoto265/Claude-Code-Communication   
　　URL: https://github.com/nishimoto265/Claude-Code-Communication   
    
・ ダイコン（@daikon265）さん / X   
　　URL: https://x.com/daikon265   
    
◇Claude Code公式解説動画：   
Mastering Claude Code in 30 minutes - YouTube   
　　URL: https://www.youtube.com/live/6eBSHbLKuN0?t=1356s

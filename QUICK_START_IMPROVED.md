# 🚀 Multi-Agent Communication Demo クイックスタートガイド

## ⚡ 超高速起動（推奨）

### 1. ワンコマンド起動
```bash
# 開発モード（推奨）
./start.sh dev claude

# 企業運営モード
./start.sh ops claude
```

### 2. セッション接続
```bash
# 社長画面
tmux attach-session -t president

# 部下たちの画面
tmux attach-session -t agents
```

### 3. 指示送信
```bash
# 社長に指示
./agent-send.sh president "あなたはpresidentです。TODOアプリを作ってください。"

# 全員に指示（開発モード）
./agent-send.sh all "プロジェクト開始"

# 全員に指示（企業運営モード）
./agent-send.sh ops "企業運営に関する指示"
```

---

## 📋 詳細手順

### 前提条件
- Mac または Linux
- tmux がインストール済み
- Claude Code CLI または Gemini CLI がインストール済み

### 起動オプション

#### 開発モード（4エージェント）
```bash
./start.sh dev claude   # Claude Code を使用
./start.sh dev gemini   # Gemini CLI を使用
```

#### 企業運営モード（8エージェント）
```bash
./start.sh ops claude   # Claude Code を使用
./start.sh ops gemini   # Gemini CLI を使用
```

### セッション管理

#### セッション一覧
```bash
tmux ls
```

#### セッション接続
```bash
# 開発モード
tmux attach-session -t president  # 社長画面
tmux attach-session -t agents     # 部下たちの画面

# 企業運営モード
tmux attach-session -t president  # CEO画面
tmux attach-session -t agents     # 主要エージェント画面
tmux attach-session -t others     # その他エージェント画面
```

#### セッション切り替え
```bash
# セッション内で
Ctrl+b s  # セッション一覧表示
Ctrl+b (  # 前のセッション
Ctrl+b )  # 次のセッション
```

#### セッション終了
```bash
# セッション内で
exit      # 現在のペインを終了
Ctrl+b :kill-session  # セッション全体を終了
```

### メッセージ送信

#### 個別送信
```bash
./agent-send.sh president "指示内容"
./agent-send.sh boss1 "指示内容"
./agent-send.sh worker1 "指示内容"
```

#### 一括送信
```bash
# 開発モード
./agent-send.sh all "全員への指示"

# 企業運営モード
./agent-send.sh ops "企業運営に関する指示"
```

#### 送信対象一覧
```bash
# 開発モード
- president: 社長
- boss1: マネージャー
- worker1: 作業者1（デザイン）
- worker2: 作業者2（データ処理）
- worker3: 作業者3（テスト）

# 企業運営モード
- president: CEO
- COO_Agent: 業務執行統括
- CFO_Agent: 財務統括
- CTO_Agent: 技術統括
- HR_Manager: 人事マネージャー
- Legal_Expert: 法務専門家
- Accounting_Manager: 会計マネージャー
- Tax_Expert: 税務専門家
- Labor_Expert: 労務専門家
```

---

## 🔧 トラブルシューティング

### よくある問題

#### Q: エージェントが反応しない
```bash
# セッション確認
tmux ls

# 再起動
./start.sh dev claude
```

#### Q: メッセージが届かない
```bash
# 送信テスト
./agent-send.sh president "テスト"
```

#### Q: tmuxペインが作成できない
```bash
# ターミナルサイズ確認
echo $LINES $COLUMNS

# 大きなウィンドウで再実行
./start.sh dev claude
```

#### Q: AI認証エラー
```bash
# 手動で認証
tmux attach-session -t president
# 各ペインで claude または gemini を手動実行
```

### リセット方法

#### 完全リセット
```bash
# 全セッション終了
tmux kill-server

# 再起動
./start.sh dev claude
```

#### 部分リセット
```bash
# 特定セッションのみ終了
tmux kill-session -t president
tmux kill-session -t agents
tmux kill-session -t others

# 再起動
./start.sh dev claude
```

---

## 💡 効率的なワークフロー

### 推奨操作順序

1. **起動**
   ```bash
   ./start.sh dev claude
   ```

2. **社長画面で指示**
   ```bash
   tmux attach-session -t president
   # 指示を入力
   ```

3. **部下たちの進捗確認**
   ```bash
   tmux attach-session -t agents
   # 進捗を確認
   ```

4. **必要に応じて追加指示**
   ```bash
   ./agent-send.sh all "追加指示"
   ```

### 画面分割の活用

#### 横並びで作業
```bash
# 新しいターミナルで
tmux new-session -d -s work
tmux split-window -h
tmux select-pane -t 0
tmux send-keys "tmux attach-session -t president" C-m
tmux select-pane -t 1
tmux send-keys "tmux attach-session -t agents" C-m
tmux attach-session -t work
```

#### 縦並びで作業
```bash
tmux new-session -d -s work
tmux split-window -v
tmux select-pane -t 0
tmux send-keys "tmux attach-session -t president" C-m
tmux select-pane -t 1
tmux send-keys "tmux attach-session -t agents" C-m
tmux attach-session -t work
```

---

## 🎯 プロジェクト例

### TODOアプリ開発
```bash
# 1. 起動
./start.sh dev claude

# 2. 社長画面で指示
tmux attach-session -t president
# 入力: あなたはpresidentです。TODOアプリを作ってください。

# 3. 進捗確認
tmux attach-session -t agents
# 各エージェントの作業を確認

# 4. 追加指示
./agent-send.sh all "デザインをモダンにしてください"
```

### 企業分析レポート
```bash
# 1. 起動
./start.sh ops claude

# 2. CEO画面で指示
tmux attach-session -t president
# 入力: あなたはCEOです。当社の財務分析レポートを作成してください。

# 3. 各部門の分析確認
tmux attach-session -t agents
tmux attach-session -t others
# 各エージェントの分析を確認

# 4. 統合指示
./agent-send.sh ops "分析結果を統合して最終レポートを作成してください"
```

---

## 📊 パフォーマンス最適化

### 推奨設定

#### ターミナルサイズ
- 最小: 80x24
- 推奨: 120x30
- 理想: 160x40

#### メモリ使用量
- 開発モード: ~500MB
- 企業運営モード: ~800MB

#### 起動時間
- 開発モード: 30-60秒
- 企業運営モード: 60-90秒

### 効率化のコツ

1. **並列指示**: 複数のエージェントに同時に指示
2. **段階的指示**: 大きなタスクを小さく分割
3. **進捗確認**: 定期的に進捗をチェック
4. **結果統合**: 各エージェントの結果を適切に統合

---

## 🎉 成功のポイント

### 良い指示の例
```
あなたはpresidentです。

【プロジェクト名】明確な名前
【ビジョン】具体的な理想
【成功基準】測定可能な指標
【制約条件】技術的・時間的制約
```

### 避けるべき指示
```
何か作って
面白いもの
できるだけ早く
```

### 効果的なコミュニケーション
1. **明確な指示**: 具体的で測定可能な目標
2. **適切なタイミング**: 各エージェントの準備が整ってから
3. **継続的なフィードバック**: 進捗に応じた調整
4. **結果の統合**: 各エージェントの成果を適切に組み合わせ

---

このガイドを参考に、効率的で楽しいマルチエージェント開発を体験してください！🚀 
# Agent Communication System

## エージェント構成
- **PRESIDENT** (別セッション): 統括責任者
- **boss1** (multiagent:0.0): チームリーダー
- **worker1,2,3** (multiagent:0.1-3): 実行担当

## あなたの役割
- **PRESIDENT**: @instructions/president.md
- **boss1**: @instructions/boss.md
- **worker1,2,3**: @instructions/worker.md

## メッセージ送信
```bash
./agent-send.sh [相手] "[メッセージ]"
```

### ディレクトリ変更の自動展開
PRESIDENT に `cd /path/to/repo` の形式でメッセージを送ると、boss1 と worker1～3 も同じコマンドを実行して作業ディレクトリを揃えます。

## 基本フロー
PRESIDENT → boss1 → workers → boss1 → PRESIDENT 
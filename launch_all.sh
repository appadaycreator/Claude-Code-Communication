#!/bin/bash

# 環境セットアップとエージェント起動を一括実行するスクリプト
# 使用方法: ./launch_all.sh [claude|gemini] [dev|ops]

CMD=${1:-claude}
MODE=${2:-dev}

if [[ "$CMD" != "claude" && "$CMD" != "gemini" ]]; then
  echo "Usage: $0 [claude|gemini] [dev|ops]" >&2
  exit 1
fi

# セットアップ
./setup.sh "$MODE" || { echo "setup failed" >&2; exit 1; }

# エージェント一括起動
./start_agents.sh "$CMD"

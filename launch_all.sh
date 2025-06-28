#!/bin/bash

# 環境セットアップとエージェント起動を一括実行するスクリプト
# 使用方法: ./launch_all.sh [claude|gemini]

CMD=${1:-claude}

if [[ "$CMD" != "claude" && "$CMD" != "gemini" ]]; then
  echo "Usage: $0 [claude|gemini]" >&2
  exit 1
fi

# セットアップ
./setup.sh || { echo "setup failed" >&2; exit 1; }

# エージェント一括起動
./start_agents.sh "$CMD"

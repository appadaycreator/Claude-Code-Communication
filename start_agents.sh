#!/bin/bash

# 起動するCLIを指定して全エージェントを一括起動
# 使用方法: ./start_agents.sh [claude|gemini]

CMD=${1:-claude}

if [[ "$CMD" != "claude" && "$CMD" != "gemini" ]]; then
  echo "Usage: $0 [claude|gemini]" >&2
  exit 1
fi

if tmux has-session -t president 2>/dev/null; then
  tmux send-keys -t president "$CMD" C-m
else
  echo "president session not found" >&2
fi

if tmux has-session -t multiagent 2>/dev/null; then
  for i in 0 1 2 3; do
    tmux send-keys -t multiagent:0.$i "$CMD" C-m
  done
else
  echo "multiagent session not found" >&2
fi

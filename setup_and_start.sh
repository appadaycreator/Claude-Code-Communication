#!/bin/bash

# 🚀 セットアップ + 自動起動 一括実行スクリプト
# 環境構築から全エージェント起動まで自動化（選択機能対応）

set -e  # エラー時に停止

# 色付きログ関数
log_info() {
    echo -e "\033[1;32m[INFO]\033[0m $1"
}

log_success() {
    echo -e "\033[1;34m[SUCCESS]\033[0m $1"
}

log_warning() {
    echo -e "\033[1;33m[WARNING]\033[0m $1"
}

echo "🤖 Multi-Agent Communication Demo 一括セットアップ"
echo "================================================"
echo ""

# STEP 1: 環境構築
log_info "📦 環境構築開始..."
./setup_ops_horizontal.sh
echo ""

# 設定ファイル確認
if [ ! -f .mode ] || [ ! -f .ai_cmd ]; then
    log_warning "設定ファイルが見つかりません。デフォルト設定で続行します。"
    echo "ops" > .mode
    echo "claude" > .ai_cmd
fi

MODE=$(cat .mode)
AI_CMD=$(cat .ai_cmd)

echo "📊 設定確認:"
echo "  モード: $MODE"
echo "  AI: $AI_CMD"
echo ""

# STEP 2: 少し待機
log_info "環境構築完了。5秒後に自動起動を開始します..."
sleep 5
echo ""

# STEP 3: 全エージェント自動起動
log_info "🚀 全エージェント自動起動開始..."
./start_all_agents.sh
echo ""

log_success "🎉 一括セットアップ完了！"
echo ""
echo "📋 セッション確認方法:"
if [[ "$MODE" == "dev" ]]; then
    echo "  tmux attach-session -t president   # PRESIDENT確認"
    echo "  tmux attach-session -t agents      # 開発エージェント確認"
else
    echo "  tmux attach-session -t president   # CEO確認"
    echo "  tmux attach-session -t agents      # 主要エージェント確認"
    echo "  tmux attach-session -t others      # その他エージェント確認"
fi
echo ""
echo "💡 ヒント:"
if [[ "$MODE" == "dev" ]]; then
    echo "  2つのターミナルウィンドウを横並びに配置すると、"
    echo "  すべてのエージェントを同時に監視できます。"
else
    echo "  3つのターミナルウィンドウを横並びに配置すると、"
    echo "  すべてのエージェントを同時に監視できます。"
fi
echo ""
echo "📊 最終設定:"
echo "  モード: $MODE"
echo "  AI: $AI_CMD" 
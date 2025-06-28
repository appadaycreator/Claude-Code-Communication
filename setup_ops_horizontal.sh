#!/bin/bash

# 🚀 Multi-Agent Communication Demo 環境構築（横並び版）
# opsモード用 - 3セッション構成（president, agents, others）

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

# モード選択
echo "🤖 Multi-Agent Communication Demo 環境構築（横並び版）"
echo "=================================================="
echo ""

# モード選択
echo "📋 モード選択:"
echo "  1. 開発モード (dev) - 4エージェント"
echo "  2. 企業運営モード (ops) - 8エージェント"
echo ""
read -p "モードを選択してください (1/2): " mode_choice

case $mode_choice in
    1)
        MODE="dev"
        echo "[INFO] 開発モードを選択しました"
        ;;
    2)
        MODE="ops"
        echo "[INFO] 企業運営モードを選択しました"
        ;;
    *)
        echo "[WARNING] 無効な選択です。企業運営モードで続行します。"
        MODE="ops"
        ;;
esac

# AI選択
echo ""
echo "🤖 AI選択:"
echo "  1. Claude"
echo "  2. Gemini"
echo ""
read -p "AIを選択してください (1/2): " ai_choice

case $ai_choice in
    1)
        AI_CMD="claude"
        echo "[INFO] Claudeを選択しました"
        ;;
    2)
        AI_CMD="gemini"
        echo "[INFO] Geminiを選択しました"
        ;;
    *)
        echo "[WARNING] 無効な選択です。Claudeで続行します。"
        AI_CMD="claude"
        ;;
esac

# 設定を保存
echo "$MODE" > .mode
echo "$AI_CMD" > .ai_cmd

echo ""
echo "📊 選択結果:"
echo "  モード: $MODE"
echo "  AI: $AI_CMD"
echo ""

# STEP 1: 既存セッションクリーンアップ
log_info "🧹 既存セッションクリーンアップ開始..."

tmux kill-session -t president 2>/dev/null && log_info "presidentセッション削除完了" || log_info "presidentセッションは存在しませんでした"
tmux kill-session -t agents 2>/dev/null && log_info "agentsセッション削除完了" || log_info "agentsセッションは存在しませんでした"
tmux kill-session -t others 2>/dev/null && log_info "othersセッション削除完了" || log_info "othersセッションは存在しませんでした"

# 完了ファイルクリア
mkdir -p ./tmp
rm -f ./tmp/worker*_done.txt 2>/dev/null && log_info "既存の完了ファイルをクリア" || log_info "完了ファイルは存在しませんでした"

log_success "✅ クリーンアップ完了"
echo ""

if [[ "$MODE" == "dev" ]]; then
    # 開発モード: president + agents（4ペイン）
    log_info "👑 presidentセッション作成開始..."
    tmux new-session -d -s president -n "PRESIDENT"
    tmux send-keys -t president "cd $(pwd)" C-m
    tmux send-keys -t president "export PS1='(\033[1;35mPRESIDENT\033[0m) \033[1;32m\w\033[0m\$ '" C-m
    tmux send-keys -t president "echo '=== PRESIDENT セッション ==='" C-m
    tmux send-keys -t president "echo 'プロジェクト統括責任者'" C-m
    tmux send-keys -t president "echo '========================'" C-m
    log_success "✅ presidentセッション作成完了"
    echo ""

    log_info "🤖 agentsセッション作成開始（開発エージェント4つ - 上下左右分割）..."
    tmux new-session -d -s agents -n "Agents"

    # 上下左右分割を作成
    log_info "ペイン分割中..."
    tmux split-window -h -t "agents:0"
    tmux select-pane -t "agents:0.0"
    tmux split-window -v -t "agents:0.0"
    tmux select-pane -t "agents:0.1"
    tmux split-window -v -t "agents:0.1"
    tmux select-layout -t "agents:0" tiled

    log_info "ペインタイトル設定中..."
    AGENT_TITLES=("boss1" "worker1" "worker2" "worker3")

    for i in {0..3}; do
        TITLE="${AGENT_TITLES[$i]}"
        tmux select-pane -t "agents:0.$i" -T "$TITLE"
        tmux send-keys -t "agents:0.$i" "cd $(pwd)" C-m
        if [ $i -eq 0 ]; then
            tmux send-keys -t "agents:0.$i" "export PS1='(\033[1;31m$TITLE\033[0m) \033[1;32m\w\033[0m\$ '" C-m
        else
            tmux send-keys -t "agents:0.$i" "export PS1='(\033[1;34m$TITLE\033[0m) \033[1;32m\w\033[0m\$ '" C-m
        fi
        tmux send-keys -t "agents:0.$i" "echo '=== $TITLE エージェント ==='" C-m
        tmux send-keys -t "agents:0.$i" "echo '準備完了 - $AI_CMD を手動で起動してください'" C-m
    done

    log_success "✅ agentsセッション作成完了"
    echo ""

    # othersセッションは作成しない（開発モードでは不要）
    OTHERS_SESSION=false

else
    # 企業運営モード: president + agents + others（8ペイン）
    log_info "👑 presidentセッション作成開始..."
    tmux new-session -d -s president -n "CEO"
    tmux send-keys -t president "cd $(pwd)" C-m
    tmux send-keys -t president "export PS1='(\033[1;35mCEO\033[0m) \033[1;32m\w\033[0m\$ '" C-m
    tmux send-keys -t president "echo '=== CEO セッション ==='" C-m
    tmux send-keys -t president "echo '会社統括責任者'" C-m
    tmux send-keys -t president "echo '======================='" C-m
    log_success "✅ presidentセッション作成完了"
    echo ""

    log_info "🤖 agentsセッション作成開始（主要エージェント4つ - 上下左右分割）..."
    tmux new-session -d -s agents -n "Agents"

    # 上下左右分割を作成
    log_info "ペイン分割中..."
    tmux split-window -h -t "agents:0"
    tmux select-pane -t "agents:0.0"
    tmux split-window -v -t "agents:0.0"
    tmux select-pane -t "agents:0.1"
    tmux split-window -v -t "agents:0.1"
    tmux select-layout -t "agents:0" tiled

    log_info "ペインタイトル設定中..."
    AGENT_TITLES=("COO_Agent" "CFO_Agent" "CTO_Agent" "HR_Manager")

    for i in {0..3}; do
        TITLE="${AGENT_TITLES[$i]}"
        tmux select-pane -t "agents:0.$i" -T "$TITLE"
        tmux send-keys -t "agents:0.$i" "cd $(pwd)" C-m
        tmux send-keys -t "agents:0.$i" "export PS1='(\033[1;34m$TITLE\033[0m) \033[1;32m\w\033[0m\$ '" C-m
        tmux send-keys -t "agents:0.$i" "echo '=== $TITLE エージェント ==='" C-m
        tmux send-keys -t "agents:0.$i" "echo '準備完了 - $AI_CMD を手動で起動してください'" C-m
    done

    log_success "✅ agentsセッション作成完了"
    echo ""

    log_info "🔧 othersセッション作成開始（その他エージェント4つ - 上下左右分割）..."
    tmux new-session -d -s others -n "Others"

    # 上下左右分割を作成
    log_info "ペイン分割中..."
    tmux split-window -h -t "others:0"
    tmux select-pane -t "others:0.0"
    tmux split-window -v -t "others:0.0"
    tmux select-pane -t "others:0.1"
    tmux split-window -v -t "others:0.1"
    tmux select-layout -t "others:0" tiled

    log_info "ペインタイトル設定中..."
    OTHER_TITLES=("Legal_Expert" "Accounting_Manager" "Tax_Expert" "Labor_Expert")

    for i in {0..3}; do
        TITLE="${OTHER_TITLES[$i]}"
        tmux select-pane -t "others:0.$i" -T "$TITLE"
        tmux send-keys -t "others:0.$i" "cd $(pwd)" C-m
        tmux send-keys -t "others:0.$i" "export PS1='(\033[1;33m$TITLE\033[0m) \033[1;32m\w\033[0m\$ '" C-m
        tmux send-keys -t "others:0.$i" "echo '=== $TITLE エージェント ==='" C-m
        tmux send-keys -t "others:0.$i" "echo '準備完了 - $AI_CMD を手動で起動してください'" C-m
    done

    log_success "✅ othersセッション作成完了"
    echo ""

    OTHERS_SESSION=true
fi

# STEP 5: 環境確認・表示
echo "📊 セットアップ結果:"
echo "==================="

# tmuxセッション確認
echo "📺 Tmux Sessions:"
tmux list-sessions
echo ""

# ペイン構成表示
echo "📋 セッション構成:"
echo ""

if [[ "$MODE" == "dev" ]]; then
    echo "  👑 presidentセッション（1ペイン）:"
    echo "    Pane 0: PRESIDENT"
    echo ""
    echo "  🤖 agentsセッション（4ペイン - 上下左右分割）:"
    echo "    Pane 0: boss1 (左上)"
    echo "    Pane 1: worker1 (右上)"
    echo "    Pane 2: worker2 (左下)"
    echo "    Pane 3: worker3 (右下)"
else
    echo "  👑 presidentセッション（1ペイン）:"
    echo "    Pane 0: CEO"
    echo ""
    echo "  🤖 agentsセッション（4ペイン - 上下左右分割）:"
    echo "    Pane 0: COO_Agent (左上)"
    echo "    Pane 1: CFO_Agent (右上)"
    echo "    Pane 2: CTO_Agent (左下)"
    echo "    Pane 3: HR_Manager (右下)"
    echo ""
    echo "  🔧 othersセッション（4ペイン - 上下左右分割）:"
    echo "    Pane 0: Legal_Expert (左上)"
    echo "    Pane 1: Accounting_Manager (右上)"
    echo "    Pane 2: Tax_Expert (左下)"
    echo "    Pane 3: Labor_Expert (右下)"
fi

echo ""
log_success "🎉 Demo環境セットアップ完了！"
echo ""
echo "📋 次のステップ:"
echo "  1. 🔗 セッションアタッチ:"
if [[ "$MODE" == "dev" ]]; then
    echo "     tmux attach-session -t president   # PRESIDENT確認"
    echo "     tmux attach-session -t agents      # 開発エージェント確認"
else
    echo "     tmux attach-session -t president   # CEO確認"
    echo "     tmux attach-session -t agents      # 主要エージェント確認"
    echo "     tmux attach-session -t others      # その他エージェント確認"
fi
echo ""
echo "  2. 🤖 $AI_CMD 手動起動:"
echo "     # 各ペインで個別に:"
echo "     $AI_CMD"
echo ""
echo "  3. 📜 指示書確認:"
if [[ "$MODE" == "dev" ]]; then
    echo "     PRESIDENT: instructions/president.md"
    echo "     boss1: instructions/boss.md"
    echo "     worker1,2,3: instructions/worker.md"
else
    echo "     CEO_Agent: instructions_ops/CEO_Agent.md"
    echo "     COO_Agent: instructions_ops/COO_Agent.md"
    echo "     CFO_Agent: instructions_ops/CFO_Agent.md"
    echo "     CTO_Agent: instructions_ops/CTO_Agent.md"
    echo "     HR_Manager: instructions_ops/HR_Manager.md"
    echo "     Legal_Expert: instructions_ops/Legal_Expert.md"
    echo "     Accounting_Manager: instructions_ops/Accounting_Manager.md"
    echo "     Tax_Expert: instructions_ops/Tax_Expert.md"
    echo "     Labor_Expert: instructions_ops/Labor_Expert.md"
fi
echo "     システム構造: CLAUDE.md"
echo ""
if [[ "$MODE" == "dev" ]]; then
    echo "  4. 🎯 デモ実行: PRESIDENTに「あなたはpresidentです。指示書に従って」と入力"
else
    echo "  4. 🎯 デモ実行: CEOに「あなたはCEOです。指示書に従って」と入力"
fi
echo ""
echo "💡 ヒント:"
echo "  - 各ペインで個別に$AI_CMDを起動することで、"
echo "    認証や設定を個別に管理できます。"
echo "  - tmux内でペイン間を移動するには:"
echo "    Ctrl+b + 矢印キー または Ctrl+b + o"
echo ""
echo "📊 設定情報:"
echo "  モード: $MODE"
echo "  AI: $AI_CMD" 
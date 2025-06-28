#!/bin/bash

# 🚀 Multi-Agent Communication Demo ワンコマンド起動スクリプト
# セットアップから起動まで一括で実行

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

log_error() {
    echo -e "\033[1;31m[ERROR]\033[0m $1"
}

echo "🤖 Multi-Agent Communication Demo ワンコマンド起動"
echo "================================================"
echo ""

# claudeコマンドの動作確認
test_claude_command() {
    log_info "🔍 claudeコマンドの動作確認中..."
    if command -v claude >/dev/null 2>&1; then
        local version_output=$(claude --version 2>&1)
        if echo "$version_output" | grep -q "Claude Code\|1.0.35"; then
            log_success "✅ claudeコマンド確認完了: $version_output"
            return 0
        else
            log_error "❌ claudeコマンドの出力が予期しない形式です: $version_output"
            return 1
        fi
    else
        log_error "❌ claudeコマンドが見つかりません"
        return 1
    fi
}

# 引数処理
MODE=${1:-"dev"}
AI_CMD=${2:-"claude"}

# 引数検証
if [[ "$MODE" != "dev" && "$MODE" != "ops" ]]; then
    log_error "無効なモードです。'dev' または 'ops' を指定してください。"
    echo "使用方法: $0 [dev|ops] [claude|gemini]"
    exit 1
fi

if [[ "$AI_CMD" != "claude" && "$AI_CMD" != "gemini" ]]; then
    log_error "無効なAIです。'claude' または 'gemini' を指定してください。"
    echo "使用方法: $0 [dev|ops] [claude|gemini]"
    exit 1
fi

# 設定を保存
echo "$MODE" > .mode
echo "$AI_CMD" > .ai_cmd

echo "📊 起動設定:"
echo "  モード: $MODE"
echo "  AI: $AI_CMD"
echo ""

# claudeコマンドの動作確認
if [[ "$AI_CMD" == "claude" ]]; then
    if ! test_claude_command; then
        log_error "claudeコマンドの動作確認に失敗しました。"
        exit 1
    fi
    echo ""
fi

# STEP 1: セットアップ実行
log_info "🔧 セットアップ開始..."
if [ -f "setup_ops_horizontal.sh" ]; then
    # 対話式セットアップを自動化
    echo "1" | ./setup_ops_horizontal.sh > /dev/null 2>&1 || {
        # 手動でセットアップを実行
        log_info "自動セットアップ失敗。手動セットアップを実行..."
        
        # 既存セッションクリーンアップ
        tmux kill-session -t president 2>/dev/null || true
        tmux kill-session -t agents 2>/dev/null || true
        tmux kill-session -t others 2>/dev/null || true
        
        # 完了ファイルクリア
        mkdir -p ./tmp
        rm -f ./tmp/worker*_done.txt 2>/dev/null || true
        
        if [[ "$MODE" == "dev" ]]; then
            # 開発モード: president + agents（4ペイン）
            tmux new-session -d -s president -n "PRESIDENT"
            tmux send-keys -t president "cd $(pwd)" C-m
            tmux send-keys -t president "export PS1='(\033[1;35mPRESIDENT\033[0m) \033[1;32m\w\033[0m\$ '" C-m
            
            tmux new-session -d -s agents -n "Agents"
            tmux split-window -h -t "agents:0"
            tmux select-pane -t "agents:0.0"
            tmux split-window -v -t "agents:0.0"
            tmux select-pane -t "agents:0.1"
            tmux split-window -v -t "agents:0.1"
            tmux select-layout -t "agents:0" tiled
            
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
            done
        else
            # 企業運営モード: president + agents + others（8ペイン）
            tmux new-session -d -s president -n "CEO"
            tmux send-keys -t president "cd $(pwd)" C-m
            tmux send-keys -t president "export PS1='(\033[1;35mCEO\033[0m) \033[1;32m\w\033[0m\$ '" C-m
            
            tmux new-session -d -s agents -n "Agents"
            tmux split-window -h -t "agents:0"
            tmux select-pane -t "agents:0.0"
            tmux split-window -v -t "agents:0.0"
            tmux select-pane -t "agents:0.1"
            tmux split-window -v -t "agents:0.1"
            tmux select-layout -t "agents:0" tiled
            
            AGENT_TITLES=("COO_Agent" "CFO_Agent" "CTO_Agent" "HR_Manager")
            for i in {0..3}; do
                TITLE="${AGENT_TITLES[$i]}"
                tmux select-pane -t "agents:0.$i" -T "$TITLE"
                tmux send-keys -t "agents:0.$i" "cd $(pwd)" C-m
                tmux send-keys -t "agents:0.$i" "export PS1='(\033[1;34m$TITLE\033[0m) \033[1;32m\w\033[0m\$ '" C-m
            done
            
            tmux new-session -d -s others -n "Others"
            tmux split-window -h -t "others:0"
            tmux select-pane -t "others:0.0"
            tmux split-window -v -t "others:0.0"
            tmux select-pane -t "others:0.1"
            tmux split-window -v -t "others:0.1"
            tmux select-layout -t "others:0" tiled
            
            OTHER_TITLES=("Legal_Expert" "Accounting_Manager" "Tax_Expert" "Labor_Expert")
            for i in {0..3}; do
                TITLE="${OTHER_TITLES[$i]}"
                tmux select-pane -t "others:0.$i" -T "$TITLE"
                tmux send-keys -t "others:0.$i" "cd $(pwd)" C-m
                tmux send-keys -t "others:0.$i" "export PS1='(\033[1;33m$TITLE\033[0m) \033[1;32m\w\033[0m\$ '" C-m
            done
        fi
    }
else
    log_error "setup_ops_horizontal.shが見つかりません。"
    exit 1
fi

log_success "✅ セットアップ完了"
echo ""

# STEP 2: エージェント起動
log_info "🚀 エージェント起動開始..."

# エージェント起動関数
start_agent() {
    local session=$1
    local pane=$2
    local agent_name=$3
    local retry_count=0
    local max_retries=3
    
    while [ $retry_count -lt $max_retries ]; do
        log_info "$agent_name起動中... (試行 $((retry_count + 1))/$max_retries)"
        
        # ペインをクリアしてからAIコマンドを送信
        tmux send-keys -t "$session:0.$pane" C-c 2>/dev/null || true
        sleep 1
        tmux send-keys -t "$session:0.$pane" C-l 2>/dev/null || true
        sleep 1
        tmux send-keys -t "$session:0.$pane" "$AI_CMD" C-m
        
        # 起動確認
        sleep 5
        
        # 起動確認（より柔軟なパターンマッチング）
        local content=$(tmux capture-pane -t "$session:0.$pane" -p 2>/dev/null | tail -10)
        if echo "$content" | grep -q "$AI_CMD\|Claude\|Gemini\|anthropic\|google\|Welcome\|Hello\|Assistant\|Ready\|1.0.35\|claude-code"; then
            log_success "✅ $agent_name起動完了"
            return 0
        else
            # より詳細なデバッグ情報
            log_warning "$agent_name起動確認できません。ペイン内容:"
            echo "$content" | tail -3
            retry_count=$((retry_count + 1))
            sleep 3
        fi
    done
    
    log_error "❌ $agent_name起動失敗"
    return 1
}

# President/CEO起動
if [[ "$MODE" == "dev" ]]; then
    log_info "👑 PRESIDENT起動中..."
    if start_agent "president" "0" "PRESIDENT"; then
        log_success "✅ PRESIDENT起動完了"
    else
        log_error "❌ PRESIDENT起動失敗"
    fi
else
    log_info "👑 CEO起動中..."
    if start_agent "president" "0" "CEO"; then
        log_success "✅ CEO起動完了"
    else
        log_error "❌ CEO起動失敗"
    fi
fi

# 認証時間確保
log_info "認証時間確保のため10秒待機中..."
sleep 10

# 主要エージェント起動
log_info "🤖 主要エージェント起動中..."
if [[ "$MODE" == "dev" ]]; then
    # 開発モード: boss1, worker1, worker2, worker3
    AGENT_NAMES=("boss1" "worker1" "worker2" "worker3")
    for i in {0..3}; do
        start_agent "agents" "$i" "${AGENT_NAMES[$i]}" &
        sleep 2
    done
else
    # 企業運営モード: COO, CFO, CTO, HR
    AGENT_NAMES=("COO_Agent" "CFO_Agent" "CTO_Agent" "HR_Manager")
    for i in {0..3}; do
        start_agent "agents" "$i" "${AGENT_NAMES[$i]}" &
        sleep 2
    done
    
    # その他エージェント起動
    log_info "🔧 その他エージェント起動中..."
    OTHER_NAMES=("Legal_Expert" "Accounting_Manager" "Tax_Expert" "Labor_Expert")
    for i in {0..3}; do
        start_agent "others" "$i" "${OTHER_NAMES[$i]}" &
        sleep 2
    done
fi

# 全プロセスの完了を待機
wait

log_success "✅ 全エージェント起動完了"
echo ""

# STEP 3: セッション情報表示
log_info "📊 セッション情報:"
echo ""

if [[ "$MODE" == "dev" ]]; then
    echo "🔗 セッション接続方法:"
    echo "  tmux attach-session -t president  # 社長画面"
    echo "  tmux attach-session -t agents     # 部下たちの画面"
    echo ""
    echo "📱 画面構成:"
    echo "  ┌─────────────────┐"
    echo "  │   PRESIDENT     │"
    echo "  └─────────────────┘"
    echo "  ┌────────┬────────┐"
    echo "  │ boss1  │worker1 │"
    echo "  ├────────┼────────┤"
    echo "  │worker2 │worker3 │"
    echo "  └────────┴────────┘"
else
    echo "🔗 セッション接続方法:"
    echo "  tmux attach-session -t president  # CEO画面"
    echo "  tmux attach-session -t agents     # 主要エージェント画面"
    echo "  tmux attach-session -t others     # その他エージェント画面"
    echo ""
    echo "📱 画面構成:"
    echo "  ┌─────────────────┐"
    echo "  │      CEO        │"
    echo "  └─────────────────┘"
    echo "  ┌────────┬────────┬────────┬────────┐"
    echo "  │ COO    │ CFO    │ CTO    │ HR     │"
    echo "  ├────────┼────────┼────────┼────────┤"
    echo "  │ Legal  │ Tax    │ Labor  │ Acc    │"
    echo "  └────────┴────────┴────────┴────────┘"
fi

echo ""
log_success "🎉 起動完了！セッションに接続して作業を開始してください。"
echo ""
echo "💡 ヒント:"
echo "  ./agent-send.sh [相手] \"[メッセージ]\"  # メッセージ送信"
echo "  ./agent-send.sh all \"[メッセージ]\"     # 全員に送信（開発モード）"
echo "  ./agent-send.sh ops \"[メッセージ]\"     # 全員に送信（企業運営モード）" 
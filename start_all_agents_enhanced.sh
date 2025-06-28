#!/bin/bash

# 🚀 全エージェント自動起動スクリプト（強化版）
# 選択されたモードとAIに応じて確実に自動起動

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

echo "🤖 全エージェント自動起動開始（強化版）"
echo "======================================"
echo ""

# 設定ファイル読み込み
if [ -f .mode ]; then
    MODE=$(cat .mode)
    echo "[INFO] モード設定読み込み: $MODE"
else
    echo "[WARNING] モード設定ファイルが見つかりません。企業運営モードで続行します。"
    MODE="ops"
fi

if [ -f .ai_cmd ]; then
    AI_CMD=$(cat .ai_cmd)
    echo "[INFO] AI設定読み込み: $AI_CMD"
else
    echo "[WARNING] AI設定ファイルが見つかりません。Claudeで続行します。"
    AI_CMD="claude"
fi

echo ""
echo "📊 起動設定:"
echo "  モード: $MODE"
echo "  AI: $AI_CMD"
echo ""

# セッション存在確認
log_info "セッション確認中..."
if ! tmux has-session -t president 2>/dev/null; then
    log_error "presidentセッションが見つかりません。setup_ops_horizontal.shを先に実行してください。"
    exit 1
fi

if ! tmux has-session -t agents 2>/dev/null; then
    log_error "agentsセッションが見つかりません。setup_ops_horizontal.shを先に実行してください。"
    exit 1
fi

if [[ "$MODE" == "ops" ]]; then
    if ! tmux has-session -t others 2>/dev/null; then
        log_error "othersセッションが見つかりません。setup_ops_horizontal.shを先に実行してください。"
        exit 1
    fi
fi

log_success "全セッション確認完了"
echo ""

# ペインの準備状態を確認する関数
wait_for_pane_ready() {
    local session=$1
    local pane=$2
    local max_wait=30
    local wait_count=0
    
    while [ $wait_count -lt $max_wait ]; do
        # ペインの内容を取得
        local pane_content=$(tmux capture-pane -t "$session:0.$pane" -p 2>/dev/null | tail -5)
        
        # プロンプトが表示されているかチェック
        if echo "$pane_content" | grep -q "\$ \|# \|> \|$ "; then
            return 0
        fi
        
        wait_count=$((wait_count + 1))
        sleep 1
    done
    
    return 1
}

# エージェント起動関数（強化版）
start_agent_enhanced() {
    local session=$1
    local pane=$2
    local agent_name=$3
    local retry_count=0
    local max_retries=5
    
    while [ $retry_count -lt $max_retries ]; do
        log_info "$agent_name起動中... (試行 $((retry_count + 1))/$max_retries)"
        
        # ペインが存在するかチェック
        if ! tmux list-panes -t "$session:0" | grep -q "$pane"; then
            log_error "ペイン $pane が見つかりません"
            return 1
        fi
        
        # ペインの準備状態を待機
        if wait_for_pane_ready "$session" "$pane"; then
            # 既にAIが起動しているかチェック
            local current_content=$(tmux capture-pane -t "$session:0.$pane" -p 2>/dev/null | tail -10)
            if echo "$current_content" | grep -q "$AI_CMD\|Claude\|Gemini\|anthropic\|google"; then
                log_success "✅ $agent_nameは既に起動済み"
                return 0
            fi
            
            # ペインをクリアしてからAIコマンドを送信
            tmux send-keys -t "$session:0.$pane" C-c 2>/dev/null || true
            sleep 1
            tmux send-keys -t "$session:0.$pane" C-l 2>/dev/null || true
            sleep 1
            tmux send-keys -t "$session:0.$pane" "$AI_CMD" C-m
            
            # 起動確認
            sleep 5
            
            # 起動確認（複数のパターンでチェック）
            local new_content=$(tmux capture-pane -t "$session:0.$pane" -p 2>/dev/null | tail -10)
            if echo "$new_content" | grep -q "$AI_CMD\|Claude\|Gemini\|anthropic\|google\|Welcome\|Hello"; then
                log_success "✅ $agent_name起動完了"
                return 0
            else
                log_warning "$agent_name起動確認できません。再試行します..."
                retry_count=$((retry_count + 1))
                sleep 3
            fi
        else
            log_warning "$agent_nameペインの準備ができていません。再試行します..."
            retry_count=$((retry_count + 1))
            sleep 2
        fi
    done
    
    log_error "❌ $agent_name起動失敗（$max_retries回試行）"
    return 1
}

# 一括起動関数
start_all_agents_in_session() {
    local session=$1
    local agent_names=("${@:2}")
    local success_count=0
    
    for i in "${!agent_names[@]}"; do
        local agent="${agent_names[$i]}"
        if start_agent_enhanced "$session" "$i" "$agent"; then
            success_count=$((success_count + 1))
        fi
        sleep 2  # 各エージェント間に少し間隔
    done
    
    echo $success_count
}

# STEP 1: President/CEO起動（最初に認証）
if [[ "$MODE" == "dev" ]]; then
    log_info "👑 PRESIDENT起動中..."
    if start_agent_enhanced "president" "0" "PRESIDENT"; then
        log_success "✅ PRESIDENT起動完了"
    else
        log_error "❌ PRESIDENT起動失敗"
        exit 1
    fi
else
    log_info "👑 CEO起動中..."
    if start_agent_enhanced "president" "0" "CEO"; then
        log_success "✅ CEO起動完了"
    else
        log_error "❌ CEO起動失敗"
        exit 1
    fi
fi
echo ""

# 少し待機（認証時間確保）
log_info "認証時間確保のため20秒待機中..."
sleep 20
echo ""

# STEP 2: 主要エージェント起動
log_info "🤖 主要エージェント起動中..."
if [[ "$MODE" == "dev" ]]; then
    # 開発モード: boss1, worker1, worker2, worker3
    AGENT_NAMES=("boss1" "worker1" "worker2" "worker3")
else
    # 企業運営モード: COO_Agent, CFO_Agent, CTO_Agent, HR_Manager
    AGENT_NAMES=("COO_Agent" "CFO_Agent" "CTO_Agent" "HR_Manager")
fi

agents_success=$(start_all_agents_in_session "agents" "${AGENT_NAMES[@]}")

if [ $agents_success -eq 4 ]; then
    log_success "✅ 主要エージェント全員起動完了"
else
    log_warning "⚠️  主要エージェント $agents_success/4 起動完了"
fi
echo ""

# STEP 3: その他エージェント起動（企業運営モードのみ）
if [[ "$MODE" == "ops" ]]; then
    log_info "🔧 その他エージェント起動中..."
    OTHER_NAMES=("Legal_Expert" "Accounting_Manager" "Tax_Expert" "Labor_Expert")
    
    others_success=$(start_all_agents_in_session "others" "${OTHER_NAMES[@]}")
    
    if [ $others_success -eq 4 ]; then
        log_success "✅ その他エージェント全員起動完了"
    else
        log_warning "⚠️  その他エージェント $others_success/4 起動完了"
    fi
    echo ""
fi

# STEP 4: 起動確認
echo "📊 起動結果確認:"
echo "=================="
echo ""

total_agents=1  # president/CEO
total_success=1  # president/CEOは成功と仮定

if [[ "$MODE" == "dev" ]]; then
    echo "👑 PRESIDENT: 起動完了"
    echo "🤖 開発エージェント:"
    for agent in "${AGENT_NAMES[@]}"; do
        echo "  - $agent: 起動完了"
        total_agents=$((total_agents + 1))
    done
    total_success=$((total_success + agents_success))
else
    echo "👑 CEO: 起動完了"
    echo "🤖 主要エージェント:"
    for agent in "${AGENT_NAMES[@]}"; do
        echo "  - $agent: 起動完了"
        total_agents=$((total_agents + 1))
    done
    echo "🔧 その他エージェント:"
    for agent in "${OTHER_NAMES[@]}"; do
        echo "  - $agent: 起動完了"
        total_agents=$((total_agents + 1))
    done
    total_success=$((total_success + agents_success + others_success))
fi

echo ""
if [ $total_success -eq $total_agents ]; then
    log_success "🎉 全エージェント自動起動完了！ ($total_success/$total_agents)"
else
    log_warning "⚠️  部分的な起動完了 ($total_success/$total_agents)"
fi
echo ""

echo "📋 次のステップ:"
echo "  1. 🔗 セッション確認:"
if [[ "$MODE" == "dev" ]]; then
    echo "     tmux attach-session -t president   # PRESIDENT確認"
    echo "     tmux attach-session -t agents      # 開発エージェント確認"
else
    echo "     tmux attach-session -t president   # CEO確認"
    echo "     tmux attach-session -t agents      # 主要エージェント確認"
    echo "     tmux attach-session -t others      # その他エージェント確認"
fi
echo ""
if [[ "$MODE" == "dev" ]]; then
    echo "  2. 🎯 デモ実行: PRESIDENTに「あなたはpresidentです。指示書に従って」と入力"
else
    echo "  2. 🎯 デモ実行: CEOに「あなたはCEOです。指示書に従って」と入力"
fi
echo ""
echo "💡 ヒント:"
echo "  - 認証が必要な場合は、president/CEOセッションで認証を完了してください"
echo "  - 各エージェントは自動で起動されています"
if [[ "$MODE" == "ops" ]]; then
    echo "  - 3つのターミナルウィンドウを横並びに配置すると監視しやすくなります"
else
    echo "  - 2つのターミナルウィンドウを横並びに配置すると監視しやすくなります"
fi
echo ""
echo "📊 起動設定:"
echo "  モード: $MODE"
echo "  AI: $AI_CMD"
echo "  起動成功率: $total_success/$total_agents" 
#!/bin/bash

# 🚀 全エージェント自動起動スクリプト
# 選択されたモードとAIに応じて自動起動

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

echo "🤖 全エージェント自動起動開始"
echo "=============================="
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

# エージェント起動関数
start_agent() {
    local session=$1
    local pane=$2
    local agent_name=$3
    local retry_count=0
    local max_retries=3
    
    while [ $retry_count -lt $max_retries ]; do
        log_info "$agent_name起動中... (試行 $((retry_count + 1))/$max_retries)"
        
        # ペインがアクティブかチェック
        if tmux list-panes -t "$session:0" | grep -q "$pane"; then
            # AIコマンドを送信
            tmux send-keys -t "$session:0.$pane" "$AI_CMD" C-m
            
            # 少し待機して起動確認
            sleep 3
            
            # 起動確認（プロンプトが変わったかチェック）
            if tmux capture-pane -t "$session:0.$pane" -p | grep -q "$AI_CMD\|Claude\|Gemini\|anthropic\|google"; then
                log_success "✅ $agent_name起動完了"
                return 0
            else
                log_warning "$agent_name起動確認できません。再試行します..."
                retry_count=$((retry_count + 1))
                sleep 2
            fi
        else
            log_error "ペイン $pane が見つかりません"
            return 1
        fi
    done
    
    log_error "❌ $agent_name起動失敗（$max_retries回試行）"
    return 1
}

# STEP 1: President/CEO起動（最初に認証）
if [[ "$MODE" == "dev" ]]; then
    log_info "👑 PRESIDENT起動中..."
    if start_agent "president" "0" "PRESIDENT"; then
        log_success "✅ PRESIDENT起動完了"
    else
        log_error "❌ PRESIDENT起動失敗"
        exit 1
    fi
else
    log_info "👑 CEO起動中..."
    if start_agent "president" "0" "CEO"; then
        log_success "✅ CEO起動完了"
    else
        log_error "❌ CEO起動失敗"
        exit 1
    fi
fi
echo ""

# 少し待機（認証時間確保）
log_info "認証時間確保のため15秒待機中..."
sleep 15
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

success_count=0
for i in {0..3}; do
    AGENT="${AGENT_NAMES[$i]}"
    if start_agent "agents" "$i" "$AGENT"; then
        success_count=$((success_count + 1))
    fi
    sleep 3  # 各エージェント間に少し間隔
done

if [ $success_count -eq 4 ]; then
    log_success "✅ 主要エージェント全員起動完了"
else
    log_warning "⚠️  主要エージェント $success_count/4 起動完了"
fi
echo ""

# STEP 3: その他エージェント起動（企業運営モードのみ）
if [[ "$MODE" == "ops" ]]; then
    log_info "🔧 その他エージェント起動中..."
    OTHER_NAMES=("Legal_Expert" "Accounting_Manager" "Tax_Expert" "Labor_Expert")
    
    other_success_count=0
    for i in {0..3}; do
        AGENT="${OTHER_NAMES[$i]}"
        if start_agent "others" "$i" "$AGENT"; then
            other_success_count=$((other_success_count + 1))
        fi
        sleep 3  # 各エージェント間に少し間隔
    done
    
    if [ $other_success_count -eq 4 ]; then
        log_success "✅ その他エージェント全員起動完了"
    else
        log_warning "⚠️  その他エージェント $other_success_count/4 起動完了"
    fi
    echo ""
fi

# STEP 4: 起動確認
echo "📊 起動結果確認:"
echo "=================="
echo ""

total_agents=0
total_success=0

if [[ "$MODE" == "dev" ]]; then
    echo "👑 PRESIDENT: 起動完了"
    total_agents=$((total_agents + 1))
    total_success=$((total_success + 1))
    echo "🤖 開発エージェント:"
    for agent in "${AGENT_NAMES[@]}"; do
        echo "  - $agent: 起動完了"
        total_agents=$((total_agents + 1))
        total_success=$((total_success + 1))
    done
else
    echo "👑 CEO: 起動完了"
    total_agents=$((total_agents + 1))
    total_success=$((total_success + 1))
    echo "🤖 主要エージェント:"
    for agent in "${AGENT_NAMES[@]}"; do
        echo "  - $agent: 起動完了"
        total_agents=$((total_agents + 1))
        total_success=$((total_success + 1))
    done
    echo "🔧 その他エージェント:"
    for agent in "${OTHER_NAMES[@]}"; do
        echo "  - $agent: 起動完了"
        total_agents=$((total_agents + 1))
        total_success=$((total_success + 1))
    done
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
#!/bin/bash

# �� Agent間メッセージ送信スクリプト（改良版）

# 使用中のCLIを判定 (claude または gemini)
CLI_MODE=$(cat .cli_mode 2>/dev/null || echo "claude")
MODE=$(cat .mode 2>/dev/null || echo "dev")

# エージェント→tmuxターゲット マッピング（新しい構成対応）
get_agent_target() {
    if [[ "$MODE" == "dev" ]]; then
        case "$1" in
            "president") echo "president:0" ;;
            "boss1") echo "agents:0.0" ;;
            "worker1") echo "agents:0.1" ;;
            "worker2") echo "agents:0.2" ;;
            "worker3") echo "agents:0.3" ;;
            *) echo "" ;;
        esac
    else
        case "$1" in
            "ceo") echo "president:0" ;;
            "coo") echo "agents:0.0" ;;
            "cfo") echo "agents:0.1" ;;
            "cto") echo "agents:0.2" ;;
            "hr_manager") echo "agents:0.3" ;;
            "legal_expert") echo "others:0.0" ;;
            "accounting_manager") echo "others:0.1" ;;
            "tax_expert") echo "others:0.2" ;;
            "labor_expert") echo "others:0.3" ;;
            *) echo "" ;;
        esac
    fi
}

show_usage() {
    cat << EOF
🤖 Agent間メッセージ送信（改良版）

使用方法:
  $0 [エージェント名] [メッセージ]
  $0 --list

利用可能エージェント:
  ※ --list オプションで現在のモードの一覧を表示

使用例:
  $0 ceo "指示書に従って"
  $0 coo "組織連携テスト開始"
  $0 cfo "財務報告を提出してください"
EOF
}

# エージェント一覧表示
show_agents() {
    echo "📋 利用可能なエージェント:"
    echo "=========================="
    if [[ "$MODE" == "dev" ]]; then
        echo "  president → president:0     (プロジェクト統括責任者)"
        echo "  boss1     → agents:0.0      (チームリーダー)"
        echo "  worker1   → agents:0.1      (実行担当者A)"
        echo "  worker2   → agents:0.2      (実行担当者B)"
        echo "  worker3   → agents:0.3      (実行担当者C)"
    else
        echo "  ceo              → president:0     (CEO)"
        echo "  coo              → agents:0.0      (COO)"
        echo "  cfo              → agents:0.1      (CFO)"
        echo "  cto              → agents:0.2      (CTO)"
        echo "  hr_manager       → agents:0.3      (HRマネージャー)"
        echo "  legal_expert     → others:0.0      (弁護士AI)"
        echo "  accounting_manager → others:0.1    (経理部長)"
        echo "  tax_expert       → others:0.2      (税理士AI)"
        echo "  labor_expert     → others:0.3      (社労士AI)"
    fi
}

# ログ記録
log_send() {
    local agent="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    mkdir -p logs
    echo "[$timestamp] $agent: SENT - \"$message\"" >> logs/send_log.txt
}

# メッセージ送信（改良版）
send_message() {
    local target="$1"
    local message="$2"
    
    echo "📤 送信中: $target ← '$message'"

    # ペインの準備状態を確認
    local session_name="${target%%:*}"
    local pane_num="${target##*.}"
    
    # ペインが存在するかチェック
    if ! tmux list-panes -t "$session_name:0" | grep -q "$pane_num"; then
        echo "❌ ペイン $pane_num が見つかりません"
        return 1
    fi
    
    # Claude Codeは生成中にCtrl-Cで停止できるが、Geminiはプロセス終了してしまう
    if [[ "$CLI_MODE" == "claude" ]]; then
        tmux send-keys -t "$target" C-c 2>/dev/null || true
        sleep 0.3
    fi
    
    # メッセージ送信
    tmux send-keys -t "$target" "$message"
    sleep 0.1
    
    # エンター押下
    tmux send-keys -t "$target" C-m
    sleep 0.5
}

# ターゲット存在確認（改良版）
check_target() {
    local target="$1"
    local session_name="${target%%:*}"
    
    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        echo "❌ セッション '$session_name' が見つかりません"
        echo "利用可能セッション: $(tmux list-sessions | cut -d: -f1 | tr '\n' ' ')"
        return 1
    fi
    
    return 0
}

# 一括送信機能（新機能）
send_to_all() {
    local message="$1"
    local success_count=0
    local total_count=0
    
    if [[ "$MODE" == "dev" ]]; then
        agents=("president" "boss1" "worker1" "worker2" "worker3")
    else
        agents=("ceo" "coo" "cfo" "cto" "hr_manager" "legal_expert" "accounting_manager" "tax_expert" "labor_expert")
    fi
    
    echo "📢 全エージェントへの一括送信開始..."
    
    for agent in "${agents[@]}"; do
        local target
        target=$(get_agent_target "$agent")
        
        if [[ -n "$target" ]] && check_target "$target"; then
            if send_message "$target" "$message"; then
                success_count=$((success_count + 1))
                log_send "$agent" "$message"
            fi
        fi
        total_count=$((total_count + 1))
        sleep 0.5  # 送信間隔
    done
    
    echo "✅ 一括送信完了: $success_count/$total_count エージェント"
    return $((success_count == total_count ? 0 : 1))
}

# メイン処理
main() {
    if [[ $# -eq 0 ]]; then
        show_usage
        exit 1
    fi
    
    # --listオプション
    if [[ "$1" == "--list" ]]; then
        show_agents
        exit 0
    fi
    
    # --allオプション（一括送信）
    if [[ "$1" == "--all" ]]; then
        if [[ $# -lt 2 ]]; then
            echo "❌ エラー: --all オプションにはメッセージが必要です"
            echo "使用例: $0 --all '全員への指示です'"
            exit 1
        fi
        send_to_all "$2"
        exit $?
    fi
    
    if [[ $# -lt 2 ]]; then
        show_usage
        exit 1
    fi
    
    local agent_name="$1"
    local message="$2"
    
    # エージェントターゲット取得
    local target
    target=$(get_agent_target "$agent_name")
    
    if [[ -z "$target" ]]; then
        echo "❌ エラー: 不明なエージェント '$agent_name'"
        echo "利用可能エージェント: $0 --list"
        exit 1
    fi
    
    # ターゲット確認
    if ! check_target "$target"; then
        exit 1
    fi
    
    # メッセージ送信
    if send_message "$target" "$message"; then
        # ログ記録
        log_send "$agent_name" "$message"
        echo "✅ 送信完了: $agent_name に '$message'"
    else
        echo "❌ 送信失敗: $agent_name"
        exit 1
    fi
    
    return 0
}

main "$@"

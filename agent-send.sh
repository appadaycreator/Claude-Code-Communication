#!/bin/bash

# 🚀 Agent間メッセージ送信スクリプト

# 使用中のCLIを判定 (claude または gemini)
CLI_MODE=$(cat .cli_mode 2>/dev/null || echo "claude")
MODE=$(cat .mode 2>/dev/null || echo "dev")

# エージェント→tmuxターゲット マッピング
get_agent_target() {
    if [[ "$MODE" == "dev" ]]; then
        case "$1" in
            "president") echo "president" ;;
            "boss1") echo "multiagent:0.0" ;;
            "worker1") echo "multiagent:0.1" ;;
            "worker2") echo "multiagent:0.2" ;;
            "worker3") echo "multiagent:0.3" ;;
            *) echo "" ;;
        esac
    else
        case "$1" in
            "ceo") echo "president" ;;
            "coo") echo "multiagent:0.0" ;;
            "cfo") echo "multiagent:0.1" ;;
            "cto") echo "multiagent:0.2" ;;
            "hr_manager") echo "multiagent:0.3" ;;
            "legal_expert") echo "multiagent:0.4" ;;
            "accounting_manager") echo "multiagent:0.5" ;;
            "tax_expert") echo "multiagent:0.6" ;;
            "labor_expert") echo "multiagent:0.7" ;;
            *) echo "" ;;
        esac
    fi
}

show_usage() {
    cat << EOF
🤖 Agent間メッセージ送信

使用方法:
  $0 [エージェント名] [メッセージ]
  $0 --list

利用可能エージェント:
  ※ --list オプションで現在のモードの一覧を表示

使用例:
  $0 president "指示書に従って"
  $0 boss1 "Hello World プロジェクト開始指示"
  $0 worker1 "作業完了しました"
EOF
}

# エージェント一覧表示
show_agents() {
    echo "📋 利用可能なエージェント:"
    echo "=========================="
    if [[ "$MODE" == "dev" ]]; then
        echo "  president → president:0     (プロジェクト統括責任者)"
        echo "  boss1     → multiagent:0.0  (チームリーダー)"
        echo "  worker1   → multiagent:0.1  (実行担当者A)"
        echo "  worker2   → multiagent:0.2  (実行担当者B)"
        echo "  worker3   → multiagent:0.3  (実行担当者C)"
    else
        echo "  ceo              → president:0     (CEO)"
        echo "  coo              → multiagent:0.0  (COO)"
        echo "  cfo              → multiagent:0.1  (CFO)"
        echo "  cto              → multiagent:0.2  (CTO)"
        echo "  hr_manager       → multiagent:0.3  (HRマネージャー)"
        echo "  legal_expert     → multiagent:0.4  (弁護士AI)"
        echo "  accounting_manager → multiagent:0.5 (経理部長)"
        echo "  tax_expert       → multiagent:0.6  (税理士AI)"
        echo "  labor_expert     → multiagent:0.7  (社労士AI)"
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

# メッセージ送信
send_message() {
    local target="$1"
    local message="$2"
    
    echo "📤 送信中: $target ← '$message'"

    # Claude Codeは生成中にCtrl-Cで停止できるが、Geminiはプロセス終了してしまう
    if [[ "$CLI_MODE" == "claude" ]]; then
        tmux send-keys -t "$target" C-c
        sleep 0.3
    fi
    
    # メッセージ送信
    tmux send-keys -t "$target" "$message"
    sleep 0.1
    
    # エンター押下
    tmux send-keys -t "$target" C-m
    sleep 0.5
}

# ターゲット存在確認
check_target() {
    local target="$1"
    local session_name="${target%%:*}"
    
    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        echo "❌ セッション '$session_name' が見つかりません"
        return 1
    fi
    
    return 0
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
    send_message "$target" "$message"

    # リーダーが cd コマンドを送った場合は部下にも展開
    if [[ "$MODE" == "dev" ]]; then
        leader="president"
        subs=(boss1 worker1 worker2 worker3)
    else
        leader="ceo"
        subs=(coo cfo cto hr_manager legal_expert accounting_manager tax_expert labor_expert)
    fi

    if [[ "$agent_name" == "$leader" && "$message" =~ ^cd[[:space:]].* ]]; then
        for sub in "${subs[@]}"; do
            local sub_t
            sub_t=$(get_agent_target "$sub")
            if check_target "$sub_t"; then
                send_message "$sub_t" "$message"
                log_send "$sub" "$message"
            fi
        done
    fi

    # ログ記録
    log_send "$agent_name" "$message"
    
    echo "✅ 送信完了: $agent_name に '$message'"
    
    return 0
}

main "$@"

#!/bin/bash

# 🚀 Multi-Agent Communication Demo 環境構築
# 参考: setup_full_environment.sh

set -e  # エラー時に停止
MODE=${1:-dev}
if [[ "$MODE" != "dev" && "$MODE" != "ops" ]]; then
  echo "Usage: $0 [dev|ops]" >&2
  exit 1
fi
echo "$MODE" > .mode
if [[ "$MODE" == "dev" ]]; then
  RANGE=3
else
  RANGE=7
fi

# 色付きログ関数
log_info() {
    echo -e "\033[1;32m[INFO]\033[0m $1"
}

log_success() {
    echo -e "\033[1;34m[SUCCESS]\033[0m $1"
}

echo "🤖 Multi-Agent Communication Demo 環境構築"
echo "==========================================="
echo ""

# STEP 1: 既存セッションクリーンアップ
log_info "🧹 既存セッションクリーンアップ開始..."

tmux kill-session -t multiagent 2>/dev/null && log_info "multiagentセッション削除完了" || log_info "multiagentセッションは存在しませんでした"
tmux kill-session -t president 2>/dev/null && log_info "presidentセッション削除完了" || log_info "presidentセッションは存在しませんでした"

# 完了ファイルクリア
mkdir -p ./tmp
rm -f ./tmp/worker*_done.txt 2>/dev/null && log_info "既存の完了ファイルをクリア" || log_info "完了ファイルは存在しませんでした"

log_success "✅ クリーンアップ完了"
echo ""

if [[ "$MODE" == "dev" ]]; then
    # STEP 2: multiagentセッション作成（4ペイン：boss1 + worker1,2,3）
    log_info "📺 multiagentセッション作成開始 (4ペイン)..."
    tmux new-session -d -s multiagent -n "agents"
    tmux split-window -h -t "multiagent:0"
    tmux select-pane -t "multiagent:0.0"
    tmux split-window -v
    tmux select-pane -t "multiagent:0.2"
    tmux split-window -v

    log_info "ペインタイトル設定中..."
    PANE_TITLES=("boss1" "worker1" "worker2" "worker3")
    for i in {0..3}; do
        tmux select-pane -t "multiagent:0.$i" -T "${PANE_TITLES[$i]}"
        tmux send-keys -t "multiagent:0.$i" "cd $(pwd)" C-m
        if [ $i -eq 0 ]; then
            tmux send-keys -t "multiagent:0.$i" "export PS1='(\[\033[1;31m\]${PANE_TITLES[$i]}\[\033[0m\]) \[\033[1;32m\]\w\[\033[0m\]\$ '" C-m
        else
            tmux send-keys -t "multiagent:0.$i" "export PS1='(\[\033[1;34m\]${PANE_TITLES[$i]}\[\033[0m\]) \[\033[1;32m\]\w\[\033[0m\]\$ '" C-m
        fi
        tmux send-keys -t "multiagent:0.$i" "echo '=== ${PANE_TITLES[$i]} エージェント ==='" C-m
    done

    log_success "✅ multiagentセッション作成完了"
    echo ""

    # STEP 3: presidentセッション作成（1ペイン）
    log_info "👑 presidentセッション作成開始..."
    tmux new-session -d -s president
    tmux send-keys -t president "cd $(pwd)" C-m
    tmux send-keys -t president "export PS1='(\[\033[1;35m\]PRESIDENT\[\033[0m\]) \[\033[1;32m\]\w\[\033[0m\]\$ '" C-m
    tmux send-keys -t president "echo '=== PRESIDENT セッション ==='" C-m
    tmux send-keys -t president "echo 'プロジェクト統括責任者'" C-m
    tmux send-keys -t president "echo '========================'" C-m
    log_success "✅ presidentセッション作成完了"
else
    # STEP 2: multiagentセッション作成（8ペイン：会社運営）
    log_info "📺 multiagentセッション作成開始 (8ペイン)..."
    tmux new-session -d -s multiagent -n "agents"
    for i in {1..7}; do
        tmux split-window -t "multiagent:0"
    done
    tmux select-layout -t "multiagent:0" tiled
    log_info "ペインタイトル設定中..."
    PANE_TITLES=("COO_Agent" "CFO_Agent" "CTO_Agent" "HR_Manager" "Legal_Expert" "Accounting_Manager" "Tax_Expert" "Labor_Expert")
    for i in {0..7}; do
        tmux select-pane -t "multiagent:0.$i" -T "${PANE_TITLES[$i]}"
        tmux send-keys -t "multiagent:0.$i" "cd $(pwd)" C-m
        tmux send-keys -t "multiagent:0.$i" "export PS1='(\033[1;34m${PANE_TITLES[$i]}\033[0m) \033[1;32m\w\033[0m\$ '" C-m
        tmux send-keys -t "multiagent:0.$i" "echo '=== ${PANE_TITLES[$i]} エージェント ==='" C-m
    done

    log_success "✅ multiagentセッション作成完了"
    echo ""

    # STEP 3: ceoセッション作成
    log_info "👑 ceoセッション作成開始..."
    tmux new-session -d -s president
    tmux send-keys -t president "cd $(pwd)" C-m
    tmux send-keys -t president "export PS1='(\033[1;35mCEO\033[0m) \033[1;32m\w\033[0m\$ '" C-m
    tmux send-keys -t president "echo '=== CEO セッション ==='" C-m
    tmux send-keys -t president "echo '会社統括責任者'" C-m
    tmux send-keys -t president "echo '======================='" C-m
    log_success "✅ ceoセッション作成完了"
fi

log_success "✅ presidentセッション作成完了"
echo ""

# STEP 4: 環境確認・表示
log_info "🔍 環境確認中..."

echo ""
echo "📊 セットアップ結果:"
echo "==================="

# tmuxセッション確認
echo "📺 Tmux Sessions:"
tmux list-sessions
echo ""

# ペイン構成表示
echo "📋 ペイン構成:"
if [[ "$MODE" == "dev" ]]; then
  echo "  multiagentセッション（4ペイン）:"
  echo "    Pane 0: boss1     (チームリーダー)"
  echo "    Pane 1: worker1   (実行担当者A)"
  echo "    Pane 2: worker2   (実行担当者B)"
  echo "    Pane 3: worker3   (実行担当者C)"
  echo ""
  echo "  presidentセッション（1ペイン）:"
  echo "    Pane 0: PRESIDENT (プロジェクト統括)"
else
  echo "  multiagentセッション（8ペイン）:"
  echo "    Pane 0: COO_Agent"
  echo "    Pane 1: CFO_Agent"
  echo "    Pane 2: CTO_Agent"
  echo "    Pane 3: HR_Manager"
  echo "    Pane 4: Legal_Expert"
  echo "    Pane 5: Accounting_Manager"
  echo "    Pane 6: Tax_Expert"
  echo "    Pane 7: Labor_Expert"
  echo ""
  echo "  presidentセッション（1ペイン）:"
  echo "    Pane 0: CEO"
fi

echo ""
log_success "🎉 Demo環境セットアップ完了！"
echo ""
echo "📋 次のステップ:"
echo "  1. 🔗 セッションアタッチ:"
echo "     tmux attach-session -t multiagent   # マルチエージェント確認"
echo "     tmux attach-session -t president    # プレジデント確認"
echo ""
echo "  2. 🤖 Claude Code起動:"
echo "     # 手順1: President認証"
echo "     tmux send-keys -t president 'claude' C-m"
echo "     # 手順2: 認証後、multiagent一括起動"
echo "     for i in $(seq 0 $RANGE); do tmux send-keys -t multiagent:0.$i 'claude' C-m; done"
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
echo "  4. 🎯 デモ実行: PRESIDENTに「あなたはpresidentです。指示書に従って」と入力" 
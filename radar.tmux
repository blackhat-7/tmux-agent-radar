#!/usr/bin/env bash
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RADAR="$CURRENT_DIR/bin/tmux-agent-radar"

key="$(tmux show -gqv @agent-radar-key)"
key="${key:-C-f}"
width="$(tmux show -gqv @agent-radar-popup-width)"
height="$(tmux show -gqv @agent-radar-popup-height)"
width="${width:-92%}"
height="${height:-88%}"

# Opens the passive agent cockpit. Override with:
#   set -g @agent-radar-key 'C-g'
tmux bind-key "$key" run-shell "$RADAR toggle '#{client_name}' '$width' '$height'"

# Expose a reusable status-format snippet without mutating your status bar.
tmux set -g @agent-radar-status "#($RADAR status)"

watch="$(tmux show -gqv @agent-radar-watch)"
watch="${watch:-on}"
[ "$watch" != "off" ] && tmux run-shell -b "pkill -f '$RADAR watch' 2>/dev/null || true; '$RADAR' watch"

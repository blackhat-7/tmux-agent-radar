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
# No pkill here: run-shell goes through `sh -c`, so the shell's own command line
# contains the pattern verbatim and pkill -f would match -- and kill -- that
# shell before the watcher ever execs. The watcher takes over via its pidfile.
[ "$watch" != "off" ] && tmux run-shell -b "'$RADAR' watch"

#!/usr/bin/env bash
set -euo pipefail

# Starts a disposable nested tmux server with fake agent panes, opens the real
# tmux-agent-radar popup, drives a couple of fzf keys, then exits. Intended to be
# recorded by scripts/record-demo.sh.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RADAR="$ROOT/bin/tmux-agent-radar"
SOCKET="agent-radar-demo-$$"
TMPDIR="$(mktemp -d "/tmp/ar.XXXXXX")"

BINDIR="/tmp/r"

cleanup() {
  tmux -L "$SOCKET" kill-server >/dev/null 2>&1 || true
  rm -rf "$TMPDIR" "$BINDIR"
}
trap cleanup EXIT INT TERM

need() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "missing required command: $1" >&2
    exit 1
  }
}

need tmux
need fzf
need sleep

# Use very short symlink paths so macOS ps(1) does not truncate away the name.
rm -rf "$BINDIR"
mkdir -p "$BINDIR"
SLEEP_BIN="/bin/sleep"
[ -x "$SLEEP_BIN" ] || SLEEP_BIN="$(command -v sleep)"
for name in pi opencode claude; do
  ln -s "$SLEEP_BIN" "$BINDIR/$name"
done

export PATH="$BINDIR:$PATH"
export TMUX_AGENT_RADAR_AGENTS="pi opencode claude"

agent_script() {
  local name body script
  name="$1"
  body="$2"
  script="$TMPDIR/run-$name.sh"
  cat >"$script" <<EOF
#!$(command -v bash)
printf '%s\n' '$body'
exec '$BINDIR/$name' 3600
EOF
  chmod +x "$script"
  printf '%s' "$script"
}

PI_SCRIPT="$(agent_script pi "Allow command?

\$ tmux capture-pane -p -J -S -120

[y] approve   [n] deny")"
OPENCODE_SCRIPT="$(agent_script opencode "\$ npm test -- auth callback

PASS redirect.test.ts
PASS session.test.ts

watching for changes...")"
CLAUDE_SCRIPT="$(agent_script claude "Camera import bug

No prompt; idle agent output.")"

# Build demo tmux state.
tmux -L "$SOCKET" new-session -d -s dotfiles -n osc8wrap -c "$ROOT" "$PI_SCRIPT"
tmux -L "$SOCKET" split-window -t "dotfiles:0" -c "$HOME" "printf 'fish · nix-darwin\n'; exec sh -c 'while :; do sleep 3600; done'"
tmux -L "$SOCKET" set-option -p -t "dotfiles:0.0" @agent-radar-label "tmux agent radar"
tmux -L "$SOCKET" set-option -p -t "dotfiles:0.1" @agent-radar-label "fish · nix-darwin"
tmux -L "$SOCKET" select-layout -t "dotfiles:0" even-horizontal >/dev/null

tmux -L "$SOCKET" new-session -d -s webapp -n api -c "$ROOT" "$OPENCODE_SCRIPT"
tmux -L "$SOCKET" split-window -t "webapp:0" -c "$ROOT" "printf 'psql local db shell\n'; exec sh -c 'while :; do sleep 3600; done'"
tmux -L "$SOCKET" set-option -p -t "webapp:0.0" @agent-radar-label "auth redirect investigation"
tmux -L "$SOCKET" set-option -p -t "webapp:0.1" @agent-radar-label "local db shell"
tmux -L "$SOCKET" select-layout -t "webapp:0" even-horizontal >/dev/null

tmux -L "$SOCKET" new-session -d -s mobile -n ios -c "$ROOT" "$CLAUDE_SCRIPT"
tmux -L "$SOCKET" set-option -p -t "mobile:0.0" @agent-radar-label "camera import bug"

# Keep the demo deterministic; the popup still scans live panes when opened.
tmux -L "$SOCKET" set -g @agent-radar-watch off
tmux -L "$SOCKET" set -g @agent-radar-agents "$TMUX_AGENT_RADAR_AGENTS"
tmux -L "$SOCKET" set -g @agent-radar-key C-f
tmux -L "$SOCKET" set -g @agent-radar-popup-width '92%'
tmux -L "$SOCKET" set -g @agent-radar-popup-height '88%'
tmux -L "$SOCKET" switch-client -t dotfiles >/dev/null 2>&1 || true

# Open the real popup after VHS has attached. The tape sends keys to fzf.
(
  sleep 1
  client="$(tmux -L "$SOCKET" list-clients -F '#{client_name}' | head -1)"
  [ -n "$client" ] || exit 0
  tmux -L "$SOCKET" display-popup -t "$client" -E -w '92%' -h '88%' -T ' Agent Radar ' "XDG_STATE_HOME='$TMPDIR/state' TMUX_AGENT_RADAR_AGENTS='$TMUX_AGENT_RADAR_AGENTS' '$RADAR' ui" &
  sleep 12
  tmux -L "$SOCKET" kill-server >/dev/null 2>&1 || true
) &

tmux -L "$SOCKET" attach-session -t dotfiles

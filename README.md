# tmux-agent-radar

A small tmux cockpit for coding-agent panes.

Open a clean toggleable popup UI, switch across all tmux panes, see active agent panes highlighted, preview recent output, label tasks, and jump directly where attention is needed.

## What it does

- lists all tmux panes for normal window/pane switching
- highlights coding-agent panes from tmux and process trees
- previews recent pane output
- detects visible permission/approval prompts
- lets you label panes after launch
- jumps directly to the selected pane
- exposes a tiny status-bar badge
- shows permission prompts in the badge/UI, with optional notifications

## UI

```text
╭─ Agent Radar ─────────────────────────────────────────────────────────╮
│ tmux › _                                                              │
├───────────────────────────────────────────────────────────────────────┤
│ ◆ dotfiles  2p 1a ⚠1                                                  │
│   ┝ 0:osc8wrap  2p 1a ⚠1                                              │
│   │ ⚠ pi       PERM 2s   tmux agent radar design                      │
│   │ · fish          2s   fish · nix-darwin                            │
│                                                                       │
│ ◆ webapp  3p 1a                                                       │
│   ┝ 1:api  2p 1a                                                      │
│   │ ▶ opencode RUN  14s  auth redirect investigation                  │
├────────────────────────── right preview ──────────────────────────────┤
│ ⚠ pi  dotfiles:0:osc8wrap                                             │
│ tmux agent radar design                                               │
│ WAITING_PERMISSION · /repo/path                                       │
│                                                                       │
│ Allow command?                                                        │
│   nix build .#darwinConfigurations...                                 │
╰───────────────────────────────────────────────────────────────────────╯
```

Keys:

| Key | Action |
| --- | --- |
| `Enter` | jump to pane |
| `Ctrl-F` | close popup; makes `prefix + C-f` feel like a toggle inside the popup |
| `Ctrl-T` | toggle all panes / agent panes only |
| `Esc` | close |
| `prefix + C-f` | open popup; when already inside the popup, it closes via `Ctrl-F` |

## Install

### Manual/local

```tmux
run-shell ~/projects/tmux-agent-radar/radar.tmux
```

Reload tmux config or run:

```sh
tmux run-shell ~/projects/tmux-agent-radar/radar.tmux
```

### TPM-style local plugin

```tmux
set -g @plugin '~/projects/tmux-agent-radar'
```

Then reload TPM.

## Status bar

The plugin does not mutate your status bar. Add the badge wherever you want:

```tmux
set -g status-right "#(~/projects/tmux-agent-radar/bin/tmux-agent-radar status) #[default]#h"
```

Example output:

```text
🤖4 ⚠1 ▶2
```

## Options

```tmux
# Key binding. Default: C-f under your tmux prefix.
set -g @agent-radar-key 'C-f'

# Agent command names to detect.
set -g @agent-radar-agents 'pi opencode claude codex gemini aider goose amp qwen'

# Background watcher for permission prompts. Default: on.
set -g @agent-radar-watch 'on'

# Watch interval in seconds. Default: 3.
set -g @agent-radar-watch-interval '3'

# tmux display-message notifications. Default: off.
set -g @agent-radar-notify 'on'

# macOS notifications. Default: off.
set -g @agent-radar-notify-macos 'on'

# Popup size.
set -g @agent-radar-popup-width '92%'
set -g @agent-radar-popup-height '88%'
```

## Labels

Labels are optional.

1. open `prefix + C-f`
2. select pane
3. press `Ctrl-L`
4. type a short task label

The label is stored as a tmux pane option:

```sh
tmux show-option -p -v -t %12 @agent-radar-label
```

## Reliability notes

Very reliable:

- tmux pane discovery
- process/cwd detection
- jumping
- labels
- preview capture
- status badge

Best-effort:

- automatic task inference
- permission prompt detection
- idle/running classification

Permission detection uses visible pane text, so it avoids stale scrollback but cannot detect prompts hidden by the agent UI.

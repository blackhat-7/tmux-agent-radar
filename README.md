# tmux-agent-radar

A tmux/fzf popup for finding CLI coding-agent panes.

It scans tmux panes for agents like `pi`, `opencode`, `claude`, `codex`, `gemini`, and `cursor-agent`, flags visible permission prompts, previews captured pane output, and jumps to the selected pane.

This is intentionally a passive radar. It does **not** approve, reject, or type into agent prompts from the popup; jump to the pane and answer there.

![tmux-agent-radar demo](assets/demo.gif)

## Features

- Toggleable tmux/fzf popup: `prefix + C-f`
- Agent detection from pane commands and process trees
- Permission-prompt detection from visible pane text
- Raw recent-output preview before jumping
- Agents-only / all-panes toggle with `Ctrl-A`
- Jump to the selected pane with `Enter`
- Optional status-bar badge: `🤖4 ⚠1 ▶2`
- Optional tmux or macOS notifications for permission prompts

## Popup controls

- `Enter`: jump to the selected pane
- `Ctrl-A`: toggle agents-only / all-panes
- `Ctrl-F` or `Esc`: close the popup

Not supported from the popup: approving, denying, rejecting, editing labels, renaming windows, or killing panes.

## Demo recording

The demo GIF is recorded from a disposable nested tmux session using the real plugin UI, not hand-drawn. To regenerate it:

```sh
scripts/record-demo.sh
```

`record-demo.sh` prefers [VHS](https://github.com/charmbracelet/vhs), and can fall back to `asciinema` + `agg`.

## Requirements

- `tmux`
- `fzf` for the popup UI

## Install

Add the plugin to your tmux config:

```tmux
run-shell ~/projects/tmux-agent-radar/radar.tmux
```

Or with a local TPM-style plugin entry:

```tmux
set -g @plugin '~/projects/tmux-agent-radar'
```

Reload tmux, then open Radar with `prefix + C-f`.

## Status bar

Radar does not edit your status bar automatically. Add the badge wherever you want:

```tmux
set -g status-right "#(~/projects/tmux-agent-radar/bin/tmux-agent-radar status) #[default]#h"
```

## Options

```tmux
# Popup key. Default: prefix + C-f
set -g @agent-radar-key 'C-f'

# Agent command names to detect.
set -g @agent-radar-agents 'pi opencode claude codex gemini aider cursor-agent goose amp qwen'

# Background permission watcher. Default: on
set -g @agent-radar-watch 'on'
set -g @agent-radar-watch-interval '5'

# Notifications. Default: off
set -g @agent-radar-notify 'on'
set -g @agent-radar-notify-macos 'on'

# Popup size.
set -g @agent-radar-popup-width '92%'
set -g @agent-radar-popup-height '88%'
```

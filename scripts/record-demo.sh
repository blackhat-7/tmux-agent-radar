#!/usr/bin/env bash
set -euo pipefail

# Record the real tmux/fzf popup into assets/demo.gif.
# Preferred path: VHS records the terminal and writes the GIF directly.
# Fallback: asciinema records a cast, then agg renders it to GIF.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/assets/demo.gif"
TAPE="$ROOT/assets/demo.tape"
CAST="${TMPDIR:-/tmp}/agent-radar-demo.cast"

need() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "missing required command: $1" >&2
    exit 1
  }
}

need tmux
need fzf

if command -v vhs >/dev/null 2>&1; then
  cd "$ROOT"
  vhs "$TAPE"
  exit 0
fi

if command -v asciinema >/dev/null 2>&1 && command -v agg >/dev/null 2>&1; then
  rm -f "$CAST"
  asciinema rec --overwrite --quiet --command "$ROOT/scripts/demo-session.sh" "$CAST"
  agg --cols 112 --rows 34 --font-size 14 "$CAST" "$OUT"
  exit 0
fi

cat >&2 <<'EOF'
Missing a terminal GIF recorder.

Install either:
  - vhs: https://github.com/charmbracelet/vhs
  - or asciinema + agg: https://github.com/asciinema/agg

Then run:
  scripts/record-demo.sh
EOF
exit 1

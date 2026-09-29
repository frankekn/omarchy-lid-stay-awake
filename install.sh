#!/bin/bash

# omarchy-lid-stay-awake installer.
# Run from the cloned plugin directory (after `omarchy plugin add <url>`)
# or from a source checkout. Installs the helper script and registers the
# lid switch bindings in ~/.config/hypr/bindings.lua.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ID="io.github.frankekn.lid"
BIN_DIR="$HOME/.local/bin"
BINDINGS="$HOME/.config/hypr/bindings.lua"

for cmd in hyprctl systemd-inhibit omarchy-hyprland-monitor-laptop omarchy-hw-laptop-closed; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "install.sh: required command not found: $cmd (is this Omarchy?)" >&2
    exit 1
  }
done

install -Dm755 "$HERE/bin/omarchy-lid-stay-awake" "$BIN_DIR/omarchy-lid-stay-awake"
echo "installed $BIN_DIR/omarchy-lid-stay-awake"

if ! grep -q "lid-stay-awake closed" "$BINDINGS" 2>/dev/null; then
  cp "$BINDINGS" "$BINDINGS.bak.$(date +%s)" 2>/dev/null || true
  cat >> "$BINDINGS" <<'EOF'

-- Lid stay-awake: when the toggle is on, lid close disables the internal
-- panel instead of suspending. No-ops while the mode is off.
o.bind("switch:on:Lid Switch", nil, "omarchy-lid-stay-awake closed", { locked = true })
o.bind("switch:off:Lid Switch", nil, "omarchy-lid-stay-awake opened", { locked = true })
EOF
  echo "added lid switch bindings to $BINDINGS"
  hyprctl reload >/dev/null 2>&1 || true
else
  echo "lid switch bindings already present in $BINDINGS"
fi

if [[ ! -f "$HOME/.config/omarchy/plugins/$PLUGIN_ID/manifest.json" ]]; then
  echo
  echo "Plugin not installed yet. Install it with:"
  echo "  omarchy plugin add https://github.com/frankekn/omarchy-lid-stay-awake --enable"
else
  omarchy-shell shell rescanPlugins >/dev/null 2>&1 || true
  if ! grep -q "\"$PLUGIN_ID\"" "$HOME/.config/omarchy/shell.json" 2>/dev/null; then
    omarchy plugin enable "$PLUGIN_ID" right || true
  fi
  echo "plugin ready; it should appear on the right side of the bar"
fi

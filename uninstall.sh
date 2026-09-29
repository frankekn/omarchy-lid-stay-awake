#!/bin/bash

# Removes the helper script, the Hyprland lid bindings, and (optionally)
# disables the bar widget. The plugin directory itself is left to
# `omarchy plugin remove io.github.frankekn.lid`.

set -euo pipefail

PLUGIN_ID="io.github.frankekn.lid"
BIN="$HOME/.local/bin/omarchy-lid-stay-awake"
BINDINGS="$HOME/.config/hypr/bindings.lua"
STATE_DIR="$HOME/.local/state/omarchy"

"$BIN" off 2>/dev/null || true
rm -f "$BIN" "$STATE_DIR/lid-stay-awake"
echo "removed $BIN"

if grep -q "lid-stay-awake" "$BINDINGS" 2>/dev/null; then
  cp "$BINDINGS" "$BINDINGS.bak.$(date +%s)"
  sed -i '/lid-stay-awake/d' "$BINDINGS"
  # Drop the comment block left behind, if it is now an orphan.
  sed -i '/-- Lid stay-awake: when the toggle is on/d;/-- panel instead of suspending\. No-ops while the mode is off\./d' "$BINDINGS"
  hyprctl reload >/dev/null 2>&1 || true
  echo "removed lid switch bindings from $BINDINGS"
fi

omarchy plugin disable "$PLUGIN_ID" 2>/dev/null || true
echo "done. To fully remove: omarchy plugin remove $PLUGIN_ID"

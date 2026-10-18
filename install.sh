#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${HOME}/.local/bin"
CONFIG="${HOME}/.config/omarchy/shell.json"
mkdir -p "$BIN_DIR" "$(dirname "$CONFIG")"
install -m 0755 "$ROOT/scripts/pocket-rotate" "$BIN_DIR/pocket-rotate"
export PATH="$BIN_DIR:$PATH"

if [[ ! -f "$CONFIG" ]]; then
  echo "No $CONFIG found; refusing to generate a shell.json from scratch." >&2
  echo "Command installed at $BIN_DIR/pocket-rotate, but bar widget was not added." >&2
  exit 1
fi
backup="$CONFIG.pocket-rotate.$(date +%Y%m%d-%H%M%S).bak"
cp -a "$CONFIG" "$backup"
python - "$CONFIG" <<'PY'
import json, sys
path=sys.argv[1]
with open(path, encoding='utf-8') as f: data=json.load(f)
bar=data.setdefault('bar', {})
layout=bar.setdefault('layout', {})
right=layout.setdefault('right', [])
widget={"id":"pocket-rotate","type":"command","exec":"~/.local/bin/pocket-rotate status","interval":2,"tooltip":"Rotate display (click to toggle)","onClick":"~/.local/bin/pocket-rotate toggle"}
if any(isinstance(x,dict) and x.get('id')=='pocket-rotate' for x in right):
    print('pocket-rotate widget already exists; no duplicate added.')
else:
    # Place before omarchy.monitor if present, otherwise append to right side.
    idx=next((i for i,x in enumerate(right) if isinstance(x,dict) and x.get('id')=='omarchy.monitor'), len(right))
    right.insert(idx, widget)
    print('Added pocket-rotate to bar.layout.right.')
with open(path,'w',encoding='utf-8') as f:
    json.dump(data,f,indent=2,ensure_ascii=False); f.write('\n')
PY
if command -v omarchy-shell >/dev/null 2>&1; then
  omarchy-shell shell reloadConfig >/dev/null 2>&1 || true
fi
echo "Installed. Backup: $backup"
echo "Try: $BIN_DIR/pocket-rotate status"
echo "If the bar has not updated, run: omarchy-restart-shell"

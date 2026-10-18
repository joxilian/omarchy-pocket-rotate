#!/usr/bin/env bash
set -euo pipefail
CONFIG="${HOME}/.config/omarchy/shell.json"
BIN="${HOME}/.local/bin/pocket-rotate"
if [[ -f "$CONFIG" ]]; then
  cp -a "$CONFIG" "$CONFIG.pre-uninstall-$(date +%Y%m%d-%H%M%S).bak"
  python - "$CONFIG" <<'PY'
import json, sys
p=sys.argv[1]
with open(p,encoding='utf-8') as f: d=json.load(f)
right=d.get('bar',{}).get('layout',{}).get('right',[])
d.get('bar',{}).get('layout',{})['right']=[x for x in right if not (isinstance(x,dict) and x.get('id')=='pocket-rotate')]
with open(p,'w',encoding='utf-8') as f: json.dump(d,f,indent=2,ensure_ascii=False); f.write('\n')
PY
fi
rm -f "$BIN"
if command -v omarchy-shell >/dev/null 2>&1; then omarchy-shell shell reloadConfig >/dev/null 2>&1 || true; fi
echo "Removed Pocket Rotate command and bar widget. Backups were preserved."

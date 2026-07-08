#!/usr/bin/env bash
# ============================================================
#  THE PHANTOM VULNERABILITY — Live Demo
#  Slide 10: $ npm ls esbuild_
#
#  Usage:  ./demo.sh          (interactive, press Enter between steps)
#          ./demo.sh --fast   (no pauses)
# ============================================================
cd "$(dirname "$0")"

PAUSE=true
[ "$1" = "--fast" ] && PAUSE=false

step() {
  echo
  echo "════════════════════════════════════════════════════════════"
  echo "  $1"
  echo "════════════════════════════════════════════════════════════"
  if $PAUSE; then read -rp "  [Enter to run]" _; fi
}

run() { echo; echo "  \$ $*"; echo; eval "$@" || true; }

step "STEP 0 — The setup: a '100% JavaScript' app (slide 4)"
run "cat package.json"
run "grep -rn \"require.*esbuild\\|from .esbuild\" src/ packages/*/src/ || echo '  → zero esbuild imports anywhere in our source code'"

step "STEP 1 — The haystack: how big is this lockfile? (slide 5)"
run "wc -l package-lock.json"
run "grep -c '\"node_modules/' package-lock.json"
echo "  → In production this was 26,172 lines and 1,247 packages."

step "STEP 2 — The trace: where does esbuild come from? (slide 7)"
run "npm ls esbuild"
echo "  → app → @xyz/xy-react → vanilla-extract → integration → esbuild"

step "STEP 3 — The phantom: Go binaries in a JS app (slide 4)"
esbuild_bin=$(find node_modules/@esbuild -path '*/bin/esbuild' -type f | head -1)
run "ls node_modules/@esbuild/ 2>/dev/null | head -5; find node_modules/@esbuild -name esbuild -type f"
run "file \"$esbuild_bin\""
echo "  → A statically-linked GO executable, in a JavaScript app."

step "STEP 4 — What the scanner reads (slide 15)"
run "grep -a -o 'go1\\.[0-9.]*' \"$esbuild_bin\" | head -1"
echo "  → The scanner reads this embedded Go version string and"
echo "    fires Go-runtime CVEs against your JavaScript app."

step "STEP 5 — Trust but verify: the lockfile line numbers (slide 12)"
run "grep -n '\"node_modules/@vanilla-extract/integration\"' package-lock.json"
run "grep -n '\"node_modules/esbuild\"' package-lock.json"
run "grep -n '\"node_modules/@esbuild/' package-lock.json | head -3"

step "STEP 6 — The fix, part 1: remove the unused dependency (slide 12)"
echo "  'We removed @vanilla-extract/next-plugin — build still works.'"
run "node -e \"const fs=require('fs');const p='packages/xy-react/package.json';const j=JSON.parse(fs.readFileSync(p));const target=j.devDependencies||{};delete target['@vanilla-extract/next-plugin'];delete target['@vanilla-extract/css'];j.devDependencies=target;fs.writeFileSync(p,JSON.stringify(j,null,2))\""
run "npm install --no-audit --no-fund --silent"
run "npm ls esbuild"
run "find node_modules -path '*@esbuild*' -name esbuild | wc -l"
echo "  → esbuild is GONE. The phantom is exorcised."

step "STEP 7 — (Optional, needs Docker) The fix, part 2: multi-stage build (slide 9)"
run "docker buildx build -f Dockerfile.single-stage -t phantom-demo:before ."
run "docker buildx build -f Dockerfile.multi-stage -t phantom-demo:after ."
run "docker run --rm phantom-demo:after sh -c 'find / -name esbuild 2>/dev/null | grep . || echo esbuild: ABSENT'"
run "docker images | grep phantom-demo

step "RESET — restore the vulnerable state for the next run"
run "git checkout packages/xy-react/package.json 2>/dev/null || cp .demo-backup/xy-react-package.json packages/xy-react/package.json"
run "npm install --no-audit --no-fund --silent"
run "npm ls esbuild"
echo
echo "  Demo complete. Ghost story over."

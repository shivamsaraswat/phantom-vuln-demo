# The Phantom Vulnerability — Live Demo Repo 👻

Companion demo for the talk **"The Phantom Vulnerability: A Node.js Ghost Story"** (#ACSC2026, BSides Bangalore).

A 100% JavaScript Next.js app that ships **Go binaries** via
`app → @xyz/xy-react → @vanilla-extract/next-plugin → @vanilla-extract/integration → esbuild@0.25.5 → @esbuild/linux-x64`.

## Quick start
```bash
npm install
./demo.sh          # interactive live demo (Enter to advance)
```

## Files
- `demo.sh` — the on-stage demo, 7 steps mapped to slides 4–12, auto-resets
- `DEMO_SCRIPT.md` — presenter runbook: talk track, timings, expected output, contingency plan
- `BACKUP_OUTPUT.txt` — real captured run, in case the live demo gods are unkind
- `Dockerfile.single-stage` — BEFORE: esbuild ships to production (slide 9, left)
- `Dockerfile` — AFTER: multi-stage, esbuild absent (slide 9, right)
- `packages/xy-react/` — stand-in for the internal component library

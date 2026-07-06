# The Phantom Vulnerability — Live Demo Repo 👻

Companion repo for the talk **"The Phantom Vulnerability: A Node.js Ghost Story"** (#ACSC2026, BSides Bangalore).

This project is a minimal Next.js application that demonstrates how a JavaScript-only dependency chain can still bring a Go binary into the runtime image through transitive build tooling. The demo highlights the contrast between a single-stage build and a multi-stage build.

## What this demo shows

The app is intentionally simple, but the dependency chain is the point:

`app → @xyz/xy-react → @vanilla-extract/next-plugin → @vanilla-extract/integration → esbuild@0.25.5 → @esbuild/linux-x64`

That chain is what makes the phantom visible: a Go-based executable can appear inside a project that looks like a pure JavaScript app.

## Project structure

- [package.json](package.json) — app dependencies and scripts
- [Dockerfile](Dockerfile) — multi-stage build example
- [Dockerfile.single-stage](Dockerfile.single-stage) — single-stage build example
- [next.config.js](next.config.js) — standalone output and tracing exclusions
- [packages/xy-react/package.json](packages/xy-react/package.json) — internal component library stub
- [packages/xy-react/src/index.js](packages/xy-react/src/index.js) — demo component exports
- [src/app/page.js](src/app/page.js) — simple app entry point

## Demo flow

The script walks through:

1. The app looks like a normal JavaScript project.
2. The dependency tree reveals how `esbuild` enters the picture.
3. The Go binary is found in the installed dependencies.
4. A multi-stage Docker build removes the build-time tool from the final runtime image.

## Docker builds

Run the two builds side by side to compare the outcomes:

```bash
docker build -f Dockerfile.single-stage -t demo-single-stage:latest .
docker build -t demo-multi-stage:latest .
```

The single-stage image keeps the build tool in the production image, while the multi-stage image ships only the runtime output.

## Notes

The demo is intentionally lightweight and focused on the vulnerability story rather than full application complexity.

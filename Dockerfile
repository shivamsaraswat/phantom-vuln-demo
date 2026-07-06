# ============================================================
# AFTER — Multi-stage build (slide 9, right side)
# Stage 1 uses esbuild to compile. Stage 2 ships ONLY the
# compiled output + production deps. esbuild never boards
# the ship.
#
#   docker build -t phantom-demo:after .
#   docker run --rm phantom-demo:after sh -c "find / -name esbuild 2>/dev/null | grep . || echo 'esbuild: ABSENT'"
#   → esbuild: ABSENT
#
# NOTE: multi-stage alone is NOT enough here. Next.js standalone
# output runs a file tracer (@vercel/nft) that conservatively
# copies esbuild into .next/standalone if it might be required.
# next.config.js uses outputFileTracingExcludes to keep build-time
# tools out of the traced runtime output. Trust but verify —
# always run the find inside the final image.
#
#   docker images | grep phantom-demo
#   → before  ~1.2 GB   after  ~0.5 GB   (↓ ~59%)
# ============================================================

# ---------- Stage 1: builder (esbuild lives and dies here) ----------
FROM node:22-alpine AS builder

WORKDIR /app

COPY package.json package-lock.json ./
COPY packages ./packages
RUN npm ci

COPY . .
RUN npm run build

# ---------- Stage 2: production (only compiled output ships) ----------
FROM node:22-alpine AS runner

ENV NODE_ENV=production
WORKDIR /app

# Next.js standalone output contains the server + only the
# runtime deps it traced — no devDependencies, no build tools.
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

USER node
EXPOSE 3000
CMD ["node", "server.js"]

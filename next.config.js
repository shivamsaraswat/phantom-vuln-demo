/** @type {import('next').NextConfig} */
const nextConfig = {
  // Required for the multi-stage Dockerfile: emits .next/standalone
  output: "standalone",

  // The file tracer conservatively includes esbuild because it exists in
  // node_modules (pulled in transitively by build-time CSS tooling).
  // esbuild only ever runs during `npm run build` — never at runtime —
  // so we explicitly exclude it from the production standalone output.
  outputFileTracingExcludes: {
    "*": [
      "node_modules/esbuild/**",
      "node_modules/@esbuild/**",
      "node_modules/@vanilla-extract/**",
      "node_modules/vite/**",
    ],
  },
};
module.exports = nextConfig;

# burrow-php

Static PHP builds (CLI and FPM) for [Burrow](https://burrow-website-steel.vercel.app),
built with [static-php-cli](https://github.com/crazywhalecc/static-php-cli).

- PHP 8.1 – 8.5, newest patch release of each, for Linux x86_64 / aarch64 and macOS (Apple Silicon).
- Extensions: see [`extensions.txt`](extensions.txt). Compared with static-php's
  "common" builds this adds **intl**, **opcache** and **sodium**.
- Every build is smoke-tested (all extensions load, `intl` formats numbers,
  `php-fpm` starts) before it is published.

Files are in the [`builds` release](../../releases/tag/builds), with
`index.json` listing each file's size and SHA-256. Burrow downloads from there
by default and checks every file against `index.json`.

The workflow runs weekly to pick up new PHP patch releases, and can be run by
hand from the Actions tab (optionally for some versions, or forcing a rebuild).

## Valkey for macOS

Valkey has no official macOS builds, so the **Build Valkey (macOS)** workflow
compiles it from source (TLS off, system libraries only, checked with `otool`
and a start + `PING`) and publishes it to the [`valkey` release](../../releases/tag/valkey).
Burrow pins the SHA-256 in its service catalog.

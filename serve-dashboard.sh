#!/usr/bin/env bash
# Architect Dashboard v2 — Express + SSE
# Delegates to server.mjs (all logic moved there)

cd "$(dirname "${BASH_SOURCE[0]}")"
exec node server.mjs

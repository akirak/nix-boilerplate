#!/usr/bin/env bash
set -e
tmp="$(mktemp)"
find "$(nix-build)" \
     -name default.nix \
     -o -name README.md \
     -o -name '*.el' \
     -o -path '*/.github/workflows/*.*' \
     -o -path '*/.recipes/*' \
     > "$tmp"
[[ "$(wc -l "$tmp" | cut -d' ' -f1)" -eq 0 ]]

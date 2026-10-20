#!/usr/bin/env bash
# Push matugen CSS into Obsidian vault snippets (hot-reload on mtime).
# Do NOT rewrite appearance.json on every theme toggle — that fights
# Obsidian's live "Adapt to system" / portal switching.

set -euo pipefail

SRC="${XDG_CONFIG_HOME:-$HOME/.config}/obsidian/themes/matugen-dynamic.css"
OBSIDIAN_JSON="${XDG_CONFIG_HOME:-$HOME/.config}/obsidian/obsidian.json"

[ -f "$SRC" ] || exit 0

enable_snippet_once() {
    local appearance="$1"
    [ -f "$appearance" ] || return 0
    command -v jq >/dev/null 2>&1 || return 0

    # Already enabled → leave the file untouched (preserves live theme state)
    if jq -e '.enabledCssSnippets | index("matugen") != null' "$appearance" >/dev/null 2>&1; then
        return 0
    fi

    local tmp
    tmp=$(mktemp)
    jq '.enabledCssSnippets = (((.enabledCssSnippets // []) + ["matugen"]) | unique)' \
        "$appearance" > "$tmp" && mv -f "$tmp" "$appearance"
}

sync_vault() {
    local vault="$1"
    local dir="$vault/.obsidian"
    local snippets="$dir/snippets"

    [ -d "$vault" ] || return 0
    mkdir -p "$snippets"
    cp -f "$SRC" "$snippets/matugen.css.tmp"
    mv -f "$snippets/matugen.css.tmp" "$snippets/matugen.css"
    enable_snippet_once "$dir/appearance.json"
}

if [ -f "$OBSIDIAN_JSON" ] && command -v jq >/dev/null 2>&1; then
    while IFS= read -r vault; do
        [ -n "$vault" ] && sync_vault "$vault"
    done < <(jq -r '.vaults // {} | to_entries[].value.path // empty' "$OBSIDIAN_JSON")
else
    sync_vault "$HOME/obsidian"
fi
